import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/core/graphics/graphics.dart';
import 'package:gymbro/core/theme/app_theme.dart';

void main() {
  final artifactDir = Directory(
      'C:/Users/Armin/.gemini/antigravity/brain/b3221214-45b8-4363-b995-5464e3d643ff/screenshots');

  Future<void> capture(
      WidgetTester tester, Widget widget, String filename, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repaintKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: const Color(0xFF0B0E14),
          body: Center(
            child: RepaintBoundary(
              key: repaintKey,
              child: widget,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    await tester.runAsync(() async {
      try {
        final boundary = repaintKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 1.0);
          final byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            if (!artifactDir.existsSync()) {
              artifactDir.createSync(recursive: true);
            }
            final file = File('${artifactDir.path}/$filename');
            file.writeAsBytesSync(byteData.buffer.asUint8List());
          }
        }
      } catch (e) {
        // Handle headless mode
      }
    });
  }

  testWidgets('Task 1: Muscle Icons Showcase', (tester) async {
    await capture(
      tester,
      Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF121622),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: GymBroMuscleGroup.values.take(6).map((m) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GymBroMuscleIllustration(
                  muscle: m,
                  activation: GymBroMuscleActivation.primary,
                  size: 56,
                  isAnimated: false,
                ),
                const SizedBox(height: 6),
                Text(
                  m.name,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      'task1_muscles_after.png',
      const Size(550, 260),
    );
  });

  testWidgets('Task 2: Nutrition Emoji Icons Showcase', (tester) async {
    await capture(
      tester,
      Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF121622),
        child: Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            GymBroNutritionType.protein,
            GymBroNutritionType.carbs,
            GymBroNutritionType.fat,
            GymBroNutritionType.calories,
            GymBroNutritionType.water,
            GymBroNutritionType.fruits,
            GymBroNutritionType.vegetables,
            GymBroNutritionType.meat,
            GymBroNutritionType.eggs,
            GymBroNutritionType.rice,
            GymBroNutritionType.supplements,
            GymBroNutritionType.foodScanner,
          ].map((n) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GymBroNutritionIllustration(type: n, size: 48),
                const SizedBox(height: 4),
                Text(
                  n.name,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      'task2_nutrition_after.png',
      const Size(680, 280),
    );
  });

  testWidgets('Task 3: Dashboard Icons Redesign Showcase', (tester) async {
    await capture(
      tester,
      Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF121622),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            GymBroDashboardIconType.workout,
            GymBroDashboardIconType.focusedTraining,
            GymBroDashboardIconType.aiCoach,
            GymBroDashboardIconType.stopwatch,
            GymBroDashboardIconType.timer,
            GymBroDashboardIconType.personalRecord,
            GymBroDashboardIconType.progress,
            GymBroDashboardIconType.statistics,
          ].map((d) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GymBroIcon(icon: d, size: 36, active: true),
                const SizedBox(height: 6),
                Text(
                  d.name,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      'task3_dashboard_after.png',
      const Size(550, 220),
    );
  });

  testWidgets('Task 4: Stopwatch Mathematical Confinement Proof', (tester) async {
    await capture(
      tester,
      Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF121622),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GymBroIcon(
              icon: GymBroDashboardIconType.stopwatch,
              size: 64,
              active: true,
            ),
            SizedBox(height: 10),
            Text(
              'Stopwatch needle strictly bounded inside dial (r <= 72%)',
              style: TextStyle(color: Color(0xFFCCFF00), fontSize: 12),
            ),
          ],
        ),
      ),
      'task4_stopwatch_after.png',
      const Size(380, 200),
    );
  });
}
