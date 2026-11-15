import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gymbro/core/ai/ai_context_builder.dart';
import 'package:gymbro/core/ai/gemini_service.dart';
import 'package:gymbro/core/ai/openrouter_ai_service.dart';
import 'package:gymbro/models/chat_message.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/marketplace_models.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';

// Fake storage for unit test isolation
class FakeLocalStorageService extends LocalStorageService {
  @override
  UserProfile getProfile() => UserProfile(
        id: 'user_armin_01',
        firstName: 'آرمین',
        lastName: 'جعفری',
        phone: '09123456789',
        email: 'armin@gymbro.app',
        weightKg: 78.5,
        heightCm: 182,
        fitnessGoal: 'Hypertrophy (افزایش حجم عضلانی خالص)',
        fitnessLevel: 'Advanced',
        level: UserLevel.athlete,
        coins: 140,
        dailyFreeScans: 10,
        streakDays: 14,
        totalWorkoutsCompleted: 38,
        activeSinceMonths: 4,
      );

  @override
  NutritionPlan getNutritionPlan() => NutritionPlan(
        id: 'nut_plan_hypertrophy',
        dailyCalories: 2650,
        targetProteinG: 165,
        targetCarbsG: 300,
        targetFatG: 70,
        targetWaterMl: 3500,
      );

  @override
  List<WorkoutPlan> getWorkoutPlans() => [
        WorkoutPlan(
          id: 'plan_push_day',
          titleFa: 'روز هل دادنی (Push Day A)',
          titleEn: 'Push Day A',
          descriptionFa: 'تمرین سینه، سرشانه و پشت بازو',
          splitType: 'PPL',
          exercises: [],
        ),
      ];

  @override
  List<CalorieScanLog> getCalorieLogs() => [
        CalorieScanLog(
          id: 'cal_test_1',
          foodName: 'جو دوسر، شیر، موز و کره بادام‌زمینی',
          mealType: 'صبحانه',
          calories: 680,
          proteinG: 32.0,
          carbsG: 85.0,
          fatG: 22.0,
          portionG: 450,
          dateString: DateTime.now().toIso8601String().substring(0, 10),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      ];

  @override
  List<Exercise> getExercises() => [];

  @override
  List<WorkoutLog> getWorkoutLogs() => [];

  @override
  List<Gym> getGyms() => [];

  @override
  List<Trainer> getTrainers() => [];

  @override
  List<Booking> getBookings() => [];

  @override
  String getApiKey() => '';

  @override
  String getGeminiApiKey() => '';

  @override
  String getGeminiModel() => 'gemini-1.5-flash';
}

void main() {
  group('Food analysis demo boundaries', () {
    test('Local food estimates are marked as simulated', () async {
      final result = await OpenRouterAiService().analyzeFood(
        description: 'قورمه سبزی',
        apiKey: '',
      );

      expect(result.isSimulated, isTrue);
      expect(result.foodNameFa, contains('قورمه'));
    });

    test('Remote API failures are surfaced instead of returning demo data',
        () async {
      final service = OpenRouterAiService(
        client: MockClient((_) async => http.Response('unavailable', 503)),
      );

      await expectLater(
        service.analyzeFood(description: 'قورمه سبزی', apiKey: 'test-key'),
        throwsA(isA<FoodAnalysisException>()),
      );
    });
  });

  group('Gemini AI Integration Tests', () {
    test('GeminiService available models and default configuration', () {
      expect(GeminiService.defaultModel, 'gemini-1.5-flash');
      expect(GeminiService.availableModels, contains('gemini-1.5-flash'));
      expect(GeminiService.availableModels, contains('gemini-2.0-flash'));
      expect(GeminiService.availableModels, contains('gemini-1.5-pro'));
    });

    test('GeminiService throws clear Persian exception when API key is empty',
        () async {
      final service = GeminiService();
      expect(
        () => service.generateContent(
          apiKey: '   ',
          systemInstruction: 'test',
          history: [],
          userMessage: 'سلام',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('کلید API جمینای تنظیم نشده است'),
        )),
      );
    });

    test('GeminiService testConnection returns false on empty key', () async {
      final service = GeminiService();
      final result = await service.testConnection(apiKey: '');
      expect(result, isFalse);
    });

    test('ChatMessage model creates user and AI messages with correct flags',
        () {
      final now = DateTime.now();
      final userMsg = ChatMessage(
        id: 'u1',
        text: 'برنامه امروز من چیه؟',
        isUser: true,
        timestamp: now,
      );
      expect(userMsg.isUser, isTrue);
      expect(userMsg.isError, isFalse);

      final aiMsg = ChatMessage(
        id: 'ai1',
        text: 'امروز نوبت تمرین Push Day است.',
        isUser: false,
        timestamp: now,
      );
      expect(aiMsg.isUser, isFalse);
      expect(aiMsg.isError, isFalse);

      final errMsg = ChatMessage(
        id: 'err1',
        text: 'خطا در شبکه',
        isUser: false,
        timestamp: now,
        isError: true,
      );
      expect(errMsg.isError, isTrue);
    });

    test(
        'AiContextBuilder generates complete Persian system prompt with strict guardrails',
        () {
      final fakeStorage = FakeLocalStorageService();
      final appState = AppState(storage: fakeStorage);

      final prompt = AiContextBuilder.buildSystemPrompt(appState);

      // Verify GymBro persona
      expect(prompt, contains('مربی هوشمند جیم‌برو (GymBro AI Coach)'));
      expect(prompt, contains('فارسی روان'));

      // Verify strict guardrail: never silently modify plans
      expect(
          prompt,
          contains(
              'قانون اساسی: شما به عنوان هوش مصنوعی هرگز نباید ادعا کنید که برنامه تمرینی یا رژیم ورزشکار را مستقیماً در دیتابیس تغییر داده‌اید'));

      // Verify real athlete profile injected
      expect(prompt, contains('آرمین'));
      expect(prompt, contains('78.5'));
      expect(prompt, contains('182'));
      expect(prompt, contains('23.7')); // BMI
      expect(prompt, contains('14 روز')); // Streak
      expect(prompt, contains('38 جلسه')); // Total workouts

      // Verify real nutrition targets
      expect(prompt, contains('2650 کیلوکالری'));
      expect(prompt, contains('165 گرم'));
      expect(prompt, contains('300 گرم'));
      expect(prompt, contains('70 گرم'));
      expect(prompt, contains('3500 میلی‌لیتر'));

      // Verify today meals injected
      expect(prompt, contains('جو دوسر، شیر، موز و کره بادام‌زمینی'));
      expect(prompt, contains('680 کیلوکالری'));

      // Verify active workout routine injected
      expect(prompt, contains('روز هل دادنی (Push Day A)'));
    });
  });
}
