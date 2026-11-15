import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Standard Rounded Linear Progress Bar
class GymBroLinearProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? progressColor;
  final Color? trackColor;
  final double height;

  const GymBroLinearProgress({
    super.key,
    required this.progress,
    this.progressColor,
    this.trackColor,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = progressColor ?? tokens.lime;
    final track = trackColor ?? tokens.cardElevated;
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: track,
        borderRadius: AppRadii.pillRadius,
      ),
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: clamped,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadii.pillRadius,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.35), blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular Athletic Ring Progress Indicator (Calories, Steps, Time)
class GymBroCircularRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? trackColor;
  final Widget? centerChild;

  const GymBroCircularRing({
    super.key,
    required this.progress,
    this.size = 80.0,
    this.strokeWidth = 7.0,
    this.progressColor,
    this.trackColor,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = progressColor ?? tokens.lime;
    final track = trackColor ?? tokens.cardElevated;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              progressColor: color,
              trackColor: track,
            ),
          ),
          if (centerChild != null) centerChild!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
