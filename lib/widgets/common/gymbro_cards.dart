import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Standard Premium Card Surface for GymBro Design System
/// Warm Graphite surface (#171D27) with subtle structural border and tactile Material Ink ripple.
class GymBroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const GymBroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.gradient,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final effectiveRadius = borderRadius ?? AppRadii.lgRadius;
    final effectiveBorder = borderColor ?? tokens.borderColor.withOpacity(0.5);
    final effectiveBg = backgroundColor ?? tokens.cardBackground;

    final decoration = BoxDecoration(
      color: gradient == null ? effectiveBg : null,
      gradient: gradient,
      borderRadius: effectiveRadius,
      border: Border.all(color: effectiveBorder, width: 1.0),
      boxShadow: AppShadows.subtle,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: tokens.lime.withOpacity(0.10),
          highlightColor: tokens.lime.withOpacity(0.04),
          child: Ink(
            width: width,
            height: height,
            padding: padding,
            decoration: decoration,
            child: child,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}

/// Elevated Card Treatment (Layered surface #202A37 with subtle depth)
class GymBroElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GymBroElevatedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final effectiveRadius = borderRadius ?? AppRadii.lgRadius;

    final decoration = BoxDecoration(
      color: tokens.cardElevated,
      borderRadius: effectiveRadius,
      border: Border.all(color: tokens.borderColor.withOpacity(0.4), width: 1.0),
      boxShadow: AppShadows.card,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: tokens.lime.withOpacity(0.10),
          child: Ink(
            padding: padding,
            decoration: decoration,
            child: child,
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}

/// Compact Metric Stat Card (for Heart Rate 123 bpm, Calories 824, etc.)
class GymBroMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final Widget? icon;
  final String? delta;
  final Color? accentColor;
  final VoidCallback? onTap;

  const GymBroMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.delta,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final accent = accentColor ?? tokens.lime;

    return GymBroCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: AppRadii.smRadius,
                  ),
                  child: Text(
                    delta!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Hero Banner Card (for Daily Challenge, Coach Spotlight, Announcements)
class GymBroHeroCard extends StatelessWidget {
  final Widget content;
  final Widget? backgroundAsset;
  final LinearGradient? overlayGradient;
  final VoidCallback? onTap;

  const GymBroHeroCard({
    super.key,
    required this.content,
    this.backgroundAsset,
    this.overlayGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    const radius = AppRadii.xlRadius;

    final defaultGradient = LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [
        tokens.cardBackground.withOpacity(0.95),
        tokens.cardElevated.withOpacity(0.80),
      ],
    );

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          if (backgroundAsset != null)
            Positioned.fill(child: backgroundAsset!),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: overlayGradient ?? defaultGradient,
              ),
            ),
          ),
          GymBroCard(
            onTap: onTap,
            backgroundColor: Colors.transparent,
            borderColor: tokens.borderColor.withOpacity(0.35),
            borderRadius: radius,
            child: content,
          ),
        ],
      ),
    );
  }
}
