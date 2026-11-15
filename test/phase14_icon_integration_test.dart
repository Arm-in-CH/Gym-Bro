import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/core/graphics/graphics.dart';
import 'package:gymbro/widgets/empty_state_widget.dart';
import 'package:gymbro/widgets/level_badge.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 14: Complete Icon Integration & Responsive UI Tests', () {
    testWidgets('EmptyStateWidget renders custom GymBro graphic seamlessly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: EmptyStateWidget(
              customGraphic: GymBroIcon(
                icon: GymBroDashboardIconType.exerciseHistory,
                size: 48,
                active: true,
              ),
              title: 'تست تاریخچه',
              subtitle: 'پیام تست زیرنویس',
            ),
          ),
        ),
      );

      expect(find.text('تست تاریخچه'), findsOneWidget);
      expect(find.text('پیام تست زیرنویس'), findsOneWidget);
      expect(find.byType(GymBroIcon), findsOneWidget);
    });

    testWidgets('LevelBadge renders custom GymBro achievement vector icon',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: LevelBadge(level: UserLevel.elite),
          ),
        ),
      );

      expect(find.text(UserLevel.elite.displayNameFa), findsOneWidget);
      expect(find.byType(GymBroIcon), findsOneWidget);
    });

    testWidgets('All 17 GymBroDashboardIconType values render without throwing',
        (tester) async {
      for (final iconType in GymBroDashboardIconType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: GymBroIcon(
                icon: iconType,
                size: 32,
                active: true,
              ),
            ),
          ),
        );
        expect(find.byType(GymBroIcon), findsOneWidget);
      }
    });

    testWidgets('All 13 GymBroNutritionType values render without throwing',
        (tester) async {
      for (final nutrType in GymBroNutritionType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: GymBroNutritionIllustration(
                type: nutrType,
                size: 32,
              ),
            ),
          ),
        );
        expect(find.byType(GymBroNutritionIllustration), findsOneWidget);
      }
    });

    testWidgets('All 12 GymBroMuscleGroup values render without throwing',
        (tester) async {
      for (final muscle in GymBroMuscleGroup.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: GymBroMuscleIllustration(
                muscle: muscle,
                activation: GymBroMuscleActivation.primary,
                size: 48,
                isAnimated: false,
              ),
            ),
          ),
        );
        expect(find.byType(GymBroMuscleIllustration), findsOneWidget);
      }
    });

    testWidgets('All 13 GymBroEquipmentType values render without throwing',
        (tester) async {
      for (final equip in GymBroEquipmentType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: GymBroEquipmentIllustration(
                type: equip,
                size: 48,
              ),
            ),
          ),
        );
        expect(find.byType(GymBroEquipmentIllustration), findsOneWidget);
      }
    });
  });
}
