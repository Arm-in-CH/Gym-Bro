import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/localization/persian_utils.dart';
import '../../models/body_analytics_models.dart';

enum MeasurementMetricType {
  waist,
  chest,
  arm,
  hip,
  thigh,
  calf,
  bodyFat;

  String get labelFa {
    switch (this) {
      case MeasurementMetricType.waist:
        return 'دور کمر';
      case MeasurementMetricType.chest:
        return 'دور سینه';
      case MeasurementMetricType.arm:
        return 'دور بازو';
      case MeasurementMetricType.hip:
        return 'دور باسن';
      case MeasurementMetricType.thigh:
        return 'دور ران';
      case MeasurementMetricType.calf:
        return 'ساق پا';
      case MeasurementMetricType.bodyFat:
        return 'درصد چربی';
    }
  }

  String get unit {
    return this == MeasurementMetricType.bodyFat ? '%' : 'cm';
  }

  double? getValue(BodyMeasurementRecord r) {
    switch (this) {
      case MeasurementMetricType.waist:
        return r.waistCm;
      case MeasurementMetricType.chest:
        return r.chestCm;
      case MeasurementMetricType.arm:
        return r.rightArmCm ?? r.leftArmCm;
      case MeasurementMetricType.hip:
        return r.hipCm;
      case MeasurementMetricType.thigh:
        return r.thighCm;
      case MeasurementMetricType.calf:
        return r.calfCm;
      case MeasurementMetricType.bodyFat:
        return r.bodyFatPercentage;
    }
  }
}

/// Interactive Body Measurement Circumferences trend chart with metric selector.
class BodyMeasurementsChart extends StatefulWidget {
  final List<BodyMeasurementRecord> records;
  final VoidCallback onAddMeasurement;

  const BodyMeasurementsChart({
    super.key,
    required this.records,
    required this.onAddMeasurement,
  });

  @override
  State<BodyMeasurementsChart> createState() => _BodyMeasurementsChartState();
}

class _BodyMeasurementsChartState extends State<BodyMeasurementsChart> {
  MeasurementMetricType _selectedMetric = MeasurementMetricType.waist;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    // Filter points that have values for the selected metric
    final validPoints = <_ChartPoint>[];
    for (int i = 0; i < widget.records.length; i++) {
      final val = _selectedMetric.getValue(widget.records[i]);
      if (val != null) {
        validPoints.add(_ChartPoint(date: widget.records[i].date, value: val, index: i));
      }
    }

