import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/models/marketplace_models.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/screens/main_navigation_screen.dart';
import 'package:gymbro/screens/dashboard_screen.dart';
import 'package:gymbro/screens/workout_screen.dart';
import 'package:gymbro/screens/active_workout_screen.dart';
import 'package:gymbro/screens/focused_training_screen.dart';
import 'package:gymbro/screens/workout_history_screen.dart';
import 'package:gymbro/screens/achievements_screen.dart';
import 'package:gymbro/screens/settings_screen.dart';
import 'package:gymbro/screens/nutrition_screen.dart';
import 'package:gymbro/screens/meal_scanner_screen.dart';
import 'package:gymbro/screens/marketplace_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';
import 'package:gymbro/screens/ai_coach_screen.dart';
import 'package:gymbro/screens/ai_config_screen.dart';
import 'package:gymbro/screens/home_workout_mode_screen.dart';
import 'package:gymbro/screens/add_food_dialog.dart';
import 'package:gymbro/screens/add_measurement_dialog.dart';
import 'package:gymbro/screens/edit_nutrition_goals_dialog.dart';
import 'package:gymbro/screens/edit_profile_dialog.dart';
import 'package:gymbro/widgets/rest_timer_dialog.dart';
import 'package:gymbro/widgets/one_rm_calculator_dialog.dart';

class _MockStorageService extends LocalStorageService {
  @override
  UserProfile getProfile() => UserProfile(
        id: 'u1',
        firstName: 'آرمین',
        lastName: 'جعفری',
        phone: '09123456789',
        email: 'armin@gymbro.app',
        weightKg: 78.5,
        heightCm: 182,
        targetWeightKg: 75.0,
        fitnessGoal: 'Hypertrophy',
        fitnessLevel: 'Advanced',
        level: UserLevel.athlete,
        coins: 240,
        dailyFreeScans: 10,
        streakDays: 14,
        totalWorkoutsCompleted: 42,
        activeSinceMonths: 6,
      );

  @override
  NutritionPlan getNutritionPlan() => NutritionPlan(
        id: 'n1',
        dailyCalories: 2650,
        targetProteinG: 165,
        targetCarbsG: 300,
        targetFatG: 70,
        targetWaterMl: 3500,
      );

  @override
  List<WorkoutPlan> getWorkoutPlans() => [
        WorkoutPlan(
          id: 'p1',
          titleFa: 'روز هل دادنی تخصصی سینه و سرشانه',
          titleEn: 'Push Day A',
          descriptionFa: 'تمرین سینه، سرشانه و پشت بازو سنگین',
          splitType: 'PPL',
          daysPerWeek: 4,
          difficulty: 'پیشرفته',
          exercises: [
            WorkoutPlanExercise(
              id: 'pe1',
              planId: 'p1',
              exerciseId: 'ex_bench',
              dayOfWeek: 1,
              dayNameFa: 'شنبه',
              orderInDay: 1,
              targetSets: 4,
              targetReps: 8,
              targetWeightKg: 85.0,
              restSeconds: 90,
            ),
          ],
        ),
      ];

  @override
  List<Exercise> getExercises() => [
        Exercise(
          id: 'ex_bench',
          nameFa: 'پرس سینه هالتر روی نیمکت تخت',
          nameEn: 'Barbell Flat Bench Press',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Barbell',
          equipmentFa: 'هالتر و نیمکت',
          instructionsFa: 'روی نیمکت دراز بکشید و هالتر را تا بالای سینه پایین بیاورید.',
          homeEquivalentId: 'ex_pushups',
        ),
      ];

  @override
  List<CalorieScanLog> getCalorieLogs() => [
        CalorieScanLog(
          id: 'c1',
          foodName: 'چلو کباب کوبیده با برنج زعفرانی',
          mealType: 'ناهار',
          calories: 850,
          proteinG: 45,
          carbsG: 90,
          fatG: 35,
          portionG: 400,
          dateString: '2026-11-09',
          timestamp: 1000,
        ),
      ];

