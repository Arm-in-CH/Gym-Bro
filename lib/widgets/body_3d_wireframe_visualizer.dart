import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../models/body_analytics_models.dart';

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

/// Interactive 3D Wireframe Anthropometric Body Visualizer inspired by professional body scanning systems.
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
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: tokens.lime, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(
                      'Live Metrics',
                      style: TextStyle(fontSize: 10, color: tokens.lime, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          // Central Wireframe Silhouette & Quick Stats Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 3D Mesh Wireframe Canvas
              SizedBox(
                width: 130,
                height: 240,
                child: CustomPaint(
                  painter: _BodyWireframePainter(
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

class _BodyWireframePainter extends CustomPainter {
  final BodyPartFocus selectedPart;
  final AppThemeExtension tokens;

  _BodyWireframePainter({
    required this.selectedPart,
    required this.tokens,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // High-tech Neon Cyan & Deep Space Blue Palette
    final meshContourPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final meshFillPaint = Paint()
      ..color = const Color(0xFF0369A1).withOpacity(0.16)
      ..style = PaintingStyle.fill;

    final internalGuidePaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.65)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final crossSectionPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.35)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final activeScanPaint = Paint()
      ..color = tokens.lime
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activeGlowPaint = Paint()
      ..color = tokens.lime.withOpacity(0.28)
      ..style = PaintingStyle.fill;

    // 1. Head & Athletic Jawline
    final headRect = Rect.fromCenter(
      center: Offset(cx, h * 0.10),
      width: w * 0.22,
      height: h * 0.11,
    );
    canvas.drawOval(headRect, meshFillPaint);
    canvas.drawOval(headRect, meshContourPaint);

    // 2. Full Athletic Muscular Body Contour (Smooth Anatomical Silhouette)
    final bodyPath = Path();
    // Neck starts at base of head
    bodyPath.moveTo(cx - w * 0.06, h * 0.15);
    // Trapezius and left shoulder / deltoid cap
    bodyPath.quadraticBezierTo(cx - w * 0.18, h * 0.17, cx - w * 0.32, h * 0.21);
    bodyPath.quadraticBezierTo(cx - w * 0.38, h * 0.25, cx - w * 0.37, h * 0.30);
    // Left arm: bicep swell, elbow, forearm, wrist, hand
    bodyPath.lineTo(cx - w * 0.40, h * 0.38);
    bodyPath.quadraticBezierTo(cx - w * 0.43, h * 0.46, cx - w * 0.40, h * 0.54);
    bodyPath.lineTo(cx - w * 0.36, h * 0.57); // Hand tip
    bodyPath.lineTo(cx - w * 0.33, h * 0.52); // Inner wrist
    bodyPath.lineTo(cx - w * 0.33, h * 0.44); // Inner forearm
    bodyPath.lineTo(cx - w * 0.31, h * 0.36); // Inner elbow
    bodyPath.lineTo(cx - w * 0.23, h * 0.27); // Armpit
    // Left torso: chest swell, V-taper waist, iliac flare
    bodyPath.quadraticBezierTo(cx - w * 0.25, h * 0.32, cx - w * 0.16, h * 0.40);
    bodyPath.quadraticBezierTo(cx - w * 0.20, h * 0.47, cx - w * 0.21, h * 0.51); // Left hip
    // Left leg: vastus lateralis, outer knee, calf bulge, outer ankle, foot
    bodyPath.quadraticBezierTo(cx - w * 0.25, h * 0.60, cx - w * 0.20, h * 0.70); // Knee
    bodyPath.quadraticBezierTo(cx - w * 0.24, h * 0.79, cx - w * 0.16, h * 0.89); // Ankle
    bodyPath.lineTo(cx - w * 0.19, h * 0.94); // Foot
    bodyPath.lineTo(cx - w * 0.11, h * 0.94);
    bodyPath.lineTo(cx - w * 0.10, h * 0.89); // Inner ankle
    bodyPath.quadraticBezierTo(cx - w * 0.08, h * 0.79, cx - w * 0.08, h * 0.70); // Inner knee
    bodyPath.quadraticBezierTo(cx - w * 0.07, h * 0.62, cx - w * 0.03, h * 0.53); // Groin base
    // Groin center to right leg
    bodyPath.lineTo(cx + w * 0.03, h * 0.53);
    // Right leg: inner thigh, knee, calf, ankle, foot
    bodyPath.quadraticBezierTo(cx + w * 0.07, h * 0.62, cx + w * 0.08, h * 0.70);
    bodyPath.quadraticBezierTo(cx + w * 0.08, h * 0.79, cx + w * 0.10, h * 0.89);
    bodyPath.lineTo(cx + w * 0.11, h * 0.94);
    bodyPath.lineTo(cx + w * 0.19, h * 0.94);
    bodyPath.lineTo(cx + w * 0.16, h * 0.89);
    bodyPath.quadraticBezierTo(cx + w * 0.24, h * 0.79, cx + w * 0.20, h * 0.70);
    bodyPath.quadraticBezierTo(cx + w * 0.25, h * 0.60, cx + w * 0.21, h * 0.51); // Right hip
    // Right torso: waist, chest swell, armpit
    bodyPath.quadraticBezierTo(cx + w * 0.20, h * 0.47, cx + w * 0.16, h * 0.40);
    bodyPath.quadraticBezierTo(cx + w * 0.25, h * 0.32, cx + w * 0.23, h * 0.27);
    // Right arm
    bodyPath.lineTo(cx + w * 0.31, h * 0.36);
    bodyPath.lineTo(cx + w * 0.33, h * 0.44);
    bodyPath.lineTo(cx + w * 0.33, h * 0.52);
    bodyPath.lineTo(cx + w * 0.36, h * 0.57);
    bodyPath.lineTo(cx + w * 0.40, h * 0.54);
    bodyPath.quadraticBezierTo(cx + w * 0.43, h * 0.46, cx + w * 0.40, h * 0.38);
    bodyPath.lineTo(cx + w * 0.37, h * 0.30);
    bodyPath.quadraticBezierTo(cx + w * 0.38, h * 0.25, cx + w * 0.32, h * 0.21);
    // Right trapezius to neck
    bodyPath.quadraticBezierTo(cx + w * 0.18, h * 0.17, cx + w * 0.06, h * 0.15);
    bodyPath.close();

    canvas.drawPath(bodyPath, meshFillPaint);
    canvas.drawPath(bodyPath, meshContourPaint);

    // 3. Anatomical Internal Structure Guides
    // Clavicle (Collarbones)
    final clavicle = Path();
    clavicle.moveTo(cx - w * 0.20, h * 0.20);
    clavicle.quadraticBezierTo(cx - w * 0.08, h * 0.215, cx, h * 0.205);
    clavicle.quadraticBezierTo(cx + w * 0.08, h * 0.215, cx + w * 0.20, h * 0.20);
    canvas.drawPath(clavicle, internalGuidePaint);

    // Pectoralis Major (Chest Contours)
    final leftPec = Path();
    leftPec.moveTo(cx - w * 0.21, h * 0.26);
    leftPec.quadraticBezierTo(cx - w * 0.10, h * 0.31, cx - w * 0.01, h * 0.29);
    canvas.drawPath(leftPec, internalGuidePaint);

    final rightPec = Path();
    rightPec.moveTo(cx + w * 0.21, h * 0.26);
    rightPec.quadraticBezierTo(cx + w * 0.10, h * 0.31, cx + w * 0.01, h * 0.29);
    canvas.drawPath(rightPec, internalGuidePaint);

    // Abdominal guidelines (6-pack)
    canvas.drawLine(Offset(cx, h * 0.29), Offset(cx, h * 0.43), internalGuidePaint);
    canvas.drawLine(Offset(cx - w * 0.08, h * 0.34), Offset(cx + w * 0.08, h * 0.34), crossSectionPaint);
    canvas.drawLine(Offset(cx - w * 0.07, h * 0.38), Offset(cx + w * 0.07, h * 0.38), crossSectionPaint);
    canvas.drawLine(Offset(cx - w * 0.07, h * 0.42), Offset(cx + w * 0.07, h * 0.42), crossSectionPaint);

    // Kneecaps (Patellas)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.14, h * 0.70), width: w * 0.07, height: h * 0.035),
      internalGuidePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.14, h * 0.70), width: w * 0.07, height: h * 0.035),
      internalGuidePaint,
    );

    // 4. Volumetric 3D Cylinder Cross-Section Rings
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.29), width: w * 0.38, height: h * 0.04),
      crossSectionPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.40), width: w * 0.30, height: h * 0.036),
      crossSectionPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.49), width: w * 0.36, height: h * 0.04),
      crossSectionPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.14, h * 0.61), width: w * 0.17, height: h * 0.03),
      crossSectionPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.14, h * 0.61), width: w * 0.17, height: h * 0.03),
      crossSectionPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.13, h * 0.79), width: w * 0.14, height: h * 0.026),
      crossSectionPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.13, h * 0.79), width: w * 0.14, height: h * 0.026),
      crossSectionPaint,
    );

    // 5. Highlight Active Anthropometric Zone with Glowing Hologram Ring
    switch (selectedPart) {
      case BodyPartFocus.chest:
        final chestRing = Rect.fromCenter(
          center: Offset(cx, h * 0.29),
          width: w * 0.42,
          height: h * 0.048,
        );
        canvas.drawOval(chestRing, activeGlowPaint);
        canvas.drawOval(chestRing, activeScanPaint);
        break;

      case BodyPartFocus.waist:
        final waistRing = Rect.fromCenter(
          center: Offset(cx, h * 0.40),
          width: w * 0.34,
          height: h * 0.044,
        );
        canvas.drawOval(waistRing, activeGlowPaint);
        canvas.drawOval(waistRing, activeScanPaint);
        break;

      case BodyPartFocus.hip:
        final hipRing = Rect.fromCenter(
          center: Offset(cx, h * 0.49),
          width: w * 0.40,
          height: h * 0.048,
        );
        canvas.drawOval(hipRing, activeGlowPaint);
        canvas.drawOval(hipRing, activeScanPaint);
        break;

      case BodyPartFocus.arm:
        final leftBicep = Rect.fromCenter(
          center: Offset(cx - w * 0.35, h * 0.35),
          width: w * 0.14,
          height: h * 0.05,
        );
        final rightBicep = Rect.fromCenter(
          center: Offset(cx + w * 0.35, h * 0.35),
          width: w * 0.14,
          height: h * 0.05,
        );
        canvas.drawOval(leftBicep, activeGlowPaint);
        canvas.drawOval(leftBicep, activeScanPaint);
        canvas.drawOval(rightBicep, activeGlowPaint);
        canvas.drawOval(rightBicep, activeScanPaint);
        break;

      case BodyPartFocus.thigh:
        final leftThigh = Rect.fromCenter(
          center: Offset(cx - w * 0.14, h * 0.61),
          width: w * 0.19,
          height: h * 0.04,
        );
        final rightThigh = Rect.fromCenter(
          center: Offset(cx + w * 0.14, h * 0.61),
          width: w * 0.19,
          height: h * 0.04,
        );
        canvas.drawOval(leftThigh, activeGlowPaint);
        canvas.drawOval(leftThigh, activeScanPaint);
        canvas.drawOval(rightThigh, activeGlowPaint);
        canvas.drawOval(rightThigh, activeScanPaint);
        break;

      case BodyPartFocus.calf:
        final leftCalf = Rect.fromCenter(
          center: Offset(cx - w * 0.13, h * 0.79),
          width: w * 0.15,
          height: h * 0.035,
        );
        final rightCalf = Rect.fromCenter(
          center: Offset(cx + w * 0.13, h * 0.79),
          width: w * 0.15,
          height: h * 0.035,
        );
        canvas.drawOval(leftCalf, activeGlowPaint);
        canvas.drawOval(leftCalf, activeScanPaint);
        canvas.drawOval(rightCalf, activeGlowPaint);
        canvas.drawOval(rightCalf, activeScanPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BodyWireframePainter oldDelegate) {
    return oldDelegate.selectedPart != selectedPart;
  }
}
