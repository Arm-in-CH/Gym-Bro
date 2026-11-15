import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'gymbro_icon_data.dart';
import '../theme/app_tokens.dart';

/// Optically balanced, human-crafted vector illustration for GymBro human anatomy.
/// Engineered with sculpted organic Bézier curves matching professional athletic
/// design systems (Nike Training Club, Whoop, Linear) — eliminating rigid AI polygons.
class GymBroMuscleIllustration extends StatefulWidget {
  final GymBroMuscleGroup muscle;
  final GymBroMuscleActivation activation;
  final double size;
  final bool isAnimated;

  const GymBroMuscleIllustration({
    super.key,
    required this.muscle,
    this.activation = GymBroMuscleActivation.primary,
    this.size = 64.0,
    this.isAnimated = true,
  });

  @override
  State<GymBroMuscleIllustration> createState() => _GymBroMuscleIllustrationState();
}

class _GymBroMuscleIllustrationState extends State<GymBroMuscleIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (widget.isAnimated && widget.activation != GymBroMuscleActivation.inactive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GymBroMuscleIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && widget.activation != GymBroMuscleActivation.inactive) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Color highlightColor;
    switch (widget.activation) {
      case GymBroMuscleActivation.primary:
        highlightColor = tokens.lime;
        break;
      case GymBroMuscleActivation.secondary:
        highlightColor = tokens.gold;
        break;
      case GymBroMuscleActivation.inactive:
        highlightColor = const Color(0xFF475569);
        break;
    }

    final painter = CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _SculptedMusclePainter(
        muscle: widget.muscle,
        activation: widget.activation,
        highlightColor: highlightColor,
      ),
    );

    if (disableAnimations || !widget.isAnimated || widget.activation == GymBroMuscleActivation.inactive) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: painter,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final pulseScale = 1.0 + (math.sin(t * 2 * math.pi) * 0.035);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Transform.scale(
            scale: pulseScale,
            child: child,
          ),
        );
      },
      child: painter,
    );
  }
}

class _SculptedMusclePainter extends CustomPainter {
  final GymBroMuscleGroup muscle;
  final GymBroMuscleActivation activation;
  final Color highlightColor;

  _SculptedMusclePainter({
    required this.muscle,
    required this.activation,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Normalize coordinates to 100x100
    final scale = size.width / 100.0;
    canvas.scale(scale, scale);

    // 1. Organic Anatomical Torso Silhouette (Subtle Matte Steel Base)
    _drawSculptedTorso(canvas);

    // 2. High-Precision Muscle Group Highlight with Bézier Contours
    switch (muscle) {
      case GymBroMuscleGroup.chest:
        _drawPectorals(canvas);
        break;
      case GymBroMuscleGroup.back:
        _drawBackMuscles(canvas);
        break;
      case GymBroMuscleGroup.shoulders:
        _drawDeltoids(canvas);
        break;
      case GymBroMuscleGroup.biceps:
        _drawBiceps(canvas);
        break;
      case GymBroMuscleGroup.triceps:
        _drawTriceps(canvas);
        break;
      case GymBroMuscleGroup.forearms:
        _drawForearms(canvas);
        break;
      case GymBroMuscleGroup.abs:
        _drawRectusAbdominis(canvas);
        break;
      case GymBroMuscleGroup.obliques:
        _drawObliques(canvas);
        break;
      case GymBroMuscleGroup.quadriceps:
        _drawQuadriceps(canvas);
        break;
      case GymBroMuscleGroup.hamstrings:
        _drawHamstrings(canvas);
        break;
      case GymBroMuscleGroup.calves:
        _drawCalves(canvas);
        break;
      case GymBroMuscleGroup.glutes:
        _drawGlutes(canvas);
        break;
    }

    canvas.restore();
  }

  void _drawSculptedTorso(Canvas canvas) {
    final bodyFill = Paint()
      ..color = const Color(0xFF131924)
      ..style = PaintingStyle.fill;

    final bodyOutline = Paint()
      ..color = const Color(0xFF263245)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Head with athletic jawline
    final headPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(42, 6, 16, 18),
        const Radius.circular(8),
      ));
    canvas.drawPath(headPath, bodyFill);
    canvas.drawPath(headPath, bodyOutline);

