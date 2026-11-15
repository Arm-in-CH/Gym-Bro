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
import 'package:gymbro/screens/main_navigation_screen.dart';

class _LandingTestStorageService extends LocalStorageService {
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
          instructionsFa:
              'روی نیمکت دراز بکشید و هالتر را تا بالای قفسه سینه پایین بیاورید.',
        ),
      ];

  @override
  List<WorkoutLog> getWorkoutLogs() => [];
}

Widget buildTestLandingApp({
  required Widget child,
  required Size screenSize,
  required EdgeInsets padding,
  EdgeInsets? viewPadding,
  double devicePixelRatio = 3.0,
  TextDirection textDirection = TextDirection.rtl,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: MediaQueryData(
          size: screenSize,
          devicePixelRatio: devicePixelRatio,
          padding: padding,
          viewPadding: viewPadding ?? padding,
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

  group('Landing Screen: Camera Cutout & Dynamic Island Safe Area Tests', () {
    late AppState state;

    setUp(() {
      state = AppState(storage: _LandingTestStorageService());
    });

    testWidgets(
        'Scenario 1: iPhone 15/16 Pro Dynamic Island (top: 59px) — Zero Overlap',
        (tester) async {
      const screenSize = Size(393, 852);
      const topInset = 59.0;
      const islandRect = Rect.fromLTWH((393 - 125) / 2, 11, 125, 37);

      tester.view.physicalSize = Size(screenSize.width * 3.0, screenSize.height * 3.0);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestLandingApp(
        screenSize: screenSize,
        padding: const EdgeInsets.only(top: topInset),
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

      // Find the landing greeting header
      final greetingFinder = find.textContaining('عزیز');
      expect(greetingFinder, findsOneWidget);

      final greetingTop = tester.getTopLeft(greetingFinder).dy;
      // Must be strictly below the topInset (59.0) plus 8dp margin => >= 67.0
      expect(greetingTop, greaterThanOrEqualTo(topInset + 8.0));
      // Must not intersect with the Dynamic Island hardware bounding box
      expect(greetingTop, greaterThan(islandRect.bottom));

      // Verify the App Logo / Avatar position
      final logoFinder = find.bySemanticsLabel('لوگوی برنامه جیم‌برو - رفتن به پروفایل کاربری');
      expect(logoFinder, findsOneWidget);
      final logoRect = tester.getRect(logoFinder);
      expect(logoRect.top, greaterThanOrEqualTo(topInset + 8.0));
      expect(logoRect.overlaps(islandRect), isFalse);

      // Verify streak and coins pills
      final streakFinder = find.bySemanticsLabel(RegExp(r'روزهای استمرار'));
      expect(streakFinder, findsOneWidget);
      final streakRect = tester.getRect(streakFinder);
      expect(streakRect.top, greaterThanOrEqualTo(topInset + 8.0));
      expect(streakRect.overlaps(islandRect), isFalse);
    });

    testWidgets(
        'Scenario 2: iPhone 13/14 Traditional Notch (top: 47px) — Zero Overlap',
        (tester) async {
      const screenSize = Size(390, 844);
      const topInset = 47.0;
      const notchRect = Rect.fromLTWH((390 - 160) / 2, 0, 160, 34);

      tester.view.physicalSize = Size(screenSize.width * 3.0, screenSize.height * 3.0);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestLandingApp(
        screenSize: screenSize,
        padding: const EdgeInsets.only(top: topInset),
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

      final greetingFinder = find.textContaining('عزیز');
      expect(greetingFinder, findsOneWidget);
      final greetingTop = tester.getTopLeft(greetingFinder).dy;
      expect(greetingTop, greaterThanOrEqualTo(topInset + 8.0));
      expect(greetingTop, greaterThan(notchRect.bottom));

      final logoFinder = find.bySemanticsLabel('لوگوی برنامه جیم‌برو - رفتن به پروفایل کاربری');
      expect(logoFinder, findsOneWidget);
      final logoRect = tester.getRect(logoFinder);
      expect(logoRect.top, greaterThanOrEqualTo(topInset + 8.0));
      expect(logoRect.overlaps(notchRect), isFalse);
    });

    testWidgets(
        'Scenario 3: Android Centered Punch-Hole Camera (top: 36px) — Zero Overlap',
        (tester) async {
      const screenSize = Size(412, 915);
      const topInset = 36.0;
      const punchHoleRect = Rect.fromLTWH((412 - 24) / 2, 8, 24, 24);

      tester.view.physicalSize = Size(screenSize.width * 2.6, screenSize.height * 2.6);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestLandingApp(
        screenSize: screenSize,
        padding: const EdgeInsets.only(top: topInset),
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

      final greetingFinder = find.textContaining('عزیز');
      final greetingTop = tester.getTopLeft(greetingFinder).dy;
      expect(greetingTop, greaterThanOrEqualTo(topInset + 8.0));
      expect(greetingTop, greaterThan(punchHoleRect.bottom));

      final logoFinder = find.bySemanticsLabel('لوگوی برنامه جیم‌برو - رفتن به پروفایل کاربری');
      final logoRect = tester.getRect(logoFinder);
      expect(logoRect.top, greaterThanOrEqualTo(topInset + 8.0));
      expect(logoRect.overlaps(punchHoleRect), isFalse);
    });

    testWidgets(
        'Scenario 4: Android Standard Status Bar (top: 24px) — Clean Athletic Spacing',
        (tester) async {
      const screenSize = Size(392, 816);
      const topInset = 24.0;

      tester.view.physicalSize = Size(screenSize.width * 2.0, screenSize.height * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestLandingApp(
        screenSize: screenSize,
        padding: const EdgeInsets.only(top: topInset),
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

      final greetingFinder = find.textContaining('عزیز');
      final greetingTop = tester.getTopLeft(greetingFinder).dy;
      // 24.0 + 8.0 = 32.0 minimum
      expect(greetingTop, greaterThanOrEqualTo(topInset + 8.0));
    });

    testWidgets(
        'Scenario 5: Device Without Camera Cutout (top: 0px) — Standard Screen Margin',
        (tester) async {
      const screenSize = Size(800, 1280);
      const topInset = 0.0;

      tester.view.physicalSize = Size(screenSize.width * 1.5, screenSize.height * 1.5);
      tester.view.devicePixelRatio = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestLandingApp(
        screenSize: screenSize,
        padding: const EdgeInsets.only(top: topInset),
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

      // On a 0-cutout screen, top padding must equal AppSpacing.base (16.0) + row vertical alignment offset (2.5)
      final logoFinder = find.bySemanticsLabel('لوگوی برنامه جیم‌برو - رفتن به پروفایل کاربری');
      final logoTop = tester.getTopLeft(logoFinder).dy;
      expect(logoTop, equals(18.5));
    });

    testWidgets(
        'Scenario 6: Small Narrow Screen (320x640) — Responsive Stacking without Overlap',
        (tester) async {
      const screenSize = Size(320, 640);
      const topInset = 32.0;

      tester.view.physicalSize = Size(screenSize.width * 2.0, screenSize.height * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestLandingApp(
        screenSize: screenSize,
        padding: const EdgeInsets.only(top: topInset),
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

      final greetingFinder = find.textContaining('عزیز');
      expect(greetingFinder, findsOneWidget);
      final greetingTop = tester.getTopLeft(greetingFinder).dy;
      expect(greetingTop, greaterThanOrEqualTo(topInset + 8.0));
    });

    testWidgets(
        'Scenario 7: Full MainNavigationScreen Host with Landing Tab 0',
        (tester) async {
      const screenSize = Size(393, 852);
      const topInset = 59.0;

      tester.view.physicalSize = Size(screenSize.width * 3.0, screenSize.height * 3.0);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestLandingApp(
        screenSize: screenSize,
        padding: const EdgeInsets.only(top: topInset),
        child: MainNavigationScreen(state: state),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify Landing Screen is active at Tab 0
      final greetingFinder = find.textContaining('عزیز');
      expect(greetingFinder, findsOneWidget);
      final greetingTop = tester.getTopLeft(greetingFinder).dy;
      expect(greetingTop, greaterThanOrEqualTo(topInset + 8.0));
    });
  });
}
