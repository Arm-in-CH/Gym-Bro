import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/graphics/graphics.dart';
import '../models/user_level.dart';

class LevelBadge extends StatelessWidget {
  final UserLevel level;

  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final isElite = level == UserLevel.elite;

    return Semantics(
      label: 'سطح کاربری',
      value: level.displayNameFa,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isElite ? null : level.badgeColor.withOpacity(0.18),
          gradient: isElite
              ? const LinearGradient(
                  colors: [
                    Color(0xFFB8860B),
                    Color(0xFFFFD700),
                    Color(0xFFFFA500),
                  ],
                )
              : null,
          borderRadius: AppRadii.roundedSm,
          border: Border.all(
            color: isElite ? tokens.gold : level.badgeColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GymBroIcon(
              icon: GymBroDashboardIconType.achievements,
              size: 14,
              active: true,
              activeColor: isElite ? const Color(0xFF211500) : level.badgeColor,
            ),
            AppSpacing.wXs,
            Flexible(
              child: Text(
                level.displayNameFa,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isElite ? const Color(0xFF211500) : level.badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
