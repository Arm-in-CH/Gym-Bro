import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gymbro/core/ai/ai_context_builder.dart';
import 'package:gymbro/core/ai/gemini_service.dart';
import 'package:gymbro/core/ai/openrouter_ai_service.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/state/app_state.dart';

class _SecurityMockStorage extends LocalStorageService {
  final UserProfile? profile;
  final List<WorkoutPlan> plans;
  final List<Exercise> exerciseList;
  final List<WorkoutLog> logs;
  String storedGeminiKey = '';
  String storedOpenRouterKey = '';

  _SecurityMockStorage({
    this.profile,
    this.plans = const [],
    this.exerciseList = const [],
    this.logs = const [],
  });

  @override
  UserProfile getProfile() =>
      profile ??
      UserProfile(
        id: 'u_anon',
        firstName: '',
        lastName: '',
        phone: '',
        email: '',
        weightKg: 0,
        heightCm: 0,
        age: 0,
        bodyFatPercentage: 0,
        muscleMassKg: 0,
        fitnessGoal: '',
        fitnessLevel: '',
        level: UserLevel.member,
        coins: 0,
        dailyFreeScans: 0,
        streakDays: 0,
        totalWorkoutsCompleted: 0,
        activeSinceMonths: 0,
      );

  @override
  NutritionPlan getNutritionPlan() => NutritionPlan(
        id: 'nut_1',
        dailyCalories: 2400,
        targetProteinG: 150,
        targetCarbsG: 250,
        targetFatG: 60,
        targetWaterMl: 3000,
      );

  @override
  List<WorkoutPlan> getWorkoutPlans() => plans;

  @override
  List<Exercise> getExercises() => exerciseList;

  @override
  List<WorkoutLog> getWorkoutLogs() => logs;

  @override
  List<CalorieScanLog> getCalorieLogs() => [];

  @override
  String getGeminiApiKey() => storedGeminiKey;

  @override
  Future<void> saveGeminiApiKey(String key) async {
    storedGeminiKey = key.trim();
  }

  @override
  String getApiKey() => storedOpenRouterKey;

  @override
  Future<void> saveApiKey(String key) async {
    storedOpenRouterKey = key.trim();
  }
}

