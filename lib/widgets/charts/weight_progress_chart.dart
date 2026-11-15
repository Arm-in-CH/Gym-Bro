import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/localization/persian_utils.dart';
import '../../models/body_analytics_models.dart';

enum WeightChartRange {
  oneWeek,
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  all;

  String get labelFa {
    switch (this) {
      case WeightChartRange.oneWeek:
        return '۱ هفته';
      case WeightChartRange.oneMonth:
        return '۱ ماه';
      case WeightChartRange.threeMonths:
        return '۳ ماه';
      case WeightChartRange.sixMonths:
        return '۶ ماه';
      case WeightChartRange.oneYear:
        return '۱ سال';
      case WeightChartRange.all:
        return 'همه';
    }
  }

  Duration? get duration {
    switch (this) {
      case WeightChartRange.oneWeek:
        return const Duration(days: 7);
      case WeightChartRange.oneMonth:
        return const Duration(days: 30);
      case WeightChartRange.threeMonths:
        return const Duration(days: 90);
      case WeightChartRange.sixMonths:
        return const Duration(days: 180);
      case WeightChartRange.oneYear:
        return const Duration(days: 365);
      case WeightChartRange.all:
        return null;
    }
  }
}

/// Professional interactive weight progress line chart with glowing gradient fill,
/// target reference line, touch tooltip inspection, multi-range filters, and callout pins.
/// Designed according to Reference Images 1 & 3.
class WeightProgressChart extends StatefulWidget {
  final List<WeightRecord> records;
  final double targetWeightKg;
  final VoidCallback onAddRecord;

  const WeightProgressChart({
    super.key,
    required this.records,
    required this.targetWeightKg,
    required this.onAddRecord,
  });

  @override
  State<WeightProgressChart> createState() => _WeightProgressChartState();
}

class _WeightProgressChartState extends State<WeightProgressChart> {
  WeightChartRange _selectedRange = WeightChartRange.all;
  int? _hoveredIndex;

