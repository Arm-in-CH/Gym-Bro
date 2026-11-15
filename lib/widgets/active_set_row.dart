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
  final double? previousRecordWeightKg;
  final int? previousRecordReps;
  final bool? isCurrent;

  const ActiveSetRow({
    super.key,
    required this.workoutSet,
    required this.restSeconds,
    required this.onToggleComplete,
    required this.onDataChanged,
    this.previousSet,
    this.previousRecordWeightKg,
    this.previousRecordReps,
    this.isCurrent,
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

  void _fillFromRecord({required double weight, required int reps}) {
    if (widget.workoutSet.isCompleted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _weightController.text = weight > 0 ? (weight % 1 == 0 ? weight.toInt().toString() : weight.toString()) : '0';
      _repsController.text = reps.toString();
      widget.workoutSet.actualWeightKg = weight;
      widget.workoutSet.actualReps = reps;
    });
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final s = widget.workoutSet;
    final isCompleted = s.isCompleted;
    final bool isCurrent = widget.isCurrent ?? (!isCompleted && (widget.previousSet == null || widget.previousSet!.isCompleted));

    final verticalPadding = isCompleted
        ? 4.0
        : (isCurrent ? 9.0 : 6.0);
    final double inputHeight = isCurrent ? 44.0 : 38.0;
    final double setNumberSize = isCurrent ? 16.0 : (isCompleted ? 12.0 : 13.5);
    final double inputFontSize = isCurrent ? 14.5 : 13.0;

    return FocusTraversalGroup(
      child: AnimatedOpacity(
        duration: AppDurations.fast,
        opacity: isCompleted ? 0.68 : 1.0,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isCurrent
                ? tokens.cardElevated
                : (isCompleted
                    ? tokens.cardBackground.withOpacity(0.7)
                    : tokens.cardElevated.withOpacity(0.85)),
            borderRadius: AppRadii.roundedMd,
            border: Border.all(
              color: isCurrent
                  ? tokens.lime.withOpacity(0.55)
                  : (isCompleted
                      ? tokens.borderColor.withOpacity(0.5)
                      : tokens.borderColor.withOpacity(0.35)),
              width: isCurrent ? 1.6 : 1.0,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: tokens.lime.withOpacity(0.12),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Set Number with athletic sizing
              SizedBox(
                width: 28,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: AppDurations.fast,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w800,
                      fontSize: setNumberSize,
                      color: isCurrent
                          ? tokens.lime
                          : (isCompleted
                              ? tokens.textMuted
                              : theme.colorScheme.onSurface),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    child: Text(PersianUtils.toPersianDigits(s.setNumber)),
                  ),
                ),
              ),

              // Target Reps & Weight + Tap-to-Fill Previous Record
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
                    // Previous Session or Previous Set Record (Tap to quick-fill)
                    if (widget.previousRecordWeightKg != null && widget.previousRecordReps != null)
                      GestureDetector(
                        onTap: () => _fillFromRecord(
                          weight: widget.previousRecordWeightKg!,
                          reps: widget.previousRecordReps!,
                        ),
                        child: Tooltip(
                          message: 'لمس برای استفاده از رکورد جلسه قبل',
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: tokens.textMuted.withOpacity(0.12),
                              borderRadius: AppRadii.roundedXs,
                            ),
                            child: FittedBox(
                              alignment: AlignmentDirectional.centerStart,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'جلسه قبل: ${PersianUtils.toPersianDigits(widget.previousRecordWeightKg!.toInt())}kg × ${PersianUtils.toPersianDigits(widget.previousRecordReps!)}',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: tokens.textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (widget.previousSet != null)
                      GestureDetector(
                        onTap: () => _fillFromRecord(
                          weight: widget.previousSet!.actualWeightKg,
                          reps: widget.previousSet!.actualReps,
                        ),
                        child: Tooltip(
                          message: 'لمس برای استفاده از ست قبلی',
                          child: FittedBox(
                            alignment: AlignmentDirectional.centerStart,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'قبل: ${PersianUtils.toPersianDigits(widget.previousSet!.actualWeightKg.toInt())}kg × ${PersianUtils.toPersianDigits(widget.previousSet!.actualReps)}',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: isCurrent ? tokens.cyan : tokens.textMuted,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
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
                    height: inputHeight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(
                        color: isCurrent
                            ? tokens.lime.withOpacity(0.4)
                            : (isCompleted
                                ? tokens.borderColor.withOpacity(0.5)
                                : tokens.borderColor.withOpacity(0.3)),
                      ),
                    ),
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: inputFontSize,
                        color: isCompleted
                            ? tokens.textMuted
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.bold : FontWeight.w600),
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
                    height: inputHeight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(
                        color: isCurrent
                            ? tokens.lime.withOpacity(0.4)
                            : (isCompleted
                                ? tokens.borderColor.withOpacity(0.5)
                                : tokens.borderColor.withOpacity(0.3)),
                      ),
                    ),
                    child: TextFormField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: inputFontSize,
                        color: isCompleted
                            ? tokens.textMuted
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.bold : FontWeight.w600),
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

              // Checkbox Button
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
                      width: isCurrent ? 44 : 40,
                      height: isCurrent ? 44 : 40,
                      decoration: BoxDecoration(
                        color: isCompleted ? tokens.lime : tokens.cardElevated,
                        borderRadius: AppRadii.roundedMd,
                        border: Border.all(
                          color: isCompleted
                              ? tokens.lime
                              : (isCurrent
                                  ? tokens.lime.withOpacity(0.8)
                                  : tokens.borderColor.withOpacity(0.8)),
                          width: isCompleted ? 1.0 : (isCurrent ? 1.6 : 1.2),
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: tokens.lime.withOpacity(0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : (isCurrent
                                ? [
                                    BoxShadow(
                                      color: tokens.lime.withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : null),
                      ),
                      child: AnimatedScale(
                        scale: isCompleted ? 1.0 : 0.88,
                        duration: AppDurations.fast,
                        curve: Curves.easeOutBack,
                        child: Icon(
                          isCompleted ? Icons.check : Icons.crop_square,
                          size: 22,
                          color:
                              isCompleted ? tokens.textOnLime : (isCurrent ? tokens.lime : tokens.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
