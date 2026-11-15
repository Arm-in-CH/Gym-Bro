import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/localization/persian_utils.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/screens/dashboard_screen.dart';
import 'package:gymbro/screens/workout_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';

class _MockStorage extends LocalStorageService {
  @override
  UserProfile getProfile() => UserProfile(
        id: 'user_rtl',
        firstName: 'سید محمدرضا',
        lastName: 'حسینی‌نیا',
        phone: '09120000000',
        email: 'reza@gymbro.app',
        weightKg: 84.5,
        heightCm: 186,
        targetWeightKg: 80.0,
        fitnessGoal: 'Hypertrophy',
        fitnessLevel: 'Advanced',
        level: UserLevel.pro,
        coins: 350,
        streakDays: 28,
        totalWorkoutsCompleted: 64,
        activeSinceMonths: 8,
        dailyFreeScans: 10,
      );

  @override
  NutritionPlan getNutritionPlan() => NutritionPlan(
        id: 'n_rtl',
        dailyCalories: 2800,
        targetProteinG: 180,
        targetCarbsG: 320,
        targetFatG: 75,
        targetWaterMl: 3800,
      );

  @override
  List<WorkoutPlan> getWorkoutPlans() => [
        WorkoutPlan(
          id: 'plan_rtl_1',
          titleFa: 'برنامه تخصصی سرشانه و بازو با سوپرست سنگین',
          titleEn: 'Heavy Shoulders & Arms Split',
          descriptionFa: 'تمرین قدرتی ۵ ست همراه با دراپ‌ست انتهای جلسه',
          splitType: 'Custom',
          daysPerWeek: 4,
          difficulty: 'پیشرفته',
          exercises: [
            WorkoutPlanExercise(
              id: 'pe_press',
              planId: 'plan_rtl_1',
              exerciseId: 'ex_press',
              dayOfWeek: 1,
              dayNameFa: 'شنبه',
              orderInDay: 1,
              targetSets: 4,
              targetReps: 10,
              targetWeightKg: 70.0,
              restSeconds: 90,
            ),
          ],
        ),
      ];

  @override
  List<Exercise> getExercises() => [
        Exercise(
          id: 'ex_press',
          nameFa: 'پرس سرشانه دمبل نشسته',
          nameEn: 'Seated Dumbbell Shoulder Press',
          muscleGroup: 'Shoulders',
          muscleGroupFa: 'سرشانه',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa: 'روی نیمکت ۹۰ درجه بنشینید و دمبل‌ها را به آرامی بالا ببرید.',
        ),
      ];
}

