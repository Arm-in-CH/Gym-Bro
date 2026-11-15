import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/widgets/nutrition_recommendation_card.dart';
import 'package:gymbro/widgets/cabbage_mascot_loader.dart';
import 'package:gymbro/core/theme/app_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({
    required Widget child,
    Size size = const Size(412, 915),
    double textScaleFactor = 1.0,
    bool disableAnimations = false,
    TextDirection textDirection = TextDirection.rtl,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData.light().copyWith(
        extensions: [AppThemeExtension.light],
      ),
      darkTheme: ThemeData.dark().copyWith(
        extensions: [AppThemeExtension.dark],
      ),
      home: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScaleFactor),
            disableAnimations: disableAnimations,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('NutritionRecommendationCard - UI Layout & Animation Phase 6 Tests',
      () {
    testWidgets(
        'Renders all 5 meal category buttons with correct Persian labels',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const NutritionRecommendationCard(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('صبحانه'), findsOneWidget);
      expect(find.text('ناهار'), findsOneWidget);
      expect(find.text('عصرانه ورزشی'), findsOneWidget);
      expect(find.text('شام'), findsOneWidget);
      expect(find.text('میان‌وعده'), findsOneWidget);
      expect(find.text('پیشنهاد هوشمند تغذیه ورزشی'), findsOneWidget);
    });

    testWidgets('Tapping each category switches recommendations smoothly',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const NutritionRecommendationCard(),
      ));
      await tester.pumpAndSettle();

      // Default category is صبحانه
      expect(find.text('تست پروتئینی و تخم‌مرغ آبپز'), findsOneWidget);

      // Tap ناهار
      await tester.tap(find.text('ناهار'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(find.text('کته با فیله مرغ گریل شده'), findsOneWidget);

      // Tap عصرانه ورزشی
      await tester.tap(find.text('عصرانه ورزشی'));
      await tester.pumpAndSettle();
      expect(find.text('شیک وی و کراتین پس از تمرین'), findsOneWidget);

      // Tap شام
      await tester.tap(find.text('شام'));
      await tester.pumpAndSettle();
      expect(find.text('استیک فیله گوشت و سیب‌زمینی پخته'), findsOneWidget);

      // Tap میان‌وعده
      await tester.tap(find.text('میان‌وعده'));
      await tester.pumpAndSettle();
      expect(find.text('شیر کم‌چرب و بادام درختی'), findsOneWidget);
    });

    testWidgets('Does not overflow on small screen (360x640) at textScale 1.0',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const NutritionRecommendationCard(),
        size: const Size(360, 640),
        textScaleFactor: 1.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(NutritionRecommendationCard), findsOneWidget);
    });

    testWidgets(
        'Does not overflow on small screen (360x640) at textScale 2.0 (Accessibility)',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const NutritionRecommendationCard(),
        size: const Size(360, 640),
        textScaleFactor: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(NutritionRecommendationCard), findsOneWidget);
    });

    testWidgets('Renders properly on tablet/desktop (1024x768)',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const NutritionRecommendationCard(),
        size: const Size(1024, 768),
        textScaleFactor: 1.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(NutritionRecommendationCard), findsOneWidget);
    });

    testWidgets('Respects disableAnimations flag without stutter or error',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const NutritionRecommendationCard(),
        disableAnimations: true,
      ));
      await tester.pumpAndSettle();

      // Tap different category with disabled animations
      await tester.tap(find.text('ناهار'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('کته با فیله مرغ گریل شده'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Maintains ClipRRect bounding on animated panel',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const NutritionRecommendationCard(),
      ));
      await tester.pumpAndSettle();

      // Find ClipRRect widgets within NutritionRecommendationCard
      final clipFinders = find.descendant(
        of: find.byType(NutritionRecommendationCard),
        matching: find.byType(ClipRRect),
      );
      expect(clipFinders, findsWidgets);

      // Verify FadeTransition and SlideTransition exist
      final slideFinder = find.descendant(
        of: find.byType(NutritionRecommendationCard),
        matching: find.byType(SlideTransition),
      );
      expect(slideFinder, findsOneWidget);
    });

    testWidgets('Disposes cleanly without lingering timers or controllers',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const NutritionRecommendationCard(),
      ));
      await tester.pumpAndSettle();

      // Replace widget with empty container to trigger dispose()
      await tester.pumpWidget(buildTestableWidget(
        child: const SizedBox.shrink(),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('CabbageMascotLoader - Animation Clipping & RTL Phase 6 Tests', () {
    testWidgets('Renders loader with ClipRect on conveyor belt',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const CabbageMascotLoader(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final clipRects = find.descendant(
        of: find.byType(CabbageMascotLoader),
        matching: find.byType(ClipRect),
      );
      expect(clipRects, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Conveyor items use PositionedDirectional for RTL compliance',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const CabbageMascotLoader(),
        textDirection: TextDirection.rtl,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      final positionedWidgets = find.descendant(
        of: find.byType(CabbageMascotLoader),
        matching: find.byType(PositionedDirectional),
      );
      expect(positionedWidgets, findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Does not overflow at textScale 2.0', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const CabbageMascotLoader(),
        size: const Size(360, 640),
        textScaleFactor: 2.0,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('Respects disableAnimations in didChangeDependencies',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: const CabbageMascotLoader(),
        disableAnimations: true,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });
  });
}
