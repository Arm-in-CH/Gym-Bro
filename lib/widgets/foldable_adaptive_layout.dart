import 'package:flutter/material.dart';
import '../core/services/foldable_device_service.dart';

/// An adaptive two-pane layout designed for foldable inner displays and tabletop/flex postures.
/// It automatically avoids physical hinges and splits content into logical panes.
class FoldableTwoPane extends StatelessWidget {
  /// The primary pane (left pane in portrait book-fold, top pane in tabletop mode)
  final Widget pane1;

  /// The secondary pane (right pane in portrait book-fold, bottom pane in tabletop mode)
  final Widget pane2;

  /// Fallback widget for single/cover screens (if omitted, pane1 is used)
  final Widget? singlePane;

  /// Minimum screen width required to trigger side-by-side dual pane when no physical hinge is detected
  final double dualPaneMinWidth;

  /// Gap between panes if no physical hinge is present
  final double paneGap;

  const FoldableTwoPane({
    super.key,
    required this.pane1,
    required this.pane2,
    this.singlePane,
    this.dualPaneMinWidth = 660.0,
    this.paneGap = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final foldableService = FoldableDeviceService();
    foldableService.updateDisplayMetrics(
      screenSize: size,
      displayFeatures: mediaQuery.displayFeatures,
    );

    final hinge = foldableService.hingeInfo;

    // Check if in Tabletop / Flex mode with a horizontal hinge
    if (foldableService.isTabletopMode &&
        hinge != null &&
        hinge.orientation == HingeOrientation.horizontal) {
      final topHeight = hinge.bounds.top > 0
          ? hinge.bounds.top
          : (size.height / 2);
      final bottomHeight = size.height - hinge.bounds.bottom;

      return Column(
        children: [
          SizedBox(
            height: topHeight,
            width: double.infinity,
            child: pane1,
          ),
          // Hinge space avoidance
          SizedBox(height: hinge.bounds.height > 0 ? hinge.bounds.height : 12.0),
          Expanded(
            child: SizedBox(
              height: bottomHeight > 0 ? bottomHeight : null,
              width: double.infinity,
              child: pane2,
            ),
          ),
        ],
      );
    }

    // Check for vertical book-fold hinge
    if (hinge != null && hinge.orientation == HingeOrientation.vertical) {
      final leftWidth = hinge.bounds.left > 0
          ? hinge.bounds.left
          : ((size.width - hinge.bounds.width) / 2);
      final rightWidth = size.width - hinge.bounds.right;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftWidth,
            child: pane1,
          ),
          // Physical Hinge Gap
          SizedBox(width: hinge.bounds.width > 0 ? hinge.bounds.width : paneGap),
          SizedBox(
            width: rightWidth > 0 ? rightWidth : leftWidth,
            child: pane2,
          ),
        ],
      );
    }

    // Unfolded wide screen without active occluding hinge (e.g. flat state or wide inner screen)
    if (size.width >= dualPaneMinWidth && (foldableService.isUnfolded || !foldableService.isFolded)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: pane1),
          SizedBox(width: paneGap),
          Expanded(child: pane2),
        ],
      );
    }

    // Single screen / folded phone cover display
    return singlePane ?? pane1;
  }
}

/// A wrapper that pads its child away from physical hinge bounds
class HingeAwarePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets minimum;

  const HingeAwarePadding({
    super.key,
    required this.child,
    this.minimum = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final foldableService = FoldableDeviceService();
    foldableService.updateDisplayMetrics(
      screenSize: mediaQuery.size,
      displayFeatures: mediaQuery.displayFeatures,
    );

    final hinge = foldableService.hingeInfo;
    if (hinge == null || !hinge.isOccluding) {
      return Padding(padding: minimum, child: child);
    }

    final size = mediaQuery.size;
    EdgeInsets hingePadding = minimum;

    if (hinge.orientation == HingeOrientation.vertical) {
      final leftPadding = hinge.bounds.right;
      if (leftPadding < size.width / 2) {
        hingePadding = hingePadding.copyWith(left: leftPadding + minimum.left);
      }
    } else if (hinge.orientation == HingeOrientation.horizontal) {
      final topPadding = hinge.bounds.bottom;
      if (topPadding < size.height / 2) {
        hingePadding = hingePadding.copyWith(top: topPadding + minimum.top);
      }
    }

    return Padding(padding: hingePadding, child: child);
  }
}