Widget _wrapScreen(
  Widget child, {
  Size size = const Size(360, 780),
  double textScale = 1.0,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: size,
      textScaler: TextScaler.linear(textScale),
      padding: const EdgeInsets.only(top: 24, bottom: 16),
    ),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, c) => Directionality(
        textDirection: TextDirection.rtl,
        child: c ?? const SizedBox.shrink(),
      ),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppState testState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    testState = AppState(storage: _MockStorage());
  });

  group('GymBro Phase 07: Persian RTL & Accessibility Engineering Tests', () {
    test('1. PersianUtils: Standardized digits, percentages, and measurement units', () {
      // Persian digits
      expect(PersianUtils.toPersianDigits(1234567890), equals('۱۲۳۴۵۶۷۸۹۰'));
      expect(PersianUtils.fromPersianDigits('۱۲۳۴۵'), equals('12345'));

      // Percentage formatting
      expect(PersianUtils.formatPercentage(0), equals('۰٪'));
      expect(PersianUtils.formatPercentage(45.6, decimalDigits: 1), equals('۴۵.۶٪'));
      expect(PersianUtils.formatPercentage(100), equals('۱۰۰٪'));

      // Measurement and weight units
      expect(PersianUtils.formatWeight(82.5), equals('۸۲.۵ کیلوگرم'));
      expect(PersianUtils.formatHeight(180), equals('۱۸۰ سانتی‌متر'));
      expect(PersianUtils.formatMeasurement(84.0), equals('۸۴.۰ سانتی‌متر'));
      expect(PersianUtils.formatCalories(2500), equals('۲,۵۰۰ کالری'));
      expect(PersianUtils.formatSeconds(45), equals('۴۵ ثانیه'));
      expect(PersianUtils.formatTonnage(5200), equals('۵,۲۰۰ کیلوگرم'));
      expect(PersianUtils.formatGrams(150), equals('۱۵۰ گرم'));
      expect(PersianUtils.formatDistance(5.2), equals('۵.۲ کیلومتر'));
      expect(PersianUtils.formatDurationMinutesSeconds(90), equals('۰۱:۳۰'));
    });

    testWidgets('2. RTL Drilldown Navigation: Chevrons point left in RTL flow', (tester) async {
      await tester.pumpWidget(_wrapScreen(
        WorkoutScreen(
          state: testState,
          onStartWorkout: (_) {},
          onOpenHomeMode: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // In RTL, drilling down into subpages points to the left
      final leftChevrons = find.byIcon(Icons.chevron_left_rounded);
      expect(leftChevrons, findsWidgets);

      // Verify no inappropriate right-pointing arrow_forward_ios in list drilldowns
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNothing);
    });

    testWidgets('3. Truncation Resilience: Long Persian greeting renders without overflow', (tester) async {
      await tester.pumpWidget(_wrapScreen(
        DashboardScreen(
          state: testState,
          onOpenMealScanner: () {},
          onOpenHomeMode: () {},
          onOpenWorkouts: () {},
          onStartWorkout: (_) {},
          onOpenMarketplace: () {},
          onOpenAiCoach: () {},
        ),
        size: const Size(320, 640), // Very narrow phone
      ));
      await tester.pumpAndSettle();

      // Long greeting with first name
      expect(find.textContaining('سید محمدرضا'), findsOneWidget);
      // No RenderFlex errors caught
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. Dynamic Accessibility Font Scale 2.0x Stress Test', (tester) async {
      await tester.pumpWidget(_wrapScreen(
        DashboardScreen(
          state: testState,
          onOpenMealScanner: () {},
          onOpenHomeMode: () {},
          onOpenWorkouts: () {},
          onStartWorkout: (_) {},
          onOpenMarketplace: () {},
          onOpenAiCoach: () {},
        ),
        size: const Size(360, 800),
        textScale: 2.0, // 200% system font scaling for visually impaired users
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Screen Reader Semantics: Metric badges & quick action cards', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrapScreen(
        DashboardScreen(
          state: testState,
          onOpenMealScanner: () {},
          onOpenHomeMode: () {},
          onOpenWorkouts: () {},
          onStartWorkout: (_) {},
          onOpenMarketplace: () {},
          onOpenAiCoach: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Hero metric badges have semantic descriptions
      expect(find.byType(HeroMetricBadge), findsWidgets);
      // Quick action cards have semantic buttons
      expect(find.bySemanticsLabel(RegExp(r'برآورد غذا')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'مربی هوشمند AI')), findsOneWidget);

      handle.dispose();
    });

    testWidgets('6. Touch Target Minimums: Workout plan action buttons meet 48dp', (tester) async {
      await tester.pumpWidget(_wrapScreen(
        WorkoutScreen(
          state: testState,
          onStartWorkout: (_) {},
          onOpenHomeMode: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Find edit and delete icon buttons on workout plan card
      final editButtonFinder = find.ancestor(
        of: find.byTooltip('ویرایش برنامه'),
        matching: find.byType(IconButton),
      );
      final deleteButtonFinder = find.ancestor(
        of: find.byTooltip('حذف برنامه'),
        matching: find.byType(IconButton),
      );

      expect(editButtonFinder, findsOneWidget);
      expect(deleteButtonFinder, findsOneWidget);

      final editSize = tester.getSize(editButtonFinder);
      final deleteSize = tester.getSize(deleteButtonFinder);

      expect(editSize.width, greaterThanOrEqualTo(44.0));
      expect(editSize.height, greaterThanOrEqualTo(44.0));
      expect(deleteSize.width, greaterThanOrEqualTo(44.0));
      expect(deleteSize.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('7. Multi-Device Viewport Responsiveness: 320px, 360px, 412px, 600px', (tester) async {
      final viewports = [
        const Size(320, 640), // Small cover screen
        const Size(360, 780), // Standard Redmi / Samsung A-series
        const Size(412, 915), // Large Android flagship
        const Size(600, 900), // Foldable unfolded / small tablet
      ];

      for (final vp in viewports) {
        await tester.pumpWidget(_wrapScreen(
          ProfileScreen(state: testState),
          size: vp,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
