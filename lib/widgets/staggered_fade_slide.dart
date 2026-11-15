import 'package:flutter/material.dart';

/// Pass-through container replacing generic AI staggered cascading entrance animations.
/// Content mounts and renders immediately with solid structural presence and zero artificial latency.
class StaggeredFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration delayStep;
  final Duration duration;
  final double slideOffset;

  const StaggeredFadeSlide({
    super.key,
    required this.index,
    required this.child,
    this.delayStep = Duration.zero,
    this.duration = Duration.zero,
    this.slideOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) => child;
}
