import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

/// Lightweight, 60fps-compliant skeleton shimmer placeholder for asynchronous loading
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  const SkeletonLoader.card({
    super.key,
    this.width = double.infinity,
    this.height = 100.0,
    this.borderRadius,
  });

  const SkeletonLoader.line({
    super.key,
    this.width = double.infinity,
    this.height = 16.0,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      if (_animController.isAnimating) {
        _animController.stop();
        _animController.value = 0.5;
      }
    } else {
      if (!_animController.isAnimating) {
        _animController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final r = widget.borderRadius ?? AppRadii.smRadius;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: tokens.cardElevated.withOpacity(_animation.value),
              borderRadius: r,
            ),
          );
        },
      ),
    );
  }
}
