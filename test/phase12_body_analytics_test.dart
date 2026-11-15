import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/models/body_analytics_models.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/widgets/bmi_indicator_card.dart';
import 'package:gymbro/widgets/charts/weight_progress_chart.dart';
import 'package:gymbro/widgets/charts/body_measurements_chart.dart';
import 'package:gymbro/widgets/body_3d_wireframe_visualizer.dart';
import 'package:gymbro/widgets/body_muscle_map.dart';
import 'package:gymbro/screens/add_measurement_dialog.dart';
import 'package:gymbro/screens/edit_profile_dialog.dart';
import 'package:gymbro/screens/profile_screen.dart';

Widget _wrapWithApp(Widget child, [AppState? state]) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
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

  group('Phase 12: Body Analytics Models & Calculations', () {
    test('BmiCategory accurately classifies WHO spectrum', () {
      expect(BmiCategory.fromBmi(17.5), BmiCategory.underweight);
      expect(BmiCategory.fromBmi(22.0), BmiCategory.normal);
      expect(BmiCategory.fromBmi(27.4), BmiCategory.overweight);
      expect(BmiCategory.fromBmi(32.1), BmiCategory.obeseClass1);
      expect(BmiCategory.fromBmi(38.0), BmiCategory.obeseClass2);

      // Verify clinical disclaimer is present on all categories
      for (final cat in BmiCategory.values) {
        expect(cat.clinicalNoteFa, isNotEmpty);
        expect(cat.displayNameFa, isNotEmpty);
      }
    });

    test('WeightRecord serialization and deserialization preserves all fields', () {
      final now = DateTime(2026, 11, 9, 10, 0);
      final record = WeightRecord(
        id: 'w_test_1',
        date: now,
        weightKg: 74.2,
        note: 'تمرین صبحگاهی ناشتا',
      );

      final json = record.toJson();
      final restored = WeightRecord.fromJson(json);

      expect(restored.id, 'w_test_1');
      expect(restored.date, now);
      expect(restored.weightKg, 74.2);
      expect(restored.note, 'تمرین صبحگاهی ناشتا');
    });

    test('BodyMeasurementRecord serialization and deserialization preserves circumferences', () {
      final now = DateTime(2026, 11, 9, 12, 0);
      final record = BodyMeasurementRecord(
        id: 'bm_test_1',
        date: now,
        waistCm: 84.5,
        chestCm: 101.0,
        hipCm: 99.0,
        rightArmCm: 37.5,
        leftArmCm: 37.2,
        thighCm: 57.0,
        calfCm: 37.0,
        bodyFatPercentage: 16.5,
        note: 'پایان دوره کات',
      );

      final json = record.toJson();
      final restored = BodyMeasurementRecord.fromJson(json);

      expect(restored.id, 'bm_test_1');
      expect(restored.waistCm, 84.5);
      expect(restored.chestCm, 101.0);
      expect(restored.hipCm, 99.0);
      expect(restored.rightArmCm, 37.5);
      expect(restored.bodyFatPercentage, 16.5);
      expect(restored.note, 'پایان دوره کات');
    });

    test('Goal Progress Fraction calculation reflects fat loss vs muscle building', () {
      // 1. Fat Loss Goal: initial 76.5kg, target 70.0kg, current 72.6kg
      expect(testState.initialWeightKg, 76.5);
      expect(testState.currentWeightKg, 72.6);
      expect(testState.targetWeightKg, 70.0);
      expect(testState.totalWeightChangeKg, closeTo(-3.9, 0.05));
      expect(testState.weightToTargetKg, closeTo(2.6, 0.05));

      final progress = testState.goalProgressFraction;
      expect(progress, isNotNull);
      // (76.5 - 72.6) / (76.5 - 70.0) = 3.9 / 6.5 = 0.60 (60% completed)
      expect(progress!, closeTo(0.60, 0.02));
    });
  });

  group('Phase 12: Local Storage & Seeding Operations', () {
    test('Storage adds, retrieves, and deletes weight records accurately', () async {
      final initialCount = testState.weightRecords.length;
      expect(initialCount, greaterThan(0));

      await testState.addWeightRecord(weightKg: 71.8, note: 'توزین جدید');
      expect(testState.weightRecords.length, initialCount + 1);
      expect(testState.currentWeightKg, 71.8);
      expect(testState.userProfile.weightKg, 71.8);

      final addedId = testState.weightRecords.last.id;
      await testState.deleteWeightRecord(addedId);
      expect(testState.weightRecords.length, initialCount);
    });

    test('Storage adds, retrieves, and deletes body measurement records accurately', () async {
      final initialCount = testState.bodyMeasurements.length;
      expect(initialCount, greaterThan(0));

      final newMeasurement = BodyMeasurementRecord(
        id: 'bm_custom_99',
        date: DateTime.now(),
        waistCm: 81.5,
        chestCm: 103.0,
        bodyFatPercentage: 15.0,
      );

      await testState.addBodyMeasurement(newMeasurement);
      expect(testState.bodyMeasurements.length, initialCount + 1);
      expect(testState.latestBodyMeasurement?.waistCm, 81.5);

      await testState.deleteBodyMeasurement('bm_custom_99');
      expect(testState.bodyMeasurements.length, initialCount);
    });
  });

  group('Phase 12: Interactive Widgets & Visualizations', () {
    testWidgets('BmiIndicatorCard renders spectrum, numerical value, and disclaimer', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const BmiIndicatorCard(
            bmi: 24.2,
            heightCm: 178,
            weightKg: 76.5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('شاخص توده بدنی (BMI)'), findsOneWidget);
      expect(find.byType(BmiIndicatorCard), findsOneWidget);
      // Explanatory medical screening disclaimer must be present
      expect(find.textContaining('شاخص غربالگری آماری'), findsOneWidget);
    });

    testWidgets('WeightProgressChart renders range filters and handles empty states', (tester) async {
      // 1. Chart with historical data
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

      expect(find.text('نمودار تغییرات وزن و هدف'), findsOneWidget);
      expect(find.text('۱ ماه'), findsOneWidget);
      expect(find.text('۳ ماه'), findsOneWidget);
      expect(find.text('۶ ماه'), findsOneWidget);
      expect(find.text('۱ سال'), findsOneWidget);
      expect(find.text('همه'), findsOneWidget);

      // Tap 1M range filter
      await tester.tap(find.text('۱ ماه'));
      await tester.pumpAndSettle();

      // 2. Chart with insufficient data (< 2 records)
      await tester.pumpWidget(
        _wrapWithApp(
          WeightProgressChart(
            records: [testState.weightRecords.first],
            targetWeightKg: 70.0,
            onAddRecord: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('داده‌های وزنی برای رسم نمودار کافی نیست'), findsOneWidget);
    });

    testWidgets('BodyMeasurementsChart switches metrics and updates UI', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          BodyMeasurementsChart(
            records: testState.bodyMeasurements,
            onAddMeasurement: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('روند تغییر سایزهای بدنی'), findsOneWidget);
      expect(find.text('دور کمر'), findsOneWidget);
      expect(find.text('دور سینه'), findsOneWidget);
      expect(find.text('دور بازو'), findsOneWidget);

      // Tap chest metric pill
      await tester.tap(find.text('دور سینه'));
      await tester.pumpAndSettle();

      expect(find.byType(BodyMeasurementsChart), findsOneWidget);
    });

    testWidgets('Body3dWireframeVisualizer highlights selected body part on tap', (tester) async {
      BodyPartFocus? tappedPart;
      await tester.pumpWidget(
        _wrapWithApp(
          Body3dWireframeVisualizer(
            latestMeasurement: testState.latestBodyMeasurement,
            onPartSelected: (part) => tappedPart = part,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('نقشه آناتومیک و سایزهای بدن (3D Map)'), findsOneWidget);

      // Tap chest selector pill
      await tester.tap(find.text('دور سینه'));
      await tester.pumpAndSettle();

      expect(tappedPart, BodyPartFocus.chest);
    });

    testWidgets('BodyMuscleMap selects front muscles from image hotspots', (tester) async {
      BodyPartFocus? tappedPart;
      await tester.pumpWidget(
        _wrapWithApp(
          SingleChildScrollView(
            child: BodyMuscleMap(
              latestMeasurement: testState.latestBodyMeasurement,
              exercises: testState.exercises,
              onPartSelected: (part) => tappedPart = part,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('body-hotspot-chest-center')));
      await tester.pumpAndSettle();

      expect(tappedPart, BodyPartFocus.chest);
      expect(find.text('حرکت‌های مرتبط'), findsOneWidget);
      expect(find.text('ثبت اندازه‌گیری بدن'), findsOneWidget);
    });

    testWidgets('BodyMuscleMap switches to back and selects back muscles', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          SingleChildScrollView(
            child: BodyMuscleMap(exercises: testState.exercises),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('نمای پشت'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('body-hotspot-upperBack-center')));
      await tester.pumpAndSettle();

      expect(find.text('پشت میانی'), findsWidgets);
      expect(find.byKey(const ValueKey('body-region-glutes')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('body-hotspot-rearShoulders-left')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('body-region-rearShoulders')), findsOneWidget);
    });

    testWidgets('BodyMuscleMap keeps measurement entry separate from selection', (tester) async {
      var addMeasurementPressed = false;
      await tester.pumpWidget(
        _wrapWithApp(
          SingleChildScrollView(
            child: BodyMuscleMap(
              onAddMeasurement: () => addMeasurementPressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('body-hotspot-chest-center')));
      await tester.pumpAndSettle();
      expect(addMeasurementPressed, isFalse);

      await tester.ensureVisible(find.byKey(const ValueKey('add-body-measurement')));
      await tester.tap(find.byKey(const ValueKey('add-body-measurement')));
      await tester.pumpAndSettle();
      expect(addMeasurementPressed, isTrue);
    });
  });

  group('Phase 12: Dialogs & Profile Editing Flow', () {
    testWidgets('AddMeasurementDialog logs new weight record and saves to AppState', (tester) async {
      await tester.pumpWidget(_wrapWithApp(AddMeasurementDialog(state: testState), testState));
      await tester.pumpAndSettle();

      expect(find.text('ثبت آمار و اندازه‌گیری جدید'), findsOneWidget);
      expect(find.text('ثبت وزن (kg)'), findsOneWidget);

      // Enter weight
      final weightField = find.widgetWithText(TextFormField, 'وزن ناشتا (کیلوگرم)');
      await tester.enterText(weightField, '71.5');

      // Submit
      await tester.tap(find.text('ثبت و ذخیره وزن'));
      await tester.pumpAndSettle();

      expect(testState.currentWeightKg, 71.5);
    });

    testWidgets('EditProfileDialog enforces metric boundaries and updates profile', (tester) async {
      await tester.pumpWidget(_wrapWithApp(EditProfileDialog(state: testState), testState));
      await tester.pumpAndSettle();

      expect(find.text('ویرایش مشخصات فیزیکی'), findsOneWidget);

      final weightField = find.widgetWithText(TextFormField, 'وزن فعلی (کیلوگرم)');
      final heightField = find.widgetWithText(TextFormField, 'قد (سانتی‌متر)');

      // Invalid weight < 30
      await tester.enterText(weightField, '20');
      await tester.tap(find.text('ذخیره تغییرات'));
      await tester.pumpAndSettle();
      expect(find.text('وزن باید بین ۳۰ تا ۳۰۰ کیلوگرم باشد.'), findsOneWidget);

      // Invalid height < 100
      await tester.enterText(weightField, '75.0');
      await tester.enterText(heightField, '90');
      await tester.tap(find.text('ذخیره تغییرات'));
      await tester.pumpAndSettle();
      expect(find.text('قد باید بین ۱۰۰ تا ۲۵۰ سانتی‌متر باشد.'), findsOneWidget);

      // Valid values
      await tester.enterText(heightField, '182');
      await tester.tap(find.text('ذخیره تغییرات'));
      await tester.pumpAndSettle();

      expect(testState.userProfile.weightKg, 75.0);
      expect(testState.userProfile.heightCm, 182.0);
    });

    testWidgets('ProfileScreen mounts all Phase 12 modules seamlessly', (tester) async {
      await tester.pumpWidget(_wrapWithApp(ProfileScreen(state: testState), testState));
      await tester.pumpAndSettle();

      expect(find.text('پروفایل و جایگاه ورزشی'), findsOneWidget);
      expect(find.byType(BmiIndicatorCard), findsOneWidget);
      expect(find.byType(WeightProgressChart), findsOneWidget);
      expect(find.byType(BodyMeasurementsChart), findsOneWidget);
      expect(find.byType(BodyMuscleMap), findsOneWidget);
      expect(find.text('تاریخچه و پرونده اندازه‌گیری‌ها'), findsOneWidget);
    });
  });
}
