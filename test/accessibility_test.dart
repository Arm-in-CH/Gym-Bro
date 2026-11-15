import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'package:gymbro/screens/marketplace_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';
import 'package:gymbro/widgets/cabbage_mascot_loader.dart';
import 'package:gymbro/widgets/calorie_budget_card.dart';
import 'package:gymbro/widgets/rest_timer_dialog.dart';
import 'package:gymbro/widgets/one_rm_calculator_dialog.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';

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
        level: UserLevel.pro,
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
          name: 'استاد سامان سعیدی',
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
  List<Booking> getBookings() => [
        Booking(
          id: 'b1',
          trainerId: 't1',
          trainerName: 'استاد سامان سعیدی',
          sessionType: 'مشاوره حضوری',
          date: '۱۴۰۵/۰۸/۲۰',
          timeSlot: '۱۸:۰۰ - ۱۹:۰۰',
          priceToman: 950000,
          commissionToman: 95000,
          status: BookingStatus.confirmed,
        ),
      ];

  @override
  String getApiKey() => '';

  @override
  String getGeminiApiKey() => '';

  @override
  String getGeminiModel() => 'gemini-1.5-flash';
}

Widget _wrapForAccessibility(
  Widget child, {
  bool disableAnimations = false,
  double textScale = 1.0,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: const Size(412, 915),
      textScaler: TextScaler.linear(textScale),
      disableAnimations: disableAnimations,
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    testState = AppState(storage: _TestStorageService());
  });

  group('WCAG 2.2 AA Accessibility & Guidelines Testing', () {
    testWidgets(
        'CalorieBudgetCard meets WCAG 2.2 AA Tap Target & Label Guidelines',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapForAccessibility(
          const SingleChildScrollView(
            child: CalorieBudgetCard(
              consumedCalories: 2100,
              targetCalories: 2800,
              consumedProtein: 160,
              targetProtein: 190,
              consumedCarbs: 240,
              targetCarbs: 320,
              consumedFat: 55,
              targetFat: 70,
              isOverLimit: false,
              overdraftCalories: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
      await WorkoutTimerService().cancel();
    });

    testWidgets(
        'ActiveWorkoutScreen set row controls satisfy tap targets and semantics',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapForAccessibility(
          ActiveWorkoutScreen(
            state: testState,
            planId: 'p1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check day selector tabs and form inputs have valid semantics
      expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
      expect(find.text('برنامه ۱: پا و شکم'), findsOneWidget);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
      await WorkoutTimerService().cancel();
    });

    testWidgets(
        'RestTimerDialog meets tap target & close button labeling guidelines',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapForAccessibility(
          const RestTimerDialog(initialSeconds: 45),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
      await WorkoutTimerService().cancel();
    });

    testWidgets(
        'OneRmCalculatorDialog inputs have explicit labels and meet guidelines',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapForAccessibility(
          const OneRmCalculatorDialog(),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
      await WorkoutTimerService().cancel();
    });

    testWidgets(
        'CabbageMascotLoader respects reduced motion (disableAnimations)',
        (tester) async {
      // 1. With normal motion
      await tester.pumpWidget(
        _wrapForAccessibility(
          const CabbageMascotLoader(),
          disableAnimations: false,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 2. With reduced motion
      await tester.pumpWidget(
        _wrapForAccessibility(
          const CabbageMascotLoader(),
          disableAnimations: true,
        ),
      );
      await tester.pumpAndSettle();

      // Should render without exception or infinite ticker loop
      expect(find.byType(CabbageMascotLoader), findsOneWidget);
    });

    testWidgets(
        'Profile tier pills convey active tier through text and shape, not color alone',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapForAccessibility(
          ProfileScreen(state: testState),
        ),
      );
      await tester.pumpAndSettle();

      // Active level is Pro (حرفه‌ای)
      expect(find.text('حرفه‌ای'), findsWidgets);
      // Icons.check is present next to active tier
      expect(find.byIcon(Icons.check), findsWidgets);

      handle.dispose();
    });

    testWidgets(
        'MarketplaceScreen booking status uses distinct icons and text, not color alone',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapForAccessibility(
          MarketplaceScreen(state: testState),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to bookings tab
      await tester.tap(find.text('رزروهای من'));
      await tester.pumpAndSettle();

      // Confirmed status badge has event_available icon + text
      expect(find.text('تایید شده (در نوبت)'), findsOneWidget);
      expect(find.byIcon(Icons.event_available), findsOneWidget);

      handle.dispose();
    });

    testWidgets('DashboardScreen meets labeled tap target guideline',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapForAccessibility(
          DashboardScreen(
            state: testState,
            onOpenMealScanner: () {},
            onOpenHomeMode: () {},
            onOpenWorkouts: () {},
            onStartWorkout: (_) {},
            onOpenMarketplace: () {},
            onOpenAiCoach: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });
}