  @override
  List<Gym> getGyms() => [
        Gym(
          id: 'g1',
          name: 'باشگاه وی آی پی نیاوران',
          address: 'تهران، نیاوران، خیابان باهنر',
          district: 'نیاوران',
          latitude: 35.81,
          longitude: 51.46,
          monthlyFeeToman: 4200000,
          rating: 4.9,
          reviewCount: 38,
          amenities: ['استخر', 'سونا', 'کافه پروتئینی'],
        ),
      ];

  @override
  List<Trainer> getTrainers() => [
        Trainer(
          id: 't1',
          name: 'استاد علیرضا راد',
          title: 'مربی رسمی فدراسیون IFBB',
          specialty: 'هایپرتروفی',
          bio: 'دارای ۱۰ سال سابقه تمرینات تخصصی هایپرتروفی',
          hourlyRateToman: 650000,
          sessionType: 'حضوری در باشگاه',
          rating: 5.0,
          reviewCount: 42,
        ),
      ];

  @override
  List<WorkoutLog> getWorkoutLogs() => [
        WorkoutLog(
          id: 'log1',
          planId: 'p1',
          planTitle: 'سینه و جلو بازو انفجاری',
          date: '2026-11-08',
          durationMinutes: 52,
          totalVolumeKg: 2140,
          completedSets: 8,
          isHomeWorkout: false,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          sets: [
            WorkoutSetLog(
              id: 's1',
              exerciseName: 'پرس سینه هالتر',
              setNumber: 1,
              weightKg: 80,
              reps: 10,
            ),
          ],
        ),
      ];

  @override
  List<Booking> getBookings() => [];
  @override
  String getApiKey() => 'test_key';
  @override
  String getGeminiApiKey() => 'test_gemini';
  @override
  String getGeminiModel() => 'gemini-1.5-flash';
}

