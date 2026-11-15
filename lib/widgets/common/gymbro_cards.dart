import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';

/// Anti-Boxy Athletic Card Surface for GymBro Design System
/// Uses pure tonal depth (#171D27 over #0B0E13) eliminating rigid 1.2px bright borders around every component.
/// Provides optional flush/borderless styling and tactile Material ink response.
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
  final bool hasBorder;

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
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final effectiveRadius = borderRadius ?? AppRadii.lgRadius;
    final effectiveBorder = borderColor ?? tokens.borderColor.withOpacity(0.35);
    final effectiveBg = backgroundColor ?? tokens.cardBackground;

    final decoration = BoxDecoration(
      color: gradient == null ? effectiveBg : null,
      gradient: gradient,
      borderRadius: effectiveRadius,
      border: hasBorder ? Border.all(color: effectiveBorder, width: 1.0) : null,
      boxShadow: AppShadows.subtle,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: tokens.lime.withOpacity(0.08),
          highlightColor: tokens.lime.withOpacity(0.03),
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

/// Seamless, borderless flush card container for break-away athletic lists and blocks.
/// Replaces generic nested card boxes with organic whitespace and subtle surface elevation.
class GymBroFlushCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const GymBroFlushCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.base,
      vertical: AppSpacing.md,
    ),
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final effectiveBg = backgroundColor ?? tokens.cardBackground;
    final effectiveRadius = borderRadius ?? AppRadii.mdRadius;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: effectiveRadius,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: tokens.lime.withOpacity(0.08),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Ultra-subtle hairline linear separator for grouping content without nested box enclosures.
class GymBroHairlineDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final EdgeInsetsGeometry margin;

  const GymBroHairlineDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 0.5,
    this.color,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final effectiveColor = color ?? tokens.borderColor.withOpacity(0.20);

    return Padding(
      padding: margin,
      child: Divider(
        height: height,
        thickness: thickness,
        color: effectiveColor,
      ),
    );
  }
}

/// Elevated Card Treatment (Layered surface #202A37 with subtle depth)
class GymBroElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool hasBorder;

  const GymBroElevatedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.onTap,
    this.borderRadius,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final effectiveRadius = borderRadius ?? AppRadii.lgRadius;

    final decoration = BoxDecoration(
      color: tokens.cardElevated,
      borderRadius: effectiveRadius,
      border: hasBorder ? Border.all(color: tokens.borderColor.withOpacity(0.35), width: 1.0) : null,
      boxShadow: AppShadows.card,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: tokens.lime.withOpacity(0.08),
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

/// Compact Metric Stat Card with High-Impact Tabular Figures (Whoop / Nike Training Club style)
class GymBroMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final Widget? icon;
  final String? delta;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool hasBorder;

  const GymBroMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.delta,
    this.accentColor,
    this.onTap,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final accent = accentColor ?? tokens.lime;

    return GymBroCard(
      onTap: onTap,
      hasBorder: hasBorder,
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
                style: AppTypography.metricValue(
                  context,
                  size: 28,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: 11.5,
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
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: content,
          ),
          if (onTap != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: tokens.lime.withOpacity(0.12),
                  highlightColor: tokens.lime.withOpacity(0.05),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