    // Anatomical Torso Silhouette with smooth Bézier curves
    final torsoPath = Path();
    torsoPath.moveTo(46, 23); // Left neck base
    torsoPath.cubicTo(41, 24, 30, 27, 21, 33); // Left trapezius slope
    torsoPath.cubicTo(16, 36, 14, 44, 16, 50); // Left deltoid round cap
    torsoPath.cubicTo(18, 54, 25, 66, 28, 74); // Left latissimus V-taper
    torsoPath.cubicTo(29, 78, 31, 84, 35, 87); // Left iliac crest / hip
    torsoPath.cubicTo(38, 90, 47, 92, 50, 92); // Lower pelvic arch center
    torsoPath.cubicTo(53, 92, 62, 90, 65, 87); // Right pelvic arch
    torsoPath.cubicTo(69, 84, 71, 78, 72, 74); // Right iliac crest
    torsoPath.cubicTo(75, 66, 82, 54, 84, 50); // Right latissimus flare
    torsoPath.cubicTo(86, 44, 84, 36, 79, 33); // Right deltoid cap
    torsoPath.cubicTo(70, 27, 59, 24, 54, 23); // Right trapezius slope
    torsoPath.close();

    canvas.drawPath(torsoPath, bodyFill);
    canvas.drawPath(torsoPath, bodyOutline);

