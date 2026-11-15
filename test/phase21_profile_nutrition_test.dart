import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/widgets/charts/weight_progress_chart.dart';
import 'package:gymbro/widgets/charts/calorie_gauge_card.dart';
import 'package:gymbro/screens/profile_screen.dart';
import 'package:gymbro/screens/add_food_dialog.dart';

Widget _wrapWithApp(Widget child, [AppState? state]) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalStorageService storage;
  late AppState testState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    testState = AppState(storage: storage);
  });

  group('Phase 21: Weight Progress Chart & Hero Display Tests', () {
    testWidgets('WeightProgressChart renders Hero Weight, range pills, and target stats', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          WeightProgressChart(
            records: testState.weightRecords,
            targetWeightKg: 70.0,
            onAddRecord: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify chart header
      expect(find.text('نمودار تغییرات وزن و هدف'), findsOneWidget);

      // Verify all range selector pills including 1 week (Phase 21)
      expect(find.text('۱ هفته'), findsOneWidget);
      expect(find.text('۱ ماه'), findsOneWidget);
      expect(find.text('۳ ماه'), findsOneWidget);
      expect(find.text('۶ ماه'), findsOneWidget);
      expect(find.text('۱ سال'), findsOneWidget);
      expect(find.text('همه'), findsOneWidget);

      // Verify Hero Weight display
      expect(find.text('آخرین پایش ثبت‌شده در سیستم'), findsOneWidget);
      expect(find.textContaining('کیلوگرم'), findsWidgets);

      // Verify Start vs Target summary cards
      expect(find.text('وزن شروع'), findsOneWidget);
      expect(find.text('وزن هدف'), findsOneWidget);
      expect(find.text('پیشرفت هدف'), findsOneWidget);

      // Tap 1 week filter
      await tester.tap(find.text('۱ هفته'));
      await tester.pumpAndSettle();
      expect(find.byType(WeightProgressChart), findsOneWidget);
    });
  });

  group('Phase 21: Profile Weight History & Deltas Tests', () {
    testWidgets('ProfileScreen renders enhanced weight history cards with deltas and sparklines', (tester) async {
      // Add a couple of distinct weight records to test deltas
      await testState.addWeightRecord(weightKg: 73.0, note: 'رکورد میانی');
      await testState.addWeightRecord(weightKg: 72.2, note: 'رکورد جدید');

      await tester.pumpWidget(
        _wrapWithApp(ProfileScreen(state: testState), testState),
      );
      await tester.pumpAndSettle();

      // Scroll to history section
      final historyFinder = find.text('آخرین وزن‌کشی‌های ثبت‌شده:');
      await tester.scrollUntilVisible(
        historyFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(historyFinder, findsOneWidget);

      // Should show the records
      expect(find.textContaining('72.2'), findsNothing); // Persian digits used
      expect(find.textContaining('kg'), findsWidgets);

      // Delete action can be triggered
      final deleteBtn = find.byTooltip('حذف رکورد').first;
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('حذف رکورد وزنی'), findsOneWidget);
      await tester.tap(find.text('انصراف'));
      await tester.pumpAndSettle();
    });
  });

  group('Phase 21: Calorie Gauge Card & Macro Integration Tests', () {
    testWidgets('CalorieGaugeCard renders percentage, macro progress bars, and bottom stats', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          CalorieGaugeCard(
            consumedCalories: 1670,
            targetCalories: 2200,
            consumedProtein: 85.0,
            targetProtein: 140,
            consumedCarbs: 180.0,
            targetCarbs: 240,
            consumedFat: 45.0,
            targetFat: 60,
            onEditGoals: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & edit action
      expect(find.text('بودجه انرژی و کالری روزانه'), findsOneWidget);
      expect(find.text('تنظیم هدف'), findsOneWidget);

      // Verify percentage gauge (1670 / 2200 = 76%)
      expect(find.textContaining('٪'), findsWidgets);
      expect(find.text('تامین هدف کالری'), findsOneWidget);

      // Verify integrated macro bars (Protein, Fat, Carbs)
      expect(find.text('پروتئین'), findsOneWidget);
      expect(find.text('چربی'), findsOneWidget);
      expect(find.text('کربوهیدرات'), findsOneWidget);

      // Verify bottom stat cards
      expect(find.text('مصرف‌شده'), findsOneWidget);
      expect(find.text('هدف کل'), findsOneWidget);
      expect(find.text('باقی‌مانده'), findsOneWidget);
    });
  });

  group('Phase 21: AddFoodDialog Auto-Macro Calculation Tests', () {
    testWidgets('AddFoodDialog auto-calculates calories from protein, carbs, and fat', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          AddFoodDialog(state: testState, initialMealType: 'صبحانه'),
          testState,
        ),
      );
      await tester.pumpAndSettle();

      // Verify fields exist
      expect(find.text('ثبت وعده غذایی جدید'), findsOneWidget);
      expect(find.text('محاسبه هوشمند کالری از ماکروها (P×4 + C×4 + F×9)'), findsOneWidget);

      // Enter protein: 20, carbs: 30, fat: 10
      // Expected total: 20*4 + 30*4 + 10*9 = 80 + 120 + 90 = 290 kcal
      final proteinField = find.widgetWithText(TextFormField, 'پروتئین (g)');
      final carbsField = find.widgetWithText(TextFormField, 'کربوهیدرات (g)');
      final fatField = find.widgetWithText(TextFormField, 'چربی (g)');
      final foodNameField = find.widgetWithText(TextFormField, 'نام غذا یا ماده مصرفی *');

      await tester.enterText(foodNameField, 'تخم مرغ و جو دوسر');
      await tester.enterText(proteinField, '20');
      await tester.enterText(carbsField, '30');
      await tester.enterText(fatField, '10');

      // Tap auto calculate button
      final calcBtn = find.text('محاسبه هوشمند کالری از ماکروها (P×4 + C×4 + F×9)');
      await tester.ensureVisible(calcBtn);
      await tester.tap(calcBtn);
      await tester.pumpAndSettle();

      // Energy field should now contain 290
      final energyField = find.widgetWithText(TextFormField, 'انرژی (کالری) *');
      final textFormField = tester.widget<TextFormField>(energyField);
      expect(textFormField.controller?.text, equals('290'));
    });
  });
}
