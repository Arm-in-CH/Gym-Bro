import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/theme/app_tokens.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/screens/dashboard_screen.dart';

class _Phase2MockStorageService extends LocalStorageService {
  final List<WorkoutPlan> customPlans;
  final List<WorkoutLog> customLogs;

  _Phase2MockStorageService({
    required this.customPlans,
    this.customLogs = const [],
  });

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

WorkoutPlan createSampleGymPlan({
  required String id,
  required String titleFa,
  required int daysPerWeek,
  List<WorkoutPlanExercise>? exercises,
}) {
  return WorkoutPlan(
    id: id,
    titleFa: titleFa,
    titleEn: 'Sample Gym Plan',
    descriptionFa: 'توضیحات تمرین باشگاه',
    splitType: 'Custom Split',
    isHomeWorkout: false,
    daysPerWeek: daysPerWeek,
    difficulty: 'متوسط',
    exercises: exercises ??
        [
          WorkoutPlanExercise(
            id: 'ex_1',
            planId: id,
            exerciseId: 'bench_press',
            dayOfWeek: 1,
            dayNameFa: 'برنامه ۱: سینه و بازو',
            orderInDay: 1,
            targetSets: 3,
            targetReps: 10,
            targetWeightKg: 70,
            restSeconds: 60,
          ),
        ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GYMBRO DASHBOARD — PHASE 2: Real Data Integrity Suite', () {
    testWidgets('1. daysPerWeek = 2: Displays actual frequency in weekly strip and workout card',
        (tester) async {
      final plan = createSampleGymPlan(
        id: 'plan_2day',
        titleFa: 'برنامه تخصصی ۲ روزه',
        daysPerWeek: 2,
      );
      final storage = _Phase2MockStorageService(customPlans: [plan]);
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
      // Weekly strip frequency badge must reflect daysPerWeek = 2
      expect(find.text('۲ جلسه در هفته'), findsOneWidget);
      // Workout card frequency subtitle must reflect daysPerWeek = 2
      expect(find.textContaining('۲ روز در هفته'), findsOneWidget);
      // Hardcoded '۴ جلسه در هفته' must NOT be present
      expect(find.text('۴ جلسه در هفته'), findsNothing);
    });

    testWidgets('2. daysPerWeek = 3: Displays actual frequency in weekly strip and workout card',
        (tester) async {
      final plan = createSampleGymPlan(
        id: 'plan_3day',
        titleFa: 'برنامه ۳ روزه هایپرتروفی',
        daysPerWeek: 3,
      );
      final storage = _Phase2MockStorageService(customPlans: [plan]);
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

      expect(find.text('۳ جلسه در هفته'), findsOneWidget);
      expect(find.textContaining('۳ روز در هفته'), findsOneWidget);
      expect(find.text('۴ جلسه در هفته'), findsNothing);
    });

    testWidgets('3. daysPerWeek = 4: Displays actual frequency in weekly strip and workout card',
        (tester) async {
      final plan = createSampleGymPlan(
        id: 'plan_4day',
        titleFa: 'برنامه ۴ روزه قدرتی',
        daysPerWeek: 4,
      );
      final storage = _Phase2MockStorageService(customPlans: [plan]);
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

      expect(find.text('۴ جلسه در هفته'), findsOneWidget);
      expect(find.textContaining('۴ روز در هفته'), findsOneWidget);
    });

    testWidgets('4. daysPerWeek = 6: Displays actual frequency in weekly strip and workout card',
        (tester) async {
      final plan = createSampleGymPlan(
        id: 'plan_6day',
        titleFa: 'برنامه ۶ روزه حرفه‌ای (PPL)',
        daysPerWeek: 6,
      );
      final storage = _Phase2MockStorageService(customPlans: [plan]);
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

      expect(find.text('۶ جلسه در هفته'), findsOneWidget);
      expect(find.textContaining('۶ روز در هفته'), findsOneWidget);
      expect(find.text('۴ جلسه در هفته'), findsNothing);
    });

    testWidgets('5. Missing scheduling information: Renders neutral calendar days without fabricating training days',
        (tester) async {
      // Plan with 4 daysPerWeek, but exercises do NOT specify weekday names and no workout has been logged
      final plan = createSampleGymPlan(
        id: 'plan_no_schedule',
        titleFa: 'برنامه بدون تقویم زمانی صریح',
        daysPerWeek: 4,
        exercises: [
          WorkoutPlanExercise(
            id: 'e1',
            planId: 'plan_no_schedule',
            exerciseId: 'squat',
            dayOfWeek: 1,
            dayNameFa: 'برنامه ۱: پا و شکم',
            orderInDay: 1,
            targetSets: 3,
            targetReps: 10,
            targetWeightKg: 80,
            restSeconds: 60,
          ),
        ],
      );
      final storage = _Phase2MockStorageService(
        customPlans: [plan],
        customLogs: [], // No logs
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

      // Find all dots inside WeeklyWorkoutStrip
      final stripFinder = find.byType(WeeklyWorkoutStrip);
      expect(stripFinder, findsOneWidget);

      // Verify that no fabricated green dots are visible for missing scheduling
      final dotContainers = tester.widgetList<Container>(
        find.descendant(
          of: stripFinder,
          matching: find.byType(Container),
        ),
      ).where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration && dec.shape == BoxShape.circle) {
          return dec.color != null && dec.color != Colors.transparent;
        }
        return false;
      }).toList();

      // Because no workout log exists and no explicit weekday names exist, no day dots should be fabricated
      expect(dotContainers.length, equals(0));
    });

    testWidgets('6. No gym workout plan: Displays "بدون برنامه" and empty state without crashing',
        (tester) async {
      final storage = _Phase2MockStorageService(customPlans: []);
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
      // Strip must show 'بدون برنامه'
      expect(find.text('بدون برنامه'), findsNWidgets(2)); // Once in calendar badge, once in hero card badge
      expect(find.text('هنوز برنامه تمرینی باشگاهی ثبت نکرده‌اید'), findsOneWidget);
    });

    testWidgets('7. Empty exercise list: Displays "۰ حرکت" and does not invent duration or calories',
        (tester) async {
      final plan = WorkoutPlan(
        id: 'plan_empty_ex',
        titleFa: 'برنامه بدون تمرین',
        titleEn: 'Empty Plan',
        descriptionFa: '',
        splitType: 'Custom',
        daysPerWeek: 3,
        isHomeWorkout: false,
        exercises: [], // Empty list
      );
      final storage = _Phase2MockStorageService(
        customPlans: [plan],
        customLogs: [],
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
      expect(find.text('۰ حرکت'), findsOneWidget);
      // Must not fabricate '۴۵ دقیقه'
      expect(find.text('۴۵ دقیقه'), findsNothing);
      // Must not fabricate '۳۵۰ کیلوکالری'
      expect(find.text('۳۵۰ کیلوکالری'), findsNothing);
    });

    testWidgets('8. Missing duration information: Omits duration metric when no logs and no exercises exist',
        (tester) async {
      final plan = WorkoutPlan(
        id: 'plan_no_duration',
        titleFa: 'برنامه تست بدون مدت',
        titleEn: 'No Duration Plan',
        descriptionFa: '',
        splitType: 'Full Body',
        daysPerWeek: 2,
        isHomeWorkout: false,
        exercises: [],
      );
      final storage = _Phase2MockStorageService(
        customPlans: [plan],
        customLogs: [],
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

      expect(find.byIcon(Icons.timer_outlined), findsNothing);
      expect(find.text('۴۵ دقیقه'), findsNothing);
    });

    testWidgets('9. Missing calorie calculation: Never displays fabricated calorie badge in hero workout card',
        (tester) async {
      final plan = createSampleGymPlan(
        id: 'plan_cal_test',
        titleFa: 'برنامه تست کالری',
        daysPerWeek: 3,
      );
      final storage = _Phase2MockStorageService(customPlans: [plan]);
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

      // Verify that no fabricated calorie-burn value is displayed in hero workout card
      expect(find.descendant(of: find.byType(TodayWorkoutCard), matching: find.text('۳۵۰ کیلوکالری')), findsNothing);
      expect(find.descendant(of: find.byType(TodayWorkoutCard), matching: find.textContaining('کیلوکالری')), findsNothing);
      expect(find.descendant(of: find.byType(TodayWorkoutCard), matching: find.byIcon(Icons.local_fire_department_outlined)), findsNothing);
    });

    testWidgets('10. Real stored duration: Displays real duration from previous session logs',
        (tester) async {
      final plan = createSampleGymPlan(
        id: 'plan_logged',
        titleFa: 'برنامه با سابقه تمرین',
        daysPerWeek: 3,
      );
      final pastLog = WorkoutLog(
        id: 'wlog_1',
        planId: 'plan_logged',
        planTitle: 'برنامه با سابقه تمرین',
        date: '2026-11-10',
        durationMinutes: 52, // Real recorded duration
        totalVolumeKg: 1250.0,
        completedSets: 12,
        isHomeWorkout: false,
        timestamp: DateTime(2026, 11, 10, 18, 0).millisecondsSinceEpoch,
      );
      final storage = _Phase2MockStorageService(
        customPlans: [plan],
        customLogs: [pastLog],
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

      // Must display the real stored 52 minutes from the session history
      expect(find.text('۵۲ دقیقه'), findsOneWidget);
      expect(find.text('۴۵ دقیقه'), findsNothing);
    });

    testWidgets('11. Transparent derived duration: Displays calculated estimate when no logs exist',
        (tester) async {
      // 2 exercises * 3 sets = 6 sets.
      // Exercise 1: 10 reps * 3s + 60s rest = 90s per set * 3 = 270s
      // Exercise 2: 10 reps * 3s + 60s rest = 90s per set * 3 = 270s
      // Total = 540 seconds = 9 minutes
      final plan = createSampleGymPlan(
        id: 'plan_derived',
        titleFa: 'برنامه محاسبه شفاف مدت',
        daysPerWeek: 3,
        exercises: [
          WorkoutPlanExercise(
            id: 'ex_a',
            planId: 'plan_derived',
            exerciseId: 'e1',
            dayOfWeek: 1,
            dayNameFa: 'حرکت ۱',
            orderInDay: 1,
            targetSets: 3,
            targetReps: 10,
            targetWeightKg: 50,
            restSeconds: 60,
          ),
          WorkoutPlanExercise(
            id: 'ex_b',
            planId: 'plan_derived',
            exerciseId: 'e2',
            dayOfWeek: 1,
            dayNameFa: 'حرکت ۲',
            orderInDay: 2,
            targetSets: 3,
            targetReps: 10,
            targetWeightKg: 60,
            restSeconds: 60,
          ),
        ],
      );
      final storage = _Phase2MockStorageService(
        customPlans: [plan],
        customLogs: [], // No history
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

      // Transparent derivation must be explicitly labeled as estimate
      expect(find.text('تخمین ۹ دقیقه'), findsOneWidget);
      expect(find.text('۴۵ دقیقه'), findsNothing);
    });

    testWidgets('12. Week boundaries and month transitions: Handles month transitions smoothly in WeeklyWorkoutStrip',
        (tester) async {
      final plan = createSampleGymPlan(
        id: 'plan_boundary',
        titleFa: 'برنامه تست تقویم',
        daysPerWeek: 4,
      );
      final storage = _Phase2MockStorageService(customPlans: [plan]);
      final state = AppState(storage: storage);

      // Inject Monday, March 2, 2026 (Saturday of this week was February 28)
      final transitionDate = DateTime(2026, 3, 2);

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: WeeklyWorkoutStrip(
            tokens: AppThemeExtension.dark,
            selectedPlan: plan,
            state: state,
            currentDate: transitionDate,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Saturday must be 28 (Feb 28)
      expect(find.text('۲۸'), findsOneWidget);
      // Sunday must be 1 (March 1)
      expect(find.text('۱'), findsOneWidget);
      // Monday must be 2 (March 2)
      expect(find.text('۲'), findsOneWidget);
      // Wednesday must be 4 (March 4)
      expect(find.text('۴'), findsOneWidget);
    });
  });
}
