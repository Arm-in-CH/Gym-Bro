import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/localization/persian_utils.dart';
import '../../models/nutrition_models.dart';

/// نمودار تعاملی تحلیل هفتگی و ماهانه کالری و درشت‌مغذی‌ها
class WeeklyNutritionChart extends StatefulWidget {
  final List<DailyNutritionSummary> weeklySummaries;
  final List<DailyNutritionSummary> monthlySummaries;
  final String selectedDateString;
  final int targetCalories;
  final Function(DateTime date)? onDaySelected;

  const WeeklyNutritionChart({
    super.key,
    required this.weeklySummaries,
    required this.monthlySummaries,
    required this.selectedDateString,
    required this.targetCalories,
    this.onDaySelected,
  });

  @override
  State<WeeklyNutritionChart> createState() => _WeeklyNutritionChartState();
}

class _WeeklyNutritionChartState extends State<WeeklyNutritionChart> {
  bool _isMonthlyView = false;
  bool _showMacrosSplit = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    final summaries = _isMonthlyView ? widget.monthlySummaries : widget.weeklySummaries;

    // Calculate averages
    final totalCals = summaries.fold(0, (s, d) => s + d.totalCalories);
    final avgCals = summaries.isNotEmpty ? (totalCals / summaries.length).round() : 0;

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
          // Header & View Toggle
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'روند دریافت انرژی و درشت‌مغذی‌ها',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Weekly / Monthly segmented toggle
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: tokens.cardElevated,
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTogglePill(
                        title: '۷ روز',
                        isSelected: !_isMonthlyView,
                        onTap: () => setState(() => _isMonthlyView = false),
                        tokens: tokens,
                        theme: theme,
                      ),
                      _buildTogglePill(
                        title: '۳۰ روز',
                        isSelected: _isMonthlyView,
                        onTap: () => setState(() => _isMonthlyView = true),
                        tokens: tokens,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Secondary Mode Switcher (Calorie vs Stacked Macros)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                InkWell(
                  onTap: () => setState(() => _showMacrosSplit = false),
                  borderRadius: AppRadii.xsRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: !_showMacrosSplit ? tokens.lime.withOpacity(0.15) : Colors.transparent,
                      borderRadius: AppRadii.xsRadius,
                      border: Border.all(
                        color: !_showMacrosSplit ? tokens.lime : tokens.borderColor,
                      ),
                    ),
                    child: Text(
                      'کالری کل',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: !_showMacrosSplit ? tokens.lime : tokens.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                InkWell(
                  onTap: () => setState(() => _showMacrosSplit = true),
                  borderRadius: AppRadii.xsRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: _showMacrosSplit ? tokens.cyan.withOpacity(0.15) : Colors.transparent,
                      borderRadius: AppRadii.xsRadius,
                      border: Border.all(
                        color: _showMacrosSplit ? tokens.cyan : tokens.borderColor,
                      ),
                    ),
                    child: Text(
                      'تفکیک ماکروها (P/C/F)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _showMacrosSplit ? tokens.cyan : tokens.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'میانگین: ${PersianUtils.formatCalories(avgCals)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Interactive Chart Canvas
          SizedBox(
            height: 180,
            width: double.infinity,
            child: summaries.isEmpty
                ? Center(
                    child: Text(
                      'داده‌ای برای این بازه ثبت نشده است',
                      style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                  )
                : CustomPaint(
                    size: Size.infinite,
                    painter: _NutritionTrendPainter(
                      summaries: summaries,
                      targetCalories: widget.targetCalories,
                      selectedDateString: widget.selectedDateString,
                      showMacros: _showMacrosSplit,
                      limeColor: tokens.lime,
                      cyanColor: tokens.cyan,
                      coralColor: const Color(0xFFF43F5E),
                      gridColor: tokens.cardElevated,
                      textMutedColor: tokens.textMuted,
                      isMonthly: _isMonthlyView,
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Legend
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_showMacrosSplit) ...[
                  _buildLegendItem(color: tokens.lime, label: 'کالری مصرفی'),
                  const SizedBox(width: AppSpacing.md),
                  _buildLegendItem(color: tokens.textMuted, label: 'سقف هدف روزانه', isDashed: true),
                ] else ...[
                  _buildLegendItem(color: tokens.lime, label: 'پروتئین'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildLegendItem(color: tokens.cyan, label: 'کربوهیدرات'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildLegendItem(color: const Color(0xFFF43F5E), label: 'چربی'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTogglePill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeExtension tokens,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.pillRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? tokens.lime : Colors.transparent,
          borderRadius: AppRadii.pillRadius,
        ),
        child: Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isSelected ? tokens.textOnLime : tokens.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _NutritionTrendPainter extends CustomPainter {
  final List<DailyNutritionSummary> summaries;
  final int targetCalories;
  final String selectedDateString;
  final bool showMacros;
  final Color limeColor;
  final Color cyanColor;
  final Color coralColor;
  final Color gridColor;
  final Color textMutedColor;
  final bool isMonthly;

  _NutritionTrendPainter({
    required this.summaries,
    required this.targetCalories,
    required this.selectedDateString,
    required this.showMacros,
    required this.limeColor,
    required this.cyanColor,
    required this.coralColor,
    required this.gridColor,
    required this.textMutedColor,
    required this.isMonthly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (summaries.isEmpty) return;

    const bottomPadding = 26.0;
    const topPadding = 16.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width;

    // Find max value
    double maxVal = targetCalories.toDouble();
    for (final s in summaries) {
      if (s.totalCalories > maxVal) maxVal = s.totalCalories.toDouble();
    }
    maxVal = maxVal * 1.15; // 15% headroom
    if (maxVal <= 0) maxVal = 2500;

    // Draw Target Line
    final targetY = topPadding + chartHeight * (1.0 - (targetCalories / maxVal));
    final targetPaint = Paint()
      ..color = textMutedColor.withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw dashed target line
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < chartWidth) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(startX + dashWidth, targetY),
        targetPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Draw Bars
    final barCount = summaries.length;
    final availableWidthPerBar = chartWidth / barCount;
    final barWidth = isMonthly
        ? (availableWidthPerBar * 0.7).clamp(3.0, 10.0)
        : (availableWidthPerBar * 0.55).clamp(16.0, 32.0);

    for (int i = 0; i < barCount; i++) {
      final summary = summaries[i];
      final isSelected = summary.dateString == selectedDateString;
      final centerX = (i + 0.5) * availableWidthPerBar;

      final calHeight = (summary.totalCalories / maxVal) * chartHeight;
      final topY = topPadding + chartHeight - calHeight;
      final bottomY = topPadding + chartHeight;

      if (showMacros) {
        // Stacked bar: Protein (bottom), Carbs (middle), Fat (top)
        final pKcal = summary.totalProtein * 4;
        final cKcal = summary.totalCarbs * 4;
        final fKcal = summary.totalFat * 9;
        final totalMacroKcal = pKcal + cKcal + fKcal;

        if (totalMacroKcal > 0) {
          final pHeight = (pKcal / maxVal) * chartHeight;
          final cHeight = (cKcal / maxVal) * chartHeight;
          final fHeight = (fKcal / maxVal) * chartHeight;

          // Protein (bottom)
          final pRect = RRect.fromRectAndCorners(
            Rect.fromLTRB(centerX - barWidth / 2, bottomY - pHeight, centerX + barWidth / 2, bottomY),
            bottomLeft: const Radius.circular(3),
            bottomRight: const Radius.circular(3),
          );
          canvas.drawRRect(pRect, Paint()..color = limeColor);

          // Carbs (middle)
          final cRect = Rect.fromLTRB(centerX - barWidth / 2, bottomY - pHeight - cHeight, centerX + barWidth / 2, bottomY - pHeight);
          canvas.drawRect(cRect, Paint()..color = cyanColor);

          // Fat (top)
          final fRect = RRect.fromRectAndCorners(
            Rect.fromLTRB(centerX - barWidth / 2, bottomY - pHeight - cHeight - fHeight, centerX + barWidth / 2, bottomY - pHeight - cHeight),
            topLeft: const Radius.circular(3),
            topRight: const Radius.circular(3),
          );
          canvas.drawRRect(fRect, Paint()..color = coralColor);
        } else {
          // Zero activity placeholder dot
          canvas.drawCircle(Offset(centerX, bottomY - 3), 2, Paint()..color = textMutedColor.withOpacity(0.3));
        }
      } else {
        // Calorie single bar
        final barColor = isSelected
            ? limeColor
            : (summary.totalCalories > targetCalories ? const Color(0xFFF43F5E) : limeColor.withOpacity(0.65));

        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(centerX - barWidth / 2, topY, centerX + barWidth / 2, bottomY),
          const Radius.circular(4),
        );

        if (isSelected) {
          // Glow around selected bar
          final glowPaint = Paint()
            ..color = limeColor.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawRRect(barRect, glowPaint);
        }

        canvas.drawRRect(barRect, Paint()..color = barColor);
      }

      // Day label under bar
      if (!isMonthly || i % 5 == 0 || i == barCount - 1) {
        final dayName = _getDayAbbreviation(summary.dateTime);
        final tp = TextPainter(
          text: TextSpan(
            text: dayName,
            style: TextStyle(
              color: isSelected ? limeColor : textMutedColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout();
        tp.paint(canvas, Offset(centerX - tp.width / 2, bottomY + 6));
      }
    }
  }

  String _getDayAbbreviation(DateTime date) {
    if (isMonthly) {
      return PersianUtils.toPersianDigits(date.day);
    }
    switch (date.weekday) {
      case DateTime.saturday:
        return 'ش';
      case DateTime.sunday:
        return '۱ش';
      case DateTime.monday:
        return '۲ش';
      case DateTime.tuesday:
        return '۳ش';
      case DateTime.wednesday:
        return '۴ش';
      case DateTime.thursday:
        return '۵ش';
      case DateTime.friday:
        return 'ج';
      default:
        return PersianUtils.toPersianDigits(date.day);
    }
  }

  @override
  bool shouldRepaint(covariant _NutritionTrendPainter oldDelegate) {
    return oldDelegate.summaries != summaries ||
        oldDelegate.selectedDateString != selectedDateString ||
        oldDelegate.showMacros != showMacros ||
        oldDelegate.isMonthly != isMonthly;
  }
}
