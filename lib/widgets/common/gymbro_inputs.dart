import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Standard Rounded Input Field for GymBro Design System
/// Minimum 48dp touch target, directionality-aware RTL layout, and defined states (default, focused, error, disabled).
class GymBroTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final int maxLines;
  final TextDirection? textDirection;

  const GymBroTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.errorText,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.maxLines = 1,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    final effectiveBorderColor = !enabled
        ? tokens.borderColor.withOpacity(0.2)
        : errorText != null
            ? tokens.red
            : tokens.borderColor.withOpacity(0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: enabled ? tokens.textMuted : tokens.textMuted.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          decoration: BoxDecoration(
            color: enabled ? tokens.cardElevated : tokens.cardBackground.withOpacity(0.5),
            borderRadius: AppRadii.lgRadius,
            border: Border.all(
              color: effectiveBorderColor,
              width: errorText != null ? 1.4 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            readOnly: readOnly,
            enabled: enabled,
            onTap: onTap,
            maxLines: maxLines,
            textDirection: textDirection,
            style: TextStyle(
              color: enabled ? theme.colorScheme.onSurface : tokens.textMuted.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: tokens.textMuted.withOpacity(0.55),
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: suffixIcon,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadii.lgRadius,
                borderSide: BorderSide(color: tokens.lime, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 13, color: tokens.red),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: TextStyle(
                    color: tokens.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
