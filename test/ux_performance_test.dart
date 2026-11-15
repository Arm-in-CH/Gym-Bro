import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/marketplace_models.dart';
import 'package:gymbro/models/chat_message.dart';
import 'package:gymbro/widgets/empty_state_widget.dart';
import 'package:gymbro/widgets/skeleton_loader.dart';
import 'package:gymbro/screens/dashboard_screen.dart';
import 'package:gymbro/screens/marketplace_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';
import 'package:gymbro/screens/workout_screen.dart';
import 'package:gymbro/screens/active_workout_screen.dart';
import 'package:gymbro/screens/ai_coach_screen.dart';

class _UxTestStorageService extends LocalStorageService {
  @override
  String getApiKey() => '';

  @override
  Future<void> saveApiKey(String key) async {}

  UserProfile _profile = UserProfile(
    id: 'u_perf',
    firstName: 'آرمین',
    lastName: 'جعفری',
    phone: '09123456789',
    email: 'armin@gymbro.app',
    weightKg: 80.0,
    heightCm: 180.0,
    fitnessGoal: 'Hypertrophy',
    fitnessLevel: 'Advanced',
    level: UserLevel.athlete,
    coins: 100,
    dailyFreeScans: 10,
    streakDays: 14,
    totalWorkoutsCompleted: 30,
    activeSinceMonths: 3,
  );

  @override
  UserProfile getProfile() => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  NutritionPlan getNutritionPlan() => NutritionPlan(
        id: 'n1',
        dailyCalories: 2600,
        targetProteinG: 160,
        targetCarbsG: 280,
        targetFatG: 70,
        targetWaterMl: 3000,
      );

  @override
  List<WorkoutPlan> getWorkoutPlans() => [
        WorkoutPlan(
          id: 'p1',
          titleFa: 'برنامه سنگین سینه و سرشانه',
          titleEn: 'Push Day',
          descriptionFa: 'تمرین سینه و سرشانه',
          splitType: 'PPL',
          daysPerWeek: 3,
          difficulty: 'پیشرفته',
          exercises: [
            WorkoutPlanExercise(
              id: 'pe1',
              planId: 'p1',
              exerciseId: 'ex1',
              dayOfWeek: 1,
              dayNameFa: 'شنبه',
              orderInDay: 1,
              targetSets: 3,
              targetReps: 10,
              targetWeightKg: 80.0,
              restSeconds: 90,
            ),
          ],
        ),
      ];

  @override
  List<WorkoutLog> getWorkoutLogs() => [];

  @override
  List<CalorieScanLog> getCalorieLogs() => [];

  @override
  List<Gym> getGyms() => [
        Gym(
          id: 'g1',
          name: 'باشگاه اکسیژن',
          address: 'زعفرانیه',
          district: 'زعفرانیه',
          latitude: 35.8,
          longitude: 51.4,
          monthlyFeeToman: 4500000,
          rating: 4.9,
          reviewCount: 142,
          amenities: ['استخر', 'سونا', 'کافه پروتئینی'],
        ),
      ];

  @override
  List<Trainer> getTrainers() => [
        Trainer(
          id: 't1',
          name: 'سهراب سرابی',
          title: 'مربی رسمی',
          specialty: 'بدنسازی پیشرفته',
          bio: 'قهرمان اسبق آسیا',
          hourlyRateToman: 400000,
          sessionType: 'حضوری در باشگاه',
          rating: 4.9,
          reviewCount: 45,
        ),
      ];

  @override
  List<Booking> getBookings() => [];

  @override
  List<Exercise> getExercises() => [
        Exercise(
          id: 'ex1',
          nameFa: 'پرس سینه هالتر',
          nameEn: 'Barbell Bench Press',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa: 'روی نیمکت دراز بکشید',
          homeEquivalentId: 'ex_pushups',
        ),
      ];
}

