import 'package:flutter/material.dart';

/// Material Design 3 Window Size Classes
enum WindowSizeClass {
  compact, // < 600 dp (mobile portrait)
  medium, // 600 - 839 dp (tablets portrait, foldables, mobile landscape)
  expanded, // >= 840 dp (tablets landscape, desktop)
}

/// Helper to query the active Material 3 Window Size Class
WindowSizeClass getWindowSizeClass(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return WindowSizeClass.compact;
  if (width < 840) return WindowSizeClass.medium;
  return WindowSizeClass.expanded;
}

/// Constrains max content width on tablets and large screens according to
/// Material 3 Window Size Classes (<600 compact, 600-839 medium, >=840 expanded),
/// preventing unnatural horizontal stretching of cards and content.
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;
  final AlignmentGeometry alignment;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.maxContentWidth = 840.0,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}

/// Bi-directionally aware navigation chevron that points in the direction of forward flow
/// (left in RTL Persian, right in LTR English).
class DirectionalChevron extends StatelessWidget {
  final double size;
  final Color? color;

  const DirectionalChevron({
    super.key,
    this.size = 14.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
      size: size,
      color: color,
    );
  }
}
