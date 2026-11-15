import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Official Ultra-Premium Vector Brand Mark & Logo for GymBro.
/// Engineered with clean geometry, metallic chrome bevels, matte dark carbon plate,
/// and signature neon lime accents (#CCFF00). Renders crisply at any resolution.
class GymBroBrandLogo extends StatelessWidget {
  final double size;
  final bool withGlow;
  final bool withText;
  final Color? customAccent;

  const GymBroBrandLogo({
    super.key,
    this.size = 48.0,
    this.withGlow = true,
    this.withText = false,
    this.customAccent,
  });

  @override
  Widget build(BuildContext context) {
    final accent = customAccent ?? const Color(0xFFCCFF00);

    Widget mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GymBroLogoPainter(
          accentColor: accent,
          withGlow: withGlow,
        ),
      ),
    );

    if (!withText) {
      return Semantics(
        label: 'لوگوی رسمی جیم‌برو',
        child: mark,
      );
    }

    return Semantics(
      label: 'نشان و عنوان برند جیم‌برو',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mark,
          SizedBox(width: size * 0.25),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GYMBRO',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.white,
                  height: 1.0,
                  shadows: withGlow
                      ? [
                          Shadow(
                            color: accent.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'PRO ATHLETIC SUITE',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: accent,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GymBroLogoPainter extends CustomPainter {
  final Color accentColor;
  final bool withGlow;

  _GymBroLogoPainter({
    required this.accentColor,
    required this.withGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Normalize to 100x100 virtual coordinate space
    final scale = size.width / 100.0;
    canvas.scale(scale, scale);

    const center = Offset(50, 50);

    // 1. Ambient Glow
    if (withGlow) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            accentColor.withOpacity(0.35),
            accentColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 48));
      canvas.drawCircle(center, 48, glowPaint);
    }

    // 2. Outer Shield Polygon (Hexagonal Bevel)
    final shieldPath = Path();
    const sides = 6;
    const radius = 44.0;
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        shieldPath.moveTo(x, y);
      } else {
        shieldPath.lineTo(x, y);
      }
    }
    shieldPath.close();

    // Shield background fill
    final shieldBgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E2638),
          Color(0xFF0F131D),
          Color(0xFF090C12),
        ],
      ).createShader(const Rect.fromLTWH(6, 6, 88, 88));
    canvas.drawPath(shieldPath, shieldBgPaint);

    // Shield Metallic Rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor,
          const Color(0xFF94A3B8),
          const Color(0xFF334155),
        ],
      ).createShader(const Rect.fromLTWH(6, 6, 88, 88));
    canvas.drawPath(shieldPath, rimPaint);

    // 3. Crossed Heavy Barbell Graphic
    final barPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
      ).createShader(const Rect.fromLTWH(20, 20, 60, 60));

    // Angled Barbell 45 degrees
    canvas.drawLine(const Offset(22, 78), const Offset(78, 22), barPaint);

    // Collar Rings & Heavy Hex Plates on Ends
    final platePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [accentColor, accentColor.withOpacity(0.75)],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

    // Bottom-Left Plate Stack
    canvas.save();
    canvas.translate(22, 78);
    canvas.rotate(-math.pi / 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -10, 8, 20), const Radius.circular(2)),
      platePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-9, -7, 4, 14), const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.restore();

    // Top-Right Plate Stack
    canvas.save();
    canvas.translate(78, 22);
    canvas.rotate(-math.pi / 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -10, 8, 20), const Radius.circular(2)),
      platePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(5, -7, 4, 14), const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.restore();

    // 4. Center Monogram Crest: Geometric 'G' with Neon Accent
    final gPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    final gPath = Path();
    // High-tech curved 'G'
    gPath.arcTo(
      const Rect.fromLTWH(34, 34, 32, 32),
      0.3,
      -math.pi * 1.5,
      false,
    );
    gPath.lineTo(50, 50);
    canvas.drawPath(gPath, gPaint);

    // Inner Core Neon Accent Dot
    final corePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(50, 50), 3.2, corePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GymBroLogoPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor || oldDelegate.withGlow != withGlow;
  }
}