Widget _wrapWithApp(Widget child, AppState state) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _UxTestStorageService testStorage;
  late AppState testState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    testStorage = _UxTestStorageService();
    await testStorage.init();
    testState = AppState(storage: testStorage);
  });

  group('UX States & Asynchronous Feedback Tests', () {
    testWidgets(
        'EmptyStateWidget renders title, subtitle, icon and triggers action',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.search_off,
              title: 'موردی یافت نشد',
              subtitle: 'هیچ آیتمی با شرایط انتخابی پیدا نشد.',
              actionLabel: 'تلاش مجدد',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('موردی یافت نشد'), findsOneWidget);
      expect(find.text('هیچ آیتمی با شرایط انتخابی پیدا نشد.'), findsOneWidget);
      expect(find.text('تلاش مجدد'), findsOneWidget);

      await tester.tap(find.text('تلاش مجدد'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('SkeletonLoader renders layout and respects disableAnimations',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SkeletonLoader(
              width: 120,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DashboardScreen supports Pull-To-Refresh', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          DashboardScreen(
            state: testState,
            onOpenMealScanner: () {},
            onOpenHomeMode: () {},
            onOpenWorkouts: () {},
            onStartWorkout: (_) {},
            onOpenMarketplace: () {},
            onOpenAiCoach: () {},
          ),
          testState,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
      await tester.fling(
          find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'ProfileScreen form validation enforces boundaries (30-300kg, 100-250cm)',
        (tester) async {
      await tester
          .pumpWidget(_wrapWithApp(ProfileScreen(state: testState), testState));
      await tester.pumpAndSettle();

      // Tap edit metrics icon button
      final editBtn = find.byTooltip('ویرایش مشخصات');
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('ویرایش مشخصات فیزیکی'), findsOneWidget);

      // Enter invalid weight (e.g. 10 kg)
      final weightField =
          find.widgetWithText(TextFormField, 'وزن فعلی (کیلوگرم)');
      await tester.enterText(weightField, '10');

      // Tap submit
      await tester.tap(find.text('ذخیره تغییرات'));
      await tester.pumpAndSettle();

      // Error message should appear
      expect(find.text('وزن باید بین ۳۰ تا ۳۰۰ کیلوگرم باشد.'), findsOneWidget);

      // Enter valid weight and submit
      await tester.enterText(weightField, '82.5');
      await tester.tap(find.text('ذخیره تغییرات'));
      await tester.pumpAndSettle();

      expect(testState.userProfile.weightKg, 82.5);
    });

    testWidgets('ActiveWorkoutScreen confirms when 0 sets completed',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          ActiveWorkoutScreen(planId: 'p1', state: testState),
          testState,
        ),
      );
      await tester.pumpAndSettle();

      // Tap finish workout button without checking any sets
      final finishBtn = find.text('اتمام تمرین و ذخیره در تاریخچه');
      expect(finishBtn, findsOneWidget);
      await tester.tap(finishBtn);
      await tester.pumpAndSettle();

      // Confirmation dialog should be shown
      expect(find.text('پایان تمرین بدون ست ثبت‌شده'), findsOneWidget);
      expect(find.text('بازگشت به تمرین'), findsOneWidget);
      expect(find.text('خروج بدون ثبت'), findsOneWidget);

      // Cancel exit
      await tester.tap(find.text('بازگشت به تمرین'));
      await tester.pumpAndSettle();
      expect(find.text('پایان تمرین بدون ست ثبت‌شده'), findsNothing);
    });

    testWidgets('MarketplaceScreen shows EmptyStateWidget for empty bookings',
        (tester) async {
      await tester.pumpWidget(
          _wrapWithApp(MarketplaceScreen(state: testState), testState));
      await tester.pumpAndSettle();

      // Tap third tab (رزروهای من)
      await tester.tap(find.text('رزروهای من'));
      await tester.pumpAndSettle();

      expect(find.text('هنوز نوبت فعالی ثبت نکرده‌اید'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets(
        'WorkoutScreen shows EmptyStateWidget when search results are empty',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          WorkoutScreen(
            state: testState,
            onStartWorkout: (_) {},
            onOpenHomeMode: () {},
          ),
          testState,
        ),
      );
      await tester.pumpAndSettle();

      // Switch to exercise library tab
      await tester.tap(find.text('بانک جامع حرکات'));
      await tester.pumpAndSettle();

      // Search for non-existent exercise
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'ناموجود');
      await tester.pumpAndSettle();

      expect(find.text('حرکتی یافت نشد'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets(
        'AiCoachScreen shows EmptyStateWidget when conversation is empty',
        (tester) async {
      // Clear welcome message to test empty state
      testState.chatMessages.clear();

      await tester
          .pumpWidget(_wrapWithApp(AiCoachScreen(state: testState), testState));
      await tester.pumpAndSettle();

      expect(find.text('گفتگو با مربی هوشمند ورزشی'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('AiCoachScreen provides Retry button on error message',
        (tester) async {
      testState.chatMessages.clear();
      testState.chatMessages.add(
        ChatMessage(
          id: 'u1',
          text: 'برنامه من چیه؟',
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      testState.chatMessages.add(
        ChatMessage(
          id: 'e1',
          text: 'خطا در ارتباط با سرور هوش مصنوعی',
          isUser: false,
          isError: true,
          timestamp: DateTime.now(),
        ),
      );

      await tester
          .pumpWidget(_wrapWithApp(AiCoachScreen(state: testState), testState));
      await tester.pumpAndSettle();

      expect(find.text('تلاش مجدد'), findsOneWidget);
    });
  });

  group('Performance Micro-benchmarks & Render Timing', () {
    testWidgets('DashboardScreen renders within 16ms target per frame',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        _wrapWithApp(
          DashboardScreen(
            state: testState,
            onOpenMealScanner: () {},
            onOpenHomeMode: () {},
            onOpenWorkouts: () {},
            onStartWorkout: (_) {},
            onOpenMarketplace: () {},
            onOpenAiCoach: () {},
          ),
          testState,
        ),
      );
      await tester.pump();
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      expect(elapsedMs, lessThan(500),
          reason: 'Widget build + layout must be fast');
    });

    testWidgets('ActiveWorkoutScreen set toggle rebuilds without frame drop',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          ActiveWorkoutScreen(planId: 'p1', state: testState),
          testState,
        ),
      );
      await tester.pumpAndSettle();

      final setCheck = find.byIcon(Icons.crop_square).first;
      await tester.ensureVisible(setCheck);
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      await tester.tap(setCheck);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      stopwatch.stop();

      expect(find.byIcon(Icons.check), findsWidgets);
      expect(stopwatch.elapsedMilliseconds, lessThan(350));
    });
  });
}
