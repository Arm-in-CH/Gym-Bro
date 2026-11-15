import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

/// Reusable MD3-compliant state widget for Empty, Error, and Info states
class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final Widget? customGraphic;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    this.icon,
    this.customGraphic,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.isError = false,
    this.iconSize = 48.0,
  }) : assert(icon != null || customGraphic != null, 'Either icon or customGraphic must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final color = isError ? tokens.red : tokens.lime;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: iconSize + 28,
              height: iconSize + 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: customGraphic ?? Icon(icon!, size: iconSize, color: color),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isError ? tokens.red : theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                  height: 1.5,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  foregroundColor: color,
                ),
                icon:
                    Icon(isError ? Icons.refresh : Icons.arrow_back, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
