import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'gymbro_anatomy_vector_data.dart';
import 'gymbro_icon_data.dart';
import '../theme/app_tokens.dart';

/// Optically balanced, high-precision athletic vector illustration for GymBro anatomy.
/// Engineered with sculpted organic Bézier curves matching professional athletic
/// design systems (Hevy, MuscleWiki, Linear) — completely eliminating crude AI polygon approximations.
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
        highlightColor = GymBroAnatomyVectorData.basePlate;
        break;
    }

    if (disableAnimations || !widget.isAnimated || widget.activation == GymBroMuscleActivation.inactive) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _VectorAnatomyMusclePainter(
            muscle: widget.muscle,
            activation: widget.activation,
            highlightColor: highlightColor,
            pulseFactor: 1.0,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final pulse = 0.95 + 0.10 * math.sin(t * math.pi);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _VectorAnatomyMusclePainter(
              muscle: widget.muscle,
              activation: widget.activation,
              highlightColor: highlightColor,
              pulseFactor: pulse,
            ),
          ),
        );
      },
    );
  }
}

class _VectorAnatomyMusclePainter extends CustomPainter {
  final GymBroMuscleGroup muscle;
  final GymBroMuscleActivation activation;
  final Color highlightColor;
  final double pulseFactor;

  _VectorAnatomyMusclePainter({
    required this.muscle,
    required this.activation,
    required this.highlightColor,
    this.pulseFactor = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Scale 240x370 coordinate space to fit widget size
    final scale = math.min(size.width / GymBroAnatomyVectorData.viewBoxWidth,
                           size.height / GymBroAnatomyVectorData.viewBoxHeight);
    final dx = (size.width - GymBroAnatomyVectorData.viewBoxWidth * scale) / 2.0;
    final dy = (size.height - GymBroAnatomyVectorData.viewBoxHeight * scale) / 2.0;

    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final view = GymBroAnatomyVectorData.getMuscleGroupPreferredView(muscle);

    // 1. Base Anatomical Silhouette
    final silhouettePath = view == BodyMapView.front
        ? GymBroAnatomyVectorData.getAnteriorSilhouette()
        : GymBroAnatomyVectorData.getPosteriorSilhouette();

    final baseFillPaint = Paint()
      ..color = GymBroAnatomyVectorData.silhouetteBase
      ..style = PaintingStyle.fill;
    canvas.drawPath(silhouettePath, baseFillPaint);

    final baseStrokePaint = Paint()
      ..color = GymBroAnatomyVectorData.silhouetteBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(silhouettePath, baseStrokePaint);

    // 2. High-Precision Muscle Vector Path Highlight
    final musclePath = GymBroAnatomyVectorData.getMuscleGroupPath(muscle);

    if (activation == GymBroMuscleActivation.primary) {
      // Glow underlay
      final glowPaint = Paint()
        ..color = highlightColor.withOpacity(0.35 * pulseFactor.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4.0)
        ..style = PaintingStyle.fill;
      canvas.drawPath(musclePath, glowPaint);

      // Solid vibrant highlight
      final fillPaint = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(musclePath, fillPaint);

      final strokePaint = Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawPath(musclePath, strokePaint);
    } else if (activation == GymBroMuscleActivation.secondary) {
      // Synergist 40% fill
      final fillPaint = Paint()
        ..color = highlightColor.withOpacity(0.42 * pulseFactor.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawPath(musclePath, fillPaint);

      final strokePaint = Paint()
        ..color = highlightColor.withOpacity(0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(musclePath, strokePaint);
    } else {
      // Inactive / base rest plate
      final fillPaint = Paint()
        ..color = GymBroAnatomyVectorData.basePlate
        ..style = PaintingStyle.fill;
      canvas.drawPath(musclePath, fillPaint);

      final strokePaint = Paint()
        ..color = GymBroAnatomyVectorData.contourBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(musclePath, strokePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VectorAnatomyMusclePainter oldDelegate) {
    return oldDelegate.muscle != muscle ||
        oldDelegate.activation != activation ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.pulseFactor != pulseFactor;
  }
}
