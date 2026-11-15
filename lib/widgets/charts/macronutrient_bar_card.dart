import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/localization/persian_utils.dart';

/// کارت تفکیک و پایش درشت‌مغذی‌ها (پروتئین، کربوهیدرات و چربی)
class MacronutrientBarCard extends StatelessWidget {
  final double consumedProtein;
  final int targetProtein;
  final double consumedCarbs;
  final int targetCarbs;
  final double consumedFat;
  final int targetFat;

  const MacronutrientBarCard({
    super.key,
    required this.consumedProtein,
    required this.targetProtein,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedFat,
    required this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    // Calculate energy contributions (Protein: 4 kcal/g, Carbs: 4 kcal/g, Fat: 9 kcal/g)
    final proteinKcal = consumedProtein * 4;
    final carbsKcal = consumedCarbs * 4;
    final fatKcal = consumedFat * 9;
    final totalKcal = proteinKcal + carbsKcal + fatKcal;

    final proteinPct = totalKcal > 0 ? ((proteinKcal / totalKcal) * 100).round() : 0;
    final carbsPct = totalKcal > 0 ? ((carbsKcal / totalKcal) * 100).round() : 0;
    final fatPct = totalKcal > 0 ? ((fatKcal / totalKcal) * 100).round() : 0;

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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفکیک درشت‌مغذی‌های مصرفی (Macros)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: tokens.cardElevated,
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Text(
                    'انرژی کل: ${PersianUtils.formatCalories(totalKcal.round())}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Protein bar
          _buildMacroRow(
            title: 'پروتئین خالص',
            consumed: consumedProtein,
            target: targetProtein.toDouble(),
            percentage: proteinPct,
            barColor: tokens.lime,
            icon: Icons.fitness_center_rounded,
            theme: theme,
            tokens: tokens,
          ),
          const SizedBox(height: AppSpacing.md),

          // Carbs bar
          _buildMacroRow(
            title: 'کربوهیدرات پیچیده',
            consumed: consumedCarbs,
            target: targetCarbs.toDouble(),
            percentage: carbsPct,
            barColor: tokens.cyan,
            icon: Icons.grain_rounded,
            theme: theme,
            tokens: tokens,
          ),
          const SizedBox(height: AppSpacing.md),

          // Fat bar
          _buildMacroRow(
            title: 'چربی‌های سالم',
            consumed: consumedFat,
            target: targetFat.toDouble(),
            percentage: fatPct,
            barColor: const Color(0xFFF43F5E), // Coral Pink
            icon: Icons.water_drop_rounded,
            theme: theme,
            tokens: tokens,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow({
    required String title,
    required double consumed,
    required double target,
    required int percentage,
    required Color barColor,
    required IconData icon,
    required ThemeData theme,
    required AppThemeExtension tokens,
  }) {
    final validTarget = target > 0 ? target : 1.0;
    final fraction = (consumed / validTarget).clamp(0.0, 1.0);
    final remaining = (validTarget - consumed) > 0 ? (validTarget - consumed) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            children: [
              Icon(icon, size: 16, color: barColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.15),
                  borderRadius: AppRadii.xsRadius,
                ),
                child: Text(
                  '${PersianUtils.toPersianDigits(percentage)}٪ کالری',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${PersianUtils.toPersianDigits(consumed.toInt())} / ${PersianUtils.toPersianDigits(target.toInt())}g',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Progress bar
        ClipRRect(
          borderRadius: AppRadii.pillRadius,
          child: Container(
            height: 10,
            width: double.infinity,
            color: tokens.cardElevated,
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: AppRadii.pillRadius,
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withOpacity(0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${PersianUtils.toPersianDigits((fraction * 100).toInt())}٪ از هدف محقق شده',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tokens.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                remaining > 0
                    ? '${PersianUtils.toPersianDigits(remaining.toInt())}g باقیمانده'
                    : 'تکمیل شده ✓',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: remaining > 0 ? tokens.textMuted : barColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
