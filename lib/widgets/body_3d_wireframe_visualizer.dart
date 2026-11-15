import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/graphics/gymbro_anatomy_vector_data.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../models/body_analytics_models.dart';
import 'body_muscle_map.dart';

enum BodyPartFocus {
  chest,
  waist,
  hip,
  arm,
  thigh,
  calf;

  String get labelFa {
    switch (this) {
      case BodyPartFocus.chest:
        return 'دور سینه';
      case BodyPartFocus.waist:
        return 'دور کمر';
      case BodyPartFocus.hip:
        return 'دور باسن';
      case BodyPartFocus.arm:
        return 'دور بازو';
      case BodyPartFocus.thigh:
        return 'دور ران';
      case BodyPartFocus.calf:
        return 'ساق پا';
    }
  }

  double? getValue(BodyMeasurementRecord? r) {
    if (r == null) return null;
    switch (this) {
      case BodyPartFocus.chest:
        return r.chestCm;
      case BodyPartFocus.waist:
        return r.waistCm;
      case BodyPartFocus.hip:
        return r.hipCm;
      case BodyPartFocus.arm:
        return r.rightArmCm ?? r.leftArmCm;
      case BodyPartFocus.thigh:
        return r.thighCm;
      case BodyPartFocus.calf:
        return r.calfCm;
    }
  }
}

/// Interactive Biometric Anatomical Body Visualizer integrated with GymBro vector anatomy.
/// Replaces primitive geometric approximations with precision Bézier contours and active biometric scan overlays.
class Body3dWireframeVisualizer extends StatefulWidget {
  final BodyMeasurementRecord? latestMeasurement;
  final BodyMeasurementRecord? previousMeasurement;
  final ValueChanged<BodyPartFocus>? onPartSelected;

  const Body3dWireframeVisualizer({
    super.key,
    this.latestMeasurement,
    this.previousMeasurement,
    this.onPartSelected,
  });

  @override
  State<Body3dWireframeVisualizer> createState() => _Body3dWireframeVisualizerState();
}

