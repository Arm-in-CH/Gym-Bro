import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/core/graphics/gymbro_brand_logo.dart';
import 'package:gymbro/core/localization/persian_utils.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/widgets/active_set_row.dart';
import 'package:gymbro/widgets/common/gymbro_cards.dart';

void main() {
  group('Phase 25 - Persian Numeral Parser & Localization Tests', () {
    test('PersianUtils.fromPersianDigits correctly converts digits and punctuation', () {
      expect(PersianUtils.fromPersianDigits('۱۲۳۴۵۶۷۸۹۰'), '1234567890');
      expect(PersianUtils.fromPersianDigits('١٢٣٤٥٦٧٨٩٠'), '1234567890');
      expect(PersianUtils.fromPersianDigits('۸۵٫۵'), '85.5');
      expect(PersianUtils.fromPersianDigits('۷۲،۴'), '72.4');
      expect(PersianUtils.fromPersianDigits('  ۹۰/۵  ').trim(), '90.5');
    });

    test('PersianUtils.tryParseDouble parses Persian and Arabic numerals', () {
      expect(PersianUtils.tryParseDouble('۸۵٫۵'), 85.5);
      expect(PersianUtils.tryParseDouble('۷۰'), 70.0);
      expect(PersianUtils.tryParseDouble('١٠٠.٢٥'), 100.25);
      expect(PersianUtils.tryParseDouble('  ۹۲٫۵  '), 92.5);
      expect(PersianUtils.tryParseDouble('نامعتبر'), isNull);
      expect(PersianUtils.tryParseDouble(null), isNull);
      expect(PersianUtils.tryParseDouble(''), isNull);
    });

    test('PersianUtils.tryParseInt parses Persian and Arabic numerals', () {
      expect(PersianUtils.tryParseInt('۱۲'), 12);
      expect(PersianUtils.tryParseInt('۴'), 4);
      expect(PersianUtils.tryParseInt('٢٥'), 25);
      expect(PersianUtils.tryParseInt('  ۱۵  '), 15);
      expect(PersianUtils.tryParseInt('۸۵٫۵'), isNull);
      expect(PersianUtils.tryParseInt('abc'), isNull);
      expect(PersianUtils.tryParseInt(null), isNull);
    });
  });

  group('Phase 25 - Premium Visual Assets & Brand Identity Tests', () {
    testWidgets('GymBroBrandLogo renders properly across standard and custom sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  GymBroBrandLogo(size: 32, withGlow: false),
                  GymBroBrandLogo(size: 64, withGlow: true),
                  GymBroBrandLogo(size: 128, withGlow: true),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GymBroBrandLogo), findsNWidgets(3));
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('Phase 25 - Interactive Components & Tap Reliability Tests', () {
    testWidgets('GymBroCard responds to taps and displays content with tactile ripple', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GymBroCard(
              onTap: () {
                tapped = true;
              },
              child: const Text('Test Workout Card'),
            ),
          ),
        ),
      );

      expect(find.text('Test Workout Card'), findsOneWidget);
      await tester.tap(find.byType(GymBroCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('ActiveSetRow accepts Persian input digits for weight and reps without crashing', (WidgetTester tester) async {
      final activeSet = ActiveWorkoutSet(
        setNumber: 1,
        targetReps: 10,
        targetWeightKg: 70.0,
        actualReps: 10,
        actualWeightKg: 70.0,
        isCompleted: false,
      );

      bool dataChanged = false;
      bool completedToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: ActiveSetRow(
                workoutSet: activeSet,
                restSeconds: 90,
                onDataChanged: () {
                  dataChanged = true;
                },
                onToggleComplete: (val) {
                  completedToggled = val;
                },
              ),
            ),
          ),
        ),
      );

      // Verify initial rendering
      expect(find.byType(ActiveSetRow), findsOneWidget);
      expect(find.text('۱'), findsOneWidget);

      // Find the text fields for weight and reps
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      // Enter Persian numerals in weight field: ۸۲٫۵
      await tester.enterText(textFields.first, '۸۲٫۵');
      await tester.pump();
      expect(dataChanged, isTrue);
      expect(activeSet.actualWeightKg, 82.5);

      // Enter Persian numerals in reps field: ۱۲
      await tester.enterText(textFields.last, '۱۲');
      await tester.pump();
      expect(activeSet.actualReps, 12);

      // Tap the completion button / checkbox
      final inkWellFinder = find.descendant(
        of: find.byType(ActiveSetRow),
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsWidgets);
      await tester.tap(inkWellFinder.first);
      await tester.pump();
      expect(completedToggled, isTrue);
    });
  });
}
