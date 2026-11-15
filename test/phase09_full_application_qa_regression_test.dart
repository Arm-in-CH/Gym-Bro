import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';
import 'package:gymbro/core/error/app_exceptions.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/body_analytics_models.dart';
import 'package:gymbro/screens/main_navigation_screen.dart';
import 'package:gymbro/screens/workout_screen.dart';
import 'package:gymbro/screens/nutrition_screen.dart';

Widget _wrapInApp(Widget child, {Size size = const Size(390, 844), double textScale = 1.0}) {
  return MediaQuery(
    data: MediaQueryData(
      size: size,
      textScaler: TextScaler.linear(textScale),
      padding: const EdgeInsets.only(top: 24, bottom: 16),
    ),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late AppState state;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    state = AppState(storage: storage);
  });

  tearDown(() async {
    await WorkoutTimerService().cancel();
  });

  group('GymBro Phase 09: Full Application QA & Regression Test Suite', () {
    // -------------------------------------------------------------------------
    // 1. FUNCTIONAL & END-TO-END WORKFLOW TESTING
    // -------------------------------------------------------------------------
    testWidgets('1. End-to-End User Journey: Navigation across primary tabs', (tester) async {
      await tester.pumpWidget(_wrapInApp(MainNavigationScreen(state: state)));
      await tester.pumpAndSettle();

      // Starts on Dashboard tab (index 0)
      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.text('تمرینات'), findsOneWidget);
      expect(find.text('تغذیه'), findsOneWidget);
      expect(find.text('پروفایل'), findsOneWidget);

      // Navigate to Workout tab (index 1)
      await tester.tap(find.text('تمرینات'));
      await tester.pumpAndSettle();
      expect(find.text('برنامه‌های تمرینی'), findsOneWidget);
      expect(find.text('بانک جامع حرکات'), findsOneWidget);

      // Navigate to Nutrition tab (index 2)
      await tester.tap(find.text('تغذیه'));
      await tester.pumpAndSettle();
      expect(find.text('تغذیه و پایش هوشمند کالری'), findsOneWidget);
      expect(find.text('ثبت وعده'), findsOneWidget);

      // Navigate to Profile tab (index 3)
      await tester.tap(find.text('پروفایل'));
      await tester.pumpAndSettle();
      expect(find.text('پروفایل و جایگاه ورزشی'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    test('2. Functional: Workout Plan Lifecycle (Create -> Edit -> Start Session -> Complete -> Verify History)', () async {
      final initialPlansCount = state.workoutPlans.length;
      final initialHistoryCount = state.workoutLogs.length;

      // 1. Create Workout Plan
      await state.createWorkoutPlan(
        titleFa: 'برنامه تخصصی کنترل کیفیت QA',
        descriptionFa: 'برنامه تستی با حرکات پایه‌ای بدنسازی',
        splitType: 'Full Body',
        daysPerWeek: 3,
      );
      expect(state.workoutPlans.length, equals(initialPlansCount + 1));
      final createdPlan = state.workoutPlans.firstWhere(
        (p) => p.titleFa == 'برنامه تخصصی کنترل کیفیت QA',
      );

      // 2. Edit Workout Plan
      final updatedPlan = createdPlan.copyWith(
        titleFa: 'برنامه ویرایش‌شده نهایی QA',
        daysPerWeek: 4,
      );
      await state.updateWorkoutPlan(updatedPlan);
      expect(
        state.workoutPlans.firstWhere((p) => p.id == createdPlan.id).titleFa,
        equals('برنامه ویرایش‌شده نهایی QA'),
      );

      // 3. Start Session Draft
      await state.startWorkoutSession(planId: createdPlan.id);
      expect(state.getActiveWorkoutDraft(createdPlan.id), isNotNull);

      // 4. Complete Session with valid sets
      final setLogs = [
        WorkoutSetLog(
          id: 's_qa_1',
          exerciseName: 'پرس سینه هالتر',
          setNumber: 1,
          reps: 10,
          weightKg: 80.0,
        ),
        WorkoutSetLog(
          id: 's_qa_2',
          exerciseName: 'پرس سینه هالتر',
          setNumber: 2,
          reps: 8,
          weightKg: 85.0,
        ),
      ];

      final log = await state.completeWorkoutSession(
        plan: updatedPlan,
        totalVolumeKg: 1480.0,
        completedSets: 2,
        setLogs: setLogs,
        durationMinutes: 40,
      );

      expect(log.id, startsWith('wlog_'));
      expect(log.completedSets, equals(2));
      expect(log.totalVolumeKg, equals(1480.0));
      expect(state.workoutLogs.length, equals(initialHistoryCount + 1));
      expect(state.getActiveWorkoutDraft(createdPlan.id), isNull); // Cleans draft
    });

    // -------------------------------------------------------------------------
    // 2. NUTRITION & HYDRATION PERSISTENCE & INTEGRITY
    // -------------------------------------------------------------------------
    test('3. Functional & Persistence: Nutrition Logging, Duplicate, and Water Tracking', () async {
      final initialMealsCount = state.calorieLogs.length;
      final initialWater = state.selectedConsumedWaterMl;

      // 1. Add Food Log
      await state.addMealLog(
        foodName: 'استیک فیله گوساله با برنج کته',
        mealType: 'ناهار',
        calories: 650,
        proteinG: 55.0,
        carbsG: 60.0,
        fatG: 15.0,
        portionG: 350.0,
      );
      expect(state.calorieLogs.length, equals(initialMealsCount + 1));
      final addedMeal = state.calorieLogs.first;
      expect(addedMeal.foodName, equals('استیک فیله گوساله با برنج کته'));

      // 2. Duplicate Food Log
      await state.duplicateFoodEntry(addedMeal);
      expect(state.calorieLogs.length, equals(initialMealsCount + 2));

      // 3. Water Logging & Undo
      await state.logWater(250);
      expect(state.selectedConsumedWaterMl, equals(initialWater + 250));
      await state.logWater(500);
      expect(state.selectedConsumedWaterMl, equals(initialWater + 750));
      await state.undoWater(250);
      expect(state.selectedConsumedWaterMl, equals(initialWater + 500));

      // 4. Simulate App Restart and verify data persists
      final restartedStorage = LocalStorageService();
      await restartedStorage.init();
      final restartedState = AppState(storage: restartedStorage);

      expect(restartedState.calorieLogs.length, equals(initialMealsCount + 2));
      expect(restartedState.selectedConsumedWaterMl, equals(initialWater + 500));
    });

    // -------------------------------------------------------------------------
    // 3. ANTHROPOMETRIC & BODY MEASUREMENT LIFECYCLE
    // -------------------------------------------------------------------------
    test('4. Functional & Calculations: Anthropometrics, Weight Progress, and BMI Spectrum', () async {
      final initialWeightRecords = state.weightRecords.length;
      final initialMeasurements = state.bodyMeasurements.length;

      // 1. Add Weight Record
      await state.addWeightRecord(
        weightKg: 82.5,
        date: DateTime.now(),
        note: 'ثبت هفتگی تست کنترل کیفیت',
      );
      expect(state.weightRecords.length, equals(initialWeightRecords + 1));
      expect(state.currentWeightKg, equals(82.5));

      // 2. Add Circumference Measurements
      final newMeasure = BodyMeasurementRecord(
        id: 'bmr_qa_1',
        date: DateTime.now(),
        chestCm: 108.0,
        waistCm: 84.0,
        rightArmCm: 39.5,
        hipCm: 99.0,
        thighCm: 61.0,
      );
      await state.addBodyMeasurement(newMeasure);
      expect(state.bodyMeasurements.length, equals(initialMeasurements + 1));
      expect(state.latestBodyMeasurement?.chestCm, equals(108.0));

      // 3. Delete Record cleanly
      final addedRecord = state.weightRecords.firstWhere((r) => r.weightKg == 82.5);
      await state.deleteWeightRecord(addedRecord.id);
      expect(state.weightRecords.any((r) => r.id == addedRecord.id), isFalse);

      await state.deleteBodyMeasurement(newMeasure.id);
      expect(state.bodyMeasurements.any((m) => m.id == newMeasure.id), isFalse);
    });

    // -------------------------------------------------------------------------
    // 4. AI CONFIGURATION & MODEL SWITCHING
    // -------------------------------------------------------------------------
    test('5. Functional: AI Engine Configuration & Model Provider Selection', () async {
      expect(state.geminiModel, isNotEmpty);

      // Save custom Gemini API Key & Model
      await state.saveGeminiConfig(
        apiKey: 'AIzaSyMockKeyForQaTesting12345',
        model: 'gemini-1.5-pro',
      );

      expect(state.geminiApiKey, equals('AIzaSyMockKeyForQaTesting12345'));
      expect(state.geminiModel, equals('gemini-1.5-pro'));

      // Save custom OpenRouter Key
      await state.updateApiKey('sk-or-v1-mock-key-testing');
      expect(state.openRouterApiKey, equals('sk-or-v1-mock-key-testing'));

      // Verify persistence on cold restart
      final restartedStorage = LocalStorageService();
      await restartedStorage.init();
      final restartedState = AppState(storage: restartedStorage);

      expect(restartedState.geminiApiKey, equals('AIzaSyMockKeyForQaTesting12345'));
      expect(restartedState.geminiModel, equals('gemini-1.5-pro'));
      expect(restartedState.openRouterApiKey, equals('sk-or-v1-mock-key-testing'));
    });

    // -------------------------------------------------------------------------
    // 5. STORAGE RESILIENCE & CORRUPTED DATA RECOVERY
    // -------------------------------------------------------------------------
    test('6. Resilience: Self-healing and corrupt JSON recovery', () async {
      final prefs = await SharedPreferences.getInstance();

      // Inject corrupted JSON into user profile and workout plans
      await prefs.setString('gymbro_user_profile', '{{{INVALID_MALFORMED_JSON_CORRUPT');
      await prefs.setString('gymbro_workout_plans', '[{non_json_corrupted');

      // Instantiate fresh storage
      final corruptStorage = LocalStorageService();
      await corruptStorage.init();
      final resilientState = AppState(storage: corruptStorage);

      // Must NOT throw StateError or FormatException, but fallback gracefully to defaults or backup
      expect(resilientState.userProfile, isNotNull);
      expect(resilientState.userProfile.id, isNotEmpty);
      expect(resilientState.workoutPlans, isNotEmpty);
    });

    // -------------------------------------------------------------------------
    // 6. EDGE CASES & RAPID INTERACTION STABILITY
    // -------------------------------------------------------------------------
    testWidgets('7. Edge Cases: Zero-volume workout completion rejection & Rapid Tab Taps', (tester) async {
      // 1. Validating zero sets completion throws ValidationException
      expect(
        () async => await state.completeWorkoutSession(
          plan: state.workoutPlans.first,
          totalVolumeKg: 0,
          completedSets: 0,
          setLogs: [],
          durationMinutes: 10,
        ),
        throwsA(isA<ValidationException>()),
      );

      // 2. Rapid Tab Transitions Stress (60 rapid switches)
      await tester.pumpWidget(_wrapInApp(MainNavigationScreen(state: state)));
      await tester.pumpAndSettle();

      for (int i = 0; i < 20; i++) {
        await tester.tap(find.text('تمرینات'));
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('تغذیه'));
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('پروفایل'));
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // -------------------------------------------------------------------------
    // 7. RESPONSIVENESS & ACCESSIBILITY (320px Cover to 1024px Tablet)
    // -------------------------------------------------------------------------
    testWidgets('8. UI Testing: Responsive Viewports & TextScale 2.0x Stress', (tester) async {
      final viewports = [
        const Size(320, 640),   // Compact foldable cover screen
        const Size(360, 780),   // Standard Android phone
        const Size(412, 915),   // Large flagship phone
        const Size(768, 1024),  // Tablet display
      ];

      for (final vp in viewports) {
        await tester.pumpWidget(_wrapInApp(
          WorkoutScreen(
            state: state,
            onStartWorkout: (_) {},
            onOpenHomeMode: () {},
          ),
          size: vp,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Accessibility 200% font scale
      await tester.pumpWidget(_wrapInApp(
        NutritionScreen(state: state, onOpenScanner: () {}),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
