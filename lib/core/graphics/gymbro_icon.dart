import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'gymbro_icon_data.dart';

/// Unified premium vector icon for GymBro dashboard, navigation, and actions.
class GymBroIcon extends StatelessWidget {
  final dynamic icon; // GymBroDashboardIconType or GymBroNavIconType
  final double size;
  final bool active;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? semanticLabel;

  const GymBroIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.active = false,
    this.activeColor,
    this.inactiveColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? const Color(0xFFC9F36A);
    final effectiveInactiveColor = inactiveColor ?? const Color(0xFF94A3B8);

    return Semantics(
      label: semanticLabel ?? _defaultLabel(),
      child: CustomPaint(
        size: Size(size, size),
        painter: _GymBroIconPainter(
          icon: icon,
          active: active,
          activeColor: effectiveActiveColor,
          inactiveColor: effectiveInactiveColor,
        ),
      ),
    );
  }

  String _defaultLabel() {
    if (icon is GymBroDashboardIconType) {
      return (icon as GymBroDashboardIconType).name;
    } else if (icon is GymBroNavIconType) {
      return (icon as GymBroNavIconType).name;
    }
    return 'gymbro_icon';
  }
}

class _GymBroIconPainter extends CustomPainter {
  final dynamic icon;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;

  _GymBroIconPainter({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
  });

  Color get primaryColor => active ? activeColor : inactiveColor;
  Color get metallicColor => active ? const Color(0xFFF1F5F9) : const Color(0xFF64748B);
  Color get accentGold => const Color(0xFFF59E0B);

  @override
  void paint(Canvas canvas, Size size) {
    if (icon is GymBroDashboardIconType) {
      _paintDashboardIcon(canvas, size, icon as GymBroDashboardIconType);
    } else if (icon is GymBroNavIconType) {
      _paintNavIcon(canvas, size, icon as GymBroNavIconType);
    }
  }

  void _paintDashboardIcon(Canvas canvas, Size size, GymBroDashboardIconType type) {
    switch (type) {
      case GymBroDashboardIconType.workout:
        _paintWorkout(canvas, size);
        break;
      case GymBroDashboardIconType.trainingPlans:
        _paintTrainingPlans(canvas, size);
        break;
      case GymBroDashboardIconType.exerciseHistory:
        _paintExerciseHistory(canvas, size);
        break;
      case GymBroDashboardIconType.timer:
        _paintTimer(canvas, size);
        break;
      case GymBroDashboardIconType.stopwatch:
        _paintStopwatch(canvas, size);
        break;
      case GymBroDashboardIconType.calendar:
        _paintCalendar(canvas, size);
        break;
      case GymBroDashboardIconType.progress:
        _paintProgress(canvas, size);
        break;
      case GymBroDashboardIconType.statistics:
        _paintStatistics(canvas, size);
        break;
      case GymBroDashboardIconType.personalRecord:
        _paintPersonalRecord(canvas, size);
        break;
      case GymBroDashboardIconType.notification:
        _paintNotification(canvas, size);
        break;
      case GymBroDashboardIconType.profile:
        _paintProfile(canvas, size);
        break;
      case GymBroDashboardIconType.settings:
        _paintSettings(canvas, size);
        break;
      case GymBroDashboardIconType.achievements:
        _paintAchievements(canvas, size);
        break;
      case GymBroDashboardIconType.goals:
        _paintGoals(canvas, size);
        break;
      case GymBroDashboardIconType.focusedTraining:
        _paintFocusedTraining(canvas, size);
        break;
      case GymBroDashboardIconType.homeMode:
        _paintHomeMode(canvas, size);
        break;
      case GymBroDashboardIconType.aiCoach:
        _paintAiCoach(canvas, size);
        break;
    }
  }

  void _paintNavIcon(Canvas canvas, Size size, GymBroNavIconType type) {
    switch (type) {
      case GymBroNavIconType.home:
        _paintHomeMode(canvas, size);
        break;
      case GymBroNavIconType.workout:
        _paintWorkout(canvas, size);
        break;
      case GymBroNavIconType.nutrition:
        _paintNutritionNav(canvas, size);
        break;
      case GymBroNavIconType.marketplace:
        _paintMarketplace(canvas, size);
        break;
      case GymBroNavIconType.profile:
        _paintProfile(canvas, size);
        break;
      case GymBroNavIconType.aiCoach:
        _paintAiCoach(canvas, size);
        break;
    }
  }

