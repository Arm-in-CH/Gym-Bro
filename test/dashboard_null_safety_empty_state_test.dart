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
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/screens/dashboard_screen.dart';

class _CustomMockStorageService extends LocalStorageService {
  final List<WorkoutPlan> customPlans;
  final List<WorkoutLog> customLogs;
  final UserProfile? customProfile;

  _CustomMockStorageService({
    required this.customPlans,
    this.customLogs = const [],
    this.customProfile,
  });

  @override
  UserProfile getProfile() =>
      customProfile ??
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
        targetWaterMl: 3500,
      );

  @override
  List<WorkoutPlan> getWorkoutPlans() => customPlans;

  @override
  List<Exercise> getExercises() => [];

  @override
  List<WorkoutLog> getWorkoutLogs() => customLogs;
}

Widget buildTestApp({required Widget child}) {
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

  group('GYMBRO DASHBOARD — PHASE 1: Critical Null-Safety & Empty State Suite', () {
    testWidgets('1. Empty workoutPlans: Displays professional empty state without StateError',
        (tester) async {
      final storage = _CustomMockStorageService(customPlans: []);
      final state = AppState(storage: storage);
      bool onOpenWorkoutsCalled = false;

      await tester.pumpWidget(buildTestApp(
        child: DashboardScreen(
          state: state,
          onOpenMealScanner: () {},
          onOpenHomeMode: () {},
          onOpenWorkouts: () {
            onOpenWorkoutsCalled = true;
          },
          onStartWorkout: (_) {},
          onOpenMarketplace: () {},
          onOpenAiCoach: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Ensure zero crash / no StateError
      expect(tester.takeException(), isNull);

      // Verify Empty State elements
      expect(find.text('هنوز برنامه تمرینی باشگاهی ثبت نکرده‌اید'), findsOneWidget);
      expect(find.text('طراحی و انتخاب برنامه تمرینی'), findsOneWidget);
      expect(find.descendant(of: find.byType(TodayWorkoutCard), matching: find.text('بدون برنامه')), findsOneWidget);

      // Test functional CTA
      await tester.tap(find.text('طراحی و انتخاب برنامه تمرینی'));
      await tester.pump();
      expect(onOpenWorkoutsCalled, isTrue);

      // Verify the rest of the dashboard remains accessible
      expect(find.text('تقویم هفتگی تمرینات'), findsOneWidget);
      expect(find.text('ابزارهای سریع'), findsOneWidget);
    });

    testWidgets('2. Only home workout plans: Does NOT fallback to home workout, shows gym empty state',
        (tester) async {
      final homePlans = [
        WorkoutPlan(
          id: 'home_1',
          titleFa: 'تمرین خانگی وزن بدن و شکم',
          titleEn: 'Home Core & Bodyweight',
          descriptionFa: 'بدون وسیله',
          splitType: 'Full Body',
          daysPerWeek: 3,
          isHomeWorkout: true,
          exercises: [],
        ),
        WorkoutPlan(
          id: 'home_2',
          titleFa: 'تمرین کششی و موبیلیتی خانه',
          titleEn: 'Home Stretching',
          descriptionFa: 'ریکاوری در خانه',
          splitType: 'Mobility',
          daysPerWeek: 2,
          isHomeWorkout: true,
          exercises: [],
        ),
      ];

      final storage = _CustomMockStorageService(customPlans: homePlans);
      final state = AppState(storage: storage);

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

      expect(tester.takeException(), isNull);

      // Must show empty state for gym workouts, NOT silently render the home plan as today's gym plan
      expect(find.text('هنوز برنامه تمرینی باشگاهی ثبت نکرده‌اید'), findsOneWidget);
      expect(find.text('طراحی و انتخاب برنامه تمرینی'), findsOneWidget);
      expect(find.text('تمرین خانگی وزن بدن و شکم'), findsNothing);
    });

    testWidgets('3. One valid gym workout plan: Renders plan correctly with start CTA',
        (tester) async {
      final gymPlan = WorkoutPlan(
        id: 'gym_1',
        titleFa: 'سینه و جلو بازو انفجاری',
        titleEn: 'Chest & Biceps Hypertrophy',
        descriptionFa: 'تمرین سنگین باشگاه',
        splitType: 'PPL',
        daysPerWeek: 4,
        difficulty: 'پیشرفته',
        isHomeWorkout: false,
        exercises: [
          WorkoutPlanExercise(
            id: 'e1',
            planId: 'gym_1',
            exerciseId: 'ex_bench',
            dayOfWeek: 1,
            dayNameFa: 'شنبه',
            orderInDay: 1,
            targetSets: 4,
            targetReps: 8,
            targetWeightKg: 80.0,
          ),
        ],
      );

      final storage = _CustomMockStorageService(customPlans: [gymPlan]);
      final state = AppState(storage: storage);
      String? startedPlanId;

      await tester.pumpWidget(buildTestApp(
        child: DashboardScreen(
          state: state,
          onOpenMealScanner: () {},
          onOpenHomeMode: () {},
          onOpenWorkouts: () {},
          onStartWorkout: (planId) {
            startedPlanId = planId;
          },
          onOpenMarketplace: () {},
          onOpenAiCoach: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify Gym Plan renders
      expect(find.text('سینه و جلو بازو انفجاری'), findsOneWidget);
      expect(find.text('هنوز برنامه تمرینی باشگاهی ثبت نکرده‌اید'), findsNothing);

      // Tap CTA to start workout
      final ctaFinder = find.text('رفتن به تمرین (ورود به جلسه زنده)');
      expect(ctaFinder, findsOneWidget);
      await tester.tap(ctaFinder);
      await tester.pump();
      expect(startedPlanId, equals('gym_1'));
    });

    testWidgets('4. Multiple gym workout plans: Rotation logic selects safely without StateError',
        (tester) async {
      final gymPlans = [
        WorkoutPlan(
          id: 'plan_push',
          titleFa: 'روز هل دادنی تخصصی سینه (Push)',
          titleEn: 'Push Day A',
          descriptionFa: 'تمرین سینه و سرشانه',
          splitType: 'PPL',
          daysPerWeek: 4,
          isHomeWorkout: false,
        ),
        WorkoutPlan(
          id: 'plan_pull',
          titleFa: 'روز کشیدنی زیربغل و پشت (Pull)',
          titleEn: 'Pull Day A',
          descriptionFa: 'تمرین زیربغل و جلو بازو',
          splitType: 'PPL',
          daysPerWeek: 4,
          isHomeWorkout: false,
        ),
        WorkoutPlan(
          id: 'plan_legs',
          titleFa: 'روز سنگین پا و شکم (Legs)',
          titleEn: 'Legs Day A',
          descriptionFa: 'تمرین چهارسر و ساق',
          splitType: 'PPL',
          daysPerWeek: 4,
          isHomeWorkout: false,
        ),
      ];

      // Previous workout was Push
      final logs = [
        WorkoutLog(
          id: 'log_1',
          planId: 'plan_push',
          planTitle: 'روز هل دادنی تخصصی سینه (Push)',
          date: '2026-11-13',
          durationMinutes: 50,
          totalVolumeKg: 2400,
          completedSets: 8,
          timestamp: 1000,
        ),
      ];

      final storage = _CustomMockStorageService(customPlans: gymPlans, customLogs: logs);
      final state = AppState(storage: storage);

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

      expect(tester.takeException(), isNull);

      // Next in rotation after Push must be Pull
      expect(find.text('روز کشیدنی زیربغل و پشت (Pull)'), findsOneWidget);
    });

    testWidgets('5. Empty exercise lists: Renders 0 movement badges without RangeError',
        (tester) async {
      final planWithNoExercises = WorkoutPlan(
        id: 'gym_empty_ex',
        titleFa: 'برنامه بدون حرکت ثبت‌شده',
        titleEn: 'Plan without exercises',
        descriptionFa: 'برنامه بدون تمرین',
        splitType: 'Upper/Lower',
        daysPerWeek: 3,
        difficulty: 'مبتدی',
        isHomeWorkout: false,
        exercises: [],
      );

      final storage = _CustomMockStorageService(customPlans: [planWithNoExercises]);
      final state = AppState(storage: storage);

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

      expect(tester.takeException(), isNull);
      expect(find.text('برنامه بدون حرکت ثبت‌شده'), findsOneWidget);
      expect(find.text('۰ حرکت'), findsOneWidget);
    });

    testWidgets('6. Incomplete user profile data: Graceful fallback without null crashes',
        (tester) async {
      final emptyProfile = UserProfile(
        id: 'u_empty',
        firstName: '',
        lastName: '',
        phone: '',
        email: '',
        weightKg: 0,
        heightCm: 0,
        fitnessGoal: '',
        fitnessLevel: '',
        level: UserLevel.member,
        coins: 0,
        dailyFreeScans: 0,
        streakDays: 0,
        totalWorkoutsCompleted: 0,
        activeSinceMonths: 0,
      );

      final storage = _CustomMockStorageService(
        customPlans: [],
        customProfile: emptyProfile,
      );
      final state = AppState(storage: storage);

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

      expect(tester.takeException(), isNull);

      // Verify friendly generic fallback greeting when firstName is empty
      expect(find.textContaining('ورزشکار عزیز'), findsOneWidget);
      expect(find.text('۰ روز'), findsOneWidget);
      expect(find.text('۰ سکه'), findsOneWidget);
    });
  });
}
