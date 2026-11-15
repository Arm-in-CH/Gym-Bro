import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';

class WorkoutSessionProgressHeader extends StatelessWidget {
  final int completedSets;
  final int totalSets;
  final double totalVolumeKg;
  final bool warmupDone;
  final bool cooldownDone;

  const WorkoutSessionProgressHeader({
    super.key,
    required this.completedSets,
    required this.totalSets,
    required this.totalVolumeKg,
    required this.warmupDone,
    required this.cooldownDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final progressFraction =
        totalSets > 0 ? (completedSets / totalSets).clamp(0.0, 1.0) : 0.0;
    final percentageInt = (progressFraction * 100).toInt();

    return Container(
      padding: AppSpacing.paddingBase,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: tokens.lime, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'پیشرفت تمرین امروز',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: tokens.lime.withOpacity(0.18),
                  borderRadius: AppRadii.roundedSm,
                  border: Border.all(color: tokens.lime.withOpacity(0.4)),
                ),
                child: Text(
                  '${PersianUtils.toPersianDigits(percentageInt)}٪ تکمیل',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.lime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: AppDurations.normal,
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progressFraction),
              builder: (ctx, val, _) => LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: tokens.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(tokens.lime),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Quick stats row with Expanded to prevent text scale overflow
          Row(
            children: [
              Expanded(
                child: Text(
                  'ست‌ها: ${PersianUtils.toPersianDigits(completedSets)} از ${PersianUtils.toPersianDigits(totalSets)} ست',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'تناژ: ${PersianUtils.toPersianDigits(totalVolumeKg.toInt())} kg',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.lime,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
