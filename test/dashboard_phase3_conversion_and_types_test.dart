import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/widgets/common/gymbro_design_system.dart';
import 'package:gymbro/core/localization/persian_utils.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/nutrition_models.dart';
import 'package:gymbro/screens/dashboard_screen.dart';

class _Phase3MockStorageService extends LocalStorageService {
  List<WorkoutPlan> customPlans;
  final bool shouldFailSave;
  final Duration? saveDelay;
  final List<WaterLog> customWaterLogs = [];

  _Phase3MockStorageService({
    required this.customPlans,
    this.shouldFailSave = false,
    this.saveDelay,
  });

  @override
  List<WaterLog> getWaterLogs() => List.from(customWaterLogs);

  @override
  Future<void> saveWaterLog(WaterLog log) async {
    customWaterLogs.insert(0, log);
  }

  @override
  UserProfile getProfile() =>
      UserProfile(
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
        targetWaterMl: 3000,
      );

  @override
  List<WorkoutPlan> getWorkoutPlans() => List.from(customPlans);

  @override
  Future<void> saveWorkoutPlans(List<WorkoutPlan> plans) async {
    if (saveDelay != null) {
      await Future.delayed(saveDelay!);
    }
    if (shouldFailSave) {
      throw Exception('خطای ذخیره‌سازی در دیسک');
    }
    customPlans = List.from(plans);
  }

  @override
  List<Exercise> getExercises() => [
        Exercise(
          id: 'ex_bench',
          nameFa: 'پرس سینه با هالتر',
          nameEn: 'Barbell Bench Press',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa: 'روی نیمکت بخوابید و هالتر را بالا ببرید',
          homeEquivalentId: 'ex_pushups',
        ),
        Exercise(
          id: 'ex_row',
          nameFa: 'زیربغل دمبل تک خم',
          nameEn: 'Dumbbell Row',
          muscleGroup: 'Back',
          muscleGroupFa: 'زیربغل',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa: 'یک دست را روی نیمکت بگذارید و دمبل را بکشید',
          homeEquivalentId: 'ex_doorframe_rows',
        ),
      ];

  @override
  List<WorkoutLog> getWorkoutLogs() => const [];
}

Widget buildTestApp({required Widget child}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: child),
    ),
  );
}

