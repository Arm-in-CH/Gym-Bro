import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Standard Dialog Container for GymBro Design System
class GymBroDialog extends StatelessWidget {
  final String title;
  final Widget? icon;
  final Widget content;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  const GymBroDialog({
    super.key,
    required this.title,
    this.icon,
    required this.content,
    this.actions,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? icon,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => GymBroDialog(
        title: title,
        icon: icon,
        content: content,
        actions: actions,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: tokens.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.xlRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: tokens.textMuted),
                    onPressed: onClose ?? () => Navigator.pop(context),
                    tooltip: 'بستن',
                    constraints: const BoxConstraints(
                      minWidth: AppSpacing.minTouchTarget,
                      minHeight: AppSpacing.minTouchTarget,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Content Body
              content,

              // Action Buttons
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Standard Bottom Sheet Wrapper with Grabber Pill
class GymBroBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  const GymBroBottomSheet({
    super.key,
    this.title,
    required this.child,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GymBroBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.sheetRadius,
        border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber Handle Pill
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.borderColor.withOpacity(0.8),
                    borderRadius: AppRadii.pillRadius,
                  ),
                ),
              ),
              if (title != null) ...[
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
