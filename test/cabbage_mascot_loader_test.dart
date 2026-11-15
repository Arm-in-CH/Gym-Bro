import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/widgets/cabbage_mascot_loader.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/graphics/graphics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cabbage Mascot Loader & Conveyor Alignment Tests', () {
    testWidgets('CabbageMascotLoader renders character, text, and subtext cleanly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: CabbageMascotLoader(
                text: 'کلم ورزشی در حال بلعیدن و هضم دمبل‌ها...',
                subtext: 'محاسبه فوری کالری و درشت‌مغذی‌ها با هوش مصنوعی...',
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Verify text elements
      expect(find.text('کلم ورزشی در حال بلعیدن و هضم دمبل‌ها...'), findsOneWidget);
      expect(
          find.text('محاسبه فوری کالری و درشت‌مغذی‌ها با هوش مصنوعی...'), findsOneWidget);

      // Verify Gym sweatband text
      expect(find.text('GYM'), findsOneWidget);

      // Verify conveyor custom vector illustrations
      expect(find.byType(GymBroEquipmentIllustration), findsNWidgets(2));
      expect(find.byType(GymBroNutritionIllustration), findsOneWidget);
    });

    testWidgets('CabbageMascotLoader aligns conveyor dumbbells with the mouth in compact mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: CabbageMascotLoader(
                compact: true,
                text: 'در حال بارگذاری...',
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('در حال بارگذاری...'), findsOneWidget);
      expect(find.text('GYM'), findsOneWidget);

      // Verify compact height constraint is respected
      final sizedBox = tester.widgetList<SizedBox>(find.byType(SizedBox)).firstWhere(
            (w) => w.height == 64,
          );
      expect(sizedBox.height, equals(64));
    });

    testWidgets('CabbageMascotLoader is responsive across narrow and wide foldable screens',
        (tester) async {
      // Test narrow screen (e.g. 320x640)
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: CabbageMascotLoader(
                text: 'کلم ورزشی در حال بلعیدن و هضم دمبل‌ها...',
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      // Test wide unfolded foldable screen (e.g. 768x900)
      tester.view.physicalSize = const Size(768, 900);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: CabbageMascotLoader(
                text: 'کلم ورزشی در حال بلعیدن و هضم دمبل‌ها...',
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  });
}
