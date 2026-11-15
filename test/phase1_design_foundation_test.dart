import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/widgets/common/gymbro_design_system.dart';
import 'package:gymbro/screens/design_system_showcase_screen.dart';

void main() {
  group('Phase 1 - Design Foundation Tokens', () {
    test('AppColors brand tokens match GymBro athletic identity', () {
      expect(AppColors.background, const Color(0xFF0B0E13));
      expect(AppColors.backgroundSecondary, const Color(0xFF111720));
      expect(AppColors.surface, const Color(0xFF171D27));
      expect(AppColors.surfaceElevated, const Color(0xFF202A37));
      expect(AppColors.lime, const Color(0xFFC9F36A));
      expect(AppColors.warmAmber, const Color(0xFFFFB86B));
      expect(AppColors.softCyan, const Color(0xFF78CFE0));
      expect(AppColors.error, const Color(0xFFFF6B70));
    });

    test('AppSpacing maintains 4dp/8dp spatial grid & 48dp touch target', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.base, 16.0);
      expect(AppSpacing.lg, 24.0);
      expect(AppSpacing.xl, 32.0);
      expect(AppSpacing.minTouchTarget, 48.0);
    });

    test('AppTypography incorporates Vazirmatn font family and fallbacks', () {
      expect(AppTypography.fallbackFonts, contains('Vazirmatn'));
      expect(AppTypography.fallbackFonts, contains('Tahoma'));
      expect(AppTypography.fallbackFonts, contains('Arial'));
      expect(AppTypography.fallbackFonts, contains('sans-serif'));
      expect(AppTypography.fontFaPrimary, 'Vazirmatn');
    });

    test('AppTheme.darkTheme incorporates Vazirmatn and AppThemeExtension', () {
      final theme = AppTheme.darkTheme;
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Vazirmatn');
      final tokens = theme.extension<AppThemeExtension>();
      expect(tokens, isNotNull);
      expect(tokens!.lime, AppColors.lime);
      expect(tokens.cardBackground, AppColors.surface);
      expect(tokens.cardElevated, AppColors.surfaceElevated);
    });
  });

  group('Phase 1 - Reusable UI Components', () {
    Widget buildTestApp(Widget child, {TextDirection textDirection = TextDirection.rtl}) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Directionality(
          textDirection: textDirection,
          child: Scaffold(
            body: Center(child: child),
          ),
        ),
      );
    }

    testWidgets('GymBroPrimaryButton meets 48dp minimum touch target and taps', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          GymBroPrimaryButton(
            text: 'تایید و ادامه',
            onPressed: () => tapped = true,
          ),
        ),
      );

      final buttonFinder = find.byType(GymBroPrimaryButton);
      expect(buttonFinder, findsOneWidget);

      final size = tester.getSize(buttonFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.text('تایید و ادامه'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('GymBroGhostButton and GymBroIconButton meet 48dp touch target', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Row(
            children: [
              GymBroGhostButton(
                text: 'انصراف',
                onPressed: () {},
              ),
              GymBroIconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'بستن',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      final ghostFinder = find.byType(GymBroGhostButton);
      final iconFinder = find.byType(GymBroIconButton);

      expect(tester.getSize(ghostFinder).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(iconFinder).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(iconFinder).width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('GymBroPillFilter toggles active state', (tester) async {
      bool selected = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              GymBroPillFilter(
                label: 'سینه',
                isSelected: selected,
                onTap: () {
                  setState(() => selected = !selected);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('سینه'), findsOneWidget);
      await tester.tap(find.text('سینه'));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
    });

    testWidgets('GymBroTextField renders and supports typing in RTL', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestApp(
          GymBroTextField(
            controller: controller,
            label: 'نام حرکت',
            hintText: 'پرس سینه دمبل',
          ),
        ),
      );

      expect(find.text('نام حرکت'), findsOneWidget);
      expect(find.text('پرس سینه دمبل'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'اسکوات هالتر');
      await tester.pumpAndSettle();
      expect(controller.text, 'اسکوات هالتر');
    });

    testWidgets('GymBroMetricCard displays value, unit, and delta correctly', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const GymBroMetricCard(
            title: 'دور سینه',
            value: '۱۰۲.۰',
            unit: 'cm',
            delta: '↑ +۴ cm',
          ),
        ),
      );

      expect(find.text('دور سینه'), findsOneWidget);
      expect(find.text('۱۰۲.۰'), findsOneWidget);
      expect(find.text('cm'), findsOneWidget);
      expect(find.text('↑ +۴ cm'), findsOneWidget);
    });

    testWidgets('DesignSystemShowcaseScreen pumps without overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const DesignSystemShowcaseScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('پایه‌ریزی سیستم طراحی جیم‌برو'), findsOneWidget);
      expect(find.text('Human-crafted Athletic Technology'), findsOneWidget);

      // Verify sections exist
      expect(find.text('پالت رنگی و سطوح گرم گرافیت'), findsOneWidget);
      expect(find.text('سلسله‌مراتب تایپوگرافی (وزیرمتن)'), findsOneWidget);
      expect(find.text('سلسله‌مراتب دکمه‌ها و تعامل لمسی'), findsOneWidget);
      expect(find.text('فیلدهای ورودی و سازگاری با ارقام فارسی'), findsOneWidget);
      expect(find.text('تنوع سطوح و ساختار کارت‌ها'), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
