import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../models/workout_plan.dart';

class ActiveSetRow extends StatefulWidget {
  final ActiveWorkoutSet workoutSet;
  final int restSeconds;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onDataChanged;
  final ActiveWorkoutSet? previousSet;

  const ActiveSetRow({
    super.key,
    required this.workoutSet,
    required this.restSeconds,
    required this.onToggleComplete,
    required this.onDataChanged,
    this.previousSet,
  });

  @override
  State<ActiveSetRow> createState() => _ActiveSetRowState();
}

class _ActiveSetRowState extends State<ActiveSetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.workoutSet.actualWeightKg > 0
          ? widget.workoutSet.actualWeightKg.toString()
          : '0',
    );
    _repsController = TextEditingController(
      text: widget.workoutSet.actualReps.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ActiveSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workoutSet.actualWeightKg !=
        widget.workoutSet.actualWeightKg) {
      final currentText = _weightController.text;
      final newText = widget.workoutSet.actualWeightKg > 0
          ? widget.workoutSet.actualWeightKg.toString()
          : '0';
      if (currentText != newText) {
        _weightController.text = newText;
      }
    }
    if (oldWidget.workoutSet.actualReps != widget.workoutSet.actualReps) {
      final currentText = _repsController.text;
      final newText = widget.workoutSet.actualReps.toString();
      if (currentText != newText) {
        _repsController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {});

    HapticFeedback.mediumImpact();
    final newStatus = !widget.workoutSet.isCompleted;
    widget.workoutSet.isCompleted = newStatus;
    setState(() {});
    widget.onToggleComplete(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final s = widget.workoutSet;
    final isCompleted = s.isCompleted;

    return FocusTraversalGroup(
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isCompleted
              ? tokens.cardBackground.withOpacity(0.9)
              : tokens.cardElevated,
          borderRadius: AppRadii.roundedMd,
          border: Border.all(
            color: isCompleted
                ? tokens.borderColor.withOpacity(0.8)
                : tokens.borderColor.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Set Number
            SizedBox(
              width: 28,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: AppDurations.fast,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isCompleted
                        ? tokens.textMuted
                        : theme.colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  child: Text(PersianUtils.toPersianDigits(s.setNumber)),
                ),
              ),
            ),

            // Target Reps & Weight + Previous Set Hint
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    alignment: AlignmentDirectional.centerStart,
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: AppDurations.fast,
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: isCompleted
                            ? tokens.textMuted.withOpacity(0.6)
                            : tokens.textMuted,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      child: Text(
                        '${PersianUtils.toPersianDigits(s.targetWeightKg.toInt())}kg × ${PersianUtils.toPersianDigits(s.targetReps)}',
                      ),
                    ),
                  ),
                  if (widget.previousSet != null)
                    FittedBox(
                      alignment: AlignmentDirectional.centerStart,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'قبل: ${PersianUtils.toPersianDigits(widget.previousSet!.actualWeightKg.toInt())}kg × ${PersianUtils.toPersianDigits(widget.previousSet!.actualReps)}',
                        style: TextStyle(
                          fontSize: 9,
                          color: tokens.cyan.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            AppSpacing.wXs,

            // Weight Input Field
            Expanded(
              flex: 2,
              child: Semantics(
                label:
                    'وزنه ست ${PersianUtils.toPersianDigits(s.setNumber)} به کیلوگرم',
                child: Container(
                  height: AppSpacing.minTouchTarget,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: AppRadii.roundedSm,
                    border: Border.all(
                      color: isCompleted
                          ? tokens.borderColor.withOpacity(0.5)
                          : tokens.borderColor.withOpacity(0.3),
                    ),
                  ),
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? tokens.textMuted
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isCompleted ? FontWeight.bold : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      final parsed = PersianUtils.tryParseDouble(val);
                      if (parsed != null && parsed >= 0) {
                        s.actualWeightKg = parsed;
                        widget.onDataChanged();
                      }
                    },
                  ),
                ),
              ),
            ),
            AppSpacing.wXs,

            // Reps Input Field
            Expanded(
              flex: 2,
              child: Semantics(
                label:
                    'تعداد تکرار ست ${PersianUtils.toPersianDigits(s.setNumber)}',
                child: Container(
                  height: AppSpacing.minTouchTarget,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: AppRadii.roundedSm,
                    border: Border.all(
                      color: isCompleted
                          ? tokens.borderColor.withOpacity(0.5)
                          : tokens.borderColor.withOpacity(0.3),
                    ),
                  ),
                  child: TextFormField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? tokens.textMuted
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isCompleted ? FontWeight.bold : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      final parsed = PersianUtils.tryParseInt(val);
                      if (parsed != null && parsed >= 1) {
                        s.actualReps = parsed;
                        widget.onDataChanged();
                      }
                    },
                  ),
                ),
              ),
            ),
            AppSpacing.wXs,

            // Checkbox Button with 48dp touch target and 42dp visual squircle
            Semantics(
              button: true,
              toggled: isCompleted,
              label: 'ثبت ست ${PersianUtils.toPersianDigits(s.setNumber)}',
              value: isCompleted ? 'تکمیل شده' : 'انجام نشده',
              child: InkWell(
                onTap: _handleToggle,
                borderRadius: AppRadii.roundedMd,
                child: Container(
                  width: AppSpacing.minTouchTarget,
                  height: AppSpacing.minTouchTarget,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    curve: Curves.easeInOut,
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isCompleted ? tokens.lime : tokens.cardElevated,
                      borderRadius: AppRadii.roundedMd,
                      border: Border.all(
                        color: isCompleted
                            ? tokens.lime
                            : tokens.borderColor.withOpacity(0.8),
                        width: 1.2,
                      ),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: tokens.lime.withOpacity(0.28),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: AnimatedScale(
                      scale: isCompleted ? 1.0 : 0.88,
                      duration: AppDurations.fast,
                      curve: Curves.easeOutBack,
                      child: Icon(
                        isCompleted ? Icons.check : Icons.crop_square,
                        size: 22,
                        color:
                            isCompleted ? tokens.textOnLime : tokens.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
