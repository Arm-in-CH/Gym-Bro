import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/localization/persian_utils.dart';

/// ویجت نمایش عقربه‌ای/نیم‌دایره‌ای پیشرفته بودجه کالری با افکت نئون و تفکیک ماکروها (الهام از طراحی Gym Hero)
class CalorieGaugeCard extends StatelessWidget {
  final int consumedCalories;
  final int targetCalories;
  final VoidCallback? onEditGoals;
  final double? consumedProtein;
  final int? targetProtein;
  final double? consumedCarbs;
  final int? targetCarbs;
  final double? consumedFat;
  final int? targetFat;

  const CalorieGaugeCard({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
    this.onEditGoals,
    this.consumedProtein,
    this.targetProtein,
    this.consumedCarbs,
    this.targetCarbs,
    this.consumedFat,
    this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    final validTarget = targetCalories > 0 ? targetCalories : 2250;
    final remaining = validTarget - consumedCalories;
    final isOver = remaining < 0;
    final overdraft = isOver ? -remaining : 0;
    final progress = (consumedCalories / validTarget).clamp(0.0, 1.3);
    final percentage = ((consumedCalories / validTarget) * 100).round();

    final hasMacros = consumedProtein != null &&
        targetProtein != null &&
        consumedCarbs != null &&
        targetCarbs != null &&
        consumedFat != null &&
        targetFat != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(
          color: isOver ? tokens.red.withOpacity(0.5) : tokens.borderColor,
          width: isOver ? 1.5 : 1.0,
        ),
        boxShadow: isOver
            ? [
                BoxShadow(
                  color: tokens.red.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Edit Goals Action
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
                        color: tokens.lime.withOpacity(0.15),
                        borderRadius: AppRadii.smRadius,
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: tokens.lime,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'بودجه انرژی و کالری روزانه',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                if (onEditGoals != null)
                  InkWell(
                    onTap: onEditGoals,
                    borderRadius: AppRadii.smRadius,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune_rounded, size: 16, color: tokens.lime),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            'تنظیم هدف',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tokens.lime,
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
          const SizedBox(height: AppSpacing.md),

          // Main Visual Area: Semicircular Arc Gauge + Macro Bars (Responsive Side-by-side or stacked)
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1.0);
              final isWide = constraints.maxWidth >= 420 && textScale <= 1.3 && hasMacros;

              final gaugeWidget = SizedBox(
                height: 160,
                width: isWide ? 170 : double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(isWide ? 165 : 240, 150),
                      painter: _SemicircleGaugePainter(
                        progress: progress,
                        trackColor: tokens.cardElevated,
                        progressColor: isOver ? tokens.red : tokens.lime,
                        glowColor: isOver
                            ? tokens.red.withOpacity(0.4)
                            : tokens.lime.withOpacity(0.35),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Percentage Display matching reference
                          Text(
                            '${PersianUtils.toPersianDigits(percentage)}٪',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isOver ? tokens.red : tokens.lime,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOver ? 'بیش از حد مجاز' : 'تامین هدف کالری',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tokens.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isOver
                                ? '${PersianUtils.formatCalories(overdraft)} مازاد'
                                : '${PersianUtils.formatCalories(consumedCalories)} / ${PersianUtils.formatCalories(validTarget)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isOver ? tokens.red : tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (hasMacros) {
                final macroWidget = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCompactMacroBar(
                      label: 'پروتئین',
                      consumed: consumedProtein!,
                      target: targetProtein!,
                      color: tokens.lime,
                      tokens: tokens,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildCompactMacroBar(
                      label: 'چربی',
                      consumed: consumedFat!,
                      target: targetFat!,
                      color: tokens.gold,
                      tokens: tokens,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildCompactMacroBar(
                      label: 'کربوهیدرات',
                      consumed: consumedCarbs!,
                      target: targetCarbs!,
                      color: tokens.cyan,
                      tokens: tokens,
                      theme: theme,
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    children: [
                      gaugeWidget,
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: macroWidget),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      gaugeWidget,
                      const SizedBox(height: AppSpacing.md),
                      macroWidget,
                    ],
                  );
                }
              }

              return gaugeWidget;
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Bottom Quick Stats Row
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: AppRadii.baseRadius,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatPill(
                    label: 'مصرف‌شده',
                    value: PersianUtils.toPersianDigits(consumedCalories),
                    color: isOver ? tokens.red : theme.colorScheme.onSurface,
                    theme: theme,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(width: 1, height: 24, color: tokens.borderColor),
                  const SizedBox(width: AppSpacing.md),
                  _buildStatPill(
                    label: 'هدف کل',
                    value: PersianUtils.toPersianDigits(validTarget),
                    color: theme.colorScheme.onSurface,
                    theme: theme,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(width: 1, height: 24, color: tokens.borderColor),
                  const SizedBox(width: AppSpacing.md),
                  _buildStatPill(
                    label: isOver ? 'مازاد' : 'باقی‌مانده',
                    value: PersianUtils.toPersianDigits(isOver ? overdraft : remaining),
                    color: isOver ? tokens.red : tokens.lime,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMacroBar({
    required String label,
    required double consumed,
    required int target,
    required Color color,
    required AppThemeExtension tokens,
    required ThemeData theme,
  }) {
    final validTarget = target > 0 ? target : 100;
    final frac = (consumed / validTarget).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${PersianUtils.toPersianDigits(consumed.toStringAsFixed(1))} / ${PersianUtils.toPersianDigits(target)} g',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 6,
            backgroundColor: tokens.cardElevated.withOpacity(0.8),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SemicircleGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;

  _SemicircleGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.88);
    final radius = math.min(size.width / 2, size.height * 0.82) - 12;

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active Progress Arc
    final activeSweep = sweepAngle * progress.clamp(0.0, 1.0);
    if (activeSweep > 0) {
      // Glow Paint
      final glowPaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        glowPaint,
      );

      // Core Progress Arc
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        progressPaint,
      );

      // Endpoint needle/dot indicator
      final endAngle = startAngle + activeSweep;
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(endPoint, 5, dotPaint);

      final outerDotPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(endPoint, 8, outerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemicircleGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