class _Body3dWireframeVisualizerState extends State<Body3dWireframeVisualizer> {
  BodyPartFocus _selectedPart = BodyPartFocus.waist;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    final currentVal = _selectedPart.getValue(widget.latestMeasurement);
    final prevVal = _selectedPart.getValue(widget.previousMeasurement);
    double? diff;
    if (currentVal != null && prevVal != null) {
      diff = currentVal - prevVal;
    }

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
                        color: tokens.lime.withOpacity(0.18),
                        border: Border.all(color: tokens.lime.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Icon(Icons.person_pin, color: tokens.lime, size: 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نقشه آناتومیک و سایزهای بدن (3D Map)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'برای مشاهده جزئیات روی بخش‌های مشخص‌شده کلیک کنید',
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tokens.lime.withOpacity(0.15),
                  borderRadius: AppRadii.xsRadius,
                  border: Border.all(color: tokens.lime.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tokens.lime,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live Metrics',
                      style: TextStyle(
                        fontSize: 10,
                        color: tokens.lime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          // Central Anatomical Model & Metrics Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // High-Precision Vector Anatomical Scan Canvas
              SizedBox(
                width: 130,
                height: 240,
                child: CustomPaint(
                  painter: _AnatomyMeshVisualizerPainter(
                    selectedPart: _selectedPart,
                    tokens: tokens,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Interactive Segment Selector Buttons & Values
              Expanded(
                child: Column(
                  children: BodyPartFocus.values.map((part) {
                    final isSelected = _selectedPart == part;
                    final val = part.getValue(widget.latestMeasurement);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedPart = part);
                          widget.onPartSelected?.call(part);
                        },
                        borderRadius: AppRadii.smRadius,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? tokens.lime.withOpacity(0.18) : tokens.cardElevated,
                            borderRadius: AppRadii.smRadius,
                            border: Border.all(
                              color: isSelected ? tokens.lime : tokens.borderColor.withOpacity(0.6),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isSelected ? tokens.lime : tokens.textMuted.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      part.labelFa,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? tokens.lime : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  val != null ? '${PersianUtils.toPersianDigits(val.toStringAsFixed(1))} cm' : 'ثبت نشده',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: val != null ? (isSelected ? tokens.lime : tokens.textMuted) : tokens.textMuted.withOpacity(0.5),
                                    fontFamily: val != null ? 'monospace' : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Active Segment Delta Highlight Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: AppRadii.smRadius,
              border: Border.all(color: tokens.borderColor),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.straighten, size: 16, color: tokens.lime),
                    const SizedBox(width: 6),
                    Text(
                      'سایز انتخابی: ${_selectedPart.labelFa}',
                      style: TextStyle(fontSize: 11.5, color: tokens.textMuted, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (currentVal != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${PersianUtils.toPersianDigits(currentVal.toStringAsFixed(1))} cm',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: tokens.lime),
                      ),
                      if (diff != null && diff.abs() > 0.05) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (diff < 0 ? tokens.lime : tokens.gold).withOpacity(0.18),
                            borderRadius: AppRadii.xsRadius,
                          ),
                          child: Text(
                            '${diff < 0 ? "↓" : "↑"} ${PersianUtils.toPersianDigits(diff.abs().toStringAsFixed(1))}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: diff < 0 ? tokens.lime : tokens.gold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Text('داده‌ای موجود نیست', style: TextStyle(fontSize: 11, color: tokens.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Precision Vector Anatomy Painter that highlights the anthropometric target.
class _AnatomyMeshVisualizerPainter extends CustomPainter {
  final BodyPartFocus selectedPart;
  final AppThemeExtension tokens;

  _AnatomyMeshVisualizerPainter({
    required this.selectedPart,
    required this.tokens,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    final scale = math.min(size.width / GymBroAnatomyVectorData.viewBoxWidth,
                           size.height / GymBroAnatomyVectorData.viewBoxHeight);
    final dx = (size.width - GymBroAnatomyVectorData.viewBoxWidth * scale) / 2.0;
    final dy = (size.height - GymBroAnatomyVectorData.viewBoxHeight * scale) / 2.0;

    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final isBackView = selectedPart == BodyPartFocus.hip;

    // 1. Draw Authentic Base Silhouette
    final silhouette = isBackView
        ? GymBroAnatomyVectorData.getPosteriorSilhouette()
        : GymBroAnatomyVectorData.getAnteriorSilhouette();

    final basePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(silhouette, basePaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(silhouette, borderPaint);

    // 2. Draw Subtle Biometric Grid / Scanning Guides
    final scanGuidePaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.15)
      ..strokeWidth = 0.8;
    for (double y = 40; y <= 350; y += 30) {
      canvas.drawLine(Offset(50, y), Offset(190, y), scanGuidePaint);
    }

    // 3. Highlight Selected Anthropometric Muscle Region
    final highlightPath = Path();
    switch (selectedPart) {
      case BodyPartFocus.chest:
        highlightPath.addPath(GymBroAnatomyVectorData.getRegionPath(BodyMuscleRegion.chest), Offset.zero);
        break;
      case BodyPartFocus.waist:
        highlightPath.addPath(GymBroAnatomyVectorData.getRegionPath(BodyMuscleRegion.abs), Offset.zero);
        break;
      case BodyPartFocus.hip:
        highlightPath.addPath(GymBroAnatomyVectorData.getRegionPath(BodyMuscleRegion.glutes), Offset.zero);
        break;
      case BodyPartFocus.arm:
        highlightPath.addPath(GymBroAnatomyVectorData.getRegionPath(BodyMuscleRegion.biceps), Offset.zero);
        highlightPath.addPath(GymBroAnatomyVectorData.getRegionPath(BodyMuscleRegion.shoulders), Offset.zero);
        break;
      case BodyPartFocus.thigh:
        highlightPath.addPath(GymBroAnatomyVectorData.getRegionPath(BodyMuscleRegion.quadriceps), Offset.zero);
        break;
      case BodyPartFocus.calf:
        highlightPath.addPath(GymBroAnatomyVectorData.getRegionPath(BodyMuscleRegion.frontCalves), Offset.zero);
        break;
    }

    // Neon Glow
    final glowPaint = Paint()
      ..color = tokens.lime.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4.0)
      ..style = PaintingStyle.fill;
    canvas.drawPath(highlightPath, glowPaint);

    // Solid Lime Fill
    final fillPaint = Paint()
      ..color = tokens.lime
      ..style = PaintingStyle.fill;
    canvas.drawPath(highlightPath, fillPaint);

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(highlightPath, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AnatomyMeshVisualizerPainter oldDelegate) {
    return oldDelegate.selectedPart != selectedPart ||
        oldDelegate.tokens != tokens;
  }
}
