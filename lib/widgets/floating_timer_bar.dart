import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../core/services/workout_timer_service.dart';
import '../core/graphics/graphics.dart';
import 'rest_timer_dialog.dart';

class FloatingTimerBar extends StatelessWidget {
  const FloatingTimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WorkoutTimerService(),
      builder: (context, _) {
        final timer = WorkoutTimerService();
        if (timer.isIdle) return const SizedBox.shrink();

        final tokens = context.appTokens;
        final theme = Theme.of(context);
        final remaining = timer.remainingSeconds;
        final minutes = remaining ~/ 60;
        final seconds = remaining % 60;
        final timeStr =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        final isAlarm = timer.isCompleted;

        return RepaintBoundary(
          child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              elevation: 8,
              borderRadius: AppRadii.roundedLg,
              color: isAlarm ? tokens.orange : tokens.cardElevated,
              child: InkWell(
                borderRadius: AppRadii.roundedLg,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const RestTimerDialog(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.roundedLg,
                    border: Border.all(
                      color: isAlarm
                          ? tokens.orange
                          : tokens.lime.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAlarm
                              ? Colors.black
                              : tokens.lime.withOpacity(0.2),
                        ),
                        child: isAlarm
                            ? Icon(Icons.alarm_on, size: 18, color: tokens.orange)
                            : (timer.isRunning
                                ? GymBroIcon(
                                    icon: GymBroDashboardIconType.timer,
                                    size: 18,
                                    active: true,
                                    activeColor: tokens.lime,
                                  )
                                : Icon(Icons.pause_circle_outline, size: 18, color: tokens.lime)),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isAlarm
                                  ? 'زمان استراحت پایان یافت!'
                                  : (timer.isRunning
                                      ? 'استراحت بین ست در حال اجراست'
                                      : 'تایمر متوقف شده است'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAlarm
                                    ? Colors.black
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              isAlarm
                                  ? 'برای خاموش کردن زنگ کلیک کنید'
                                  : 'زمان باقی‌مانده: ${PersianUtils.toPersianDigits(timeStr)}',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    isAlarm ? Colors.black87 : tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        PersianUtils.toPersianDigits(timeStr),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isAlarm ? Colors.black : tokens.lime,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Quick pause/resume or stop with 48dp touch target
                      IconButton(
                        constraints: const BoxConstraints(
                          minWidth: AppSpacing.minTouchTarget,
                          minHeight: AppSpacing.minTouchTarget,
                        ),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isAlarm
                              ? Icons.check
                              : (timer.isRunning
                                  ? Icons.pause
                                  : Icons.play_arrow),
                          size: 20,
                          color: isAlarm ? Colors.black : tokens.lime,
                        ),
                        onPressed: () {
                          if (isAlarm) {
                            timer.cancel();
                          } else if (timer.isRunning) {
                            timer.pause();
                          } else {
                            timer.resume();
                          }
                        },
                      ),
                      IconButton(
                        constraints: const BoxConstraints(
                          minWidth: AppSpacing.minTouchTarget,
                          minHeight: AppSpacing.minTouchTarget,
                        ),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.close,
                            size: 18,
                            color: isAlarm ? Colors.black : tokens.textMuted),
                        onPressed: () => timer.cancel(),
                        tooltip: 'بستن تایمر',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
      },
    );
  }
}