    // Subtle sternum & anatomical landmark line
    final midlinePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(50, 26), const Offset(50, 78), midlinePaint);
  }

  Paint _createMusclePaint({bool isGlow = false}) {
    if (isGlow && activation == GymBroMuscleActivation.primary) {
      return Paint()
        ..color = highlightColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    }
    return Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;
  }

  Paint _createStrokePaint() {
    return Paint()
      ..color = highlightColor.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  void _drawPectorals(Canvas canvas) {
    final fill = _createMusclePaint();
    final glow = _createMusclePaint(isGlow: true);
    final stroke = _createStrokePaint();

    // Left Pec (Clavicular + Sternocostal heads)
    final leftPec = Path();
    leftPec.moveTo(49, 34);
    leftPec.cubicTo(41, 34, 27, 36, 22, 33); // Clavicular border
    leftPec.cubicTo(19, 44, 22, 54, 32, 57); // Lower curved chest sweep
    leftPec.cubicTo(41, 59, 48, 54, 49, 47); // Sternal border
    leftPec.close();

    // Right Pec
    final rightPec = Path();
    rightPec.moveTo(51, 34);
    rightPec.cubicTo(59, 34, 73, 36, 78, 33);
    rightPec.cubicTo(81, 44, 78, 54, 68, 57);
    rightPec.cubicTo(59, 59, 52, 54, 51, 47);
    rightPec.close();

    if (activation == GymBroMuscleActivation.primary) {
      canvas.drawPath(leftPec, glow);
      canvas.drawPath(rightPec, glow);
    }
    canvas.drawPath(leftPec, fill);
    canvas.drawPath(leftPec, stroke);
    canvas.drawPath(rightPec, fill);
    canvas.drawPath(rightPec, stroke);
  }

  void _drawBackMuscles(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Trapezius Kite / Diamond
    final traps = Path();
    traps.moveTo(50, 22);
    traps.cubicTo(44, 25, 34, 28, 25, 32);
    traps.cubicTo(35, 38, 44, 47, 50, 56);
    traps.cubicTo(56, 47, 65, 38, 75, 32);
    traps.cubicTo(66, 28, 56, 25, 50, 22);
    traps.close();

    // Latissimus Dorsi Sweeping Wings
    final leftLat = Path();
    leftLat.moveTo(25, 46);
    leftLat.cubicTo(20, 52, 23, 64, 30, 72);
    leftLat.cubicTo(37, 75, 44, 66, 44, 58);
    leftLat.cubicTo(36, 52, 29, 48, 25, 46);
    leftLat.close();

    final rightLat = Path();
    rightLat.moveTo(75, 46);
    rightLat.cubicTo(80, 52, 77, 64, 70, 72);
    rightLat.cubicTo(63, 75, 56, 66, 56, 58);
    rightLat.cubicTo(64, 52, 71, 48, 75, 46);
    rightLat.close();

    canvas.drawPath(traps, fill);
    canvas.drawPath(traps, stroke);
    canvas.drawPath(leftLat, fill);
    canvas.drawPath(leftLat, stroke);
    canvas.drawPath(rightLat, fill);
    canvas.drawPath(rightLat, stroke);
  }

  void _drawDeltoids(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Left Deltoid Cap
    final leftDelt = Path();
    leftDelt.moveTo(23, 31);
    leftDelt.cubicTo(16, 34, 12, 42, 14, 50);
    leftDelt.cubicTo(16, 54, 21, 56, 24, 52);
    leftDelt.cubicTo(24, 43, 23, 36, 23, 31);
    leftDelt.close();

    // Right Deltoid Cap
    final rightDelt = Path();
    rightDelt.moveTo(77, 31);
    rightDelt.cubicTo(84, 34, 88, 42, 86, 50);
    rightDelt.cubicTo(84, 54, 79, 56, 76, 52);
    rightDelt.cubicTo(76, 43, 77, 36, 77, 31);
    rightDelt.close();

    canvas.drawPath(leftDelt, fill);
    canvas.drawPath(leftDelt, stroke);
    canvas.drawPath(rightDelt, fill);
    canvas.drawPath(rightDelt, stroke);
  }

  void _drawBiceps(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Left Bicep with muscle belly peak
    final leftBicep = Path();
    leftBicep.moveTo(15, 49);
    leftBicep.cubicTo(11, 54, 11, 62, 14, 68);
    leftBicep.cubicTo(18, 69, 21, 64, 21, 57);
    leftBicep.cubicTo(20, 52, 17, 50, 15, 49);
    leftBicep.close();

    // Right Bicep
    final rightBicep = Path();
    rightBicep.moveTo(85, 49);
    rightBicep.cubicTo(89, 54, 89, 62, 86, 68);
    rightBicep.cubicTo(82, 69, 79, 64, 79, 57);
    rightBicep.cubicTo(80, 52, 83, 50, 85, 49);
    rightBicep.close();

    canvas.drawPath(leftBicep, fill);
    canvas.drawPath(leftBicep, stroke);
    canvas.drawPath(rightBicep, fill);
    canvas.drawPath(rightBicep, stroke);
  }

  void _drawTriceps(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Left Triceps Horseshoe wrap
    final leftTri = Path();
    leftTri.moveTo(13, 46);
    leftTri.cubicTo(9, 50, 8, 60, 11, 67);
    leftTri.cubicTo(14, 67, 16, 60, 15, 52);
    leftTri.close();

    // Right Triceps Horseshoe wrap
    final rightTri = Path();
    rightTri.moveTo(87, 46);
    rightTri.cubicTo(91, 50, 92, 60, 89, 67);
    rightTri.cubicTo(86, 67, 84, 60, 85, 52);
    rightTri.close();

    canvas.drawPath(leftTri, fill);
    canvas.drawPath(leftTri, stroke);
    canvas.drawPath(rightTri, fill);
    canvas.drawPath(rightTri, stroke);
  }

  void _drawForearms(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Left Forearm Brachioradialis taper
    final leftForearm = Path();
    leftForearm.moveTo(13, 67);
    leftForearm.cubicTo(9, 72, 8, 80, 10, 86);
    leftForearm.cubicTo(13, 86, 15, 80, 15, 71);
    leftForearm.close();

    // Right Forearm
    final rightForearm = Path();
    rightForearm.moveTo(87, 67);
    rightForearm.cubicTo(91, 72, 92, 80, 90, 86);
    rightForearm.cubicTo(87, 86, 85, 80, 85, 71);
    rightForearm.close();

    canvas.drawPath(leftForearm, fill);
    canvas.drawPath(leftForearm, stroke);
    canvas.drawPath(rightForearm, fill);
    canvas.drawPath(rightForearm, stroke);
  }

  void _drawRectusAbdominis(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Organic 6-Pack Muscle Bellies with rounded corners
    final absRects = [
      // Upper 2
      RRect.fromRectAndRadius(const Rect.fromLTWH(39, 48, 9, 8), const Radius.circular(2.5)),
      RRect.fromRectAndRadius(const Rect.fromLTWH(52, 48, 9, 8), const Radius.circular(2.5)),
      // Mid 2
      RRect.fromRectAndRadius(const Rect.fromLTWH(38, 58, 10, 9), const Radius.circular(2.5)),
      RRect.fromRectAndRadius(const Rect.fromLTWH(52, 58, 10, 9), const Radius.circular(2.5)),
      // Lower 2
      RRect.fromRectAndRadius(const Rect.fromLTWH(39, 69, 9, 10), const Radius.circular(2.5)),
      RRect.fromRectAndRadius(const Rect.fromLTWH(52, 69, 9, 10), const Radius.circular(2.5)),
    ];

    for (final r in absRects) {
      canvas.drawRRect(r, fill);
      canvas.drawRRect(r, stroke);
    }
  }

  void _drawObliques(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Left Obliques & Serratus Anterior fingers
    final leftOblique = Path();
    leftOblique.moveTo(33, 56);
    leftOblique.cubicTo(27, 60, 26, 72, 33, 78);
    leftOblique.cubicTo(36, 78, 38, 68, 36, 58);
    leftOblique.close();

    // Right Obliques
    final rightOblique = Path();
    rightOblique.moveTo(67, 56);
    rightOblique.cubicTo(73, 60, 74, 72, 67, 78);
    rightOblique.cubicTo(64, 78, 62, 68, 64, 58);
    rightOblique.close();

    canvas.drawPath(leftOblique, fill);
    canvas.drawPath(leftOblique, stroke);
    canvas.drawPath(rightOblique, fill);
    canvas.drawPath(rightOblique, stroke);
  }

  void _drawQuadriceps(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Left Quad Sweep & Vastus Medialis teardrop
    final leftQuad = Path();
    leftQuad.moveTo(37, 86);
    leftQuad.cubicTo(32, 92, 28, 98, 31, 100);
    leftQuad.cubicTo(37, 100, 44, 94, 45, 87);
    leftQuad.close();

    // Right Quad Sweep
    final rightQuad = Path();
    rightQuad.moveTo(63, 86);
    rightQuad.cubicTo(68, 92, 72, 98, 69, 100);
    rightQuad.cubicTo(63, 100, 56, 94, 55, 87);
    rightQuad.close();

    canvas.drawPath(leftQuad, fill);
    canvas.drawPath(leftQuad, stroke);
    canvas.drawPath(rightQuad, fill);
    canvas.drawPath(rightQuad, stroke);
  }

  void _drawHamstrings(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    final leftHam = Path();
    leftHam.moveTo(36, 88);
    leftHam.cubicTo(31, 92, 30, 98, 33, 100);
    leftHam.cubicTo(38, 98, 43, 93, 44, 88);
    leftHam.close();

    final rightHam = Path();
    rightHam.moveTo(64, 88);
    rightHam.cubicTo(69, 92, 70, 98, 67, 100);
    rightHam.cubicTo(62, 98, 57, 93, 56, 88);
    rightHam.close();

    canvas.drawPath(leftHam, fill);
    canvas.drawPath(leftHam, stroke);
    canvas.drawPath(rightHam, fill);
    canvas.drawPath(rightHam, stroke);
  }

  void _drawCalves(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    // Left Gastrocnemius heart-shaped curve
    final leftCalf = Path();
    leftCalf.moveTo(32, 98);
    leftCalf.cubicTo(28, 99, 29, 101, 33, 101);
    leftCalf.close();

    final rightCalf = Path();
    rightCalf.moveTo(68, 98);
    rightCalf.cubicTo(72, 99, 71, 101, 67, 101);
    rightCalf.close();

    canvas.drawPath(leftCalf, fill);
    canvas.drawPath(leftCalf, stroke);
    canvas.drawPath(rightCalf, fill);
    canvas.drawPath(rightCalf, stroke);
  }

  void _drawGlutes(Canvas canvas) {
    final fill = _createMusclePaint();
    final stroke = _createStrokePaint();

    final leftGlute = Path();
    leftGlute.moveTo(35, 78);
    leftGlute.cubicTo(29, 81, 31, 89, 44, 90);
    leftGlute.cubicTo(47, 86, 46, 80, 44, 78);
    leftGlute.close();

    final rightGlute = Path();
    rightGlute.moveTo(65, 78);
    rightGlute.cubicTo(71, 81, 69, 89, 56, 90);
    rightGlute.cubicTo(53, 86, 54, 80, 56, 78);
    rightGlute.close();

    canvas.drawPath(leftGlute, fill);
    canvas.drawPath(leftGlute, stroke);
    canvas.drawPath(rightGlute, fill);
    canvas.drawPath(rightGlute, stroke);
  }

  @override
  bool shouldRepaint(covariant _SculptedMusclePainter oldDelegate) {
    return oldDelegate.muscle != muscle ||
        oldDelegate.activation != activation ||
        oldDelegate.highlightColor != highlightColor;
  }
}
