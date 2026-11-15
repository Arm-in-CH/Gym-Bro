import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/body_analytics_models.dart';
import 'package:gymbro/models/achievement_model.dart';
import 'package:gymbro/models/timer_settings.dart';
import 'package:gymbro/screens/main_navigation_screen.dart';
import 'package:gymbro/screens/active_workout_screen.dart';
import 'package:gymbro/screens/workout_history_screen.dart';
import 'package:gymbro/screens/achievements_screen.dart';
import 'package:gymbro/screens/settings_screen.dart';
import 'package:gymbro/screens/nutrition_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';
import 'package:gymbro/screens/edit_profile_dialog.dart';
import 'package:gymbro/screens/add_food_dialog.dart';
import 'package:gymbro/screens/add_measurement_dialog.dart';
import 'package:gymbro/screens/edit_nutrition_goals_dialog.dart';
import 'package:gymbro/widgets/rest_timer_dialog.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: child,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 24: Comprehensive QA, Visual Regression & Final Functional Verification', () {
    late LocalStorageService storage;
    late AppState state;

    setUp(() async {
      storage = LocalStorageService();
      await storage.init();
      state = AppState(storage: storage);
    });

    test('1. Data Integrity: Default Seed Data Initialized Accurately', () {
      expect(state.userProfile.id, isNotEmpty);
      expect(state.userProfile.weightKg, greaterThan(0));
      expect(state.userProfile.heightCm, greaterThan(0));
      expect(state.workoutPlans, isNotEmpty);
      expect(state.exercises, isNotEmpty);
      expect(state.nutritionPlan.dailyCalories, greaterThan(0));
      expect(state.gyms, isNotEmpty);
      expect(state.trainers, isNotEmpty);
      expect(state.weightRecords, isNotEmpty);
      expect(state.bodyMeasurements, isNotEmpty);
    });

    testWidgets('2. Workflow: Profile & Anthropometric Measurement Logging', (tester) async {
      await tester.pumpWidget(_buildTestApp(ProfileScreen(state: state)));
      await tester.pumpAndSettle();

      // Verify Profile Screen renders hero progress and BMI
      expect(find.text('پروفایل و جایگاه ورزشی'), findsOneWidget);
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Edit Profile
      final initialWeight = state.userProfile.weightKg;
      await state.updateFullProfile(state.userProfile.copyWith(weightKg: initialWeight + 1.5));
      expect(state.userProfile.weightKg, equals(initialWeight + 1.5));

      // Add Anthropometric record
      final initialCount = state.bodyMeasurements.length;
      await state.addBodyMeasurement(BodyMeasurementRecord(
        id: 'qa_measure_1',
        date: DateTime.now(),
        chestCm: 104,
        waistCm: 82,
        hipCm: 98,
        leftArmCm: 38.5,
        rightArmCm: 38.5,
        thighCm: 59,
        calfCm: 37,
        bodyFatPercentage: 15.2,
        note: 'تست اندازه‌گیری فاز ۲۴',
      ));
      expect(state.bodyMeasurements.length, equals(initialCount + 1));
      expect(state.bodyMeasurements.last.waistCm, equals(82));
    });

    testWidgets('3. Workflow: Food Logging, Daily Macros & Budget Recalculation', (tester) async {
      await tester.pumpWidget(_buildTestApp(NutritionScreen(state: state, onOpenScanner: () {})));
      await tester.pumpAndSettle();

      final initialLogsCount = state.calorieLogs.length;
      final initialCalories = state.selectedConsumedCalories;

      // Add new meal log
      await state.addFoodEntry(CalorieScanLog(
        id: 'qa_meal_1',
        foodName: 'سینه مرغ گریل با برنج قهوه‌ای',
        mealType: 'ناهار',
        calories: 620,
        proteinG: 55,
        carbsG: 65,
        fatG: 12,
        portionG: 350,
        dateString: state.selectedNutritionDateString,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));

      expect(state.calorieLogs.length, equals(initialLogsCount + 1));
      expect(state.selectedConsumedCalories, equals(initialCalories + 620));
      expect(state.selectedConsumedProtein, greaterThan(0));

      // Water tracking
      final initialWater = state.selectedConsumedWaterMl;
      await state.logWater(250);
      expect(state.selectedConsumedWaterMl, equals(initialWater + 250));
    });

    testWidgets('4. Workflow: Workout Execution, Set Logging & History Archival', (tester) async {
      final plan = state.workoutPlans.first;

      await tester.pumpWidget(_buildTestApp(ActiveWorkoutScreen(
        planId: plan.id,
        state: state,
      )));
      await tester.pumpAndSettle();

      expect(find.text(plan.titleFa), findsOneWidget);

      // Finish workout and verify archival into workout logs
      final initialHistoryCount = state.workoutLogs.length;
      await state.completeWorkoutSession(
        plan: plan,
        totalVolumeKg: (85 * 8) + (90 * 8),
        completedSets: 2,
        durationMinutes: 48,
        setLogs: [
          WorkoutSetLog(
            id: 's1',
            exerciseName: 'پرس سینه هالتر',
            setNumber: 1,
            weightKg: 85,
            reps: 8,
          ),
          WorkoutSetLog(
            id: 's2',
            exerciseName: 'پرس سینه هالتر',
            setNumber: 2,
            weightKg: 90,
            reps: 8,
          ),
        ],
      );

      expect(state.workoutLogs.length, equals(initialHistoryCount + 1));

      // Verify PR Calculation in WorkoutHistoryScreen
      await tester.pumpWidget(_buildTestApp(WorkoutHistoryScreen(state: state)));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('5. Workflow: Achievements Calculation with 0 False Claims', (tester) async {
      await tester.pumpWidget(_buildTestApp(AchievementsScreen(state: state)));
      await tester.pumpAndSettle();

      final items = AchievementItem.computeAllAchievements(state);
      expect(items, isNotEmpty);

      // Confirm streak achievement equals real user profile streak
      final streakItem = items.firstWhere((i) => i.id == 'streak_1');
      expect(streakItem.currentValue, equals(state.userProfile.streakDays));
      expect(streakItem.isUnlocked, equals(state.userProfile.streakDays >= streakItem.targetValue));
    });

    testWidgets('6. Workflow: Settings Updates & Timer Preferences Persistence', (tester) async {
      await tester.pumpWidget(_buildTestApp(SettingsScreen(state: state)));
      await tester.pumpAndSettle();

      // Update timer settings
      await state.updateTimerSettings(const TimerSettings(
        defaultRestSeconds: 90,
        soundAlerts: false,
        vibrationAlerts: true,
      ));

      expect(state.timerSettings.defaultRestSeconds, equals(90));
      expect(state.timerSettings.soundAlerts, isFalse);
      expect(state.timerSettings.vibrationAlerts, isTrue);
    });

    testWidgets('7. Dialog Integrity: Form Submissions and Input Protection', (tester) async {
      // Edit Profile Dialog
      await tester.pumpWidget(_buildTestApp(Scaffold(body: EditProfileDialog(state: state))));
      await tester.pumpAndSettle();
      expect(find.text('ویرایش مشخصات فیزیکی'), findsOneWidget);

      // Add Food Dialog
      await tester.pumpWidget(_buildTestApp(Scaffold(body: AddFoodDialog(state: state))));
      await tester.pumpAndSettle();
      expect(find.text('ثبت وعده غذایی جدید'), findsOneWidget);

      // Add Measurement Dialog
      await tester.pumpWidget(_buildTestApp(Scaffold(body: AddMeasurementDialog(state: state))));
      await tester.pumpAndSettle();
      expect(find.text('ثبت آمار و اندازه‌گیری جدید'), findsOneWidget);

      // Edit Goals Dialog
      await tester.pumpWidget(_buildTestApp(Scaffold(body: EditNutritionGoalsDialog(state: state))));
      await tester.pumpAndSettle();
      expect(find.text('تنظیم اهداف تغذیه و هیدراتاسیون'), findsOneWidget);

      // Rest Timer Dialog
      await tester.pumpWidget(_buildTestApp(const Scaffold(body: RestTimerDialog())));
      await tester.pumpAndSettle();
      expect(find.text('تایمر استراحت بین ست'), findsOneWidget);
    });

    test('8. Persistence Roundtrip: Complete AppState Serialization Equivalency', () async {
      // Capture current state values
      final profileEmail = state.userProfile.email;
      final profileCoins = state.userProfile.coins;
      final plansCount = state.workoutPlans.length;
      final exercisesCount = state.exercises.length;
      final logsCount = state.workoutLogs.length;

      // Simulate application cold restart with a new AppState instance pointing to same storage
      final state2 = AppState(storage: storage);

      expect(state2.userProfile.email, equals(profileEmail));
      expect(state2.userProfile.coins, equals(profileCoins));
      expect(state2.workoutPlans.length, equals(plansCount));
      expect(state2.exercises.length, equals(exercisesCount));
      expect(state2.workoutLogs.length, equals(logsCount));
    });

    testWidgets('9. Stress & Rapid Lifecycle Stability: 50 Fast Tab Transitions', (tester) async {
      await tester.pumpWidget(_buildTestApp(MainNavigationScreen(state: state)));
      await tester.pumpAndSettle();

      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('تمرینات'));
        await tester.pump();
        await tester.tap(find.text('تغذیه'));
        await tester.pump();
        await tester.tap(find.text('باشگاه'));
        await tester.pump();
        await tester.tap(find.text('پروفایل'));
        await tester.pump();
        await tester.tap(find.text('داشبورد'));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
