import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/localization/persian_utils.dart';

/// ویجت هوشمند پایش هیدراتاسیون و مصرف آب روزانه با دکمه‌های سریع
class WaterTrackerCard extends StatelessWidget {
  final int consumedMl;
  final int targetMl;
  final String? dateLabel;
  final Function(int amount) onAddWater;
  final Function(int amount) onUndoWater;

  const WaterTrackerCard({
    super.key,
    required this.consumedMl,
    required this.targetMl,
    this.dateLabel,
    required this.onAddWater,
    required this.onUndoWater,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    final validTarget = targetMl > 0 ? targetMl : 3000;
    final fraction = (consumedMl / validTarget).clamp(0.0, 1.0);
    final remainingMl = (validTarget - consumedMl) > 0 ? validTarget - consumedMl : 0;
    final percentage = (fraction * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: tokens.cyan.withOpacity(0.15),
                        borderRadius: AppRadii.smRadius,
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: tokens.cyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'هیدراتاسیون و پایش آب روزانه',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (dateLabel != null && dateLabel!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              dateLabel!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: tokens.cyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: tokens.cyan.withOpacity(0.12),
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Text(
                    '${PersianUtils.formatPercentage(percentage)} از هدف',
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Visual Progress Bar & Values
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${PersianUtils.toPersianDigits(consumedMl)} / ${PersianUtils.toPersianDigits(validTarget)} میلی‌لیتر',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: tokens.cyan,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            remainingMl > 0
                                ? '${PersianUtils.toPersianDigits(remainingMl)}ml مانده'
                                : 'هدف روزانه تکمیل شد ✓',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: remainingMl > 0 ? tokens.textMuted : tokens.cyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: AppRadii.pillRadius,
                      child: Container(
                        height: 12,
                        width: double.infinity,
                        color: tokens.cardElevated,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerRight,
                          widthFactor: fraction,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [tokens.cyan.withOpacity(0.7), tokens.cyan],
                              ),
                              borderRadius: AppRadii.pillRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: tokens.cyan.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Action Buttons: +250ml, +500ml, Undo
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onAddWater(250),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.cardElevated,
                    foregroundColor: tokens.cyan,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.smRadius,
                      side: BorderSide(color: tokens.cyan.withOpacity(0.3)),
                    ),
                  ),
                  icon: const Icon(Icons.local_drink_rounded, size: 18),
                  label: const Text('+۲۵۰ml (لیوان)'),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onAddWater(500),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.cyan.withOpacity(0.15),
                    foregroundColor: tokens.cyan,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.smRadius,
                      side: BorderSide(color: tokens.cyan),
                    ),
                  ),
                  icon: const Icon(Icons.water_rounded, size: 18),
                  label: const Text('+۵۰۰ml (بطری)'),
                ),
              ),
              if (consumedMl > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  tooltip: 'کاهش ۲۵۰ میلی‌لیتر',
                  onPressed: () => onUndoWater(250),
                  icon: Icon(Icons.remove_circle_outline, color: tokens.textMuted, size: 22),
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.minTouchTarget,
                    minHeight: AppSpacing.minTouchTarget,
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
