import 'dart:async';
import 'package:flutter/material.dart';
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
import 'focused_training_screen.dart';
import '../core/graphics/graphics.dart';
import '../core/error/app_exceptions.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String planId;
  final AppState state;
  final int initialDay;
  final DateTime Function()? clock;

  const ActiveWorkoutScreen({
    super.key,
    required this.planId,
    required this.state,
    this.initialDay = 1,
    this.clock,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with WidgetsBindingObserver {
  late WorkoutPlan _plan;
  late int _selectedDay;
  late DateTime _startTime;
  final Map<String, List<ActiveWorkoutSet>> _exerciseSets = {};
  final Map<String, int> _exerciseRestSeconds = {};
  bool _warmupTreadmillDone = false;
  bool _warmupJointsDone = false;
  bool _cooldownTreadmillDone = false;
  bool _cooldownStretchingDone = false;
  bool _isFinishing = false;
  bool _isPaused = false;
  int _pausedElapsedSeconds = 0;
  final ValueNotifier<int> _elapsedSeconds = ValueNotifier<int>(0);
  Timer? _elapsedTicker;

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
  }

  @override
  void dispose() {
    FoldableDeviceService().setWorkoutActive(false);
    WidgetsBinding.instance.removeObserver(this);
    _elapsedTicker?.cancel();
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
      _elapsedSeconds.value = _currentElapsedSeconds;
      if (!_isPaused) _startElapsedTicker();
    }
  }

  void _restoreOrInitSession() {
    final draft = widget.state.getActiveWorkoutDraft(_plan.id);
    if (draft != null) {
      _selectedDay = draft.selectedDay;
      _startTime = DateTime.fromMillisecondsSinceEpoch(draft.startTimeEpoch);
      _isPaused = draft.isPaused;
      _pausedElapsedSeconds = draft.pausedElapsedSeconds;
      _warmupTreadmillDone = draft.warmupTreadmillDone;
      _warmupJointsDone = draft.warmupJointsDone;
      _cooldownTreadmillDone = draft.cooldownTreadmillDone;
      _cooldownStretchingDone = draft.cooldownStretchingDone;
      _exerciseSets.addAll(draft.exerciseSets);
      _exerciseRestSeconds.addAll(draft.exerciseRestSeconds);
    } else {
      _startTime = _now;
    }
    _ensureExercisesInitialized();
    _elapsedSeconds.value = _currentElapsedSeconds;
    if (!_isPaused) _startElapsedTicker();
  }

  int get _currentElapsedSeconds {
    if (_isPaused) return _pausedElapsedSeconds;
    return _now.difference(_startTime).inSeconds.clamp(0, 21600);
  }

  void _startElapsedTicker() {
    _elapsedTicker?.cancel();
    if (_isPaused) return;
    _elapsedTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds.value = _currentElapsedSeconds;
    });
  }

  void _toggleWorkoutPause() {
    if (_isFinishing) return;
    setState(() {
      if (_isPaused) {
        _startTime = _now.subtract(
          Duration(seconds: _pausedElapsedSeconds),
        );
        _pausedElapsedSeconds = 0;
        _isPaused = false;
        _startElapsedTicker();
      } else {
        _pausedElapsedSeconds = _currentElapsedSeconds;
        _isPaused = true;
        _elapsedTicker?.cancel();
        _elapsedTicker = null;
      }
    });
    _elapsedSeconds.value = _currentElapsedSeconds;
    _persistDraft();
  }

  String _formatElapsed(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    final raw = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    return PersianUtils.toPersianDigits(raw);
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

  void _persistDraft() {
    final progress = ActiveWorkoutProgress(
      planId: _plan.id,
      selectedDay: _selectedDay,
      startTimeEpoch: _startTime.millisecondsSinceEpoch,
      warmupTreadmillDone: _warmupTreadmillDone,
      warmupJointsDone: _warmupJointsDone,
      cooldownTreadmillDone: _cooldownTreadmillDone,
      cooldownStretchingDone: _cooldownStretchingDone,
      exerciseSets: _exerciseSets,
      exerciseRestSeconds: _exerciseRestSeconds,
      isPaused: _isPaused,
      pausedElapsedSeconds: _pausedElapsedSeconds,
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

  void _finishSession() async {
    if (_isFinishing) return;

    double totalVolume = 0.0;
    int completedCount = 0;
    final setLogs = <WorkoutSetLog>[];

    // Accurately log ONLY completed sets
    _exerciseSets.forEach((peId, sets) {
      final pe = _plan.exercises.where((e) => e.id == peId).firstOrNull;
      final ex = pe != null
          ? widget.state.exercises
              .where((e) => e.id == pe.exerciseId)
              .firstOrNull
          : null;
      final exerciseName = ex?.nameFa ??
          (pe?.dayNameFa.isNotEmpty == true ? pe!.dayNameFa : 'تمرین اختصاصی');

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
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      _isFinishing = true;
    });

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
                const Text('جلسه تمرین ثبت شد'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خسته نباشید! جلسه تمرین با موفقیت در تاریخچه ذخیره گردید.',
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
                          Text('مجموع تناژ جابجا شده:',
                              style: dialogTheme.textTheme.bodySmall),
                          Text(
                            '${PersianUtils.toPersianDigits(totalVolume.toInt())} کیلوگرم',
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
                          Text('ست‌های تکمیل شده:',
                              style: dialogTheme.textTheme.bodySmall),
                          Text(
                            '${PersianUtils.toPersianDigits(completedCount)} ست',
                            style: dialogTheme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: dialogTokens.cyan,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('عالی، خروج'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
    final tokens = context.appTokens;
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خروج از تمرین زنده'),
        content: const Text(
          'آیا مایلید وضعیت فعلی تمرین ذخیره شود تا بعداً ادامه دهید، یا جلسه به‌طور کامل لغو گردد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'continue'),
            child: Text('ادامه تمرین', style: TextStyle(color: tokens.textMuted)),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.red,
              side: BorderSide(color: tokens.red.withOpacity(0.5)),
            ),
            child: const Text('حذف پیش‌نویس و لغو'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'save_exit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.lime,
              foregroundColor: tokens.textOnLime,
            ),
            child: const Text('ذخیره و خروج', style: TextStyle(fontWeight: FontWeight.bold)),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
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
              Text(
                widget.state.userProfile.firstName.trim().isNotEmpty
                    ? 'اتاق تمرین ${widget.state.userProfile.firstName.trim()} (In-Gym Focus)'
                    : 'اتاق تمرین تخصصی (In-Gym Focus)',
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _plan.titleFa,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calculate_outlined, color: tokens.textMuted),
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
                icon: GymBroDashboardIconType.focusedTraining,
                size: 22,
                active: true,
                activeColor: tokens.gold,
              ),
              tooltip: 'ورود به تمرین متمرکز (Focus Mode)',
              onPressed: () {
                _persistDraft();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FocusedTrainingScreen(
                      planId: _plan.id,
                      state: widget.state,
                      initialDay: _selectedDay,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: GymBroIcon(
                icon: GymBroDashboardIconType.timer,
                size: 22,
                active: true,
                activeColor: tokens.textMuted,
              ),
              tooltip: 'تایمر استراحت بین ست',
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
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isFinishing ? null : _finishSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.lime,
                    foregroundColor: tokens.textOnLime,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.roundedMd,
                    ),
                    elevation: 2,
                  ),
                  icon: _isFinishing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: tokens.textOnLime,
                          ),
                        )
                      : const Icon(Icons.done_all_rounded, size: 22),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isFinishing
                          ? 'در حال ثبت تمرین...'
                          : 'اتمام تمرین و ذخیره در تاریخچه',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: AdaptiveContainer(
            child: ListView(
              key: const PageStorageKey('active_workout_list'),
              padding: AppSpacing.screenPadding,
              children: [
                // Day Selector Tabs
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(color: tokens.borderColor),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDayTab(1, 'برنامه ۱: پا و شکم', tokens, theme),
                        AppSpacing.wXs,
                        _buildDayTab(2, 'برنامه ۲: سینه و بازو', tokens, theme),
                        AppSpacing.wXs,
                        _buildDayTab(
                            3, 'برنامه ۳: پشت و سرشانه', tokens, theme),
                      ],
                    ),
                  ),
                ),
                AppSpacing.hSm,

                // Real-time Session Progress Header
                WorkoutSessionProgressHeader(
                  completedSets: _activeDayCompletedSets,
                  totalSets: _activeDayTotalSets,
                  totalVolumeKg: _activeDayTotalVolumeKg,
                  warmupDone: _warmupTreadmillDone && _warmupJointsDone,
                  cooldownDone:
                      _cooldownTreadmillDone && _cooldownStretchingDone,
                ),
                AppSpacing.hBase,

                _buildElapsedControls(theme, tokens),
                AppSpacing.hBase,

                // Warmup Protocol Card
                Container(
                  padding: AppSpacing.paddingBase,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: AppRadii.roundedBase,
                    border: Border.all(color: tokens.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ExcludeSemantics(
                            child: Icon(Icons.directions_run_rounded,
                                color: tokens.gold, size: 20),
                          ),
                          AppSpacing.wSm,
                          Expanded(
                            child: Text(
                              'پروتکل اختصاصی گرم کردن (پیش از شروع وزنه‌ها)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.hSm,
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: tokens.gold,
                        checkColor: tokens.textOnLime,
                        value: _warmupTreadmillDone,
                        onChanged: (val) {
                          setState(() => _warmupTreadmillDone = val ?? false);
                          _persistDraft();
                        },
                        title: Text(
                          '۱۰ دقیقه تردمیل برای افزایش ضربان قلب و دمای بدن',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: tokens.gold,
                        checkColor: tokens.textOnLime,
                        value: _warmupJointsDone,
                        onChanged: (val) {
                          setState(() => _warmupJointsDone = val ?? false);
                          _persistDraft();
                        },
                        title: Text(
                          '۵ دقیقه گرم کردن و چرخش مفاصل + گرم کردن اختصاصی عضلات',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hBase,

                // Exercise Cards
                ...List.generate(dayExercises.length, (index) {
                  final pe = dayExercises[index];
                  final ex = widget.state.exercises.firstWhere(
                    (e) => e.id == pe.exerciseId,
                    orElse: () => widget.state.exercises.first,
                  );
                  final sets = _exerciseSets[pe.id] ?? [];
                  final nextPe = index + 1 < dayExercises.length
                      ? dayExercises[index + 1]
                      : null;
                  final nextEx = nextPe != null
                      ? widget.state.exercises.firstWhere(
                          (e) => e.id == nextPe.exerciseId,
                          orElse: () => widget.state.exercises.first,
                        )
                      : null;

                  return Padding(
                    key: ValueKey('card_${pe.id}'),
                    padding: const EdgeInsets.only(bottom: AppSpacing.base),
                    child: _buildExerciseCard(
                      pe,
                      ex,
                      sets,
                      tokens,
                      theme,
                      index: index,
                      totalExercises: dayExercises.length,
                      nextExercise: nextEx,
                    ),
                  );
                }),

                // Cooldown Protocol Card
                Container(
                  padding: AppSpacing.paddingBase,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: AppRadii.roundedBase,
                    border: Border.all(color: tokens.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ExcludeSemantics(
                            child: Icon(Icons.self_improvement,
                                color: tokens.cyan, size: 20),
                          ),
                          AppSpacing.wSm,
                          Expanded(
                            child: Text(
                              'پروتکل اختصاصی سرد کردن (انتهای تمرین)',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.hSm,
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: tokens.cyan,
                        checkColor: Colors.black,
                        value: _cooldownTreadmillDone,
                        onChanged: (val) {
                          setState(() => _cooldownTreadmillDone = val ?? false);
                          _persistDraft();
                        },
                        title: Text(
                          '۱۵ دقیقه تردمیل با شیب ملایم جهت دفع اسید لاکتیک',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: tokens.cyan,
                        checkColor: Colors.black,
                        value: _cooldownStretchingDone,
                        onChanged: (val) {
                          setState(
                              () => _cooldownStretchingDone = val ?? false);
                          _persistDraft();
                        },
                        title: Text(
                          '۵ دقیقه حرکات کششی ایستا برای بازگشت طول عضله',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hLg,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayTab(
      int dayNum, String title, AppThemeExtension tokens, ThemeData theme) {
    final isSelected = _selectedDay == dayNum;
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDay = dayNum;
              _ensureExercisesInitialized();
              _persistDraft();
            });
          },
          borderRadius: AppRadii.roundedSm,
          child: Container(
            constraints:
                const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? tokens.cardElevated : Colors.transparent,
              borderRadius: AppRadii.roundedSm,
              border: Border.all(
                color: isSelected
                    ? tokens.borderColor
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : tokens.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElapsedControls(ThemeData theme, AppThemeExtension tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            _isPaused ? Icons.pause_circle_outline_rounded : Icons.timer_outlined,
            color: _isPaused ? tokens.gold : tokens.cyan,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPaused ? 'تمرین متوقف است' : 'زمان تمرین',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: _elapsedSeconds,
                  builder: (context, seconds, _) => Text(
                    _formatElapsed(seconds),
                    key: const ValueKey('workout-elapsed-time'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            key: const ValueKey('workout-pause-resume'),
            onPressed: _toggleWorkoutPause,
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            label: Text(_isPaused ? 'ادامه' : 'مکث'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    WorkoutPlanExercise pe,
    Exercise ex,
    List<ActiveWorkoutSet> sets,
    AppThemeExtension tokens,
    ThemeData theme, {
    int index = 0,
    int totalExercises = 1,
    Exercise? nextExercise,
  }) {
    final restSec = _exerciseRestSeconds[pe.id] ?? pe.restSeconds;
    final completedSets = sets.where((s) => s.isCompleted).length;
    final isAllCompleted = sets.isNotEmpty && completedSets == sets.length;
    final isCurrentActiveExercise = !isAllCompleted &&
        _dayExercises.firstWhere(
          (p) {
            final s = _exerciseSets[p.id] ?? [];
            return s.isEmpty || s.any((set) => !set.isCompleted);
          },
          orElse: () => pe,
        ).id == pe.id;

    return Container(
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isCurrentActiveExercise
              ? tokens.lime
              : (isAllCompleted
                  ? tokens.lime.withOpacity(0.4)
                  : tokens.borderColor),
          width: isCurrentActiveExercise ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAllCompleted
                              ? tokens.lime.withOpacity(0.2)
                              : tokens.cardElevated,
                          border: Border.all(
                            color: isAllCompleted
                                ? tokens.lime
                                : (isCurrentActiveExercise
                                    ? tokens.lime
                                    : tokens.borderColor.withOpacity(0.6)),
                          ),
                        ),
                        child: Center(
                          child: GymBroMuscleIllustration(
                            muscle: GymBroMuscleGroupX.fromString(ex.muscleGroup),
                            activation: isAllCompleted
                                ? GymBroMuscleActivation.primary
                                : GymBroMuscleActivation.primary,
                            size: 30,
                            isAnimated: false,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.wSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  ex.nameFa,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCurrentActiveExercise) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tokens.lime.withOpacity(0.2),
                                    borderRadius: AppRadii.roundedPill,
                                    border: Border.all(
                                      color: tokens.lime.withOpacity(0.6),
                                    ),
                                  ),
                                  child: Text(
                                    'در حال اجرا',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: tokens.lime,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '• ${ex.primaryMuscleFa}  • ${ex.equipmentFa}  • حرکت ${PersianUtils.toPersianDigits(index + 1)} از ${PersianUtils.toPersianDigits(totalExercises)}',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: tokens.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon:
                    Icon(Icons.info_outline, color: tokens.textMuted, size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => ExerciseDetailSheet(exercise: ex),
                  );
                },
                tooltip: 'اطلاعات حرکت',
              ),
            ],
          ),
          AppSpacing.hSm,

          // Action & Info Badges Row
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Rest Duration Customizer Chip
              Semantics(
                button: true,
                label:
                    'تنظیم زمان استراحت حرکت ${ex.nameFa}. زمان فعلی ${PersianUtils.toPersianDigits(restSec)} ثانیه',
                child: InkWell(
                  onTap: () => _openRestDurationSelector(pe, ex),
                  borderRadius: AppRadii.roundedSm,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 36),
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
                          activeColor: tokens.cyan,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'استراحت: ${PersianUtils.toPersianDigits(restSec)} ثانیه',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(Icons.tune, size: 14, color: tokens.textMuted),
                      ],
                    ),
                  ),
                ),
              ),

              // Exercise Completion Badge
              Container(
                constraints: const BoxConstraints(minHeight: 36),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isAllCompleted
                      ? tokens.lime.withOpacity(0.2)
                      : tokens.cardElevated,
                  borderRadius: AppRadii.roundedSm,
                  border: Border.all(
                    color: isAllCompleted ? tokens.lime : tokens.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAllCompleted) ...[
                      Icon(Icons.check, size: 14, color: tokens.lime),
                      const SizedBox(width: AppSpacing.xxs),
                    ],
                    Text(
                      isAllCompleted
                          ? 'تکمیل شد'
                          : '${PersianUtils.toPersianDigits(completedSets)}/${PersianUtils.toPersianDigits(sets.length)} ست',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isAllCompleted ? tokens.lime : tokens.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.hMd,

          // Table Header
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
                    child: Text('ثبت', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.hSm,

          // Sets Rows with isolated state, stable keys, and animated transitions
          ...List.generate(sets.length, (sIdx) {
            final s = sets[sIdx];
            final prevSet = sIdx > 0 ? sets[sIdx - 1] : null;
            return ActiveSetRow(
              key: ValueKey('set_${pe.id}_${s.setNumber}'),
              workoutSet: s,
              restSeconds: restSec,
              previousSet: prevSet,
              onToggleComplete: (done) =>
                  _handleSetToggle(pe.id, s, done, restSec),
              onDataChanged: () {
                _persistDraft();
                setState(() {});
              },
            );
          }),

          // Next Exercise Preview (Matching requirement)
          if (nextExercise != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: tokens.cardElevated.withOpacity(0.6),
                borderRadius: AppRadii.roundedSm,
                border: Border.all(
                  color: tokens.borderColor.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: tokens.cyan),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'حرکت بعدی: ${nextExercise.nameFa} (${nextExercise.equipmentFa})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tokens.cyan,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
