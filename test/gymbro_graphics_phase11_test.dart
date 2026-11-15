import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/core/graphics/graphics.dart';
import 'package:gymbro/core/theme/app_theme.dart';

void main() {
  group('Phase 11: GymBro Custom Vector Graphics & Iconography Suite', () {
    testWidgets('Renders all 13 GymBroEquipmentType vector illustrations cleanly',
        (tester) async {
      for (final type in GymBroEquipmentType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: GymBroEquipmentIllustration(
                  type: type,
                  size: 48,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(GymBroEquipmentIllustration), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      }
    });

    testWidgets('Renders all 12 GymBroMuscleGroup with primary and secondary activation',
        (tester) async {
      for (final group in GymBroMuscleGroup.values) {
        for (final activation in GymBroMuscleActivation.values) {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(
                body: Center(
                  child: GymBroMuscleIllustration(
                    muscle: group,
                    activation: activation,
                    size: 48,
                  ),
                ),
              ),
            ),
          );

          expect(find.byType(GymBroMuscleIllustration), findsOneWidget);
        }
      }
    });

    testWidgets('Renders all 12 GymBroNutritionType illustrations cleanly',
        (tester) async {
      for (final type in GymBroNutritionType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: GymBroNutritionIllustration(
                  type: type,
                  size: 48,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(GymBroNutritionIllustration), findsOneWidget);
      }
    });

    testWidgets('Renders GymBroIcon across dashboard & navigation icon sets',
        (tester) async {
      for (final icon in GymBroDashboardIconType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: GymBroIcon(
                  icon: icon,
                  size: 24,
                  active: true,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(GymBroIcon), findsOneWidget);
      }

      for (final nav in GymBroNavIconType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: GymBroIcon(
                  icon: nav,
                  size: 24,
                  active: false,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(GymBroIcon), findsOneWidget);
      }
    });

    testWidgets('GymBroAnimatedIcon smoothly updates across animation types',
        (tester) async {
      for (final animType in GymBroAnimationType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: GymBroAnimatedIcon(
                  animationType: animType,
                  equipment: GymBroEquipmentType.dumbbell,
                  size: 40,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(GymBroAnimatedIcon), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    });

    test('String parsers correctly map Persian and English identifiers', () {
      expect(GymBroEquipmentTypeX.fromString('دمبل ۶ ضلعی'), GymBroEquipmentType.dumbbell);
      expect(GymBroEquipmentTypeX.fromString('Barbell Bench Press'), GymBroEquipmentType.barbell);
      expect(GymBroEquipmentTypeX.fromString('دستگاه سیم‌کش'), GymBroEquipmentType.cableMachine);
      expect(GymBroEquipmentTypeX.fromString('کتل‌بل'), GymBroEquipmentType.kettlebell);

      expect(GymBroMuscleGroupX.fromString('سینه'), GymBroMuscleGroup.chest);
      expect(GymBroMuscleGroupX.fromString('زیربغل'), GymBroMuscleGroup.back);
      expect(GymBroMuscleGroupX.fromString('جلوبازو'), GymBroMuscleGroup.biceps);
      expect(GymBroMuscleGroupX.fromString('چهارسر ران'), GymBroMuscleGroup.quadriceps);
    });
  });
}