    final hasEnoughData = validPoints.length >= 2;

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
                        color: tokens.cyan.withOpacity(0.18),
                        border: Border.all(color: tokens.cyan.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Icon(Icons.accessibility_new, color: tokens.cyan, size: 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'روند تغییر سایزهای بدنی',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'پایش دور عضلات و پیشرفت آنتروپومتریک',
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
                icon: Icon(Icons.add_circle, color: tokens.cyan, size: 28),
                tooltip: 'ثبت سایز جدید',
                onPressed: widget.onAddMeasurement,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Metric Selection Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MeasurementMetricType.values.map((metric) {
                final isSelected = _selectedMetric == metric;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMetric = metric;
                        _hoveredIndex = null;
                      });
                    },
                    borderRadius: AppRadii.xsRadius,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.cyan : tokens.cardElevated,
                        borderRadius: AppRadii.xsRadius,
                        border: Border.all(
                          color: isSelected ? tokens.cyan : tokens.borderColor,
                        ),
                      ),
                      child: Text(
                        metric.labelFa,
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

          if (!hasEnoughData)
            _buildEmptyState(context, tokens)
          else ...[
            SizedBox(
              height: 180,
              width: double.infinity,
              child: GestureDetector(
                onPanDown: (d) => _handleTouch(d.localPosition, validPoints),
                onPanUpdate: (d) => _handleTouch(d.localPosition, validPoints),
                onPanEnd: (_) => setState(() => _hoveredIndex = null),
                child: CustomPaint(
                  painter: _MeasurementLineChartPainter(
                    points: validPoints,
                    unit: _selectedMetric.unit,
                    tokens: tokens,
                    hoveredIndex: _hoveredIndex,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (_hoveredIndex != null && _hoveredIndex! < validPoints.length)
              _buildTooltip(validPoints[_hoveredIndex!], tokens)
            else
              _buildMetricSummary(validPoints, tokens),
          ],
        ],
      ),
    );
  }

  void _handleTouch(Offset localPos, List<_ChartPoint> points) {
    if (points.length < 2) return;
    const paddingLeft = 36.0;
    const paddingRight = 16.0;
    final chartWidth = context.size?.width ?? 320.0;
    final usableWidth = chartWidth - paddingLeft - paddingRight;

    final x = (localPos.dx - paddingLeft).clamp(0.0, usableWidth);
    final ratio = x / usableWidth;

    final index = ((1.0 - ratio) * (points.length - 1)).round().clamp(0, points.length - 1);
    if (_hoveredIndex != index) {
      setState(() => _hoveredIndex = index);
    }
  }

  Widget _buildEmptyState(BuildContext context, AppThemeExtension tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.base),
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.cardElevated.withOpacity(0.5),
        borderRadius: AppRadii.mdRadius,
        border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.straighten, color: tokens.textMuted, size: 36),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'سایزهای کافی برای «${_selectedMetric.labelFa}» ثبت نشده است',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: tokens.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'برای مشاهده نمودار تغییر سایز، حداقل دو اندازه‌گیری ثبت کنید.',
            style: TextStyle(fontSize: 10.5, color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: widget.onAddMeasurement,
            icon: Icon(Icons.add, size: 16, color: tokens.cyan),
            label: Text('ثبت اندازه‌گیری ${_selectedMetric.labelFa}', style: TextStyle(color: tokens.cyan, fontSize: 11)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: tokens.cyan.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(_ChartPoint pt, AppThemeExtension tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.cardElevated,
        borderRadius: AppRadii.smRadius,
        border: Border.all(color: tokens.cyan.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(PersianUtils.formatPersianDate(pt.date), style: TextStyle(fontSize: 11, color: tokens.textMuted)),
          Text(
            '${PersianUtils.toPersianDigits(pt.value.toStringAsFixed(1))} ${_selectedMetric.unit}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: tokens.cyan),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSummary(List<_ChartPoint> points, AppThemeExtension tokens) {
    final first = points.first.value;
    final last = points.last.value;
    final delta = last - first;
    final isReduced = delta < 0;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text('تغییر ${_selectedMetric.labelFa}:', style: TextStyle(fontSize: 11, color: tokens.textMuted)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isReduced ? Icons.arrow_downward : (delta > 0 ? Icons.arrow_upward : Icons.remove),
              size: 14,
              color: isReduced ? tokens.lime : (delta > 0 ? tokens.gold : tokens.textMuted),
            ),
            const SizedBox(width: 4),
            Text(
              '${PersianUtils.toPersianDigits(delta.abs().toStringAsFixed(1))} ${_selectedMetric.unit} ${isReduced ? "کاهش" : (delta > 0 ? "افزایش" : "بدون تغییر")}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isReduced ? tokens.lime : (delta > 0 ? tokens.gold : tokens.textMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartPoint {
  final DateTime date;
  final double value;
  final int index;
  const _ChartPoint({required this.date, required this.value, required this.index});
}

class _MeasurementLineChartPainter extends CustomPainter {
  final List<_ChartPoint> points;
  final String unit;
  final AppThemeExtension tokens;
  final int? hoveredIndex;

  _MeasurementLineChartPainter({
    required this.points,
    required this.unit,
    required this.tokens,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    const paddingLeft = 36.0;
    const paddingRight = 16.0;
    const paddingTop = 16.0;
    const paddingBottom = 24.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    double minY = points.map((p) => p.value).reduce(math.min);
    double maxY = points.map((p) => p.value).reduce(math.max);
    minY = (minY - 1.0).floorToDouble();
    maxY = (maxY + 1.0).ceilToDouble();
    final yRange = maxY - minY == 0 ? 1.0 : maxY - minY;

    final gridPaint = Paint()
      ..color = tokens.borderColor.withOpacity(0.35)
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(textDirection: TextDirection.rtl);

    for (int i = 0; i <= 3; i++) {
      final yVal = minY + (yRange / 3) * i;
      final yPos = paddingTop + chartHeight - (chartHeight / 3) * i;

      canvas.drawLine(Offset(paddingLeft, yPos), Offset(size.width - paddingRight, yPos), gridPaint);

      textPainter.text = TextSpan(
        text: PersianUtils.toPersianDigits(yVal.toInt().toString()),
        style: TextStyle(fontSize: 9.5, color: tokens.textMuted),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft - textPainter.width - 6, yPos - textPainter.height / 2));
    }

    // Coordinates
    final offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final t = i / (points.length - 1);
      final x = (size.width - paddingRight) - t * chartWidth;
      final y = paddingTop + chartHeight - ((points[i].value - minY) / yRange) * chartHeight;
      offsets.add(Offset(x, y));
    }

    final linePath = Path();
    linePath.moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      final p0 = offsets[i - 1];
      final p1 = offsets[i];
      final cpX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient fill
    final fillPath = Path.from(linePath);
    fillPath.lineTo(offsets.last.dx, paddingTop + chartHeight);
    fillPath.lineTo(offsets.first.dx, paddingTop + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [tokens.cyan.withOpacity(0.3), tokens.cyan.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, paddingTop, size.width, chartHeight))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = tokens.cyan
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, strokePaint);

    // Dots
    final dotFill = Paint()..color = const Color(0xFF0E1118);
    final dotStroke = Paint()..color = tokens.cyan..strokeWidth = 2.0..style = PaintingStyle.stroke;

    for (int i = 0; i < offsets.length; i++) {
      final isHovered = hoveredIndex == i;
      final r = isHovered ? 5.5 : 3.5;
      canvas.drawCircle(offsets[i], r, dotFill);
      canvas.drawCircle(offsets[i], r, isHovered ? (Paint()..color = Colors.white..strokeWidth = 2.5..style = PaintingStyle.stroke) : dotStroke);
    }

    // Dates
    final firstDateStr = PersianUtils.formatPersianDate(points.first.date);
    final lastDateStr = PersianUtils.formatPersianDate(points.last.date);
    textPainter.text = TextSpan(text: firstDateStr, style: TextStyle(fontSize: 9.5, color: tokens.textMuted));
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - paddingRight - textPainter.width, size.height - paddingBottom + 6));

    textPainter.text = TextSpan(text: lastDateStr, style: TextStyle(fontSize: 9.5, color: tokens.cyan, fontWeight: FontWeight.bold));
    textPainter.layout();
    textPainter.paint(canvas, Offset(paddingLeft, size.height - paddingBottom + 6));
  }

  @override
  bool shouldRepaint(covariant _MeasurementLineChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex || oldDelegate.points != points;
  }
}
