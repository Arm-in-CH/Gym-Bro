import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../core/services/workout_timer_service.dart';
import '../core/graphics/graphics.dart';

class RestTimerDialog extends StatefulWidget {
  final int? initialSeconds;

  const RestTimerDialog({super.key, this.initialSeconds});

  @override
  State<RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  final WorkoutTimerService _timerService = WorkoutTimerService();

  @override
  void initState() {
    super.initState();
    _timerService.addListener(_onTimerChanged);

    // If starting fresh and specified an initial duration
    if (widget.initialSeconds != null &&
        (_timerService.isIdle || _timerService.isCompleted)) {
      _timerService.start(widget.initialSeconds!);
    }
  }

  @override
  void dispose() {
    _timerService.removeListener(_onTimerChanged);
    super.dispose();
  }

  void _onTimerChanged() {
    if (mounted) setState(() {});
  }

  void _showCustomDurationDialog() async {
    final controller = TextEditingController(text: '75');
    final customSeconds = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مدت زمان سفارشی استراحت'),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'مدت زمان (ثانیه)',
            hintText: 'مثال: ۷۵',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              Navigator.pop(ctx, parsed);
            },
            child: const Text('تنظیم و شروع'),
          ),
        ],
      ),
    );

    if (customSeconds != null && customSeconds > 0) {
      await _timerService.start(customSeconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final remaining = _timerService.remainingSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final progress = _timerService.progressFraction;
    final isAlarm = _timerService.isCompleted;

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainer,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height * 0.90,
        ),
        child: SingleChildScrollView(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ExcludeSemantics(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.lime.withOpacity(0.18),
                            ),
                            child: GymBroIcon(
                              icon: GymBroDashboardIconType.timer,
                              size: 20,
                              active: true,
                              activeColor: tokens.lime,
                            ),
                          ),
                        ),
                        AppSpacing.wSm,
                        Expanded(
                          child: Text(
                            'تایمر استراحت بین ست',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: tokens.textMuted),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'بستن',
                    constraints: const BoxConstraints(
                      minWidth: AppSpacing.minTouchTarget,
                      minHeight: AppSpacing.minTouchTarget,
                    ),
                  ),
                ],
              ),
              AppSpacing.hSm,

              // 2. Predefined duration presets
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...WorkoutTimerService.predefinedDurations.map((d) {
                      final isSelected =
                          _timerService.totalDurationSeconds == d &&
                              !_timerService.isIdle;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(
                            '${PersianUtils.toPersianDigits(d)}s',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? tokens.textOnLime
                                  : tokens.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: tokens.lime,
                          backgroundColor: tokens.cardElevated,
                          onSelected: (_) => _timerService.start(d),
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ActionChip(
                        avatar: const Icon(Icons.tune, size: 14),
                        label: const Text('سفارشی',
                            style: TextStyle(fontSize: 11)),
                        backgroundColor: tokens.cardElevated,
                        onPressed: _showCustomDurationDialog,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hLg,

              // 3. Circular Progress Ring (Matching Reference Images 1, 2, 3)
              Semantics(
                label: 'زمان باقی‌مانده استراحت',
                value: '$minutes دقیقه و $seconds ثانیه',
                child: RepaintBoundary(
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background track & active sweep arc
                        CustomPaint(
                          size: const Size(170, 170),
                          painter: _RestTimerArcPainter(
                            progress: progress,
                            trackColor: tokens.cardElevated,
                            arcColor: isAlarm
                                ? tokens.orange
                                : (remaining <= 5 ? tokens.orange : tokens.lime),
                            isAlarm: isAlarm,
                          ),
                        ),

                        // Center Countdown Numbers & Subtitle
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  PersianUtils.toPersianDigits(timeStr),
                                  style: theme.textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: isAlarm
                                        ? tokens.orange
                                        : (remaining <= 5
                                            ? tokens.orange
                                            : theme.colorScheme.onSurface),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAlarm
                                        ? tokens.orange.withOpacity(0.18)
                                        : tokens.cardElevated,
                                    borderRadius: AppRadii.roundedPill,
                                  ),
                                  child: Text(
                                    isAlarm
                                        ? 'وقت شروع ست!'
                                        : (_timerService.isPaused
                                            ? 'استراحت متوقف است'
                                            : (remaining > 0
                                                ? 'ثانیه تا ست بعدی'
                                                : 'آماده باشید')),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isAlarm
                                          ? tokens.orange
                                          : (_timerService.isPaused
                                              ? tokens.cyan
                                              : tokens.textMuted),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.hLg,

              // 4. Tactile Extension & Skip Buttons (Matching Reference Image 3)
              Row(
                children: [
                  // Skip Rest button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: tokens.borderColor.withOpacity(0.8),
                        ),
                        minimumSize:
                            const Size(0, AppSpacing.minTouchTarget),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.roundedBase,
                        ),
                      ),
                      onPressed: () {
                        _timerService.cancel();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.skip_next_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('رد کردن استراحت'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),

                  // +15s quick add (Reference Image 3)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.cardElevated,
                        foregroundColor: tokens.lime,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        side: BorderSide(
                          color: tokens.lime.withOpacity(0.4),
                        ),
                        minimumSize:
                            const Size(0, AppSpacing.minTouchTarget),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.roundedBase,
                        ),
                      ),
                      onPressed: () => _timerService.addSeconds(15),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('+۱۵ ثانیه'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),

                  // +30s quick add
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.cyan,
                        side: BorderSide(
                          color: tokens.cyan.withOpacity(0.4),
                        ),
                        minimumSize:
                            const Size(0, AppSpacing.minTouchTarget),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.roundedBase,
                        ),
                      ),
                      onPressed: () => _timerService.addSeconds(30),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('+۳۰ ثانیه'),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.hSm,

              // 5. Main Primary Controls (Matching Reference Image 2)
              Row(
                children: [
                  // Reset Button
                  IconButton.outlined(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'ریست زمان',
                    constraints: const BoxConstraints(
                      minWidth: AppSpacing.minTouchTarget,
                      minHeight: AppSpacing.minTouchTarget,
                    ),
                    onPressed: () => _timerService.reset(),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Pause / Resume / Start Next Set CTA
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_timerService.isCompleted) {
                          _timerService.cancel();
                          Navigator.pop(context);
                        } else if (_timerService.isRunning) {
                          _timerService.pause();
                        } else if (_timerService.isPaused) {
                          _timerService.resume();
                        } else {
                          _timerService.start(widget.initialSeconds ?? 60);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAlarm ? tokens.orange : tokens.lime,
                        foregroundColor:
                            isAlarm ? Colors.black : tokens.textOnLime,
                        minimumSize:
                            const Size(0, AppSpacing.minTouchTarget),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.roundedBase,
                        ),
                        elevation: isAlarm ? 4 : 2,
                      ),
                      icon: Icon(
                        isAlarm
                            ? Icons.fitness_center_rounded
                            : (_timerService.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                        size: 20,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isAlarm
                              ? 'شروع ست (بستن زنگ)'
                              : (_timerService.isRunning
                                  ? 'توقف موقت استراحت'
                                  : 'ادامه تایمر استراحت'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Arc Painter for circular countdown ring
class _RestTimerArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color arcColor;
  final bool isAlarm;

  _RestTimerArcPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
    required this.isAlarm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 8.0;

    // 1. Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active Sweep Arc
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      final arcPaint = Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RestTimerArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.isAlarm != isAlarm;
  }
}
