import 'package:flutter/material.dart';
import '../common/gymbro_design_system.dart';

class QuickToolsBar extends StatelessWidget {
  final AppThemeExtension tokens;
  final VoidCallback onOpenMealScanner;
  final VoidCallback onOpenHomeMode;
  final VoidCallback onOpenAiCoach;

  const QuickToolsBar({
    super.key,
    required this.tokens,
    required this.onOpenMealScanner,
    required this.onOpenHomeMode,
    required this.onOpenAiCoach,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            title: 'برآورد غذا',
            subtitle: 'ورودی متنی · نتیجه دمو مشخص می‌شود',
            customIcon: const GymBroNutritionIllustration(
              type: GymBroNutritionType.foodScanner,
              size: 20,
            ),
            accentColor: tokens.lime,
            onTap: onOpenMealScanner,
          ),
        ),
        AppSpacing.wSm,
        Expanded(
          child: _QuickActionCard(
            title: 'مربی هوشمند AI',
            subtitle: 'مشاوره بیومکانیک',
            customIcon: GymBroIcon(
              icon: GymBroDashboardIconType.aiCoach,
              size: 20,
              active: true,
              activeColor: tokens.cyan,
            ),
            accentColor: tokens.cyan,
            onTap: onOpenAiCoach,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget customIcon;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.customIcon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;

    return Semantics(
      button: true,
      label: '$title، $subtitle',
      child: GymBroCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        onTap: onTap,
        borderColor: tokens.borderColor.withOpacity(0.5),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.18),
                ),
                child: customIcon,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodySmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption(context).copyWith(
                      color: tokens.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
