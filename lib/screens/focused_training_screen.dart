import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/workout_plan.dart';
import '../models/workout_log.dart';
import '../models/exercise.dart';
import '../models/active_workout_progress.dart';
import '../core/services/workout_timer_service.dart';
import '../core/services/foldable_device_service.dart';
import '../widgets/floating_timer_bar.dart';
import '../widgets/rest_timer_dialog.dart';
import '../widgets/one_rm_calculator_dialog.dart';
import '../widgets/exercise_detail_sheet.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/active_set_row.dart';
import '../widgets/exercise_rest_selector_sheet.dart';
import '../widgets/workout_session_progress_header.dart';
import '../core/graphics/graphics.dart';
import 'workout_history_screen.dart';
import '../core/error/app_exceptions.dart';

class FocusedTrainingScreen extends StatefulWidget {
  final String planId;
  final AppState state;
  final int initialDay;
  final DateTime Function()? clock;

  const FocusedTrainingScreen({
    super.key,
    required this.planId,
    required this.state,
    this.initialDay = 1,
    this.clock,
  });

  @override
  State<FocusedTrainingScreen> createState() => _FocusedTrainingScreenState();
}

class _FocusedTrainingScreenState extends State<FocusedTrainingScreen>
    with WidgetsBindingObserver {
  late WorkoutPlan _plan;
  late int _selectedDay;
  late DateTime _sessionStartTime;
  int _currentExerciseIndex = 0;

  final Map<String, List<ActiveWorkoutSet>> _exerciseSets = {};
  final Map<String, int> _exerciseRestSeconds = {};
  bool _warmupTreadmillDone = false;
  bool _warmupJointsDone = false;
  bool _cooldownTreadmillDone = false;
  bool _cooldownStretchingDone = false;
  bool _isFinishing = false;

  // Focus Timer state
  bool _isPaused = false;
  int _pausedElapsedSeconds = 0;
  Timer? _focusTicker;
  final ValueNotifier<int> _elapsedSeconds = ValueNotifier<int>(0);

  DateTime get _now => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FoldableDeviceService().setWorkoutActive(true);
    _selectedDay = widget.initialDay;
    final foundPlan = widget.state.workoutPlans
            .where((p) => p.id == widget.planId)
            .firstOrNull ??
        widget.state.workoutPlans.firstOrNull;
    if (foundPlan == null) {
      _plan = WorkoutPlan(
        id: widget.planId,
        titleFa: 'برنامه تمرینی',
        titleEn: 'Workout Plan',
        descriptionFa: '',
        splitType: 'Custom',
      );
    } else {
      _plan = foundPlan;
    }

    _restoreOrInitSession();
    _startFocusTicker();
  }

  @override
  void dispose() {
    FoldableDeviceService().setWorkoutActive(false);
    WidgetsBinding.instance.removeObserver(this);
    _focusTicker?.cancel();
    _elapsedSeconds.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _persistDraft();
    } else if (state == AppLifecycleState.resumed) {
      _updateDisplayElapsed();
      if (!_isPaused) _startFocusTicker();
    }
  }

  void _restoreOrInitSession() {
    final draft = widget.state.getActiveWorkoutDraft(_plan.id);
    if (draft != null) {
      _selectedDay = draft.selectedDay;
      _sessionStartTime =
          DateTime.fromMillisecondsSinceEpoch(draft.startTimeEpoch);
      _warmupTreadmillDone = draft.warmupTreadmillDone;
      _warmupJointsDone = draft.warmupJointsDone;
      _cooldownTreadmillDone = draft.cooldownTreadmillDone;
      _cooldownStretchingDone = draft.cooldownStretchingDone;
      _exerciseSets.addAll(draft.exerciseSets);
      _exerciseRestSeconds.addAll(draft.exerciseRestSeconds);
      _isPaused = draft.isPaused;
      _pausedElapsedSeconds = draft.pausedElapsedSeconds;
    } else {
      _sessionStartTime = _now;
      _isPaused = false;
      _pausedElapsedSeconds = 0;
    }

    _elapsedSeconds.value = _currentElapsedSeconds;
    _ensureExercisesInitialized();
  }

  void _ensureExercisesInitialized() {
    for (var pe in _plan.exercises) {
      if (!_exerciseSets.containsKey(pe.id) || _exerciseSets[pe.id]!.isEmpty) {
        _exerciseSets[pe.id] = List.generate(
          pe.targetSets,
          (index) => ActiveWorkoutSet(
            setNumber: index + 1,
            targetReps: pe.targetReps,
            targetWeightKg: pe.targetWeightKg,
            actualReps: pe.targetReps,
            actualWeightKg: pe.targetWeightKg,
            isCompleted: false,
          ),
        );
      }
      if (!_exerciseRestSeconds.containsKey(pe.id)) {
        _exerciseRestSeconds[pe.id] = pe.restSeconds;
      }
    }
  }

  void _startFocusTicker() {
    _focusTicker?.cancel();
    if (_isPaused) return;
    _focusTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        _elapsedSeconds.value = _currentElapsedSeconds;
      }
    });
  }

  int get _currentElapsedSeconds => _isPaused
      ? _pausedElapsedSeconds
      : _now.difference(_sessionStartTime).inSeconds.clamp(0, 21600);

  void _updateDisplayElapsed() =>
      _elapsedSeconds.value = _currentElapsedSeconds;

  void _togglePauseResume() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_isPaused) {
        _sessionStartTime = _now.subtract(
          Duration(seconds: _pausedElapsedSeconds),
        );
        _pausedElapsedSeconds = 0;
        _isPaused = false;
        _startFocusTicker();
      } else {
        _pausedElapsedSeconds = _currentElapsedSeconds;
        _isPaused = true;
        _focusTicker?.cancel();
        _focusTicker = null;
      }
    });
    _updateDisplayElapsed();
    _persistDraft();
  }

  void _persistDraft() {
    final progress = ActiveWorkoutProgress(
      planId: _plan.id,
      selectedDay: _selectedDay,
      startTimeEpoch: _sessionStartTime.millisecondsSinceEpoch,
      warmupTreadmillDone: _warmupTreadmillDone,
      warmupJointsDone: _warmupJointsDone,
      cooldownTreadmillDone: _cooldownTreadmillDone,
      cooldownStretchingDone: _cooldownStretchingDone,
      exerciseSets: _exerciseSets,
      exerciseRestSeconds: _exerciseRestSeconds,
      isPaused: _isPaused,
      pausedElapsedSeconds: _isPaused ? _pausedElapsedSeconds : 0,
    );
    widget.state.saveActiveWorkoutDraft(progress);
  }

  List<WorkoutPlanExercise> get _dayExercises {
    final list =
        _plan.exercises.where((e) => e.dayOfWeek == _selectedDay).toList();
    return list.isNotEmpty ? list : _plan.exercises;
  }

  int get _activeDayTotalSets {
    int total = 0;
    for (var pe in _dayExercises) {
      total += (_exerciseSets[pe.id]?.length ?? pe.targetSets);
    }
    return total;
  }

  int get _activeDayCompletedSets {
    int count = 0;
    for (var pe in _dayExercises) {
      final sets = _exerciseSets[pe.id] ?? [];
      count += sets.where((s) => s.isCompleted).length;
    }
    return count;
  }

  double get _activeDayTotalVolumeKg {
    double volume = 0.0;
    for (var pe in _dayExercises) {
      final sets = _exerciseSets[pe.id] ?? [];
      for (var s in sets) {
        if (s.isCompleted) {
          final w = s.actualWeightKg < 0 ? 0.0 : s.actualWeightKg;
          final r = s.actualReps < 1 ? 1 : s.actualReps;
          volume += w * r;
        }
      }
    }
    return volume;
  }

  String _formatTimerDigits(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      final h = hours.toString().padLeft(2, '0');
      final m = minutes.toString().padLeft(2, '0');
      final s = seconds.toString().padLeft(2, '0');
      return PersianUtils.toPersianDigits('$h:$m:$s');
    } else {
      final m = minutes.toString().padLeft(2, '0');
      final s = seconds.toString().padLeft(2, '0');
      return PersianUtils.toPersianDigits('$m:$s');
    }
  }

  void _triggerRestTimer([int? seconds]) {
    final duration = seconds ?? widget.state.timerSettings.defaultRestSeconds;
    showDialog(
      context: context,
      builder: (_) => RestTimerDialog(initialSeconds: duration),
    );
  }

  void _openRestDurationSelector(WorkoutPlanExercise pe, Exercise ex) async {
    final currentRest = _exerciseRestSeconds[pe.id] ?? pe.restSeconds;
    final selected = await ExerciseRestSelectorSheet.show(
      context,
      exerciseName: ex.nameFa,
      currentRestSeconds: currentRest,
    );
    if (selected != null && mounted) {
      setState(() {
        _exerciseRestSeconds[pe.id] = selected;
      });
      _persistDraft();
      await widget.state.updateWorkoutPlanExerciseRest(
        planId: _plan.id,
        exercisePlanId: pe.id,
        restSeconds: selected,
      );
    }
  }

  void _handleSetToggle(
    String peId,
    ActiveWorkoutSet s,
    bool isComplete,
    int restSec,
  ) {
    s.isCompleted = isComplete;
    setState(() {});
    _persistDraft();

    if (isComplete && widget.state.timerSettings.autoStartTimer) {
      final pe = _plan.exercises.firstWhere(
        (e) => e.id == peId,
        orElse: () => _plan.exercises.first,
      );
      final ex = widget.state.exercises.firstWhere(
        (e) => e.id == pe.exerciseId,
        orElse: () => widget.state.exercises.first,
      );
      WorkoutTimerService().start(
        restSec > 0 ? restSec : 60,
        exerciseName: ex.nameFa,
      );
    }
  }

  void _quickAdjustWeight(ActiveWorkoutSet s, double delta) {
    HapticFeedback.selectionClick();
    setState(() {
      final updated = (s.actualWeightKg + delta).clamp(0.0, 500.0);
      s.actualWeightKg = updated;
    });
    _persistDraft();
  }

  void _quickAdjustReps(ActiveWorkoutSet s, int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      final updated = (s.actualReps + delta).clamp(1, 100);
      s.actualReps = updated;
    });
    _persistDraft();
  }

  void _finishSession() async {
    if (_isFinishing) return;

    double totalVolume = 0.0;
    int completedCount = 0;
    final setLogs = <WorkoutSetLog>[];

    _exerciseSets.forEach((peId, sets) {
      final pe = _plan.exercises.where((e) => e.id == peId).firstOrNull;
      final ex = pe != null
          ? widget.state.exercises
              .where((e) => e.id == pe.exerciseId)
              .firstOrNull
          : null;
      final exerciseName = ex?.nameFa ??
          (pe?.dayNameFa.isNotEmpty == true ? pe!.dayNameFa : 'تمرین متمرکز');

      for (var s in sets) {
        final safeWeight = s.actualWeightKg < 0 ? 0.0 : s.actualWeightKg;
        final safeReps = s.actualReps < 1 ? 1 : s.actualReps;

        if (s.isCompleted) {
          completedCount++;
          totalVolume += safeWeight * safeReps;
          setLogs.add(
            WorkoutSetLog(
              id: 'sl_${DateTime.now().microsecondsSinceEpoch}_${s.setNumber}',
              exerciseName: exerciseName,
              setNumber: s.setNumber,
              reps: safeReps,
              weightKg: safeWeight,
            ),
          );
        }
      }
    });

    if (completedCount == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('پایان تمرین بدون ست ثبت‌شده'),
          content: const Text(
            'هیچ ستی تکمیل نشده است؛ این جلسه در تاریخچه ذخیره نمی‌شود. خارج شوید؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('بازگشت به تمرین'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('خروج بدون ثبت'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      await widget.state.clearActiveWorkoutDraft(_plan.id);
      _focusTicker?.cancel();
      _focusTicker = null;
      await WorkoutTimerService().cancel();
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      _isFinishing = true;
    });
    _focusTicker?.cancel();
    _focusTicker = null;
    WorkoutTimerService().reset();

    final durationMinutes = (_currentElapsedSeconds / 60).ceil().clamp(1, 360);

    try {
      await widget.state.completeWorkoutSession(
        plan: _plan,
        totalVolumeKg: totalVolume,
        completedSets: completedCount,
        setLogs: setLogs,
        durationMinutes: durationMinutes,
      );

      if (!mounted) return;

      setState(() {
        _isFinishing = false;
      });

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final dialogTheme = Theme.of(ctx);
          final dialogTokens = ctx.appTokens;
          return AlertDialog(
            title: Row(
              children: [
                GymBroIcon(
                  icon: GymBroDashboardIconType.achievements,
                  size: 28,
                  active: true,
                  activeColor: dialogTokens.gold,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'جلسه تمرین ثبت شد',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خسته نباشید! جلسه تمرین متمرکز با موفقیت ذخیره گردید.',
                    style: dialogTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: dialogTokens.cardElevated,
                      borderRadius: AppRadii.roundedMd,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'مجموع تناژ جابجا شده:',
                                style: dialogTheme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              PersianUtils.formatTonnage(totalVolume),
                              style: dialogTheme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: dialogTokens.lime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'ست‌های تکمیل شده:',
                                style: dialogTheme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${PersianUtils.toPersianDigits(completedCount)} ست',
                              style: dialogTheme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: dialogTokens.cyan,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'مدت تمرین متمرکز:',
                                style: dialogTheme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${PersianUtils.toPersianDigits(durationMinutes)} دقیقه',
                              style: dialogTheme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: dialogTokens.gold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutHistoryScreen(state: widget.state),
                    ),
                  );
                },
                child: const Text('مشاهده در تاریخچه'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('عالی، بازگشت'),
              ),
            ],
          );
        },
      );
    } on AppException catch (e) {
      if (mounted) {
        _startFocusTicker();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _startFocusTicker();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ثبت جلسه تمرین: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFinishing = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خروج از تمرین متمرکز'),
        content: const Text(
          'آیا مایلید وضعیت تمرین متمرکز ذخیره شود تا بعداً ادامه دهید، یا پیش‌نویس جلسه حذف گردد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'continue'),
            child: const Text('ادامه تمرین'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('حذف پیش‌نویس'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'save_exit'),
            child: const Text('ذخیره و خروج'),
          ),
        ],
      ),
    );

    if (action == 'save_exit') {
      _persistDraft();
      return true;
    } else if (action == 'discard') {
      await widget.state.clearActiveWorkoutDraft(_plan.id);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final dayExercises = _dayExercises;

    if (_currentExerciseIndex >= dayExercises.length) {
      _currentExerciseIndex = 0;
    }

    final currentPe = dayExercises[_currentExerciseIndex];
    final currentEx = widget.state.exercises.firstWhere(
      (e) => e.id == currentPe.exerciseId,
      orElse: () => widget.state.exercises.first,
    );
    final currentSets = _exerciseSets[currentPe.id] ?? [];
    final currentRestSec =
        _exerciseRestSeconds[currentPe.id] ?? currentPe.restSeconds;

    // Find next incomplete set for quick focus
    final nextIncompleteSet = currentSets.firstWhere(
      (s) => !s.isCompleted,
      orElse: () => currentSets.last,
    );
    final isCurrentExerciseAllDone =
        currentSets.isNotEmpty && currentSets.every((s) => s.isCompleted);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _onWillPop();
        if (leave && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPaused ? tokens.gold : tokens.lime,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'تمرین متمرکز (Focus Mode)',
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                '${_plan.titleFa} • روز $_selectedDay',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calculate_outlined, color: tokens.cyan),
              tooltip: 'محاسبه‌گر 1RM',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const OneRmCalculatorDialog(),
                );
              },
            ),
            IconButton(
              icon: GymBroIcon(
                icon: GymBroDashboardIconType.exerciseHistory,
                size: 22,
                active: true,
                activeColor: tokens.gold,
              ),
              tooltip: 'تاریخچه تمرینات',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutHistoryScreen(state: widget.state),
                  ),
                );
              },
            ),
            IconButton(
              icon: GymBroIcon(
                icon: GymBroDashboardIconType.timer,
                size: 22,
                active: true,
                activeColor: tokens.lime,
              ),
              tooltip: 'تایمر استراحت',
              onPressed: () => _triggerRestTimer(),
            ),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FloatingTimerBar(),
            Container(
              padding: AppSpacing.screenPadding,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: tokens.borderColor)),
              ),
              child: ElevatedButton.icon(
                onPressed: _isFinishing ? null : _finishSession,
                icon: _isFinishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done_all),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _isFinishing
                        ? 'در حال ثبت تمرین...'
                      : 'اتمام تمرین و ذخیره در تاریخچه',
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: AdaptiveContainer(
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                // Top Focus Timer & Session Control Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _isPaused
                        ? tokens.gold.withOpacity(0.12)
                        : theme.colorScheme.surfaceContainer,
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: _isPaused
                          ? tokens.gold.withOpacity(0.4)
                          : tokens.borderColor,
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: _isPaused ? tokens.gold : tokens.lime,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'مدت جلسه: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: _elapsedSeconds,
                            builder: (context, seconds, _) => Text(
                              _formatTimerDigits(seconds),
                              key: const ValueKey('focused-elapsed-time'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isPaused ? tokens.gold : tokens.lime,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Semantics(
                        button: true,
                        label: _isPaused ? 'ادامه تمرین' : 'توقف موقت تمرین',
                        child: OutlinedButton.icon(
                          key: const ValueKey('focused-workout-pause-resume'),
                          onPressed: _togglePauseResume,
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                _isPaused ? tokens.lime : tokens.gold,
                            side: BorderSide(
                              color: _isPaused ? tokens.lime : tokens.gold,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                          ),
                          icon: Icon(
                            _isPaused ? Icons.play_arrow : Icons.pause,
                            size: 18,
                          ),
                          label: Text(_isPaused ? 'ادامه' : 'توقف موقت'),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSm,

                // Real-time Overall Session Progress
                WorkoutSessionProgressHeader(
                  completedSets: _activeDayCompletedSets,
                  totalSets: _activeDayTotalSets,
                  totalVolumeKg: _activeDayTotalVolumeKg,
                  warmupDone: _warmupTreadmillDone && _warmupJointsDone,
                  cooldownDone:
                      _cooldownTreadmillDone && _cooldownStretchingDone,
                ),
                AppSpacing.hBase,

                // Exercise Stepper / Horizontal Selector
                Text(
                  'انتخاب حرکت فعال (${PersianUtils.toPersianDigits(_currentExerciseIndex + 1)} از ${PersianUtils.toPersianDigits(dayExercises.length)}):',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dayExercises.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.xs),
                    itemBuilder: (ctx, idx) {
                      final pe = dayExercises[idx];
                      final ex = widget.state.exercises.firstWhere(
                        (e) => e.id == pe.exerciseId,
                        orElse: () => widget.state.exercises.first,
                      );
                      final sets = _exerciseSets[pe.id] ?? [];
                      final doneCount = sets.where((s) => s.isCompleted).length;
                      final isAllDone =
                          sets.isNotEmpty && doneCount == sets.length;
                      final isCurrent = idx == _currentExerciseIndex;

                      return Semantics(
                        button: true,
                        selected: isCurrent,
                        label:
                            'حرکت ${PersianUtils.toPersianDigits(idx + 1)}: ${ex.nameFa}',
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _currentExerciseIndex = idx;
                            });
                          },
                          borderRadius: AppRadii.roundedMd,
                          child: AnimatedContainer(
                            duration: AppDurations.fast,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? tokens.lime.withOpacity(0.2)
                                  : tokens.cardElevated,
                              borderRadius: AppRadii.roundedMd,
                              border: Border.all(
                                color: isCurrent
                                    ? tokens.lime
                                    : (isAllDone
                                        ? tokens.lime.withOpacity(0.5)
                                        : tokens.borderColor),
                                width: isCurrent ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isAllDone)
                                  Icon(Icons.check_circle,
                                      size: 16, color: tokens.lime)
                                else
                                  Container(
                                    width: 18,
                                    height: 18,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrent
                                          ? tokens.lime
                                          : tokens.borderColor,
                                    ),
                                    child: Text(
                                      PersianUtils.toPersianDigits(idx + 1),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? tokens.textOnLime
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  ex.nameFa,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCurrent
                                        ? tokens.lime
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppSpacing.hBase,

                // CURRENT EXERCISE FOCUSED CARD
                Container(
                  padding: AppSpacing.screenPadding,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: AppRadii.roundedLg,
                    border: Border.all(
                      color: isCurrentExerciseAllDone
                          ? tokens.lime.withOpacity(0.4)
                          : tokens.borderColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentEx.nameFa,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentExerciseAllDone
                                        ? tokens.lime
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  '${currentEx.muscleGroupFa} • ${currentEx.equipmentFa}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: tokens.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.info_outline,
                                color: tokens.cyan, size: 22),
                            tooltip: 'اطلاعات کامل حرکت',
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (_) =>
                                    ExerciseDetailSheet(exercise: currentEx),
                              );
                            },
                          ),
                        ],
                      ),
                      AppSpacing.hSm,

                      // Action Chips: Rest Duration & Completion Status
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Semantics(
                            button: true,
                            label:
                                'تنظیم زمان استراحت حرکت ${currentEx.nameFa}',
                            child: InkWell(
                              onTap: () => _openRestDurationSelector(
                                  currentPe, currentEx),
                              borderRadius: AppRadii.roundedSm,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.cardElevated,
                                  borderRadius: AppRadii.roundedSm,
                                  border: Border.all(color: tokens.borderColor),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GymBroIcon(
                                      icon: GymBroDashboardIconType.timer,
                                      size: 16,
                                      active: true,
                                      activeColor: tokens.lime,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'استراحت: ${PersianUtils.toPersianDigits(currentRestSec)} ثانیه',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Icon(Icons.tune,
                                        size: 14, color: tokens.textMuted),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentExerciseAllDone
                                  ? tokens.lime.withOpacity(0.2)
                                  : tokens.cardElevated,
                              borderRadius: AppRadii.roundedSm,
                              border: Border.all(
                                color: isCurrentExerciseAllDone
                                    ? tokens.lime
                                    : tokens.borderColor,
                              ),
                            ),
                            child: Text(
                              isCurrentExerciseAllDone
                                  ? 'تمام ست‌ها تکمیل شد'
                                  : '${PersianUtils.toPersianDigits(currentSets.where((s) => s.isCompleted).length)} از ${PersianUtils.toPersianDigits(currentSets.length)} ست',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isCurrentExerciseAllDone
                                    ? tokens.lime
                                    : tokens.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.hMd,

                      // QUICK SET ADJUSTMENT PANEL FOR ACTIVE SET
                      if (!isCurrentExerciseAllDone) ...[
                        Container(
                          padding: AppSpacing.paddingBase,
                          decoration: BoxDecoration(
                            color: tokens.cardElevated,
                            borderRadius: AppRadii.roundedMd,
                            border:
                                Border.all(color: tokens.lime.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.xxs,
                                children: [
                                  Text(
                                    'تنظیم سریع ست فعال (ست ${PersianUtils.toPersianDigits(nextIncompleteSet.setNumber)})',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: tokens.lime,
                                    ),
                                  ),
                                  Text(
                                    'هدف: ${PersianUtils.toPersianDigits(nextIncompleteSet.targetWeightKg.toInt())}kg × ${PersianUtils.toPersianDigits(nextIncompleteSet.targetReps)}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: tokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Quick weight modifier buttons
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'وزنه: ',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: tokens.textMuted,
                                        ),
                                      ),
                                      Text(
                                        PersianUtils.formatWeight(nextIncompleteSet.actualWeightKg, decimalDigits: 1),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildAdjustButton(
                                        label: '-۵',
                                        onTap: () => _quickAdjustWeight(
                                            nextIncompleteSet, -5.0),
                                        tokens: tokens,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      _buildAdjustButton(
                                        label: '-۲.۵',
                                        onTap: () => _quickAdjustWeight(
                                            nextIncompleteSet, -2.5),
                                        tokens: tokens,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      _buildAdjustButton(
                                        label: '+۲.۵',
                                        onTap: () => _quickAdjustWeight(
                                            nextIncompleteSet, 2.5),
                                        tokens: tokens,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      _buildAdjustButton(
                                        label: '+۵',
                                        onTap: () => _quickAdjustWeight(
                                            nextIncompleteSet, 5.0),
                                        tokens: tokens,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),

                              // Quick reps modifier buttons
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'تکرار: ',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: tokens.textMuted,
                                        ),
                                      ),
                                      Text(
                                        '${PersianUtils.toPersianDigits(nextIncompleteSet.actualReps)} تکرار',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildAdjustButton(
                                        label: '-۲',
                                        onTap: () => _quickAdjustReps(
                                            nextIncompleteSet, -2),
                                        tokens: tokens,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      _buildAdjustButton(
                                        label: '-۱',
                                        onTap: () => _quickAdjustReps(
                                            nextIncompleteSet, -1),
                                        tokens: tokens,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      _buildAdjustButton(
                                        label: '+۱',
                                        onTap: () => _quickAdjustReps(
                                            nextIncompleteSet, 1),
                                        tokens: tokens,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      _buildAdjustButton(
                                        label: '+۲',
                                        onTap: () => _quickAdjustReps(
                                            nextIncompleteSet, 2),
                                        tokens: tokens,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Round Indicator Pills (Matching Reference Image 2)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'وضعیت ست‌ها:',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: tokens.textMuted,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  ...currentSets.map((s) {
                                    final isDone = s.isCompleted;
                                    final isActive = s.setNumber ==
                                            nextIncompleteSet.setNumber &&
                                        !isDone;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? tokens.lime
                                            : (isActive
                                                ? tokens.lime.withOpacity(0.25)
                                                : tokens.cardElevated),
                                        borderRadius: AppRadii.roundedXs,
                                        border: Border.all(
                                          color: isActive
                                              ? tokens.lime
                                              : (isDone
                                                  ? tokens.lime
                                                  : tokens.borderColor),
                                          width: isActive ? 1.8 : 1.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: isDone
                                          ? Icon(Icons.check,
                                              size: 16,
                                              color: tokens.textOnLime)
                                          : Text(
                                              PersianUtils.toPersianDigits(
                                                  s.setNumber),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isActive
                                                    ? tokens.lime
                                                    : tokens.textMuted,
                                              ),
                                            ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Quick complete button (Matching Reference Image 2)
                              ElevatedButton.icon(
                                onPressed: () {
                                  _handleSetToggle(
                                    currentPe.id,
                                    nextIncompleteSet,
                                    true,
                                    currentRestSec,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tokens.lime,
                                  foregroundColor: tokens.textOnLime,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadii.roundedBase,
                                  ),
                                  elevation: 3,
                                ),
                                icon: const Icon(Icons.check, size: 20),
                                label: Text(
                                  'ثبت ست ${PersianUtils.toPersianDigits(nextIncompleteSet.setNumber)} (تکمیل شد)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hMd,
                      ] else ...[
                        // All sets done for current exercise celebration banner
                        Container(
                          padding: AppSpacing.paddingBase,
                          decoration: BoxDecoration(
                            color: tokens.lime.withOpacity(0.15),
                            borderRadius: AppRadii.roundedMd,
                            border: Border.all(color: tokens.lime),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: tokens.lime, size: 24),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'تمام ست‌های این حرکت با موفقیت به پایان رسید!',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: tokens.lime,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_currentExerciseIndex <
                                  dayExercises.length - 1)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentExerciseIndex++;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: tokens.lime,
                                    foregroundColor: tokens.textOnLime,
                                  ),
                                  child: const Text('حرکت بعدی'),
                                ),
                            ],
                          ),
                        ),
                        AppSpacing.hMd,
                      ],

                      // Full Table of Sets for this exercise
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('ست',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(color: tokens.textMuted)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text('هدف برنامه',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(color: tokens.textMuted)),
                            ),
                          ),
                          AppSpacing.wXs,
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('وزنه (kg)',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(color: tokens.textMuted)),
                            ),
                          ),
                          AppSpacing.wXs,
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('تکرار',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(color: tokens.textMuted)),
                            ),
                          ),
                          AppSpacing.wXs,
                          const SizedBox(
                            width: AppSpacing.minTouchTarget,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child:
                                    Text('ثبت', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.hSm,

                      ...List.generate(currentSets.length, (sIdx) {
                        final s = currentSets[sIdx];
                        final prevSet = sIdx > 0 ? currentSets[sIdx - 1] : null;
                        return ActiveSetRow(
                          key: ValueKey(
                              'focus_set_${currentPe.id}_${s.setNumber}'),
                          workoutSet: s,
                          restSeconds: currentRestSec,
                          previousSet: prevSet,
                          onToggleComplete: (done) => _handleSetToggle(
                            currentPe.id,
                            s,
                            done,
                            currentRestSec,
                          ),
                          onDataChanged: () {
                            _persistDraft();
                            setState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                ),
                AppSpacing.hMd,

                // Navigation Controls (Previous / Next Exercise)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentExerciseIndex > 0
                          ? () => setState(() => _currentExerciseIndex--)
                          : null,
                      icon: const Icon(
                          Icons.arrow_forward), // RTL forward is prev
                      label: const Text('حرکت قبلی'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentExerciseIndex < dayExercises.length - 1
                          ? () => setState(() => _currentExerciseIndex++)
                          : null,
                      icon: const Icon(Icons.arrow_back), // RTL back is next
                      label: const Text('حرکت بعدی'),
                    ),
                  ],
                ),
                AppSpacing.hLg,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustButton({
    required String label,
    required VoidCallback onTap,
    required AppThemeExtension tokens,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.roundedSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: tokens.borderColor.withOpacity(0.5),
          borderRadius: AppRadii.roundedSm,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
