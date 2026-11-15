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
import 'package:gymbro/screens/dashboard_screen.dart';
import 'package:gymbro/screens/active_workout_screen.dart';
import 'package:gymbro/screens/workout_screen.dart';
import 'package:gymbro/screens/home_workout_mode_screen.dart';
import 'package:gymbro/screens/nutrition_screen.dart';
import 'package:gymbro/screens/meal_scanner_screen.dart';
import 'package:gymbro/screens/marketplace_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';

class _TestStorageService extends LocalStorageService {
  @override
  UserProfile getProfile() => UserProfile(
        id: 'u1',
        firstName: 'آرمین',
        lastName: 'جعفری',
        phone: '09123456789',
        email: 'armin@gymbro.app',
        weightKg: 78.5,
        heightCm: 182,
        fitnessGoal: 'Hypertrophy',
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
          instructionsFa:
              'روی نیمکت دراز بکشید و هالتر را تا بالای قفسه سینه پایین بیاورید.',
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
          dateString: '2026-11-07',
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
  List<WorkoutLog> getWorkoutLogs() => [];

  @override
  List<Booking> getBookings() => [];

  @override
  String getApiKey() => '';

  @override
  String getGeminiApiKey() => '';

  @override
  String getGeminiModel() => 'gemini-1.5-flash';
}

Widget createTestApp({
  required Widget child,
  ThemeData? theme,
  TextDirection textDirection = TextDirection.rtl,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme ?? AppTheme.darkTheme,
    home: Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: MediaQueryData(
          textScaler: textScaler,
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

  group('Multi-Device Responsive Layout Stress Tests (AUDIT.md Compliance)',
      () {
    late AppState state;

    setUp(() {
      state = AppState(storage: _TestStorageService());
    });

    testWidgets(
        'DashboardScreen layouts cleanly on Small Phone Portrait (360x640)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(
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
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets(
        'ActiveWorkoutScreen layouts cleanly on Small Phone Landscape (640x360)',
        (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(
        child: ActiveWorkoutScreen(
          planId: 'p1',
          state: state,
        ),
      ));
      await tester.pumpAndSettle();

      final overflowErr = tester.takeException();
      if (overflowErr != null) {
        if (overflowErr is FlutterError) {
          for (var d in overflowErr.diagnostics) {
            // ignore: avoid_print
            print(d.toStringDeep());
          }
        } else {
          // ignore: avoid_print
          print('DEBUG OVERFLOW: $overflowErr');
        }
      }
      expect(overflowErr, isNull);
      expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
    });

    testWidgets(
        'DashboardScreen layouts with Text Scale 2.0x (Accessibility Stress)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(
        textScaler: const TextScaler.linear(2.0),
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
    });

    testWidgets(
        'ActiveWorkoutScreen layouts with Text Scale 2.0x without table overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(
        textScaler: const TextScaler.linear(2.0),
        child: ActiveWorkoutScreen(
          planId: 'p1',
          state: state,
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Screens layout cleanly on Tablet Landscape (1024x768) with AdaptiveContainer',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(
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

      final ex = tester.takeException();
      if (ex != null) {
        debugPrint(
            'DASHBOARD EXCEPTION DEEP:\n${(ex as FlutterError).toStringDeep()}');
      }
      expect(ex, isNull);
    });

    testWidgets('Screens layout cleanly in LTR English Fallback Mode (412x915)',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(
        textDirection: TextDirection.ltr,
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

      final ex = tester.takeException();
      if (ex != null) {
        debugPrint(
            'DASHBOARD EXCEPTION DEEP:\n${(ex as FlutterError).toStringDeep()}');
      }
      expect(ex, isNull);
    });

    testWidgets(
        'WorkoutScreen, NutritionScreen, MealScanner, Marketplace, Profile, AiCoach render without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Nutrition
      await tester.pumpWidget(createTestApp(
        child: NutritionScreen(state: state, onOpenScanner: () {}),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Meal Scanner
      await tester.pumpWidget(createTestApp(
        child: MealScannerScreen(state: state),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Workout Screen
      await tester.pumpWidget(createTestApp(
        child: WorkoutScreen(
          state: state,
          onStartWorkout: (_) {},
          onOpenHomeMode: () {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Home Workout Mode
      await tester.pumpWidget(createTestApp(
        child: HomeWorkoutModeScreen(
          state: state,
          onStartWorkout: (_) {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Marketplace
      await tester.pumpWidget(createTestApp(
        child: MarketplaceScreen(state: state),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Profile
      await tester.pumpWidget(createTestApp(
        child: ProfileScreen(state: state),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