void setTestDevice(
  WidgetTester tester, {
  required double width,
  required double height,
  double ratio = 1.0,
}) {
  tester.view.physicalSize = Size(width * ratio, height * ratio);
  tester.view.devicePixelRatio = ratio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget buildTestApp({
  required Widget child,
  TextDirection textDirection = TextDirection.rtl,
  double textScale = 1.0,
  EdgeInsets padding = EdgeInsets.zero,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
          padding: padding,
          viewInsets: viewInsets,
        ),
        child: child,
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 23: Complete Responsive, RTL & Device Compatibility Stress Suite', () {
    late AppState state;

    setUp(() {
      state = AppState(storage: _MockStorageService());
    });

    testWidgets('1. Narrow Cover Display (320x640) - All Primary Screens', (tester) async {
      setTestDevice(tester, width: 320, height: 640, ratio: 2.0);

      // Main Navigation
      await tester.pumpWidget(buildTestApp(child: MainNavigationScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Active Workout
      await tester.pumpWidget(buildTestApp(child: ActiveWorkoutScreen(planId: 'p1', state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Workout History & Stats
      await tester.pumpWidget(buildTestApp(child: WorkoutHistoryScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Achievements
      await tester.pumpWidget(buildTestApp(child: AchievementsScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Settings
      await tester.pumpWidget(buildTestApp(child: SettingsScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Large Android Flagship (440x956) - High Density 3.5x', (tester) async {
      setTestDevice(tester, width: 440, height: 956, ratio: 3.5);

      await tester.pumpWidget(buildTestApp(child: DashboardScreen(
        state: state,
        onOpenMealScanner: () {},
        onOpenHomeMode: () {},
        onOpenWorkouts: () {},
        onStartWorkout: (_) {},
        onOpenMarketplace: () {},
        onOpenAiCoach: () {},
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: NutritionScreen(state: state, onOpenScanner: () {})));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: WorkoutScreen(
        state: state,
        onStartWorkout: (_) {},
        onOpenHomeMode: () {},
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: MealScannerScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: MarketplaceScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: ProfileScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. Foldable Inner Expanded Display (884x1104) - Adaptive Two-Pane Layout', (tester) async {
      setTestDevice(tester, width: 884, height: 1104, ratio: 2.0);

      await tester.pumpWidget(buildTestApp(child: ActiveWorkoutScreen(planId: 'p1', state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: FocusedTrainingScreen(
        planId: 'p1',
        state: state,
        initialDay: 1,
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: WorkoutHistoryScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. Small Phone Landscape (640x360) - Navigation & Workouts', (tester) async {
      setTestDevice(tester, width: 640, height: 360, ratio: 1.5);

      await tester.pumpWidget(buildTestApp(child: DashboardScreen(
        state: state,
        onOpenMealScanner: () {},
        onOpenHomeMode: () {},
        onOpenWorkouts: () {},
        onStartWorkout: (_) {},
        onOpenMarketplace: () {},
        onOpenAiCoach: () {},
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: ActiveWorkoutScreen(planId: 'p1', state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: AchievementsScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Accessibility Font Scale 2.0x Stress - Settings, History & Dialogs', (tester) async {
      setTestDevice(tester, width: 360, height: 640, ratio: 2.0);

      // Settings screen
      await tester.pumpWidget(buildTestApp(
        child: SettingsScreen(state: state),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Workout History screen
      await tester.pumpWidget(buildTestApp(
        child: WorkoutHistoryScreen(state: state),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Achievements screen
      await tester.pumpWidget(buildTestApp(
        child: AchievementsScreen(state: state),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('6. Soft Keyboard Insets (bottom: 300) - Dialogs & Input Forms', (tester) async {
      setTestDevice(tester, width: 360, height: 640, ratio: 2.0);

      // Edit Profile Dialog
      await tester.pumpWidget(buildTestApp(
        child: Scaffold(body: EditProfileDialog(state: state)),
        viewInsets: const EdgeInsets.only(bottom: 300),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Add Food Dialog
      await tester.pumpWidget(buildTestApp(
        child: Scaffold(body: AddFoodDialog(state: state)),
        viewInsets: const EdgeInsets.only(bottom: 300),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Add Measurement Dialog
      await tester.pumpWidget(buildTestApp(
        child: Scaffold(body: AddMeasurementDialog(state: state)),
        viewInsets: const EdgeInsets.only(bottom: 300),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Edit Nutrition Goals Dialog
      await tester.pumpWidget(buildTestApp(
        child: Scaffold(body: EditNutritionGoalsDialog(state: state)),
        viewInsets: const EdgeInsets.only(bottom: 300),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('7. Notch and System Bar Insets (SafeArea Integrity)', (tester) async {
      setTestDevice(tester, width: 390, height: 844, ratio: 3.0);

      const notchInsets = EdgeInsets.only(top: 48, bottom: 34);

      await tester.pumpWidget(buildTestApp(
        child: MainNavigationScreen(state: state),
        padding: notchInsets,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(
        child: ActiveWorkoutScreen(planId: 'p1', state: state),
        padding: notchInsets,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(
        child: AiCoachScreen(state: state),
        padding: notchInsets,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('8. LTR Fallback Mode - Bi-directional Directionality Consistency', (tester) async {
      setTestDevice(tester, width: 412, height: 915, ratio: 2.6);

      // Verify screens render cleanly when explicitly set to LTR without layout blowups
      await tester.pumpWidget(buildTestApp(
        child: WorkoutHistoryScreen(state: state),
        textDirection: TextDirection.ltr,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(
        child: AchievementsScreen(state: state),
        textDirection: TextDirection.ltr,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(
        child: SettingsScreen(state: state),
        textDirection: TextDirection.ltr,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('9. Specialty Dialogs & Calculators on Small Screen (320x640)', (tester) async {
      setTestDevice(tester, width: 320, height: 640, ratio: 2.0);

      // One RM Calculator Dialog
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(body: OneRmCalculatorDialog()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Rest Timer Dialog
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(body: RestTimerDialog()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('10. AI Coach & Config on Narrow Device (340x800)', (tester) async {
      setTestDevice(tester, width: 340, height: 800, ratio: 2.5);

      await tester.pumpWidget(buildTestApp(child: AiCoachScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: AiConfigScreen(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestApp(child: HomeWorkoutModeScreen(
        state: state,
        onStartWorkout: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
