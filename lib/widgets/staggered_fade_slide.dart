import 'dart:async';
import 'package:flutter/material.dart';

/// Staggered Entrance Animation widget for GymBro cards and sections.
/// Each card delays by 60ms * index. Slide distance: 12px from bottom.
/// Animates only on first build, not on subsequent rebuilds.
class StaggeredFadeSlide extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delayStep;
  final Duration duration;
  final double slideOffset;

  const StaggeredFadeSlide({
    super.key,
    required this.index,
    required this.child,
    this.delayStep = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 320),
    this.slideOffset = 12.0,
  });

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<double>(begin: widget.slideOffset, end: 0.0).animate(curved);

    final delay = widget.delayStep * widget.index;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _delayTimer?.cancel();
      _delayTimer = null;
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0.0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
