import 'package:flutter/material.dart';

/// GymBro custom page transition: Slide up 24px from bottom + Fade in.
/// Duration: 280ms, Curve: Curves.easeOutQuart.
class GymBroPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  GymBroPageRoute({
    required this.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInQuart,
            );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation);

            return AnimatedBuilder(
              animation: curvedAnimation,
              builder: (context, child) {
                final double dy = (1.0 - curvedAnimation.value) * 24.0;
                return Transform.translate(
                  offset: Offset(0.0, dy),
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
}
