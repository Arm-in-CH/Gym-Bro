import 'package:flutter/material.dart';
import 'gymbro_icon_data.dart';
import '../theme/app_tokens.dart';

/// Premium vector illustrations for GymBro nutrition, macros, and meal tracking.
class GymBroNutritionIllustration extends StatelessWidget {
  final GymBroNutritionType type;
  final double size;
  final Color? customColor;

  const GymBroNutritionIllustration({
    super.key,
    required this.type,
    this.size = 36.0,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _NutritionPainter(
          type: type,
          tokens: tokens,
          customColor: customColor,
        ),
      ),
    );
  }
}

class _NutritionPainter extends CustomPainter {
  final GymBroNutritionType type;
  final AppThemeExtension tokens;
  final Color? customColor;

  _NutritionPainter({
    required this.type,
    required this.tokens,
    this.customColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = size.width / 100.0;
    canvas.scale(scale, scale);

    switch (type) {
      case GymBroNutritionType.protein:
        _paintProtein(canvas);
        break;
      case GymBroNutritionType.carbs:
        _paintCarbs(canvas);
        break;
      case GymBroNutritionType.fat:
        _paintFat(canvas);
        break;
      case GymBroNutritionType.calories:
        _paintCalories(canvas);
        break;
      case GymBroNutritionType.water:
        _paintWater(canvas);
        break;
      case GymBroNutritionType.fruits:
        _paintFruits(canvas);
        break;
      case GymBroNutritionType.vegetables:
        _paintVegetables(canvas);
        break;
      case GymBroNutritionType.meat:
        _paintMeat(canvas);
        break;
      case GymBroNutritionType.eggs:
        _paintEggs(canvas);
        break;
      case GymBroNutritionType.rice:
        _paintRice(canvas);
        break;
      case GymBroNutritionType.supplements:
        _paintSupplements(canvas);
        break;
      case GymBroNutritionType.foodScanner:
        _paintFoodScanner(canvas);
        break;
      case GymBroNutritionType.fallback:
        _paintFallback(canvas);
        break;
    }

    canvas.restore();
  }

  void _paintFallback(Canvas canvas) {
    // Elegant nutritional meal cloche / serving plate
    final plate = Path()
      ..addOval(const Rect.fromLTWH(18, 70, 64, 16));
    canvas.drawPath(
      plate,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.fill,
    );

    // Cloche Dome
    final dome = Path()
      ..moveTo(24, 72)
      ..cubicTo(24, 38, 76, 38, 76, 72)
      ..close();
    canvas.drawPath(
      dome,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC9F36A), Color(0xFF65A30D)],
        ).createShader(const Rect.fromLTWH(24, 38, 52, 34)),
    );

    // Handle Knob
    canvas.drawCircle(const Offset(50, 34), 5, Paint()..color = const Color(0xFFF1F5F9));
  }

  void _paintProtein(Canvas canvas) {
    // Protein Shaker Bottle
    final bottle = Path()
      ..moveTo(34, 32)
      ..lineTo(66, 32)
      ..lineTo(60, 84)
      ..lineTo(40, 84)
      ..close();

    final bottlePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      ).createShader(const Rect.fromLTWH(34, 32, 32, 52));
    canvas.drawPath(bottle, bottlePaint);

    // Measurement hashes
    final hashPaint = Paint()
      ..color = Colors.white60
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(42, 50), const Offset(48, 50), hashPaint);
    canvas.drawLine(const Offset(42, 60), const Offset(50, 60), hashPaint);
    canvas.drawLine(const Offset(42, 70), const Offset(48, 70), hashPaint);

    // Shaker Cap & Flip Top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(30, 22, 40, 10), const Radius.circular(3)),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(44, 14, 12, 8), const Radius.circular(2)),
      Paint()..color = tokens.lime,
    );
  }

  void _paintCarbs(Canvas canvas) {
    // Golden Grain Ear / Wheat stalk
    final stem = Path()
      ..moveTo(50, 86)
      ..lineTo(50, 24);
    canvas.drawPath(
      stem,
      Paint()
        ..color = tokens.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Oval Grains
    void drawGrain(double cx, double cy, double angle) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawOval(
        const Rect.fromLTWH(-5, -9, 10, 18),
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
          ).createShader(const Rect.fromLTWH(-5, -9, 10, 18)),
      );
      canvas.restore();
    }

    for (int i = 0; i < 4; i++) {
      final y = 30.0 + (i * 12.0);
      drawGrain(42, y, -0.5);
      drawGrain(58, y, 0.5);
    }
  }

  void _paintFat(Canvas canvas) {
    // Healthy Fat: Golden Avocado / Oil drop
    final drop = Path()
      ..moveTo(50, 16)
      ..cubicTo(72, 46, 76, 76, 50, 84)
      ..cubicTo(24, 76, 28, 46, 50, 16)
      ..close();

    canvas.drawPath(
      drop,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.2),
          colors: [Color(0xFFFBBF24), Color(0xFFB45309)],
        ).createShader(const Rect.fromLTWH(24, 16, 52, 68)),
    );

    // Specular Highlight
    canvas.drawCircle(const Offset(42, 44), 5, Paint()..color = Colors.white54);
  }

  void _paintCalories(Canvas canvas) {
    // Athletic Energy Flame
    final flame = Path()
      ..moveTo(50, 14)
      ..cubicTo(68, 36, 78, 54, 74, 72)
      ..cubicTo(70, 86, 30, 86, 26, 72)
      ..cubicTo(22, 54, 38, 44, 44, 34)
      ..cubicTo(48, 42, 54, 44, 56, 36)
      ..close();

    canvas.drawPath(
      flame,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, 0.3),
          colors: [Color(0xFFF97316), Color(0xFFDC2626)],
        ).createShader(const Rect.fromLTWH(22, 14, 56, 72)),
    );

    // Inner Neon Core
    final core = Path()
      ..moveTo(50, 48)
      ..cubicTo(60, 60, 60, 76, 50, 80)
      ..cubicTo(40, 76, 40, 60, 50, 48)
      ..close();

    canvas.drawPath(
      core,
      Paint()..color = tokens.lime,
    );
  }

  void _paintWater(Canvas canvas) {
    // Pure Hydration Drop with ripples
    final drop = Path()
      ..moveTo(50, 18)
      ..cubicTo(68, 44, 72, 70, 50, 78)
      ..cubicTo(28, 70, 32, 44, 50, 18)
      ..close();

    canvas.drawPath(
      drop,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.3),
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        ).createShader(const Rect.fromLTWH(28, 18, 44, 60)),
    );

    // Ripple Rings at Bottom
    final ripple = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawOval(const Rect.fromLTWH(24, 78, 52, 10), ripple);
  }

  void _paintFruits(Canvas canvas) {
    // Crisp Apple
    final apple = Path()
      ..moveTo(50, 32)
      ..cubicTo(74, 28, 78, 76, 50, 84)
      ..cubicTo(22, 76, 26, 28, 50, 32)
      ..close();

    canvas.drawPath(
      apple,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
        ).createShader(const Rect.fromLTWH(22, 28, 56, 56)),
    );

    // Leaf
    canvas.drawOval(
      const Rect.fromLTWH(52, 18, 12, 6),
      Paint()..color = tokens.lime,
    );
  }

  void _paintVegetables(Canvas canvas) {
    // Broccoli / Greens Head
    final stem = RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 54, 12, 28), const Radius.circular(3));
    canvas.drawRRect(stem, Paint()..color = const Color(0xFF16A34A));

    // Florets
    final green = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(const Offset(36, 44), 14, green);
    canvas.drawCircle(const Offset(64, 44), 14, green);
    canvas.drawCircle(const Offset(50, 32), 16, green);

    canvas.drawCircle(const Offset(44, 38), 6, Paint()..color = tokens.lime);
  }

  void _paintMeat(Canvas canvas) {
    // Steak Fillet
    final steak = Path()
      ..moveTo(30, 42)
      ..cubicTo(40, 24, 76, 32, 78, 56)
      ..cubicTo(80, 78, 48, 84, 26, 68)
      ..cubicTo(18, 56, 22, 48, 30, 42)
      ..close();

    canvas.drawPath(
      steak,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFDC2626), Color(0xFF7F1D1D)],
        ).createShader(const Rect.fromLTWH(18, 24, 62, 60)),
    );

    // Marbling Seams
    final seam = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(38, 44), const Offset(56, 52), seam);
    canvas.drawLine(const Offset(48, 62), const Offset(66, 60), seam);
  }

  void _paintEggs(Canvas canvas) {
    // Two Eggs (Whole and Cracked)
    final egg = Path()
      ..addOval(const Rect.fromLTWH(26, 30, 30, 44));
    canvas.drawPath(
      egg,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFDF4E3), Color(0xFFD6C7A1)],
        ).createShader(const Rect.fromLTWH(26, 30, 30, 44)),
    );

    // Yolk on second egg
    canvas.drawCircle(const Offset(62, 54), 12, Paint()..color = tokens.gold);
    canvas.drawCircle(const Offset(62, 54), 18,
        Paint()..color = Colors.white.withOpacity(0.35));
  }

  void _paintRice(Canvas canvas) {
    // Bowl of Athletic Rice
    final bowl = Path()
      ..moveTo(22, 50)
      ..lineTo(78, 50)
      ..cubicTo(74, 82, 26, 82, 22, 50)
      ..close();

    canvas.drawPath(bowl, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(
        bowl,
        Paint()
          ..color = tokens.lime
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Steaming Rice Grains
    final riceGrains = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(50, 44), 4, riceGrains);
    canvas.drawCircle(const Offset(40, 46), 3.5, riceGrains);
    canvas.drawCircle(const Offset(60, 46), 3.5, riceGrains);
  }

  void _paintSupplements(Canvas canvas) {
    // Capsule / Pill
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate(-0.7);

    // Left Half (Neon Lime)
    final leftCap = RRect.fromRectAndCorners(
      const Rect.fromLTWH(-20, -9, 20, 18),
      topLeft: const Radius.circular(9),
      bottomLeft: const Radius.circular(9),
    );
    canvas.drawRRect(leftCap, Paint()..color = tokens.lime);

    // Right Half (Deep Slate)
    final rightCap = RRect.fromRectAndCorners(
      const Rect.fromLTWH(0, -9, 20, 18),
      topRight: const Radius.circular(9),
      bottomRight: const Radius.circular(9),
    );
    canvas.drawRRect(rightCap, Paint()..color = const Color(0xFF0F172A));
    canvas.restore();
  }

  void _paintFoodScanner(Canvas canvas) {
    // Visual Food Scanner Reticle
    final reticle = Paint()
      ..color = tokens.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Corners
    canvas.drawLine(const Offset(22, 34), const Offset(22, 22), reticle);
    canvas.drawLine(const Offset(22, 22), const Offset(34, 22), reticle);

    canvas.drawLine(const Offset(78, 34), const Offset(78, 22), reticle);
    canvas.drawLine(const Offset(78, 22), const Offset(66, 22), reticle);

    canvas.drawLine(const Offset(22, 66), const Offset(22, 78), reticle);
    canvas.drawLine(const Offset(22, 78), const Offset(34, 78), reticle);

    canvas.drawLine(const Offset(78, 66), const Offset(78, 78), reticle);
    canvas.drawLine(const Offset(78, 78), const Offset(66, 78), reticle);

    // Center Lens
    canvas.drawCircle(const Offset(50, 50), 10, reticle..strokeWidth = 2.0);
    canvas.drawCircle(
        const Offset(50, 50), 4, Paint()..color = const Color(0xFF38BDF8));
  }

  @override
  bool shouldRepaint(_NutritionPainter old) =>
      old.type != type || old.customColor != customColor;
}
