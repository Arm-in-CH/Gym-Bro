import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'gymbro_icon_data.dart';
import '../theme/app_tokens.dart';

/// Optically balanced, human-crafted vector illustration for GymBro fitness equipment.
/// Engineered with realistic athletic proportions, smooth Bézier curves, and metallic
/// gradients matching Figma vector standards — completely free of stiff AI-generated lines.
class GymBroEquipmentIllustration extends StatelessWidget {
  final GymBroEquipmentType type;
  final double size;
  final Color? accentColor;
  final bool animate;

  const GymBroEquipmentIllustration({
    super.key,
    required this.type,
    this.size = 48.0,
    this.accentColor,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final lime = accentColor ?? tokens.lime;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _SculptedEquipmentPainter(
          type: type,
          lime: lime,
          gold: tokens.gold,
        ),
      ),
    );
  }
}

class _SculptedEquipmentPainter extends CustomPainter {
  final GymBroEquipmentType type;
  final Color lime;
  final Color gold;

  _SculptedEquipmentPainter({
    required this.type,
    required this.lime,
    required this.gold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Normalize coordinates to 100x100
    final scale = size.width / 100.0;
    canvas.scale(scale, scale);

    switch (type) {
      case GymBroEquipmentType.dumbbell:
        _paintSculptedDumbbell(canvas);
        break;
      case GymBroEquipmentType.barbell:
        _paintSculptedBarbell(canvas);
        break;
      case GymBroEquipmentType.weightPlate:
        _paintSculptedWeightPlate(canvas);
        break;
      case GymBroEquipmentType.kettlebell:
        _paintSculptedKettlebell(canvas);
        break;
      case GymBroEquipmentType.resistanceBand:
        _paintSculptedResistanceBand(canvas);
        break;
      case GymBroEquipmentType.benchPress:
        _paintSculptedBenchPress(canvas);
        break;
      case GymBroEquipmentType.treadmill:
        _paintSculptedTreadmill(canvas);
        break;
      case GymBroEquipmentType.exerciseBike:
        _paintSculptedExerciseBike(canvas);
        break;
      case GymBroEquipmentType.cableMachine:
        _paintSculptedCableMachine(canvas);
        break;
      case GymBroEquipmentType.pullUpBar:
        _paintSculptedPullUpBar(canvas);
        break;
      case GymBroEquipmentType.legPress:
        _paintSculptedLegPress(canvas);
        break;
      case GymBroEquipmentType.smithMachine:
        _paintSculptedSmithMachine(canvas);
        break;
      case GymBroEquipmentType.gymMachine:
        _paintSculptedGymMachine(canvas);
        break;
    }

    canvas.restore();
  }

  void _paintSculptedDumbbell(Canvas canvas) {
    // 45-degree angle rotation for dynamic athletic optical balance
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate(-math.pi / 4);

    // Contoured Chrome Handle with center knurling bulge
    final handlePath = Path();
    handlePath.moveTo(-22, -3.5);
    handlePath.cubicTo(-10, -5.5, 10, -5.5, 22, -3.5);
    handlePath.cubicTo(24, -3.5, 25, -2, 25, 0);
    handlePath.cubicTo(25, 2, 24, 3.5, 22, 3.5);
    handlePath.cubicTo(10, 5.5, -10, 5.5, -22, 3.5);
    handlePath.cubicTo(-24, 3.5, -25, 2, -25, 0);
    handlePath.cubicTo(-25, -2, -24, -3.5, -22, -3.5);
    handlePath.close();

    final chromePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF1F5F9), Color(0xFF94A3B8), Color(0xFF334155)],
      ).createShader(const Rect.fromLTWH(-25, -6, 50, 12));
    canvas.drawPath(handlePath, chromePaint);

    // Left Hex Head with 3D Chamfered Bézier facets
    final hexPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2D3748), Color(0xFF1A202C), Color(0xFF0F131A)],
      ).createShader(const Rect.fromLTWH(-40, -24, 20, 48));

    final strokePaint = Paint()
      ..color = lime.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final leftHead = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-36, -22, 14, 44),
      const Radius.circular(5),
    );
    canvas.drawRRect(leftHead, hexPaint);
    canvas.drawRRect(leftHead, strokePaint);

    // Right Hex Head
    final rightHead = RRect.fromRectAndRadius(
      const Rect.fromLTWH(22, -22, 14, 44),
      const Radius.circular(5),
    );
    canvas.drawRRect(rightHead, hexPaint);
    canvas.drawRRect(rightHead, strokePaint);

    // Inner Weight Flange Collars
    final collarPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-24, -12, 4, 24), const Radius.circular(2)),
        collarPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(20, -12, 4, 24), const Radius.circular(2)),
        collarPaint);

    canvas.restore();
  }

  void _paintSculptedBarbell(Canvas canvas) {
    // 20kg Olympic Standard Bar with Rotating Sleeves & Dual Bumper Plates
    final chromeBar = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8FAFC), Color(0xFFCBD5E1), Color(0xFF475569)],
      ).createShader(const Rect.fromLTWH(8, 47, 84, 6));

    // Shaft
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(8, 47, 84, 6), const Radius.circular(2)),
      chromeBar,
    );

    // Rotating Sleeve Bushing Collars
    final bushingPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(18, 43, 4, 14), const Radius.circular(1.5)),
      bushingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(78, 43, 4, 14), const Radius.circular(1.5)),
      bushingPaint,
    );

    // Dual Olympic Bumper Plates (Inner + Outer)
    final plateDark = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF263245), Color(0xFF141A24)],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

    final limeBorder = Paint()
      ..color = lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // Left Plates
    final leftOuter = RRect.fromRectAndRadius(const Rect.fromLTWH(22, 16, 7, 68), const Radius.circular(3));
    final leftInner = RRect.fromRectAndRadius(const Rect.fromLTWH(29, 22, 6, 56), const Radius.circular(2.5));
    canvas.drawRRect(leftOuter, plateDark);
    canvas.drawRRect(leftOuter, limeBorder);
    canvas.drawRRect(leftInner, plateDark);

    // Right Plates
    final rightInner = RRect.fromRectAndRadius(const Rect.fromLTWH(65, 22, 6, 56), const Radius.circular(2.5));
    final rightOuter = RRect.fromRectAndRadius(const Rect.fromLTWH(71, 16, 7, 68), const Radius.circular(3));
    canvas.drawRRect(rightInner, plateDark);
    canvas.drawRRect(rightOuter, plateDark);
    canvas.drawRRect(rightOuter, limeBorder);
  }

  void _paintSculptedWeightPlate(Canvas canvas) {
    const center = Offset(50, 50);

    // Outer Bumper Rim
    final outerPlate = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF2A3444), Color(0xFF141923)],
      ).createShader(Rect.fromCircle(center: center, radius: 44));
    canvas.drawCircle(center, 44, outerPlate);

    final limeRing = Paint()
      ..color = lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;
    canvas.drawCircle(center, 44, limeRing);

    // 3 Ergonomic Curved Tri-Grip Cutouts
    final cutoutPaint = Paint()
      ..color = const Color(0xFF090D13)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - (math.pi / 2);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final cutoutPath = Path();
      cutoutPath.moveTo(-16, -26);
      cutoutPath.cubicTo(-8, -32, 8, -32, 16, -26);
      cutoutPath.cubicTo(12, -20, -12, -20, -16, -26);
      cutoutPath.close();

      canvas.drawPath(cutoutPath, cutoutPaint);
      canvas.restore();
    }

    // Stainless Steel Center 50.4mm Hub
    final hubPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF64748B)],
      ).createShader(Rect.fromCircle(center: center, radius: 14));
    canvas.drawCircle(center, 14, hubPaint);
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFF090D13));
  }

  void _paintSculptedKettlebell(Canvas canvas) {
    const center = Offset(50, 60);

    // Seamless Curved Horn Handle with smooth Bézier arch
    final hornPath = Path();
    hornPath.moveTo(32, 46);
    hornPath.cubicTo(26, 18, 74, 18, 68, 46);
    final hornPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(hornPath, hornPaint);

    // Spherical Cast-Iron Bell with Flat Machined Base
    final bellPath = Path();
    bellPath.moveTo(24, 48);
    bellPath.cubicTo(16, 56, 18, 78, 30, 84); // Left sphere
    bellPath.lineTo(70, 84); // Flat base
    bellPath.cubicTo(82, 78, 84, 56, 76, 48); // Right sphere
    bellPath.close();

    final bellPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Rect.fromCircle(center: center, radius: 36));
    canvas.drawPath(bellPath, bellPaint);

    // Neon Lime Center Recess Badge
    final badgePaint = Paint()
      ..color = lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(const Offset(50, 62), 14, badgePaint);
  }

  void _paintSculptedResistanceBand(Canvas canvas) {
    // 3D Möbius Continuous Elastic Latex Loop
    final bandPath = Path();
    bandPath.moveTo(26, 32);
    bandPath.cubicTo(14, 46, 18, 74, 38, 80);
    bandPath.cubicTo(56, 86, 78, 74, 82, 54);
    bandPath.cubicTo(86, 34, 68, 20, 48, 22);
    bandPath.cubicTo(36, 24, 28, 28, 26, 32);

    final bandGlow = Paint()
      ..color = lime.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(bandPath, bandGlow);

    final bandPaint = Paint()
      ..shader = LinearGradient(
        colors: [lime, const Color(0xFF84CC16)],
      ).createShader(const Rect.fromLTWH(10, 10, 80, 80))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bandPath, bandPaint);
  }

  void _paintSculptedBenchPress(Canvas canvas) {
    // Heavy Steel Upright Posts
    final uprightPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 5.0..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(24, 30), const Offset(24, 76), uprightPaint);
    canvas.drawLine(const Offset(76, 30), const Offset(76, 76), uprightPaint);

    // J-Hooks (Neon Lime)
    final jHookPaint = Paint()..color = lime..strokeWidth = 3.0..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(20, 36)..lineTo(26, 36)..lineTo(26, 32), jHookPaint);
    canvas.drawPath(Path()..moveTo(74, 36)..lineTo(80, 36)..lineTo(80, 32), jHookPaint);

    // Barbell Resting on J-Hooks
    canvas.drawLine(const Offset(10, 34), const Offset(90, 34), Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 4.0..strokeCap = StrokeCap.round);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(14, 25, 4, 18), const Radius.circular(1.5)), Paint()..color = lime);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(82, 25, 4, 18), const Radius.circular(1.5)), Paint()..color = lime);

    // High-Density Vinyl Flat Bench Pad
    final padPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF242C38), Color(0xFF141920)],
      ).createShader(const Rect.fromLTWH(30, 52, 40, 14));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(26, 52, 48, 12), const Radius.circular(3)), padPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(26, 52, 48, 12), const Radius.circular(3)), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Bench Support Legs
    canvas.drawLine(const Offset(34, 64), const Offset(34, 76), uprightPaint);
    canvas.drawLine(const Offset(66, 64), const Offset(66, 76), uprightPaint);
    // Base Floor Crossbar
    canvas.drawLine(const Offset(18, 76), const Offset(82, 76), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 4.0..strokeCap = StrokeCap.round);
  }

  void _paintSculptedCableMachine(Canvas canvas) {
    final framePaint = Paint()..color = const Color(0xFF263245)..strokeWidth = 4.0..strokeCap = StrokeCap.round;

    // Dual Vertical Guide Columns
    canvas.drawLine(const Offset(22, 16), const Offset(22, 84), framePaint);
    canvas.drawLine(const Offset(78, 16), const Offset(78, 84), framePaint);
    // Top Arch Beam
    canvas.drawLine(const Offset(20, 16), const Offset(80, 16), framePaint);

    // Pulleys with Lime Accents
    final pulleyPaint = Paint()..color = lime;
    canvas.drawCircle(const Offset(30, 24), 5, pulleyPaint);
    canvas.drawCircle(const Offset(70, 24), 5, pulleyPaint);

    // Cable Curves (Catenary Bézier)
    final cablePaint = Paint()
      ..color = const Color(0xFF78CFE0)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final leftCable = Path()..moveTo(30, 24)..cubicTo(35, 45, 45, 55, 50, 62);
    final rightCable = Path()..moveTo(70, 24)..cubicTo(65, 45, 55, 55, 50, 62);
    canvas.drawPath(leftCable, cablePaint);
    canvas.drawPath(rightCable, cablePaint);

    // Chrome D-Handle
    canvas.drawCircle(const Offset(50, 66), 6, Paint()..color = const Color(0xFFF1F5F9)..style = PaintingStyle.stroke..strokeWidth = 2.0);
  }

  void _paintSculptedPullUpBar(Canvas canvas) {
    final steelPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 4.5..strokeCap = StrokeCap.round;
    final limeAccent = Paint()..color = lime..strokeWidth = 4.0..strokeCap = StrokeCap.round;

    // Wall Mount Diagonal Braces
    canvas.drawLine(const Offset(18, 20), const Offset(32, 50), steelPaint);
    canvas.drawLine(const Offset(82, 20), const Offset(68, 50), steelPaint);

    // Horizontal Forward Beams
    canvas.drawLine(const Offset(18, 50), const Offset(36, 50), steelPaint);
    canvas.drawLine(const Offset(82, 50), const Offset(64, 50), steelPaint);

    // Main Ergonomic Angled Chin-Up Bar with Lime Grips
    final barPath = Path();
    barPath.moveTo(12, 60);
    barPath.lineTo(28, 50);
    barPath.lineTo(72, 50);
    barPath.lineTo(88, 60);
    canvas.drawPath(barPath, steelPaint);

    // Outer Ergonomic Wide Grip Coatings
    canvas.drawLine(const Offset(12, 60), const Offset(26, 51), limeAccent);
    canvas.drawLine(const Offset(74, 51), const Offset(88, 60), limeAccent);

    // Center Neutral Parallel Bars
    canvas.drawLine(const Offset(42, 50), const Offset(42, 62), steelPaint);
    canvas.drawLine(const Offset(58, 50), const Offset(58, 62), steelPaint);
  }

  void _paintSculptedLegPress(Canvas canvas) {
    final steelPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 4.0..strokeCap = StrokeCap.round;

    // 45-Degree Main Linear Rails
    canvas.drawLine(const Offset(22, 78), const Offset(74, 26), steelPaint);
    canvas.drawLine(const Offset(32, 84), const Offset(84, 32), steelPaint);

    // Oversized Diamond Tread Footplate
    final footplate = Path();
    footplate.moveTo(66, 18);
    footplate.lineTo(84, 36);
    footplate.lineTo(80, 40);
    footplate.lineTo(62, 22);
    footplate.close();
    canvas.drawPath(footplate, Paint()..color = lime);

    // Reclined Ergonomic Bucket Seat
    final seatPad = Path();
    seatPad.moveTo(22, 74);
    seatPad.lineTo(38, 74);
    seatPad.lineTo(30, 52);
    seatPad.close();
    canvas.drawPath(seatPad, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(seatPad, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _paintSculptedSmithMachine(Canvas canvas) {
    final frame = Paint()..color = const Color(0xFF263245)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    final chromeRod = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2.0;

    // Dual Vertical Guide Rods
    canvas.drawLine(const Offset(26, 18), const Offset(26, 82), chromeRod);
    canvas.drawLine(const Offset(74, 18), const Offset(74, 82), chromeRod);

    // Outer Cage Columns
    canvas.drawLine(const Offset(20, 16), const Offset(20, 84), frame);
    canvas.drawLine(const Offset(80, 16), const Offset(80, 84), frame);
    canvas.drawLine(const Offset(18, 16), const Offset(82, 16), frame);
    canvas.drawLine(const Offset(18, 84), const Offset(82, 84), frame);

    // Captive Barbell with Linear Bushing Sleeves
    canvas.drawLine(const Offset(10, 48), const Offset(90, 48), Paint()..color = const Color(0xFFF1F5F9)..strokeWidth = 4.0);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24, 44, 5, 8), const Radius.circular(1.5)), Paint()..color = lime);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(71, 44, 5, 8), const Radius.circular(1.5)), Paint()..color = lime);
  }

  void _paintSculptedGymMachine(Canvas canvas) {
    final frame = Paint()..color = const Color(0xFF2D3748)..strokeWidth = 4.0..strokeCap = StrokeCap.round;

    // Shrouded Weight Stack Tower
    final stack = RRect.fromRectAndRadius(const Rect.fromLTWH(62, 20, 22, 64), const Radius.circular(4));
    canvas.drawRRect(stack, Paint()..color = const Color(0xFF151B24));
    canvas.drawRRect(stack, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Selector Pin Weight Plates (Lime Accent Line)
    canvas.drawLine(const Offset(66, 38), const Offset(80, 38), Paint()..color = lime..strokeWidth = 2.5);

    // Seated Workout Post & Contoured Seat/Back Pads
    canvas.drawLine(const Offset(26, 84), const Offset(56, 84), frame);
    canvas.drawLine(const Offset(36, 84), const Offset(36, 44), frame);
    // Seat
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30, 62, 18, 6), const Radius.circular(2)), Paint()..color = const Color(0xFF334155));
    // Backrest
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(42, 36, 6, 26), const Radius.circular(2)), Paint()..color = const Color(0xFF334155));
    // Press Arm
    canvas.drawLine(const Offset(44, 38), const Offset(24, 44), Paint()..color = lime..strokeWidth = 3.5..strokeCap = StrokeCap.round);
  }

  void _paintSculptedTreadmill(Canvas canvas) {
    // Low-profile running deck
    final deck = Path();
    deck.moveTo(14, 76);
    deck.lineTo(84, 68);
    deck.lineTo(86, 76);
    deck.lineTo(16, 84);
    deck.close();
    canvas.drawPath(deck, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(deck, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Swept-Back Aerodynamic Handrails
    final rail = Path();
    rail.moveTo(76, 70);
    rail.cubicTo(66, 52, 60, 40, 56, 34);
    rail.lineTo(44, 34);
    canvas.drawPath(rail, Paint()..color = lime..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round);

    // Angled Console Display
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(50, 26, 16, 10), const Radius.circular(2.5)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(50, 26, 16, 10), const Radius.circular(2.5)), Paint()..color = lime..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  void _paintSculptedExerciseBike(Canvas canvas) {
    // Heavy Perimeter-Weighted Flywheel
    const flywheelCenter = Offset(32, 64);
    canvas.drawCircle(flywheelCenter, 18, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(flywheelCenter, 18, Paint()..color = lime..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Steel Frame Tubes
    final frame = Paint()..color = const Color(0xFF334155)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    canvas.drawLine(flywheelCenter, const Offset(56, 64), frame);
    canvas.drawLine(const Offset(56, 64), const Offset(52, 40), frame);
    canvas.drawLine(flywheelCenter, const Offset(42, 34), frame);

    // Racing Saddle
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(46, 36, 14, 5), const Radius.circular(2)), Paint()..color = const Color(0xFF0F172A));

    // Aero Bullhorn Handlebars
    final bars = Path()..moveTo(38, 38)..lineTo(44, 30)..lineTo(36, 26);
    canvas.drawPath(bars, Paint()..color = lime..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _SculptedEquipmentPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.lime != lime ||
        oldDelegate.gold != gold;
  }
}
