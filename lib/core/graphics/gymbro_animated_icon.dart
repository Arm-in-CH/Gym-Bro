import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'gymbro_icon_data.dart';
import 'gymbro_icon.dart';
import 'gymbro_equipment_illustration.dart';
import 'gymbro_nutrition_illustration.dart';

enum GymBroAnimationType {
  floatingDumbbell,
  liftingBarbell,
  rotatingStopwatch,
  pulsingEnergy,
  waterRipple,
  achievementShine,
  none,
}

/// A high-performance animated wrapper for GymBro visual assets.
class GymBroAnimatedIcon extends StatefulWidget {
  final Widget? child;
  final GymBroEquipmentType? equipment;
  final GymBroNutritionType? nutrition;
  final GymBroDashboardIconType? dashboardIcon;
  final GymBroAnimationType animationType;
  final double size;
  final Duration duration;
  final bool isAnimating;

  const GymBroAnimatedIcon({
    super.key,
    this.child,
    this.equipment,
    this.nutrition,
    this.dashboardIcon,
    this.animationType = GymBroAnimationType.pulsingEnergy,
    this.size = 32.0,
    this.duration = const Duration(milliseconds: 2000),
    this.isAnimating = true,
  });

  @override
  State<GymBroAnimatedIcon> createState() => _GymBroAnimatedIconState();
}

class _GymBroAnimatedIconState extends State<GymBroAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.isAnimating && widget.animationType != GymBroAnimationType.none) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant GymBroAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.isAnimating != oldWidget.isAnimating ||
        widget.animationType != oldWidget.animationType) {
      if (widget.isAnimating && widget.animationType != GymBroAnimationType.none) {
        if (!_controller.isAnimating) _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    if (widget.child != null) return widget.child!;
    if (widget.equipment != null) {
      return GymBroEquipmentIllustration(
        type: widget.equipment!,
        size: widget.size,
      );
    }
    if (widget.nutrition != null) {
      return GymBroNutritionIllustration(
        type: widget.nutrition!,
        size: widget.size,
      );
    }
    if (widget.dashboardIcon != null) {
      return GymBroIcon(
        icon: widget.dashboardIcon!,
        size: widget.size,
        active: true,
      );
    }
    return SizedBox(width: widget.size, height: widget.size);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating || widget.animationType == GymBroAnimationType.none) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(child: _buildContent()),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        switch (widget.animationType) {
          case GymBroAnimationType.floatingDumbbell:
            // Vertical bobbing + subtle rotation tilt
            final dy = math.sin(t * 2 * math.pi) * 3.0;
            final angle = math.sin(t * 2 * math.pi) * 0.08;
            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.rotate(
                angle: angle,
                child: child,
              ),
            );

          case GymBroAnimationType.liftingBarbell:
            // Smooth explosive press upward and controlled eccentric descend
            final lift = -math.sin(t * 2 * math.pi).clamp(0.0, 1.0) * 4.5;
            return Transform.translate(
              offset: Offset(0, lift),
              child: child,
            );

          case GymBroAnimationType.rotatingStopwatch:
            // Hand/body micro rotation
            final angle = (t * 2 * math.pi) * 0.1;
            return Transform.rotate(
              angle: math.sin(angle) * 0.15,
              child: child,
            );

          case GymBroAnimationType.pulsingEnergy:
            // Rhythmic heart/energy scale oscillation (1.0 to 1.1)
            final scale = 1.0 + (math.sin(t * 2 * math.pi) * 0.06);
            return Transform.scale(
              scale: scale,
              child: child,
            );

          case GymBroAnimationType.waterRipple:
            // Gentle wave sway
            final dx = math.cos(t * 2 * math.pi) * 2.0;
            final dy = math.sin(t * 2 * math.pi) * 2.0;
            return Transform.translate(
              offset: Offset(dx, dy),
              child: child,
            );

          case GymBroAnimationType.achievementShine:
            // Scale and slight angle shine
            final scale = 1.0 + (math.sin(t * 2 * math.pi).abs() * 0.08);
            return Transform.scale(
              scale: scale,
              child: child,
            );

          case GymBroAnimationType.none:
            return child!;
        }
      },
      child: _buildContent(),
    );
  }
}