  // ================= PAINTER IMPLEMENTATIONS =================

  void _paintWorkout(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bold Athletic Dumbbell (Fitbod / Nike Training Club hybrid style)
    // Angled at 45 degrees: center at (0.5, 0.5)
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = active ? primaryColor : primaryColor.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final innerPlateFill = Paint()
      ..color = active ? metallicColor : metallicColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Outer & inner plate shapes for barbell ends
    final path = Path();

    // Rotate canvas around center by -45 degrees for clean proportional dumbbell geometry
    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(-math.pi / 4);

    // Thick center knurled handle bar
    final barRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.44, height: h * 0.14),
      Radius.circular(w * 0.05),
    );
    final barPath = Path()..addRRect(barRect);
    if (active) {
      canvas.drawShadow(barPath, activeColor, 2.0, false);
    }
    canvas.drawRRect(barRect, fillPaint);
    canvas.drawRRect(barRect, strokePaint);

    // Knurling ribs on handle
    final gripPaint = Paint()
      ..color = active ? const Color(0xFF0F172A) : metallicColor
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-w * 0.08, -h * 0.05), Offset(-w * 0.08, h * 0.05), gripPaint);
    canvas.drawLine(Offset(0, -h * 0.05), Offset(0, h * 0.05), gripPaint);
    canvas.drawLine(Offset(w * 0.08, -h * 0.05), Offset(w * 0.08, h * 0.05), gripPaint);

    // Left outer plate (larger)
    final leftOuterRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.32, 0), width: w * 0.10, height: h * 0.52),
      Radius.circular(w * 0.04),
    );
    // Left inner plate
    final leftInnerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.23, 0), width: w * 0.08, height: h * 0.38),
      Radius.circular(w * 0.03),
    );

    // Right inner plate
    final rightInnerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.23, 0), width: w * 0.08, height: h * 0.38),
      Radius.circular(w * 0.03),
    );
    // Right outer plate (larger)
    final rightOuterRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.32, 0), width: w * 0.10, height: h * 0.52),
      Radius.circular(w * 0.04),
    );

    path.addRRect(leftOuterRect);
    path.addRRect(leftInnerRect);
    path.addRRect(rightInnerRect);
    path.addRRect(rightOuterRect);

    if (active) {
      canvas.drawShadow(path, activeColor, 2.0, false);
    }

    // Draw plates with fill + stroke outline
    canvas.drawRRect(leftInnerRect, innerPlateFill);
    canvas.drawRRect(leftInnerRect, strokePaint);
    canvas.drawRRect(leftOuterRect, fillPaint);
    canvas.drawRRect(leftOuterRect, strokePaint);

    canvas.drawRRect(rightInnerRect, innerPlateFill);
    canvas.drawRRect(rightInnerRect, strokePaint);
    canvas.drawRRect(rightOuterRect, fillPaint);
    canvas.drawRRect(rightOuterRect, strokePaint);

    canvas.restore();
  }

  void _paintTrainingPlans(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Clipboard body
    final bodyPaint = Paint()
      ..color = metallicColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.2, w * 0.64, h * 0.72),
      Radius.circular(w * 0.1),
    );
    canvas.drawRRect(rect, bodyPaint);

    // Top clip
    final clipPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.35, h * 0.1, w * 0.3, h * 0.14),
        Radius.circular(w * 0.05),
      ),
      clipPaint,
    );

    // Checklist ticks
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.32, h * 0.42), Offset(w * 0.68, h * 0.42), linePaint);
    canvas.drawLine(Offset(w * 0.32, h * 0.58), Offset(w * 0.68, h * 0.58), linePaint);
    canvas.drawLine(Offset(w * 0.32, h * 0.74), Offset(w * 0.55, h * 0.74), linePaint);
  }

  void _paintExerciseHistory(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Circular arrow
    final arcPaint = Paint()
      ..color = metallicColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.36);
    canvas.drawArc(rect, 0.4, math.pi * 1.6, false, arcPaint);

    // Arrowhead
    final arrowPath = Path();
    arrowPath.moveTo(w * 0.54, h * 0.06);
    arrowPath.lineTo(w * 0.54, h * 0.22);
    arrowPath.lineTo(w * 0.42, h * 0.14);
    arrowPath.close();

    final fillPaint = Paint()..color = primaryColor;
    canvas.drawPath(arrowPath, fillPaint);

    // Center clock hands
    final handPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.5), Offset(w * 0.5, h * 0.3), handPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.5), Offset(w * 0.65, h * 0.5), handPaint);
  }

  void _paintTimer(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bold Athletic Stopwatch / Timer (filled body + crisp stroke + active shadow)
    final path = Path();
    final center = Offset(w * 0.5, h * 0.54);
    final radius = w * 0.36;

    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = active ? primaryColor.withOpacity(0.20) : metallicColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    // Outer Dial
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    if (active) {
      canvas.drawShadow(path, activeColor, 2.0, false);
    }
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, strokePaint);

    // Active progress arc sector inside dial
    final arcPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.72),
      -math.pi / 2,
      math.pi * 1.35,
      false,
      arcPaint,
    );

    // Center pin
    final pinPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.07, pinPaint);

    // Hand pointing to 1:30
    final handPaint = Paint()
      ..color = active ? const Color(0xFF0F172A) : metallicColor
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(w * 0.68, h * 0.38), handPaint);

    // Top Pusher / Crown
    final crownPath = Path();
    final crownRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.41, h * 0.06, w * 0.18, h * 0.11),
      Radius.circular(w * 0.03),
    );
    crownPath.addRRect(crownRect);
    canvas.drawRRect(crownRect, pinPaint);
    canvas.drawRRect(crownRect, strokePaint);

    // Side secondary lap button at 2 o'clock
    final lapPaint = Paint()
      ..color = metallicColor
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.74, h * 0.26), Offset(w * 0.83, h * 0.17), lapPaint);
  }

  void _paintStopwatch(Canvas canvas, Size size) {
    _paintTimer(canvas, size);
  }

  void _paintCalendar(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final borderPaint = Paint()
      ..color = metallicColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.7),
      Radius.circular(w * 0.1),
    );
    canvas.drawRRect(rect, borderPaint);

    // Header divider
    canvas.drawLine(Offset(w * 0.15, h * 0.42), Offset(w * 0.85, h * 0.42), borderPaint);

    // Rings
    final ringPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.32, h * 0.12), Offset(w * 0.32, h * 0.24), ringPaint);
    canvas.drawLine(Offset(w * 0.68, h * 0.12), Offset(w * 0.68, h * 0.24), ringPaint);

    // Workout dot marked
    canvas.drawCircle(Offset(w * 0.5, h * 0.64), w * 0.1, Paint()..color = primaryColor);
  }

  void _paintProgress(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Upward zig-zag trending path
    final path = Path();
    path.moveTo(w * 0.15, h * 0.75);
    path.lineTo(w * 0.38, h * 0.52);
    path.lineTo(w * 0.55, h * 0.64);
    path.lineTo(w * 0.85, h * 0.25);

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Peak arrow
    final arrow = Path();
    arrow.moveTo(w * 0.68, h * 0.25);
    arrow.lineTo(w * 0.85, h * 0.25);
    arrow.lineTo(w * 0.85, h * 0.42);
    final arrowPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(arrow, arrowPaint);
  }

  void _paintStatistics(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // 3 bars with gradient-like styling
    barPaint.color = metallicColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.52, w * 0.16, h * 0.36), Radius.circular(w * 0.05)),
      barPaint,
    );

    barPaint.color = primaryColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.42, h * 0.28, w * 0.16, h * 0.6), Radius.circular(w * 0.05)),
      barPaint,
    );

    barPaint.color = metallicColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.66, h * 0.40, w * 0.16, h * 0.48), Radius.circular(w * 0.05)),
      barPaint,
    );
  }

  void _paintPersonalRecord(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bold Athletic Trophy & Medal (Fitbod / Nike Training Club hybrid style)
    final strokePaint = Paint()
      ..color = active ? primaryColor : accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cupFill = Paint()
      ..color = active ? primaryColor : accentGold.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // 1. Trophy Cup Bowl Path
    final cupPath = Path();
    cupPath.moveTo(w * 0.28, h * 0.20);
    cupPath.lineTo(w * 0.72, h * 0.20);
    cupPath.lineTo(w * 0.67, h * 0.48);
    cupPath.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.33, h * 0.48);
    cupPath.close();

    if (active) {
      canvas.drawShadow(cupPath, activeColor, 2.0, false);
    }
    canvas.drawPath(cupPath, cupFill);
    canvas.drawPath(cupPath, strokePaint);

    // Star / Number 1 badge inside cup
    final starPaint = Paint()
      ..color = active ? const Color(0xFF0F172A) : Colors.white
      ..style = PaintingStyle.fill;
    final starPath = Path();
    starPath.moveTo(w * 0.50, h * 0.26);
    starPath.lineTo(w * 0.53, h * 0.33);
    starPath.lineTo(w * 0.60, h * 0.33);
    starPath.lineTo(w * 0.55, h * 0.38);
    starPath.lineTo(w * 0.57, h * 0.45);
    starPath.lineTo(w * 0.50, h * 0.40);
    starPath.lineTo(w * 0.43, h * 0.45);
    starPath.lineTo(w * 0.45, h * 0.38);
    starPath.lineTo(w * 0.40, h * 0.33);
    starPath.lineTo(w * 0.47, h * 0.33);
    starPath.close();
    canvas.drawPath(starPath, starPaint);

    // 2. Bold Handles (Filled loops + stroke)
    final handleStroke = Paint()
      ..color = strokePaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;

    final leftHandle = Path();
    leftHandle.moveTo(w * 0.28, h * 0.24);
    leftHandle.cubicTo(w * 0.12, h * 0.24, w * 0.12, h * 0.44, w * 0.32, h * 0.44);
    canvas.drawPath(leftHandle, handleStroke);

    final rightHandle = Path();
    rightHandle.moveTo(w * 0.72, h * 0.24);
    rightHandle.cubicTo(w * 0.88, h * 0.24, w * 0.88, h * 0.44, w * 0.68, h * 0.44);
    canvas.drawPath(rightHandle, handleStroke);

    // 3. Trophy Stem
    final stemPaint = Paint()
      ..color = active ? metallicColor : metallicColor.withOpacity(0.8)
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.50, h * 0.60), Offset(w * 0.50, h * 0.73), stemPaint);

    // 4. Solid Pedestal Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.79), width: w * 0.44, height: h * 0.12),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(baseRect, Paint()..color = active ? primaryColor : metallicColor);
    canvas.drawRRect(baseRect, strokePaint);
  }

  void _paintNotification(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bellPaint = Paint()
      ..color = metallicColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(w * 0.5, h * 0.16);
    path.cubicTo(w * 0.3, h * 0.3, w * 0.25, h * 0.55, w * 0.2, h * 0.7);
    path.lineTo(w * 0.8, h * 0.7);
    path.cubicTo(w * 0.75, h * 0.55, w * 0.7, h * 0.3, w * 0.5, h * 0.16);
    canvas.drawPath(path, bellPaint);

    // Clapper
    canvas.drawCircle(Offset(w * 0.5, h * 0.82), w * 0.08, Paint()..color = metallicColor);

    // Top loop
    canvas.drawArc(Rect.fromCircle(center: Offset(w * 0.5, h * 0.16), radius: w * 0.08), math.pi, math.pi, false, bellPaint);

    // Active unread badge dot
    if (active) {
      canvas.drawCircle(Offset(w * 0.76, h * 0.22), w * 0.12, Paint()..color = primaryColor);
    }
  }

  void _paintProfile(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bold Athletic Persona: filled head circle + muscular torso arc + crisp outline
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = active ? primaryColor : primaryColor.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final path = Path();

    // 1. Head circle
    final headCenter = Offset(w * 0.50, h * 0.30);
    final headRadius = w * 0.18;
    path.addOval(Rect.fromCircle(center: headCenter, radius: headRadius));

    // 2. Muscular Torso Arc (Traps, Delts, Shoulders)
    final torsoPath = Path();
    torsoPath.moveTo(w * 0.14, h * 0.86);
    torsoPath.lineTo(w * 0.86, h * 0.86);
    torsoPath.lineTo(w * 0.86, h * 0.80);
    torsoPath.cubicTo(w * 0.86, h * 0.58, w * 0.70, h * 0.52, w * 0.50, h * 0.52);
    torsoPath.cubicTo(w * 0.30, h * 0.52, w * 0.14, h * 0.58, w * 0.14, h * 0.80);
    torsoPath.close();

    path.addPath(torsoPath, Offset.zero);

    if (active) {
      canvas.drawShadow(path, activeColor, 2.0, false);
    }

    // Head
    canvas.drawCircle(headCenter, headRadius, fillPaint);
    canvas.drawCircle(headCenter, headRadius, strokePaint);

    // Torso
    canvas.drawPath(torsoPath, fillPaint);
    canvas.drawPath(torsoPath, strokePaint);

    // Athletic collarbone / neck notch accent
    final collarPaint = Paint()
      ..color = active ? const Color(0xFF0F172A) : metallicColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.44, h * 0.56), Offset(w * 0.50, h * 0.62), collarPaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.56), Offset(w * 0.50, h * 0.62), collarPaint);
  }

  void _paintSettings(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mechanical gear
    final gearPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08;

    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.22, gearPaint);

    // 8 teeth around perimeter
    final toothPaint = Paint()
      ..color = metallicColor
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final x1 = w * 0.5 + math.cos(angle) * (w * 0.26);
      final y1 = h * 0.5 + math.sin(angle) * (h * 0.26);
      final x2 = w * 0.5 + math.cos(angle) * (w * 0.40);
      final y2 = h * 0.5 + math.sin(angle) * (h * 0.40);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), toothPaint);
    }
  }

  void _paintAchievements(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Diamond medal
    final medalPath = Path();
    medalPath.moveTo(w * 0.5, h * 0.12);
    medalPath.lineTo(w * 0.84, h * 0.46);
    medalPath.lineTo(w * 0.5, h * 0.8);
    medalPath.lineTo(w * 0.16, h * 0.46);
    medalPath.close();

    final medalPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(medalPath, medalPaint);

    // Inner star
    final starPaint = Paint()..color = accentGold;
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.12, starPaint);
  }

  void _paintGoals(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Concentric target rings
    final outerPaint = Paint()
      ..color = metallicColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, outerPaint);

    final midPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.22, midPaint);

    // Bullseye
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.09, Paint()..color = accentGold);
  }

  void _paintFocusedTraining(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tactical crosshair
    final reticlePaint = Paint()
      ..color = metallicColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.34, reticlePaint);

    final tickPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.08), Offset(w * 0.5, h * 0.24), tickPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.76), Offset(w * 0.5, h * 0.92), tickPaint);
    canvas.drawLine(Offset(w * 0.08, h * 0.5), Offset(w * 0.24, h * 0.5), tickPaint);
    canvas.drawLine(Offset(w * 0.76, h * 0.5), Offset(w * 0.92, h * 0.5), tickPaint);

    // Lightning bolt in center
    final bolt = Path();
    bolt.moveTo(w * 0.52, h * 0.34);
    bolt.lineTo(w * 0.44, h * 0.50);
    bolt.lineTo(w * 0.52, h * 0.50);
    bolt.lineTo(w * 0.46, h * 0.66);
    bolt.lineTo(w * 0.58, h * 0.48);
    bolt.lineTo(w * 0.50, h * 0.48);
    bolt.close();

    final boltPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bolt, boltPaint);
  }

  void _paintHomeMode(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bold Athletic Home shape: filled roof triangle + outlined walls + door rectangle + shadow
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final roofFill = Paint()
      ..color = active ? primaryColor : primaryColor.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final wallFill = Paint()
      ..color = active ? primaryColor.withOpacity(0.20) : metallicColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final path = Path();

    // 1. Triangular Roof
    final roofPath = Path();
    roofPath.moveTo(w * 0.50, h * 0.16);
    roofPath.lineTo(w * 0.88, h * 0.48);
    roofPath.lineTo(w * 0.12, h * 0.48);
    roofPath.close();

    // 2. House Body / Walls
    final wallRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.20, h * 0.46, w * 0.80, h * 0.86),
      Radius.circular(w * 0.04),
    );

    path.addPath(roofPath, Offset.zero);
    path.addRRect(wallRect);

    if (active) {
      canvas.drawShadow(path, activeColor, 2.0, false);
    }

    // Draw Roof
    canvas.drawPath(roofPath, roofFill);
    canvas.drawPath(roofPath, strokePaint);

    // Draw Walls
    canvas.drawRRect(wallRect, wallFill);
    canvas.drawRRect(wallRect, strokePaint);

    // 3. Athletic Door Rectangle
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.40, h * 0.58, w * 0.60, h * 0.86),
      topLeft: Radius.circular(w * 0.04),
      topRight: Radius.circular(w * 0.04),
    );
    canvas.drawRRect(doorRect, Paint()..color = active ? primaryColor : metallicColor);
    canvas.drawRRect(doorRect, strokePaint);
  }

  void _paintAiCoach(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bold AI Coach: High-impact Lightning Bolt & Neural Diamond Hybrid
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = active ? primaryColor : primaryColor.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    // Diamond Neural Halo
    final haloPath = Path();
    haloPath.moveTo(w * 0.50, h * 0.12);
    haloPath.lineTo(w * 0.86, h * 0.50);
    haloPath.lineTo(w * 0.50, h * 0.88);
    haloPath.lineTo(w * 0.14, h * 0.50);
    haloPath.close();

    final haloFill = Paint()
      ..color = active ? primaryColor.withOpacity(0.18) : metallicColor.withOpacity(0.10)
      ..style = PaintingStyle.fill;
    canvas.drawPath(haloPath, haloFill);
    canvas.drawPath(haloPath, strokePaint);

    // Center Lightning Energy Bolt (Nike Athletic Style)
    final boltPath = Path();
    boltPath.moveTo(w * 0.54, h * 0.18);
    boltPath.lineTo(w * 0.36, h * 0.48);
    boltPath.lineTo(w * 0.50, h * 0.48);
    boltPath.lineTo(w * 0.44, h * 0.82);
    boltPath.lineTo(w * 0.66, h * 0.44);
    boltPath.lineTo(w * 0.52, h * 0.44);
    boltPath.close();

    if (active) {
      canvas.drawShadow(boltPath, activeColor, 2.0, false);
    }
    canvas.drawPath(boltPath, fillPaint);
    canvas.drawPath(boltPath, strokePaint);

    // Brain Circuit Node accents
    final nodePaint = Paint()
      ..color = active ? const Color(0xFF0F172A) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.12), w * 0.04, nodePaint);
    canvas.drawCircle(Offset(w * 0.86, h * 0.50), w * 0.04, nodePaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.88), w * 0.04, nodePaint);
    canvas.drawCircle(Offset(w * 0.14, h * 0.50), w * 0.04, nodePaint);
  }

  void _paintNutritionNav(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bold Athletic Apple: filled D-shape body + leaf + bite cut-out
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = active ? primaryColor : primaryColor.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    // Apple body path with natural bottom indents
    final applePath = Path();
    applePath.moveTo(w * 0.50, h * 0.32);
    applePath.cubicTo(w * 0.32, h * 0.22, w * 0.14, h * 0.38, w * 0.16, h * 0.60);
    applePath.cubicTo(w * 0.18, h * 0.82, w * 0.36, h * 0.88, w * 0.50, h * 0.84);
    applePath.cubicTo(w * 0.64, h * 0.88, w * 0.82, h * 0.82, w * 0.84, h * 0.60);
    applePath.cubicTo(w * 0.86, h * 0.38, w * 0.68, h * 0.22, w * 0.50, h * 0.32);
    applePath.close();

    // Bite cut-out arc on upper-right flank
    final bitePath = Path();
    bitePath.addOval(Rect.fromCircle(center: Offset(w * 0.85, h * 0.50), radius: w * 0.14));

    // Combined path with bite difference
    final appleWithBite = Path.combine(PathOperation.difference, applePath, bitePath);

    if (active) {
      canvas.drawShadow(appleWithBite, activeColor, 2.0, false);
    }
    canvas.drawPath(appleWithBite, fillPaint);
    canvas.drawPath(appleWithBite, strokePaint);

    // Curved Stem
    final stemPaint = Paint()
      ..color = metallicColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    final stem = Path();
    stem.moveTo(w * 0.50, h * 0.32);
    stem.quadraticBezierTo(w * 0.48, h * 0.20, w * 0.54, h * 0.14);
    canvas.drawPath(stem, stemPaint);

    // Crisp Filled Leaf pointing right
    final leafPath = Path();
    leafPath.moveTo(w * 0.54, h * 0.22);
    leafPath.quadraticBezierTo(w * 0.72, h * 0.16, w * 0.74, h * 0.26);
    leafPath.quadraticBezierTo(w * 0.62, h * 0.30, w * 0.54, h * 0.22);
    leafPath.close();

    final leafFill = Paint()
      ..color = active ? primaryColor : metallicColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, leafFill);
    canvas.drawPath(leafPath, strokePaint);
  }

  void _paintMarketplace(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bold Athletic Marketplace / Store: filled facade + awning arch + door
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final facadeFill = Paint()
      ..color = active ? primaryColor.withOpacity(0.20) : metallicColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final awningFill = Paint()
      ..color = active ? primaryColor : primaryColor.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final path = Path();

    // 1. Building Facade Body
    final facadeRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.16, h * 0.36, w * 0.84, h * 0.86),
      Radius.circular(w * 0.04),
    );

    // 2. Awning Roof Arch / Gable
    final awningPath = Path();
    awningPath.moveTo(w * 0.12, h * 0.38);
    awningPath.lineTo(w * 0.24, h * 0.18);
    awningPath.lineTo(w * 0.76, h * 0.18);
    awningPath.lineTo(w * 0.88, h * 0.38);
    awningPath.close();

    path.addRRect(facadeRect);
    path.addPath(awningPath, Offset.zero);

    if (active) {
      canvas.drawShadow(path, activeColor, 2.0, false);
    }

    // Draw Facade
    canvas.drawRRect(facadeRect, facadeFill);
    canvas.drawRRect(facadeRect, strokePaint);

    // Draw Awning
    canvas.drawPath(awningPath, awningFill);
    canvas.drawPath(awningPath, strokePaint);

    // Awning stripes
    final stripePaint = Paint()
      ..color = active ? const Color(0xFF0F172A) : metallicColor
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.38, h * 0.18), Offset(w * 0.36, h * 0.38), stripePaint);
    canvas.drawLine(Offset(w * 0.50, h * 0.18), Offset(w * 0.50, h * 0.38), stripePaint);
    canvas.drawLine(Offset(w * 0.62, h * 0.18), Offset(w * 0.64, h * 0.38), stripePaint);

    // 3. Arched Entrance Door
    final doorPath = Path();
    doorPath.moveTo(w * 0.38, h * 0.86);
    doorPath.lineTo(w * 0.38, h * 0.58);
    doorPath.cubicTo(w * 0.38, h * 0.48, w * 0.62, h * 0.48, w * 0.62, h * 0.58);
    doorPath.lineTo(w * 0.62, h * 0.86);
    doorPath.close();

    final doorFill = Paint()
      ..color = active ? primaryColor : metallicColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(doorPath, doorFill);
    canvas.drawPath(doorPath, strokePaint);

    // Athletic Foundation step
    final stepPaint = Paint()
      ..color = active ? primaryColor : metallicColor
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.10, h * 0.88), Offset(w * 0.90, h * 0.88), stepPaint);
  }

  @override
  bool shouldRepaint(covariant _GymBroIconPainter oldDelegate) {
    return oldDelegate.icon != icon ||
        oldDelegate.active != active ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
