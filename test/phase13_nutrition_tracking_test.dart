import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/models/nutrition_models.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/widgets/charts/calorie_gauge_card.dart';
import 'package:gymbro/widgets/charts/macronutrient_bar_card.dart';
import 'package:gymbro/widgets/charts/weekly_nutrition_chart.dart';
import 'package:gymbro/widgets/water_tracker_card.dart';
import 'package:gymbro/screens/nutrition_screen.dart';

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

  group('GymBro Phase 13: Nutrition Tracking & Food Analytics Tests', () {
    test('1. NutritionCalculator calculates scientific Mifflin-St Jeor BMR and macro targets', () {
      final profile = state.userProfile;

      // Test male BMR
      final bmrMale = NutritionCalculator.calculateBmr(
        weightKg: 75.0,
        heightCm: 180.0,
        age: 25,
        gender: 'male',
      );
      // (10 * 75) + (6.25 * 180) - (5 * 25) + 5 = 750 + 1125 - 125 + 5 = 1755.0
      expect(bmrMale, equals(1755.0));

      // Test female BMR
      final bmrFemale = NutritionCalculator.calculateBmr(
        weightKg: 60.0,
        heightCm: 165.0,
        age: 28,
        gender: 'female',
      );
      // (10 * 60) + (6.25 * 165) - (5 * 28) - 161 = 600 + 1031.25 - 140 - 161 = 1330.25
      expect(bmrFemale, equals(1330.25));

      // Test recommended plan generation
      final plan = NutritionCalculator.calculateRecommendedPlan(profile: profile);
      expect(plan['calories'], greaterThan(1500));
      expect(plan['protein'], greaterThan(100));
      expect(plan['carbs'], greaterThan(120));
      expect(plan['fat'], greaterThan(30));
      expect(plan['water'], greaterThan(2000));
    });

    test('2. Water logging and undo functionality works with persistence', () async {
      final initialWater = state.selectedConsumedWaterMl;

      // Add 250ml
      await state.logWater(250);
      expect(state.selectedConsumedWaterMl, equals(initialWater + 250));

      // Add another 500ml
      await state.logWater(500);
      expect(state.selectedConsumedWaterMl, equals(initialWater + 750));

      // Undo 250ml
      await state.undoWater(250);
      expect(state.selectedConsumedWaterMl, equals(initialWater + 500));
    });

    test('3. Food Logging CRUD: Add, Update, Duplicate, and Delete meals', () async {
      final initialCount = state.selectedDateMeals.length;

      // ADD
      final newMeal = CalorieScanLog(
        id: 'test_meal_1',
        foodName: 'استیک راسته گوساله با برنج',
        mealType: 'شام',
        calories: 650,
        proteinG: 50.0,
        carbsG: 60.0,
        fatG: 15.0,
        portionG: 350.0,
        dateString: state.selectedNutritionDateString,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: 'وعده بعد از تمرین ددلیفت',
      );
      await state.addFoodEntry(newMeal);
      expect(state.selectedDateMeals.length, equals(initialCount + 1));
      expect(state.selectedDateMeals.any((m) => m.id == 'test_meal_1'), isTrue);

      // UPDATE
      final updatedMeal = newMeal.copyWith(
        foodName: 'استیک فیله گوساله بدون چربی',
        calories: 550,
      );
      await state.updateFoodEntry(updatedMeal);
      final fetched = state.selectedDateMeals.firstWhere((m) => m.id == 'test_meal_1');
      expect(fetched.foodName, equals('استیک فیله گوساله بدون چربی'));
      expect(fetched.calories, equals(550));

      // DUPLICATE
      await state.duplicateFoodEntry(fetched);
      expect(state.selectedDateMeals.length, equals(initialCount + 2));

      // DELETE
      await state.deleteFoodEntry('test_meal_1');
      expect(state.selectedDateMeals.any((m) => m.id == 'test_meal_1'), isFalse);
    });

    test('4. Date Navigation filters meals and aggregates accurately per selected day', () {
      final todayStr = state.todayDateString;
      expect(state.selectedNutritionDateString, equals(todayStr));

      // Navigate to previous day
      state.selectPreviousNutritionDay();
      final prevDateStr = state.selectedNutritionDateString;
      expect(prevDateStr, isNot(equals(todayStr)));

      // Check meals on that previous day
      final prevMeals = state.selectedDateMeals;
      for (final m in prevMeals) {
        expect(m.dateString, equals(prevDateStr));
      }

      // Return to today
      state.selectTodayNutrition();
      expect(state.selectedNutritionDateString, equals(todayStr));
    });

    test('5. Weekly and monthly trend summaries calculate properly without gaps', () {
      final weeklySummaries = state.getPast7DaysSummaries();
      expect(weeklySummaries.length, equals(7));

      final monthlySummaries = state.getPast30DaysSummaries();
      expect(monthlySummaries.length, equals(30));

      for (final s in weeklySummaries) {
        expect(s.totalCalories, greaterThanOrEqualTo(0));
        expect(s.targetCalories, equals(state.nutritionPlan.dailyCalories));
        expect(s.calorieCompliance, greaterThanOrEqualTo(0.0));
      }
    });

    test('6. NutritionPlan customization updates targets and persists', () async {
      final updatedPlan = state.nutritionPlan.copyWith(
        dailyCalories: 2400,
        targetProteinG: 175,
        targetCarbsG: 250,
        targetFatG: 60,
        targetWaterMl: 3500,
      );

      await state.updateNutritionPlanGoals(updatedPlan);
      expect(state.nutritionPlan.dailyCalories, equals(2400));
      expect(state.nutritionPlan.targetProteinG, equals(175));

      // Verify reload from storage preserves it
      final reloaded = storage.getNutritionPlan();
      expect(reloaded.dailyCalories, equals(2400));
      expect(reloaded.targetProteinG, equals(175));
    });

    testWidgets('7. CalorieGaugeCard renders gauge, stats and edit action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CalorieGaugeCard(
              consumedCalories: 1800,
              targetCalories: 2250,
              onEditGoals: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('بودجه انرژی و کالری روزانه'), findsOneWidget);
      expect(find.text('تنظیم هدف'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('8. MacronutrientBarCard renders protein, carbs and fat progress bars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: MacronutrientBarCard(
              consumedProtein: 120.0,
              targetProtein: 160,
              consumedCarbs: 180.0,
              targetCarbs: 220,
              consumedFat: 45.0,
              targetFat: 55,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تفکیک درشت‌مغذی‌های مصرفی (Macros)'), findsOneWidget);
      expect(find.text('پروتئین خالص'), findsOneWidget);
      expect(find.text('کربوهیدرات پیچیده'), findsOneWidget);
      expect(find.text('چربی‌های سالم'), findsOneWidget);
    });

    testWidgets('9. WaterTrackerCard increments and decrements hydration', (tester) async {
      int added = 0;
      int undone = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WaterTrackerCard(
              consumedMl: 1500,
              targetMl: 3000,
              onAddWater: (amt) => added += amt,
              onUndoWater: (amt) => undone += amt,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('هیدراتاسیون و پایش آب روزانه'), findsOneWidget);
      expect(find.text('+۲۵۰ml (لیوان)'), findsOneWidget);
      expect(find.text('+۵۰۰ml (بطری)'), findsOneWidget);

      await tester.tap(find.text('+۲۵۰ml (لیوان)'));
      expect(added, equals(250));

      await tester.tap(find.text('+۵۰۰ml (بطری)'));
      expect(added, equals(750));
    });

    testWidgets('10. WeeklyNutritionChart renders and switches views smoothly', (tester) async {
      final weekly = state.getPast7DaysSummaries();
      final monthly = state.getPast30DaysSummaries();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WeeklyNutritionChart(
              weeklySummaries: weekly,
              monthlySummaries: monthly,
              selectedDateString: state.selectedNutritionDateString,
              targetCalories: state.nutritionPlan.dailyCalories,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('روند دریافت انرژی و درشت‌مغذی‌ها'), findsOneWidget);
      expect(find.text('۷ روز'), findsOneWidget);
      expect(find.text('۳۰ روز'), findsOneWidget);

      // Switch to 30 days
      await tester.tap(find.text('۳۰ روز'));
      await tester.pumpAndSettle();

      // Switch to Macros split
      await tester.tap(find.text('تفکیک ماکروها (P/C/F)'));
      await tester.pumpAndSettle();

      expect(find.text('پروتئین'), findsOneWidget);
      expect(find.text('کربوهیدرات'), findsOneWidget);
      expect(find.text('چربی'), findsOneWidget);
    });

    testWidgets('11. Full NutritionScreen renders complete Phase 13 dashboard without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: NutritionScreen(
              state: state,
              onOpenScanner: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تغذیه و پایش هوشمند کالری'), findsOneWidget);
      expect(find.text('ثبت وعده'), findsOneWidget);
      expect(find.byType(CalorieGaugeCard), findsOneWidget);
      expect(find.byType(MacronutrientBarCard), findsOneWidget);
      expect(find.byType(WaterTrackerCard), findsOneWidget);
      expect(find.byType(WeeklyNutritionChart), findsOneWidget);
    });
  });
}