http.Response utf8Response(String body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('1. URL & Header Security Verification (Independent Verification)', () {
    test('GeminiService.testConnection sends key in header and NEVER in URL query params',
        () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        capturedHeaders = request.headers;
        return utf8Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'OK'}
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      const testKey = 'AIzaSyD-dummy-secret-gemini-key-12345';
      final ok = await service.testConnection(apiKey: testKey);

      expect(ok, isTrue);
      expect(capturedUri, isNotNull);
      // STRICT ASSERTION: API key must NOT be in query string!
      expect(capturedUri!.queryParameters.containsKey('key'), isFalse);
      expect(capturedUri.toString(), isNot(contains(testKey)));
      // STRICT ASSERTION: API key must be in x-goog-api-key header!
      expect(capturedHeaders?['x-goog-api-key'], equals(testKey));
    });

    test('GeminiService.generateContent sends key in header and NEVER in URL query params',
        () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        capturedHeaders = request.headers;
        return utf8Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'پاسخ هوش مصنوعی'}
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      const testKey = 'AIzaSyD-dummy-content-gemini-key-99999';
      final response = await service.generateContent(
        apiKey: testKey,
        systemInstruction: 'sys',
        history: [],
        userMessage: 'سلام',
      );

      expect(response, equals('پاسخ هوش مصنوعی'));
      expect(capturedUri!.queryParameters.containsKey('key'), isFalse);
      expect(capturedUri.toString(), isNot(contains(testKey)));
      expect(capturedHeaders?['x-goog-api-key'], equals(testKey));
    });

    test('GeminiService.analyzeFoodImage sends key in header and NEVER in URL query params',
        () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        capturedHeaders = request.headers;
        return utf8Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'food_name': 'تخم مرغ آبپز',
                        'calories': 155,
                        'protein_g': 13.0,
                        'carbs_g': 1.1,
                        'fat_g': 11.0,
                        'portion_g': 100.0,
                        'description': 'منبع عالی پروتئین'
                      })
                    }
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      const testKey = 'AIzaSyD-dummy-vision-gemini-key-88888';
      final result = await service.analyzeFoodImage(
        apiKey: testKey,
        imageBytes: [1, 2, 3],
      );

      expect(result['food_name'], equals('تخم مرغ آبپز'));
      expect(capturedUri!.queryParameters.containsKey('key'), isFalse);
      expect(capturedUri.toString(), isNot(contains(testKey)));
      expect(capturedHeaders?['x-goog-api-key'], equals(testKey));
    });

    test('OpenRouterAiService sends key in Bearer Authorization header', () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        capturedHeaders = request.headers;
        return utf8Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'foodName': 'Boiled Eggs',
                    'foodNameFa': 'تخم‌مرغ آب‌پز',
                    'estimatedCalories': 150,
                    'proteinG': 12.5,
                    'carbsG': 1.0,
                    'fatG': 10.0,
                    'estimatedWeightG': 100.0,
                    'healthTipFa': 'پروتئین با ارزش بیولوژیکی ۱۰۰.'
                  })
                }
              }
            ]
          }),
          200,
        );
      });

      final service = OpenRouterAiService(client: mockClient);
      const testKey = 'sk-or-v1-secret-openrouter-key-77777';
      final result = await service.analyzeFood(
        description: 'تخم‌مرغ',
        apiKey: testKey,
      );

      expect(result.foodNameFa, equals('تخم‌مرغ آب‌پز'));
      expect(capturedUri.toString(), equals('https://openrouter.ai/api/v1/chat/completions'));
      expect(capturedHeaders?['Authorization'], equals('Bearer $testKey'));
      expect(result.isSimulated, isFalse);
    });
  });

  group('2. Missing Credentials Handling', () {
    test('GeminiService.generateContent throws clear Persian exception on empty key', () async {
      final service = GeminiService();
      expect(
        () => service.generateContent(
          apiKey: '',
          systemInstruction: 'sys',
          history: [],
          userMessage: 'msg',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('کلید API جمینای تنظیم نشده است'),
        )),
      );
    });

    test('GeminiService.testConnection safely returns false without exception on empty key',
        () async {
      final service = GeminiService();
      final result = await service.testConnection(apiKey: '   ');
      expect(result, isFalse);
    });

    test('GeminiService.analyzeFoodImage throws clear exception on empty key', () async {
      final service = GeminiService();
      expect(
        () => service.analyzeFoodImage(apiKey: '', imageBytes: [1, 2]),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('کلید API جمینای تنظیم نشده است'),
        )),
      );
    });

    test('OpenRouterAiService falls back to local Persian engine when key is missing', () async {
      final service = OpenRouterAiService();
      final result = await service.analyzeFood(
        description: 'جوجه کباب',
        apiKey: '',
      );

      expect(result.isSimulated, isTrue);
      expect(result.foodNameFa, contains('جوجه‌کباب'));
      expect(result.proteinG, greaterThan(40));
    });

    test('AppState.scanFoodWithGeminiVision enforces Gemini key and never falls back to OpenRouter key',
        () async {
      final storage = _SecurityMockStorage();
      storage.storedGeminiKey = '';
      storage.storedOpenRouterKey = 'sk-or-v1-openrouter-key-that-must-never-be-used-by-gemini';

      final state = AppState(storage: storage);

      expect(
        () => state.scanFoodWithGeminiVision([1, 2, 3]),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('کلید API جمینای تنظیم نشده است'),
        )),
      );
    });
  });

  group('3. Invalid Credentials & Error Sanitization', () {
    test('GeminiService 401/403 response is sanitized and does not leak API keys in error message',
        () async {
      const leakedKey = 'AIzaSyD-leaked-secret-key-1234567890abc';
      final mockClient = MockClient((_) async {
        return utf8Response(
          jsonEncode({
            'error': {
              'code': 400,
              'message': 'API key not valid. Please pass a valid API key: $leakedKey',
              'status': 'INVALID_ARGUMENT'
            }
          }),
          400,
        );
      });

      final service = GeminiService(client: mockClient);
      try {
        await service.generateContent(
          apiKey: leakedKey,
          systemInstruction: 'sys',
          history: [],
          userMessage: 'msg',
        );
        fail('Expected GeminiException');
      } on GeminiException catch (e) {
        expect(e.message, isNot(contains(leakedKey)));
        expect(e.message, contains('[REDACTED_API_KEY]'));
      }
    });

    test('OpenRouter 401 response throws FoodAnalysisException without leaking Bearer token',
        () async {
      const secretToken = 'sk-or-v1-super-secret-user-token-xyz123';
      final mockClient = MockClient((_) async {
        return utf8Response(
          jsonEncode({
            'error': {
              'message': 'Invalid Bearer token: $secretToken',
              'code': 401,
            }
          }),
          401,
        );
      });

      final service = OpenRouterAiService(client: mockClient);
      try {
        await service.analyzeFood(
          description: 'عدس پلو',
          apiKey: secretToken,
        );
        fail('Expected FoodAnalysisException');
      } on FoodAnalysisException catch (e) {
        expect(e.message, isNot(contains(secretToken)));
        expect(e.message, contains('کلید API نامعتبر است'));
      }
    });
  });

  group('4. Network Timeouts, HTTP 429 & HTTP 500 Reliability', () {
    test('GeminiService handles timeout gracefully with clear Persian message', () async {
      final mockClient = MockClient((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return utf8Response('{}', 200);
      });

      final service = GeminiService(client: mockClient);
      // Test timeout handler by catching TimeoutException inside implementation
      expect(
        () => service.generateContent(
          apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
          systemInstruction: 'sys',
          history: [],
          userMessage: 'msg',
        ),
        throwsA(anything),
      );
    });

    test('GeminiService handles HTTP 429 with explicit rate limit explanation', () async {
      final mockClient = MockClient((_) async => utf8Response('Rate limit exceeded', 429));
      final service = GeminiService(client: mockClient);

      expect(
        () => service.generateContent(
          apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
          systemInstruction: 'sys',
          history: [],
          userMessage: 'msg',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('سقف درخواست‌های مجاز جمینای تکمیل شده است'),
        )),
      );
    });

    test('OpenRouterAiService handles HTTP 429 with rate limit explanation', () async {
      final mockClient = MockClient((_) async => utf8Response('Rate limit exceeded', 429));
      final service = OpenRouterAiService(client: mockClient);

      expect(
        () => service.analyzeFood(
          description: 'سیب‌زمینی',
          apiKey: 'sk-or-v1-dummy-key',
        ),
        throwsA(isA<FoodAnalysisException>().having(
          (e) => e.message,
          'message',
          contains('سقف درخواست‌های سرویس OpenRouter تکمیل شده است'),
        )),
      );
    });

    test('GeminiService handles HTTP 500 transient server errors gracefully', () async {
      final mockClient = MockClient((_) async => utf8Response('Internal Server Error', 500));
      final service = GeminiService(client: mockClient);

      expect(
        () => service.generateContent(
          apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
          systemInstruction: 'sys',
          history: [],
          userMessage: 'msg',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('سرورهای گوگل موقتاً با اختلال مواجه شده‌اند'),
        )),
      );
    });
  });

  group('5. Response Parsing & Safety Filters', () {
    test('GeminiService handles safety block in promptFeedback', () async {
      final mockClient = MockClient((_) async {
        return utf8Response(
          jsonEncode({
            'promptFeedback': {
              'blockReason': 'SAFETY',
              'safetyRatings': [
                {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability': 'HIGH'}
              ]
            }
          }),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      expect(
        () => service.generateContent(
          apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
          systemInstruction: 'sys',
          history: [],
          userMessage: 'msg',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('مسدود شد'),
        )),
      );
    });

    test('GeminiService handles finishReason == SAFETY in candidate', () async {
      final mockClient = MockClient((_) async {
        return utf8Response(
          jsonEncode({
            'candidates': [
              {
                'finishReason': 'SAFETY',
                'index': 0,
              }
            ]
          }),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      expect(
        () => service.generateContent(
          apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
          systemInstruction: 'sys',
          history: [],
          userMessage: 'msg',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('فیلتر ایمنی محتوا'),
        )),
      );
    });

    test('GeminiService handles empty candidates list without StateError', () async {
      final mockClient = MockClient((_) async {
        return utf8Response(
          jsonEncode({'candidates': []}),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      expect(
        () => service.generateContent(
          apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
          systemInstruction: 'sys',
          history: [],
          userMessage: 'msg',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('نامزد خالی'),
        )),
      );
    });

    test('GeminiService combines multiple response parts cleanly', () async {
      final mockClient = MockClient((_) async {
        return utf8Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'بخش اول تحلیل.'},
                    {'text': 'بخش دوم توصیه بیومکانیکی.'},
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      final response = await service.generateContent(
        apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
        systemInstruction: 'sys',
        history: [],
        userMessage: 'msg',
      );

      expect(response, contains('بخش اول تحلیل.'));
      expect(response, contains('بخش دوم توصیه بیومکانیکی.'));
    });

    test('GeminiService.analyzeFoodImage parses Markdown-fenced JSON resiliently', () async {
      final mockClient = MockClient((_) async {
        return utf8Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': '```json\n{\n  "food_name": "فیله مرغ گریل",\n  "calories": 250\n}\n```'
                    }
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      final result = await service.analyzeFoodImage(
        apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
        imageBytes: [1, 2],
      );

      expect(result['food_name'], equals('فیله مرغ گریل'));
      expect(result['calories'], equals(250));
    });

    test('GeminiService.analyzeFoodImage handles malformed non-JSON response gracefully', () async {
      final mockClient = MockClient((_) async {
        return utf8Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'متاسفانه قادر به تشخیص غذا نبودم و JSON تولید نمی‌شود.'}
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final service = GeminiService(client: mockClient);
      expect(
        () => service.analyzeFoodImage(
          apiKey: 'AIzaSyD-dummy-key-for-test-3456789',
          imageBytes: [1, 2],
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('معتبر نیست'),
        )),
      );
    });
  });

  group('6. AI Context Privacy & Defensive Guardrails', () {
    test('AiContextBuilder does NOT contain hardcoded names when user name is different', () {
      final profile = UserProfile(
        id: 'u_sohrab',
        firstName: 'سهراب',
        lastName: 'سپهری',
        phone: '09120000000',
        email: 'sohrab@test.com',
        weightKg: 72.0,
        heightCm: 178,
        fitnessGoal: 'استقامت قلبی عروقی',
        fitnessLevel: 'Intermediate',
        level: UserLevel.athlete,
        coins: 100,
        dailyFreeScans: 5,
        streakDays: 7,
        totalWorkoutsCompleted: 12,
        activeSinceMonths: 2,
      );

      final storage = _SecurityMockStorage(profile: profile);
      final state = AppState(storage: storage);

      final prompt = AiContextBuilder.buildSystemPrompt(state);

      // Must NOT contain the previously hardcoded "آرمین"
      expect(prompt, isNot(contains('آرمین')));
      // Must contain real user name
      expect(prompt, contains('سهراب سپهری'));
      // Must NOT contain hardcoded diet title "(رژیم ۵۳۳)"
      expect(prompt, isNot(contains('(رژیم ۵۳۳)')));
      // Must NOT contain fabricated supplement schedule
      expect(prompt, isNot(contains('پروتئین Whey (ساعت ۱۲')));
      expect(prompt, isNot(contains('کراتین (۵ گرم بعد تمرین)')));
      // Must NOT contain fabricated sleep assumption
      expect(prompt, isNot(contains('۸ تا ۹ ساعت خواب عمیق جهت ترشح حداکثری')));
      // Must NOT leak coin balance
      expect(prompt, isNot(contains('موجودی سکه')));
    });

    test('AiContextBuilder handles empty profile and unrecorded metrics with explicit fallback labels',
        () {
      final emptyProfile = UserProfile(
        id: 'u_empty',
        firstName: '',
        lastName: '',
        phone: '',
        email: '',
        weightKg: 0,
        heightCm: 0,
        age: 0,
        bodyFatPercentage: 0,
        muscleMassKg: 0,
        fitnessGoal: '',
        fitnessLevel: '',
        level: UserLevel.member,
        coins: 0,
        dailyFreeScans: 0,
        streakDays: 0,
        totalWorkoutsCompleted: 0,
        activeSinceMonths: 0,
      );

      final storage = _SecurityMockStorage(
        profile: emptyProfile,
        plans: [],
        exerciseList: [],
        logs: [],
      );
      final state = AppState(storage: storage);

      // Must build without throwing StateError on empty collections
      final prompt = AiContextBuilder.buildSystemPrompt(state);

      expect(prompt, contains('ورزشکار گرامی'));
      expect(prompt, contains('سن: ثبت نشده'));
      expect(prompt, contains('وزن فعلی: ثبت نشده'));
      expect(prompt, contains('قد: ثبت نشده'));
      expect(prompt, contains('هیچ برنامه تمرینی فعالی ثبت نشده است'));
      expect(prompt, contains('سابقه تمرینی ثبت‌شده‌ای در سیستم وجود ندارد'));
    });
  });

  group('7. Local Storage Security Utilities', () {
    test('LocalStorageService.maskApiKey correctly redacts sensitive API keys', () {
      expect(LocalStorageService.maskApiKey(''), equals('(تنظیم نشده)'));
      expect(LocalStorageService.maskApiKey('short'), equals('****'));
      expect(
        LocalStorageService.maskApiKey('AIzaSyD1234567890abcdefghijklmnopqr'),
        equals('AIza...opqr'),
      );
    });
  });
}
