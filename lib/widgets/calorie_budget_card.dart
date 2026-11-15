import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';

class CalorieBudgetCard extends StatelessWidget {
  final int consumedCalories;
  final int targetCalories;
  final double consumedProtein;
  final int targetProtein;
  final double consumedCarbs;
  final int targetCarbs;
  final double consumedFat;
  final int targetFat;
  final bool isOverLimit;
  final int overdraftCalories;

  const CalorieBudgetCard({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
    required this.consumedProtein,
    required this.targetProtein,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedFat,
    required this.targetFat,
    required this.isOverLimit,
    required this.overdraftCalories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final progress =
        (consumedCalories / (targetCalories > 0 ? targetCalories : 1))
            .clamp(0.0, 1.0);
    final ringColor = isOverLimit ? theme.colorScheme.error : tokens.lime;

    return Container(
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isOverLimit
              ? theme.colorScheme.error.withOpacity(0.5)
              : tokens.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'بودجه کالری و درشت‌مغذی‌ها',
                style: theme.textTheme.titleMedium,
              ),
              if (isOverLimit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Icon(Icons.warning_amber_rounded,
                          size: AppSpacing.base,
                          color: theme.colorScheme.error),
                    ),
                    AppSpacing.wXs,
                    Text(
                      'هشدار اضافه کالری!',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          AppSpacing.hBase,

          // Main Section: Circular Progress Ring + Macros
          LayoutBuilder(
            builder: (context, constraints) {
              final ringWidget = Semantics(
                label: 'کالری مصرف شده',
                value:
                    '${PersianUtils.toPersianDigits(consumedCalories)} از ${PersianUtils.toPersianDigits(targetCalories)} کیلوکالری',
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 95,
                        height: 95,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9,
                          backgroundColor: tokens.cardElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                PersianUtils.toPersianDigits(consumedCalories),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: isOverLimit
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'از ${PersianUtils.toPersianDigits(targetCalories)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: tokens.textMuted,
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'کیلوکالری',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: tokens.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

              final macroBarsWidget = Column(
                children: [
                  _MacroBarItem(
                    title: 'پروتئین',
                    consumed: consumedProtein.toInt(),
                    target: targetProtein,
                    color: tokens.lime,
                  ),
                  AppSpacing.hSm,
                  _MacroBarItem(
                    title: 'کربوهیدرات',
                    consumed: consumedCarbs.toInt(),
                    target: targetCarbs,
                    color: tokens.cyan,
                  ),
                  AppSpacing.hSm,
                  _MacroBarItem(
                    title: 'چربی مفید',
                    consumed: consumedFat.toInt(),
                    target: targetFat,
                    color: tokens.gold,
                  ),
                ],
              );

              final isNarrow = constraints.maxWidth < 320;
              if (isNarrow) {
                return Column(
                  children: [
                    Center(child: ringWidget),
                    AppSpacing.hMd,
                    macroBarsWidget,
                  ],
                );
              }

              return Row(
                children: [
                  ringWidget,
                  AppSpacing.wLg,
                  Expanded(child: macroBarsWidget),
                ],
              );
            },
          ),

          // Over Limit Warning Banner
          if (isOverLimit) ...[
            AppSpacing.hMd,
            _OverLimitBanner(overdraftCalories: overdraftCalories),
          ],
        ],
      ),
    );
  }
}

class _MacroBarItem extends StatelessWidget {
  final String title;
  final int consumed;
  final int target;
  final Color color;

  const _MacroBarItem({
    required this.title,
    required this.consumed,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final prog = (consumed / (target > 0 ? target : 1)).clamp(0.0, 1.0);

    return Semantics(
      label: title,
      value:
          '${PersianUtils.toPersianDigits(consumed)} از ${PersianUtils.toPersianDigits(target)} گرم',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.wXs,
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    '${PersianUtils.toPersianDigits(consumed)} / ${PersianUtils.toPersianDigits(target)} گرم',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.hXs,
          ClipRRect(
            borderRadius: AppRadii.roundedXs,
            child: LinearProgressIndicator(
              value: prog,
              minHeight: 6,
              backgroundColor: tokens.cardElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverLimitBanner extends StatelessWidget {
  final int overdraftCalories;

  const _OverLimitBanner({required this.overdraftCalories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MergeSemantics(
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.12),
          borderRadius: AppRadii.roundedMd,
          border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(Icons.error_outline,
                  color: theme.colorScheme.error, size: AppSpacing.lg),
            ),
            AppSpacing.wSm,
            Expanded(
              child: Text(
                'مصرف امروز شما ${PersianUtils.toPersianDigits(overdraftCalories)} کالری بیشتر از سقف تعیین شده برنامه است. وعده بعدی را سبک‌تر انتخاب کنید.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
