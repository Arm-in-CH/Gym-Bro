import 'package:flutter/material.dart';
import '../../core/localization/persian_utils.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../state/app_state.dart';
import '../common/gymbro_cards.dart';

class CompactTelemetryStrip extends StatelessWidget {
  final AppState state;
  final AppThemeExtension tokens;
  final VoidCallback onOpenNutrition;

  const CompactTelemetryStrip({
    super.key,
    required this.state,
    required this.tokens,
    required this.onOpenNutrition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([state.hydrationState, state.nutritionState]),
      builder: (context, _) {
        // 1. Calories Metrics
        final consumedCalories = state.todayConsumedCalories;
        final targetCalories = state.nutritionPlan.dailyCalories;
        final calorieFraction = targetCalories > 0
            ? (consumedCalories / targetCalories).clamp(0.0, 1.0)
            : 0.0;
        final isOverCalorie = state.isOverCalorieLimit;

        // 2. Hydration Metrics
        final consumedWater = state.todayConsumedWaterMl;
        final targetWater = state.nutritionPlan.targetWaterMl > 0
            ? state.nutritionPlan.targetWaterMl
            : 2500;
        final waterFraction = targetWater > 0
            ? (consumedWater / targetWater).clamp(0.0, 1.0)
            : 0.0;
        final percentage = (waterFraction * 100).toInt();
        final lastWaterLog = state.getLastWaterLog(dateString: state.todayDateString);
        final lastLoggedAmount = lastWaterLog?.amountMl ?? 250;

        return LayoutBuilder(
          builder: (context, constraints) {
            final mediaQuery = MediaQuery.of(context);
            final textScale = mediaQuery.textScaler.scale(1.0);
            final isStacked = constraints.maxWidth < 460 || textScale > 1.25;

            final calorieCard = Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tokens.cardBackground.withOpacity(0.6),
                borderRadius: AppRadii.roundedMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 15,
                          color: isOverCalorie
                              ? tokens.gold
                              : const Color(0xFFFF5722)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'بودجه کالری و درشت‌مغذی‌ها',
                          style: AppTypography.caption(context).copyWith(
                            color: tokens.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    alignment: AlignmentDirectional.centerStart,
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Text(
                          PersianUtils.toPersianDigits(consumedCalories),
                          style: AppTypography.athleticLarge(context).copyWith(
                            fontSize: 22,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          ' / ${PersianUtils.toPersianDigits(targetCalories)} kcal',
                          style: AppTypography.caption(context).copyWith(
                            color: tokens.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadii.pillRadius,
                    child: LinearProgressIndicator(
                      value: calorieFraction,
                      backgroundColor: tokens.cardElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverCalorie ? tokens.gold : tokens.lime,
                      ),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      children: [
                        _MacroMiniBadge(
                          label: 'P',
                          amount: '${PersianUtils.toPersianDigits(state.todayConsumedProtein.toInt())}g',
                          color: const Color(0xFF4FC3F7),
                        ),
                        const SizedBox(width: 4),
                        _MacroMiniBadge(
                          label: 'C',
                          amount: '${PersianUtils.toPersianDigits(state.todayConsumedCarbs.toInt())}g',
                          color: const Color(0xFFFFB74D),
                        ),
                        const SizedBox(width: 4),
                        _MacroMiniBadge(
                          label: 'F',
                          amount: '${PersianUtils.toPersianDigits(state.todayConsumedFat.toInt())}g',
                          color: const Color(0xFFE57373),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            final hydrationCard = Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tokens.cardBackground.withOpacity(0.6),
                borderRadius: AppRadii.roundedMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.water_drop_rounded,
                                size: 15, color: tokens.cyan),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'مصرف آب و هیدراتاسیون',
                                style: AppTypography.caption(context).copyWith(
                                  color: tokens.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: tokens.cyan.withOpacity(0.18),
                          borderRadius: AppRadii.roundedXs,
                        ),
                        child: Text(
                          PersianUtils.formatPercentage(percentage),
                          textDirection: TextDirection.rtl,
                          style: AppTypography.caption(context).copyWith(
                            color: tokens.cyan,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    alignment: AlignmentDirectional.centerStart,
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Text(
                          PersianUtils.toPersianDigits(consumedWater),
                          style: AppTypography.athleticLarge(context).copyWith(
                            fontSize: 22,
                            color: tokens.cyan,
                          ),
                        ),
                        Text(
                          ' / ${PersianUtils.toPersianDigits(targetWater)} ml',
                          style: AppTypography.caption(context).copyWith(
                            color: tokens.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadii.pillRadius,
                    child: LinearProgressIndicator(
                      value: waterFraction,
                      backgroundColor: tokens.cardElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(tokens.cyan),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (consumedWater > 0) ...[
                          Tooltip(
                            message: 'لغو آخرین ثبت (${PersianUtils.toPersianDigits(lastLoggedAmount)} میلی‌لیتر)',
                            child: InkWell(
                              onTap: () => state.undoWater(
                                lastLoggedAmount,
                                dateString: state.todayDateString,
                              ),
                              borderRadius: AppRadii.roundedXs,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: tokens.cardElevated,
                                  borderRadius: AppRadii.roundedXs,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.undo_rounded,
                                        size: 13, color: tokens.textMuted),
                                    const SizedBox(width: 2),
                                    Text(
                                      PersianUtils.toPersianDigits(lastLoggedAmount),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: tokens.textMuted,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        InkWell(
                          onTap: () => state.logWater(
                            250,
                            dateString: state.todayDateString,
                          ),
                          borderRadius: AppRadii.roundedXs,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: tokens.cyan.withOpacity(0.18),
                              borderRadius: AppRadii.roundedXs,
                              border: Border.all(color: tokens.cyan.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 13, color: tokens.cyan),
                                const SizedBox(width: 2),
                                Text(
                                  '+۲۵۰ ml',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: tokens.cyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            return GymBroFlushCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              backgroundColor: tokens.cardElevated.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth > 60
                              ? constraints.maxWidth - 40
                              : 200,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tokens.lime,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'وضعیت روزانه: کالری و هیدراتاسیون',
                                style: AppTypography.caption(context).copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onOpenNutrition,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'جزئیات تغذیه',
                              style: AppTypography.caption(context).copyWith(
                                color: tokens.lime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 10, color: tokens.lime),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (isStacked) ...[
                    calorieCard,
                    const SizedBox(height: 10),
                    hydrationCard,
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: calorieCard),
                        const SizedBox(width: 10),
                        Expanded(child: hydrationCard),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MacroMiniBadge extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _MacroMiniBadge({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $amount',
        style: TextStyle(
          fontSize: 9.5,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