  List<WeightRecord> get _filteredRecords {
    if (widget.records.isEmpty) return [];
    final duration = _selectedRange.duration;
    if (duration == null) return widget.records;
    final cutoff = DateTime.now().subtract(duration);
    final filtered = widget.records.where((r) => r.date.isAfter(cutoff)).toList();
    if (filtered.length < 2 && widget.records.length >= 2) {
      return widget.records;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final records = _filteredRecords;

    final hasEnoughData = records.length >= 2;
    final latestRecord = widget.records.isNotEmpty ? widget.records.last : null;
    final firstRecord = widget.records.isNotEmpty ? widget.records.first : null;
    final latestWeight = latestRecord?.weightKg ?? 75.0;
    final startWeight = firstRecord?.weightKg ?? latestWeight;
    final targetWeight = widget.targetWeightKg > 0 ? widget.targetWeightKg : 70.0;

    // Progress percentage towards target
    final totalDiff = (startWeight - targetWeight).abs();
    final currentDiff = (latestWeight - targetWeight).abs();
    final progressPct = totalDiff > 0 ? ((1.0 - (currentDiff / totalDiff)).clamp(0.0, 1.0) * 100).toInt() : 100;

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
          // 1. Header with Title & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.lime.withOpacity(0.18),
                        border: Border.all(color: tokens.lime.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Icon(Icons.show_chart, color: tokens.lime, size: 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نمودار تغییرات وزن و هدف',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'خط سبز: وزن واقعی • خط‌چین: هدف (${PersianUtils.toPersianDigits(widget.targetWeightKg)}kg)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: tokens.lime, size: 28),
                tooltip: 'ثبت وزن جدید',
                onPressed: widget.onAddRecord,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 2. Hero Weight Display & Status Callout (Reference Images 1 & 3)
          if (latestRecord != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: tokens.cardElevated,
                borderRadius: AppRadii.baseRadius,
                border: Border.all(color: tokens.borderColor.withOpacity(0.6)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            PersianUtils.toPersianDigits(latestWeight),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: tokens.lime,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'کیلوگرم',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'آخرین پایش ثبت‌شده در سیستم',
                        style: TextStyle(fontSize: 10.5, color: tokens.textMuted),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: tokens.lime.withOpacity(0.18),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(color: tokens.lime.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_rounded, size: 14, color: tokens.lime),
                        const SizedBox(width: 4),
                        Text(
                          'هدف: ${PersianUtils.toPersianDigits(targetWeight)} kg',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: tokens.lime,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // 3. Range Filter Pills (Reference Images 1 & 3)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: WeightChartRange.values.map((range) {
                final isSelected = _selectedRange == range;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRange = range;
                        _hoveredIndex = null;
                      });
                    },
                    borderRadius: AppRadii.xsRadius,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.lime : tokens.cardElevated,
                        borderRadius: AppRadii.roundedSm,
                        border: Border.all(
                          color: isSelected ? tokens.lime : tokens.borderColor,
                        ),
                      ),
                      child: Text(
                        range.labelFa,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : tokens.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 4. Chart Canvas or Insufficient Data State
          if (!hasEnoughData)
            _buildInsufficientDataState(context, tokens)
          else ...[
            // Interactive Chart Surface with Callout Pins
            SizedBox(
              height: 200,
              width: double.infinity,
              child: GestureDetector(
                onPanDown: (details) => _handleTouch(details.localPosition),
                onPanUpdate: (details) => _handleTouch(details.localPosition),
                onPanEnd: (_) => setState(() => _hoveredIndex = null),
                child: CustomPaint(
                  painter: _WeightLineChartPainter(
                    records: records,
                    targetWeightKg: widget.targetWeightKg,
                    tokens: tokens,
                    hoveredIndex: _hoveredIndex,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Active Inspection Tooltip Box
            if (_hoveredIndex != null && _hoveredIndex! < records.length)
              _buildInspectionTooltip(records[_hoveredIndex!], tokens)
            else
              _buildOverallSummary(records, tokens),

            const SizedBox(height: AppSpacing.md),

            // 5. Start vs Target Weight & Progress Cards (Reference Image 3)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: tokens.cardElevated,
                      borderRadius: AppRadii.baseRadius,
                      border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('وزن شروع', style: TextStyle(fontSize: 10, color: tokens.textMuted)),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${PersianUtils.toPersianDigits(startWeight)} kg',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: tokens.cardElevated,
                      borderRadius: AppRadii.baseRadius,
                      border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('وزن هدف', style: TextStyle(fontSize: 10, color: tokens.textMuted)),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${PersianUtils.toPersianDigits(targetWeight)} kg',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: tokens.lime,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: tokens.cardElevated,
                      borderRadius: AppRadii.baseRadius,
                      border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('پیشرفت هدف', style: TextStyle(fontSize: 10, color: tokens.textMuted)),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${PersianUtils.toPersianDigits(progressPct)}٪',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: tokens.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _handleTouch(Offset localPos) {
    final records = _filteredRecords;
    if (records.length < 2) return;

    const paddingLeft = 40.0;
    const paddingRight = 20.0;
    final chartWidth = context.size?.width ?? 320.0;
    final usableWidth = chartWidth - paddingLeft - paddingRight;

    final x = (localPos.dx - paddingLeft).clamp(0.0, usableWidth);
    final ratio = x / usableWidth;

    // In RTL, 0 ratio is rightmost, 1 ratio is leftmost
    final index = ((1.0 - ratio) * (records.length - 1)).round().clamp(0, records.length - 1);

    if (_hoveredIndex != index) {
      setState(() {
        _hoveredIndex = index;
      });
    }
  }

  Widget _buildInsufficientDataState(BuildContext context, AppThemeExtension tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.base),
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.cardElevated.withOpacity(0.5),
        borderRadius: AppRadii.mdRadius,
        border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.query_stats, color: tokens.textMuted, size: 40),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'داده‌های وزنی برای رسم نمودار کافی نیست',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'برای تحلیل روند پیشرفت، حداقل ۲ رکورد وزنی با تاریخ‌های مختلف ثبت کنید.',
            style: TextStyle(fontSize: 11, color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: widget.onAddRecord,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('ثبت رکورد وزنی جدید'),
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.lime,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionTooltip(WeightRecord record, AppThemeExtension tokens) {
    final dateStr = PersianUtils.formatPersianDate(record.date);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.cardElevated,
        borderRadius: AppRadii.smRadius,
        border: Border.all(color: tokens.lime.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: tokens.lime, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(dateStr, style: TextStyle(fontSize: 11, color: tokens.textMuted)),
            ],
          ),
          Text(
            '${PersianUtils.toPersianDigits(record.weightKg)} کیلوگرم',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: tokens.lime),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallSummary(List<WeightRecord> records, AppThemeExtension tokens) {
    final first = records.first.weightKg;
    final last = records.last.weightKg;
    final delta = last - first;
    final isLoss = delta < 0;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(
          'تغییر کل در این بازه:',
          style: TextStyle(fontSize: 11, color: tokens.textMuted),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLoss ? Icons.arrow_downward : (delta > 0 ? Icons.arrow_upward : Icons.remove),
              size: 14,
              color: isLoss ? tokens.lime : (delta > 0 ? tokens.gold : tokens.textMuted),
            ),
            const SizedBox(width: 4),
            Text(
              '${PersianUtils.toPersianDigits(delta.abs().toStringAsFixed(1))} کیلوگرم ${isLoss ? "کاهش" : (delta > 0 ? "افزایش" : "بدون تغییر")}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isLoss ? tokens.lime : (delta > 0 ? tokens.gold : tokens.textMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeightLineChartPainter extends CustomPainter {
  final List<WeightRecord> records;
  final double targetWeightKg;
  final AppThemeExtension tokens;
  final int? hoveredIndex;

  _WeightLineChartPainter({
    required this.records,
    required this.targetWeightKg,
    required this.tokens,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (records.length < 2) return;

    const paddingLeft = 36.0;
    const paddingRight = 16.0;
    const paddingTop = 32.0; // Extra room for floating pin callouts
    const paddingBottom = 26.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    // Determine min/max Y values including targetWeight
    double minY = records.map((r) => r.weightKg).reduce(math.min);
    double maxY = records.map((r) => r.weightKg).reduce(math.max);
    minY = math.min(minY, targetWeightKg);
    maxY = math.max(maxY, targetWeightKg);

    // Give Y-axis 1.5kg headroom and footroom
    minY = (minY - 1.5).floorToDouble();
    maxY = (maxY + 1.5).ceilToDouble();
    final yRange = maxY - minY == 0 ? 1.0 : maxY - minY;

    // Draw horizontal grid lines and Y-axis labels
    final gridPaint = Paint()
      ..color = tokens.borderColor.withOpacity(0.35)
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(textDirection: TextDirection.rtl);

    const numGridLines = 4;
    for (int i = 0; i <= numGridLines; i++) {
      final yVal = minY + (yRange / numGridLines) * i;
      final yPos = paddingTop + chartHeight - (chartHeight / numGridLines) * i;

      canvas.drawLine(
        Offset(paddingLeft, yPos),
        Offset(size.width - paddingRight, yPos),
        gridPaint,
      );

      // Y Label
      textPainter.text = TextSpan(
        text: PersianUtils.toPersianDigits(yVal.toInt().toString()),
        style: TextStyle(fontSize: 9.5, color: tokens.textMuted),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft - textPainter.width - 6, yPos - textPainter.height / 2));
    }

    // Draw Target Weight Dotted Guide Line
    final targetY = paddingTop + chartHeight - ((targetWeightKg - minY) / yRange) * chartHeight;
    final targetLinePaint = Paint()
      ..color = tokens.lime.withOpacity(0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, Offset(paddingLeft, targetY), Offset(size.width - paddingRight, targetY), targetLinePaint);

    // Calculate (x, y) coordinates for all records
    // In RTL Persian: index 0 (oldest) is on the right, last index (newest) is on the left
    final points = <Offset>[];
    for (int i = 0; i < records.length; i++) {
      final t = i / (records.length - 1);
      final x = (size.width - paddingRight) - t * chartWidth;
      final y = paddingTop + chartHeight - ((records[i].weightKg - minY) / yRange) * chartHeight;
      points.add(Offset(x, y));
    }

    // Path for line and gradient fill
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final cpX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }

    // Fill Path with Gradient
    final fillPath = Path.from(linePath);
    fillPath.lineTo(points.last.dx, paddingTop + chartHeight);
    fillPath.lineTo(points.first.dx, paddingTop + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          tokens.lime.withOpacity(0.28),
          tokens.lime.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, paddingTop, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw Glowing Stroke Line
    final strokePaint = Paint()
      ..color = tokens.lime
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, strokePaint);

    // Draw Data Point Dots
    final dotFill = Paint()..color = const Color(0xFF0E1118);
    final dotStroke = Paint()
      ..color = tokens.lime
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final isHovered = hoveredIndex == i;
      final radius = isHovered ? 5.5 : 3.5;

      canvas.drawCircle(points[i], radius, dotFill);
      canvas.drawCircle(points[i], radius, isHovered ? (Paint()..color = Colors.white..strokeWidth = 2.5..style = PaintingStyle.stroke) : dotStroke);

      if (isHovered) {
        // Draw vertical highlight cursor line
        final cursorPaint = Paint()
          ..color = tokens.lime.withOpacity(0.4)
          ..strokeWidth = 1.0;
        canvas.drawLine(
          Offset(points[i].dx, paddingTop),
          Offset(points[i].dx, paddingTop + chartHeight),
          cursorPaint,
        );
      }
    }

    // Draw Callout Pin on hovered point or newest point (Reference Images 1 & 3)
    final pinIndex = hoveredIndex ?? (points.isNotEmpty ? points.length - 1 : null);
    if (pinIndex != null && pinIndex < points.length) {
      final p = points[pinIndex];
      final record = records[pinIndex];
      final label = '${PersianUtils.toPersianDigits(record.weightKg)} kg';

      final calloutText = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();

      final bubbleWidth = calloutText.width + 12;
      final bubbleHeight = calloutText.height + 6;
      final bubbleY = p.dy - bubbleHeight - 8;
      final bubbleX = (p.dx - bubbleWidth / 2).clamp(paddingLeft, size.width - paddingRight - bubbleWidth);

      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bubbleX, bubbleY, bubbleWidth, bubbleHeight),
        const Radius.circular(6),
      );

      final bubblePaint = Paint()..color = tokens.lime;
      canvas.drawRRect(bubbleRect, bubblePaint);

      final pointerPath = Path()
        ..moveTo(p.dx - 4, bubbleY + bubbleHeight)
        ..lineTo(p.dx + 4, bubbleY + bubbleHeight)
        ..lineTo(p.dx, bubbleY + bubbleHeight + 4)
        ..close();
      canvas.drawPath(pointerPath, bubblePaint);

      calloutText.paint(canvas, Offset(bubbleX + 6, bubbleY + 3));
    }

    // Draw First and Last Date Labels on X-axis
    final firstDateStr = PersianUtils.formatPersianDate(records.first.date);
    final lastDateStr = PersianUtils.formatPersianDate(records.last.date);

    textPainter.text = TextSpan(
      text: firstDateStr,
      style: TextStyle(fontSize: 9.5, color: tokens.textMuted),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - paddingRight - textPainter.width, size.height - paddingBottom + 6));

    textPainter.text = TextSpan(
      text: lastDateStr,
      style: TextStyle(fontSize: 9.5, color: tokens.lime, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(paddingLeft, size.height - paddingBottom + 6));
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double currentX = p1.dx;

    while (currentX < p2.dx) {
      final nextX = math.min(currentX + dashWidth, p2.dx);
      canvas.drawLine(Offset(currentX, p1.dy), Offset(nextX, p1.dy), paint);
      currentX = nextX + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLineChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.records != records ||
        oldDelegate.targetWeightKg != targetWeightKg;
  }
}