WorkoutPlan createGymPlan({
  required String id,
  required String titleFa,
  required String titleEn,
  bool isHomeWorkout = false,
}) {
  return WorkoutPlan(
    id: id,
    titleFa: titleFa,
    titleEn: titleEn,
    descriptionFa: 'تمرین تخصصی',
    splitType: 'Upper/Lower',
    isHomeWorkout: isHomeWorkout,
    daysPerWeek: 4,
    difficulty: 'متوسط',
    exercises: [
      WorkoutPlanExercise(
        id: 'e_$id',
        planId: id,
        exerciseId: 'ex_bench',
        dayOfWeek: 1,
        dayNameFa: 'جلسه ۱',
        orderInDay: 1,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 80,
      ),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GYMBRO DASHBOARD — PHASE 3: Conversion Wiring & Type Safety Suite', () {
    testWidgets('1. Conversion with a valid gym plan: Successfully converts and shows success message',
        (tester) async {
      final gymPlan = createGymPlan(
        id: 'gym_plan_valid',
        titleFa: 'سینه و جلو بازو سنگین',
        titleEn: 'Heavy Chest & Biceps',
      );
      final storage = _Phase3MockStorageService(customPlans: [gymPlan]);
      final state = AppState(storage: storage);

      await tester.pumpWidget(buildTestApp(
        child: HomeWorkoutFallbackCard(
          state: state,
          todayPlan: gymPlan,
          onOpenHomeMode: () {},
          tokens: AppThemeExtension.dark,
        ),
      ));
      await tester.pumpAndSettle();

      final convertBtnFinder = find.widgetWithText(GymBroPrimaryButton, 'تبدیل برنامه امروز');
      expect(convertBtnFinder, findsOneWidget);

      final buttonWidget = tester.widget<GymBroPrimaryButton>(convertBtnFinder);
      expect(buttonWidget.onPressed, isNotNull); // Must be enabled

      // Trigger conversion
      await tester.tap(convertBtnFinder, warnIfMissed: false);
      await tester.pump(); // Start async conversion
      await tester.pumpAndSettle(); // Finish async conversion and show SnackBar

      // Verify success SnackBar
      expect(find.textContaining('با موفقیت ایجاد شد!'), findsOneWidget);
      // Verify converted home plan exists in state
      expect(state.workoutPlans.any((p) => p.isHomeWorkout && p.titleFa.contains('سینه و جلو بازو سنگین')), isTrue);
      // Verify loading state is not stuck
      expect(state.isConvertingHome, isFalse);
    });

    testWidgets('2. Conversion with no gym plans: Button is disabled and conversion cannot proceed',
        (tester) async {
      final storage = _Phase3MockStorageService(customPlans: []);
      final state = AppState(storage: storage);

      await tester.pumpWidget(buildTestApp(
        child: HomeWorkoutFallbackCard(
          state: state,
          todayPlan: null, // No gym plan
          onOpenHomeMode: () {},
          tokens: AppThemeExtension.dark,
        ),
      ));
      await tester.pumpAndSettle();

      final convertBtnFinder = find.widgetWithText(GymBroPrimaryButton, 'تبدیل برنامه امروز');
      expect(convertBtnFinder, findsOneWidget);

      final buttonWidget = tester.widget<GymBroPrimaryButton>(convertBtnFinder);
      // Must be disabled when todayPlan is null
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('3. Conversion when only home plans exist: Button is disabled and home plan is not converted',
        (tester) async {
      final homeOnlyPlan = createGymPlan(
        id: 'home_only_1',
        titleFa: 'ورزش در خانه وزن بدن',
        titleEn: 'Bodyweight Home Workout',
        isHomeWorkout: true, // Home workout
      );
      final storage = _Phase3MockStorageService(customPlans: [homeOnlyPlan]);
      final state = AppState(storage: storage);

      await tester.pumpWidget(buildTestApp(
        child: HomeWorkoutFallbackCard(
          state: state,
          todayPlan: homeOnlyPlan, // Passed a home workout
          onOpenHomeMode: () {},
          tokens: AppThemeExtension.dark,
        ),
      ));
      await tester.pumpAndSettle();

      final convertBtnFinder = find.widgetWithText(GymBroPrimaryButton, 'تبدیل برنامه امروز');
      expect(convertBtnFinder, findsOneWidget);

      final buttonWidget = tester.widget<GymBroPrimaryButton>(convertBtnFinder);
      // Must be disabled when plan is not a gym plan
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('4. Conversion failure: Handles exceptions cleanly and does not display success message',
        (tester) async {
      final gymPlan = createGymPlan(
        id: 'gym_fail_test',
        titleFa: 'برنامه برای تست شکست',
        titleEn: 'Fail Plan',
      );
      // Storage throws exception during save
      final storage = _Phase3MockStorageService(
        customPlans: [gymPlan],
        shouldFailSave: true,
      );
      final state = AppState(storage: storage);

      await tester.pumpWidget(buildTestApp(
        child: HomeWorkoutFallbackCard(
          state: state,
          todayPlan: gymPlan,
          onOpenHomeMode: () {},
          tokens: AppThemeExtension.dark,
        ),
      ));
      await tester.pumpAndSettle();

      final convertBtnFinder = find.widgetWithText(GymBroPrimaryButton, 'تبدیل برنامه امروز');
      await tester.tap(convertBtnFinder, warnIfMissed: false);
      await tester.pump();
      await tester.pumpAndSettle();

      // Error SnackBar must be displayed
      expect(find.textContaining('خطا در تبدیل برنامه'), findsOneWidget);
      // Success SnackBar must NOT be displayed
      expect(find.textContaining('با موفقیت ایجاد شد!'), findsNothing);
      // Loading state must not be stuck
      expect(state.isConvertingHome, isFalse);
    });

    testWidgets('5. Repeated conversion taps: Disables button during conversion and prevents duplicate requests',
        (tester) async {
      final gymPlan = createGymPlan(
        id: 'gym_double_tap',
        titleFa: 'تست تپ مکرر',
        titleEn: 'Double Tap Test',
      );
      final storage = _Phase3MockStorageService(
        customPlans: [gymPlan],
        saveDelay: const Duration(milliseconds: 200),
      );
      final state = AppState(storage: storage);

      await tester.pumpWidget(buildTestApp(
        child: HomeWorkoutFallbackCard(
          state: state,
          todayPlan: gymPlan,
          onOpenHomeMode: () {},
          tokens: AppThemeExtension.dark,
        ),
      ));
      await tester.pumpAndSettle();

      final convertBtnFinder = find.widgetWithText(GymBroPrimaryButton, 'تبدیل برنامه امروز');

      // First tap starts conversion
      await tester.tap(convertBtnFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50)); // In flight

      // While converting, button is disabled / in loading state
      final inFlightButton = tester.widget<GymBroPrimaryButton>(convertBtnFinder);
      expect(inFlightButton.isLoading, isTrue);
      expect(inFlightButton.onPressed, isNull);

      // Attempt second tap during in-flight state
      await tester.tap(convertBtnFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Only one converted plan should have been inserted into state
      final convertedCount = state.workoutPlans
          .where((p) => p.titleFa.contains('تست تپ مکرر') && p.isHomeWorkout)
          .length;
      expect(convertedCount, equals(1));
    });

    testWidgets('6. Correct source plan ID: Converts the explicitly passed todayPlan, not state.workoutPlans.first',
        (tester) async {
      final planA = createGymPlan(
        id: 'plan_A',
        titleFa: 'برنامه اول A (سینه)',
        titleEn: 'Plan A',
      );
      final planB = createGymPlan(
        id: 'plan_B',
        titleFa: 'برنامه دوم B (زیربغل)',
        titleEn: 'Plan B',
      );
      // Notice: planA is first in the list
      final storage = _Phase3MockStorageService(customPlans: [planA, planB]);
      final state = AppState(storage: storage);

      // Explicitly pass planB as todayPlan to convert
      await tester.pumpWidget(buildTestApp(
        child: HomeWorkoutFallbackCard(
          state: state,
          todayPlan: planB,
          onOpenHomeMode: () {},
          tokens: AppThemeExtension.dark,
        ),
      ));
      await tester.pumpAndSettle();

      final convertBtnFinder = find.widgetWithText(GymBroPrimaryButton, 'تبدیل برنامه امروز');
      await tester.tap(convertBtnFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Converted plan must be derived from plan B, NOT plan A!
      expect(state.workoutPlans.first.titleFa, contains('برنامه دوم B (زیربغل)'));
      expect(state.workoutPlans.first.titleFa, isNot(contains('برنامه اول A (سینه)')));
    });

    testWidgets('7. Profile type safety: Strongly typed UserProfile renders greeting and level correctly',
        (tester) async {
      final typedProfile = UserProfile(
        id: 'u_test_99',
        firstName: 'فرشاد',
        lastName: 'یزدانی',
        phone: '09121112233',
        email: 'farshad@gymbro.app',
        weightKg: 84.0,
        heightCm: 185,
        targetWeightKg: 80.0,
        fitnessGoal: 'Hypertrophy',
        fitnessLevel: 'Advanced',
        level: UserLevel.pro,
        coins: 720,
        dailyFreeScans: 10,
        streakDays: 30,
        totalWorkoutsCompleted: 50,
        activeSinceMonths: 8,
      );

      await tester.pumpWidget(buildTestApp(
        child: DashboardHeader(
          profile: typedProfile,
          tokens: AppThemeExtension.dark,
          onOpenAiCoach: () {},
          onOpenProfile: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Verify strongly-typed first name greeting
      expect(find.textContaining('فرشاد عزیز'), findsOneWidget);
      // Verify strongly-typed streak and coins
      expect(find.text('۳۰ روز'), findsOneWidget);
      expect(find.text('۷۲۰ سکه'), findsOneWidget);
      // Verify strongly-typed level badge
      expect(find.text('حرفه‌ای (Pro)'), findsOneWidget);
    });

    testWidgets('8. Persian percentage formatting: Standardizes Persian numerals and standard percentage symbol (٪)',
        (tester) async {
      // 1. Direct unit verification of PersianUtils.formatPercentage
      expect(PersianUtils.formatPercentage(0), equals('۰٪'));
      expect(PersianUtils.formatPercentage(50), equals('۵۰٪'));
      expect(PersianUtils.formatPercentage(100), equals('۱۰۰٪'));
      expect(PersianUtils.formatPercentage(null), equals('۰٪'));
      expect(PersianUtils.formatPercentage(75.4), equals('۷۵٪'));

      // Check that Arabic percent sign ٪ is used and not ASCII %
      expect(PersianUtils.formatPercentage(50).contains('٪'), isTrue);
      expect(PersianUtils.formatPercentage(50).contains('%'), isFalse);
      // Check that Persian numerals are used and not Latin/English digits
      expect(PersianUtils.formatPercentage(50).contains('5'), isFalse);

      // 2. Widget verification in Dashboard
      final storage = _Phase3MockStorageService(customPlans: []);
      final state = AppState(storage: storage);
      // 1500ml of 3000ml = 50%
      await state.logWater(1500, dateString: state.todayDateString);

      await tester.pumpWidget(buildTestApp(
        child: DashboardScreen(
          state: state,
          onOpenMealScanner: () {},
          onOpenHomeMode: () {},
          onOpenWorkouts: () {},
          onStartWorkout: (_) {},
          onOpenMarketplace: () {},
          onOpenAiCoach: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Find the hydration percentage badge
      expect(find.text('۵۰٪'), findsOneWidget);
      // Monospace font style was replaced with standard typography
      final textWidget = tester.widget<Text>(find.text('۵۰٪'));
      expect(textWidget.textDirection, equals(TextDirection.rtl));
      expect(textWidget.style?.fontFamily, isNot('monospace'));
    });
  });
}
