import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Premium Full-Pill Primary Button for GymBro (Hero CTA: Begin Workout, Confirm, Save)
/// Designed with controlled tactile scale (0.98), minimum 48dp touch target, and subtle contrast.
class GymBroPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;
  final Color? customTextColor;
  final double height;

  const GymBroPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.customColor,
    this.customTextColor,
    this.height = 50.0,
  });

  @override
  State<GymBroPrimaryButton> createState() => _GymBroPrimaryButtonState();
}

class _GymBroPrimaryButtonState extends State<GymBroPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final bgColor = isEnabled
        ? (widget.customColor ?? tokens.lime)
        : tokens.borderColor.withOpacity(0.35);

    final fgColor = isEnabled
        ? (widget.customTextColor ?? tokens.textOnLime)
        : tokens.textMuted.withOpacity(0.6);

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (widget.prefixIcon != null) ...[
          widget.prefixIcon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.text,
              style: TextStyle(
                color: fgColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
        if (!widget.isLoading && widget.suffixIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          widget.suffixIcon!,
        ],
      ],
    );

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: AppDurations.fast,
      curve: AppCurves.sharp,
      child: Container(
        height: widget.height,
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.pillRadius,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: bgColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? widget.onPressed : null,
            onHighlightChanged: (pressed) {
              if (isEnabled && mounted) {
                setState(() => _isPressed = pressed);
              }
            },
            borderRadius: AppRadii.pillRadius,
            splashColor: Colors.black.withOpacity(0.12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium Secondary Charcoal Button (Previous, Cancel, Quick Start)
class GymBroSecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isFullWidth;
  final double height;

  const GymBroSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isFullWidth = false,
    this.height = 48.0,
  });

  @override
  State<GymBroSecondaryButton> createState() => _GymBroSecondaryButtonState();
}

class _GymBroSecondaryButtonState extends State<GymBroSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: AppDurations.fast,
      curve: AppCurves.sharp,
      child: Container(
        height: widget.height,
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        decoration: BoxDecoration(
          color: tokens.cardElevated,
          borderRadius: AppRadii.pillRadius,
          border: Border.all(color: tokens.borderColor.withOpacity(0.6), width: 1.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (pressed) {
              if (isEnabled && mounted) {
                setState(() => _isPressed = pressed);
              }
            },
            borderRadius: AppRadii.pillRadius,
            splashColor: tokens.lime.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Row(
                mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.prefixIcon != null) ...[
                    widget.prefixIcon!,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: isEnabled ? theme.colorScheme.onSurface : tokens.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (widget.suffixIcon != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    widget.suffixIcon!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// High-Touch Outline Button (Add set, Discard, Secondary actions)
class GymBroOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? borderColor;
  final Color? textColor;

  const GymBroOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = textColor ?? tokens.lime;
    final border = borderColor ?? tokens.lime.withOpacity(0.6);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: border, width: 1.2),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
        minimumSize: const Size(0, AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ghost Button (Clean transparent action with guaranteed 48dp touch target)
class GymBroGhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? textColor;

  const GymBroGhostButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = textColor ?? tokens.lime;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.smRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tactile Icon Button with guaranteed 48x48dp minimum touch target
class GymBroIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;

  const GymBroIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.borderColor,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final effectiveBg = backgroundColor ?? tokens.cardElevated;
    final effectiveBorder = borderColor ?? tokens.borderColor.withOpacity(0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.mdRadius,
        splashColor: tokens.lime.withOpacity(0.12),
        child: Tooltip(
          message: tooltip ?? '',
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: AppRadii.mdRadius,
              border: Border.all(color: effectiveBorder, width: 1.0),
            ),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}

/// Athletic Category Filter Chip (e.g. "سینه", "پا", "همه")
class GymBroPillFilter extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? icon;

  const GymBroPillFilter({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillRadius,
        splashColor: tokens.lime.withOpacity(0.12),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.sharp,
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? tokens.lime : tokens.cardElevated,
            borderRadius: AppRadii.pillRadius,
            border: Border.all(
              color: isSelected ? tokens.lime : tokens.borderColor.withOpacity(0.4),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? tokens.textOnLime : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
