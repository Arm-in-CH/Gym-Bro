import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/error/app_exceptions.dart';
import '../core/repository/workout_repository.dart';
import '../core/repository/profile_repository.dart';
import '../core/services/workout_timer_service.dart';
import '../core/storage/id_generator.dart';
import '../models/active_workout_progress.dart';
import '../models/exercise.dart';
import '../models/timer_settings.dart';
import '../models/workout_log.dart';
import '../models/workout_plan.dart';

class WorkoutState extends ChangeNotifier {
  final IWorkoutRepository repository;
  final IProfileRepository? profileRepository;
  final Future<void> Function(int streakDays, int totalCompleted)? onWorkoutCompleted;

  List<Exercise> exercises = [];
  List<WorkoutPlan> workoutPlans = [];
  List<WorkoutLog> workoutLogs = [];
  TimerSettings timerSettings = const TimerSettings();

  bool isConvertingHome = false;
  bool _isCompletingWorkoutSession = false;
  bool get isCompletingWorkoutSession => _isCompletingWorkoutSession;
  String? _lastCompletedSessionKey;
  DateTime? _lastCompletedSessionTime;

  WorkoutState({
    required this.repository,
    this.profileRepository,
    this.onWorkoutCompleted,
    List<Exercise>? initialExercises,
    List<WorkoutPlan>? initialWorkoutPlans,
    List<WorkoutLog>? initialWorkoutLogs,
    TimerSettings? initialTimerSettings,
  }) {
    if (initialExercises != null) exercises = initialExercises;
    if (initialWorkoutPlans != null) workoutPlans = initialWorkoutPlans;
    if (initialWorkoutLogs != null) workoutLogs = initialWorkoutLogs;
    if (initialTimerSettings != null) timerSettings = initialTimerSettings;
  }

  String get todayDateString => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadFromRepository() async {
    exercises = await repository.getExercises();
    workoutPlans = await repository.getWorkoutPlans();
    workoutLogs = await repository.getWorkoutLogs();
    timerSettings = await repository.getTimerSettings();
    notifyListeners();
  }

  // --- HOME WORKOUT CONVERSION ---

  Future<WorkoutPlan> convertGymPlanToHomePlan(String gymPlanId) async {
    if (isConvertingHome) {
      throw StateError('عملیات تبدیل در حال حاضر در حال اجرا است.');
    }

    final original = workoutPlans
            .where((p) => p.id == gymPlanId && !p.isHomeWorkout)
            .firstOrNull ??
        workoutPlans.where((p) => p.id == gymPlanId).firstOrNull;

    if (original == null) {
      throw ArgumentError('برنامه تمرینی باشگاهی با شناسه «$gymPlanId» یافت نشد.');
    }

    isConvertingHome = true;
    notifyListeners();

    try {
      final homePlanId = 'home_conv_${DateTime.now().millisecondsSinceEpoch}';
      final convertedExercises = <WorkoutPlanExercise>[];

      for (var item in original.exercises) {
        final gymEx = exercises.where((e) => e.id == item.exerciseId).firstOrNull ??
            exercises.firstOrNull;

        final homeEquivId = gymEx?.homeEquivalentId ?? 'ex_pushups';
        final adaptedReps = (item.targetReps * 1.5).round().clamp(12, 35);
        const adaptedRest = 45;

        convertedExercises.add(
          WorkoutPlanExercise(
            id: 'he_${DateTime.now().microsecondsSinceEpoch}',
            planId: homePlanId,
            exerciseId: homeEquivId,
            dayOfWeek: item.dayOfWeek,
            dayNameFa: item.dayNameFa.replaceAll('باشگاهی', 'خانگی بدون وسیله'),
            orderInDay: item.orderInDay,
            targetSets: item.targetSets,
            targetReps: adaptedReps,
            targetWeightKg: 0.0,
            restSeconds: adaptedRest,
          ),
        );
      }

      final newHomePlan = WorkoutPlan(
        id: homePlanId,
        titleFa: 'ورزش در خانه تطبیقی: ${original.titleFa}',
        titleEn: 'Adaptive Home: ${original.titleEn}',
        descriptionFa:
            'تبدیل هوشمند حرکات باشگاهی به تمرینات وزن بدن بدون نیاز به دمبل و دستگاه.',
        splitType: 'Full Body Bodyweight',
        isHomeWorkout: true,
        daysPerWeek: original.daysPerWeek,
        difficulty: original.difficulty,
        exercises: convertedExercises,
      );

      workoutPlans.insert(0, newHomePlan);
      await repository.saveWorkoutPlans(workoutPlans);

      return newHomePlan;
    } finally {
      isConvertingHome = false;
      notifyListeners();
    }
  }

  // --- WORKOUT PLANS CRUD ---

  Future<void> createWorkoutPlan({
    required String titleFa,
    String titleEn = '',
    required String descriptionFa,
    String splitType = 'Custom Split',
    bool isHomeWorkout = false,
    int daysPerWeek = 3,
    String difficulty = 'متوسط',
    List<WorkoutPlanExercise> exercises = const [],
  }) async {
    final newPlan = WorkoutPlan(
      id: IdGenerator.plan(),
      titleFa: titleFa.trim(),
      titleEn: titleEn.trim().isNotEmpty ? titleEn.trim() : 'Custom Plan',
      descriptionFa: descriptionFa.trim(),
      splitType: splitType,
      isHomeWorkout: isHomeWorkout,
      daysPerWeek: daysPerWeek,
      difficulty: difficulty,
      exercises: exercises,
    );

    await repository.saveWorkoutPlan(newPlan);
    workoutPlans = await repository.getWorkoutPlans();
    notifyListeners();
  }

  Future<void> updateWorkoutPlan(WorkoutPlan plan) async {
    await repository.saveWorkoutPlan(plan);
    workoutPlans = await repository.getWorkoutPlans();
    notifyListeners();
  }

  Future<void> deleteWorkoutPlan(String planId) async {
    await repository.deleteWorkoutPlan(planId);
    workoutPlans = await repository.getWorkoutPlans();
    notifyListeners();
  }

  Future<void> addExerciseToPlan({
    required String planId,
    required String exerciseId,
    required int dayOfWeek,
    required String dayNameFa,
    required int targetSets,
    required int targetReps,
    required double targetWeightKg,
    int restSeconds = 60,
  }) async {
    final index = workoutPlans.indexWhere((p) => p.id == planId);
    if (index < 0) return;

    final plan = workoutPlans[index];
    final currentDayExercises =
        plan.exercises.where((e) => e.dayOfWeek == dayOfWeek).toList();
    final nextOrder = currentDayExercises.isEmpty
        ? 1
        : currentDayExercises
                .map((e) => e.orderInDay)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final newExercise = WorkoutPlanExercise(
      id: IdGenerator.planExercise(),
      planId: planId,
      exerciseId: exerciseId,
      dayOfWeek: dayOfWeek,
      dayNameFa: dayNameFa,
      orderInDay: nextOrder,
      targetSets: targetSets,
      targetReps: targetReps,
      targetWeightKg: targetWeightKg,
      restSeconds: restSeconds,
    );

    final updatedExercises = List<WorkoutPlanExercise>.from(plan.exercises)
      ..add(newExercise);
    final updatedPlan = plan.copyWith(exercises: updatedExercises);

    await updateWorkoutPlan(updatedPlan);
  }

  Future<void> removeExerciseFromPlan({
    required String planId,
    required String planExerciseId,
  }) async {
    final index = workoutPlans.indexWhere((p) => p.id == planId);
    if (index < 0) return;

    final plan = workoutPlans[index];
    final updatedExercises =
        plan.exercises.where((e) => e.id != planExerciseId).toList();
    final updatedPlan = plan.copyWith(exercises: updatedExercises);

    await updateWorkoutPlan(updatedPlan);
  }

  Future<void> reorderPlanExercises({
    required String planId,
    required int dayOfWeek,
    required int oldIndex,
    required int newIndex,
  }) async {
    final planIndex = workoutPlans.indexWhere((p) => p.id == planId);
    if (planIndex < 0) return;

    final plan = workoutPlans[planIndex];
    final dayList = plan.exercises
        .where((e) => e.dayOfWeek == dayOfWeek)
        .toList()
      ..sort((a, b) => a.orderInDay.compareTo(b.orderInDay));

    if (oldIndex < 0 || oldIndex >= dayList.length) return;
    if (newIndex < 0 || newIndex > dayList.length) return;

    final moved = dayList.removeAt(oldIndex);
    final insertIdx = newIndex > oldIndex ? newIndex - 1 : newIndex;
    dayList.insert(insertIdx, moved);

    final updatedDayExercises = <WorkoutPlanExercise>[];
    for (int i = 0; i < dayList.length; i++) {
      updatedDayExercises.add(dayList[i].copyWith(orderInDay: i + 1));
    }

    final otherDayExercises =
        plan.exercises.where((e) => e.dayOfWeek != dayOfWeek).toList();
    final finalExercises = [...otherDayExercises, ...updatedDayExercises];

    final updatedPlan = plan.copyWith(exercises: finalExercises);
    await updateWorkoutPlan(updatedPlan);
  }

  // --- EXERCISE BANK CRUD ---

  Future<void> saveExercise(Exercise exercise) async {
    await repository.saveExercise(exercise);
    exercises = await repository.getExercises();
    notifyListeners();
  }

  Future<void> deleteExercise(String id) async {
    await repository.deleteExercise(id);
    exercises = await repository.getExercises();
    notifyListeners();
  }

  // --- WORKOUT HISTORY CRUD ---

  Future<void> deleteWorkoutHistoryLog(String id) async {
    await repository.deleteWorkoutLog(id);
    workoutLogs = await repository.getWorkoutLogs();
    notifyListeners();
  }

  // --- ACTIVE WORKOUT DRAFT PERSISTENCE ---

  Future<ActiveWorkoutProgress?> getActiveWorkoutDraft(String planId) async {
    return repository.getActiveWorkoutProgress(planId);
  }

  Future<void> saveActiveWorkoutDraft(ActiveWorkoutProgress progress) async {
    await repository.saveActiveWorkoutProgress(progress);
  }

  Future<void> updateWorkoutPlanExerciseRest({
    required String planId,
    required String exercisePlanId,
    required int restSeconds,
  }) async {
    final planIndex = workoutPlans.indexWhere((p) => p.id == planId);
    if (planIndex != -1) {
      final plan = workoutPlans[planIndex];
      final updatedExercises = plan.exercises.map((pe) {
        if (pe.id == exercisePlanId) {
          return pe.copyWith(restSeconds: restSeconds);
        }
        return pe;
      }).toList();
      final updatedPlan = plan.copyWith(exercises: updatedExercises);
      workoutPlans[planIndex] = updatedPlan;
      await repository.saveWorkoutPlan(updatedPlan);
      notifyListeners();
    }
  }

  Future<void> clearActiveWorkoutDraft(String planId) async {
    await repository.clearActiveWorkoutProgress(planId);
  }

  Future<void> updateTimerSettings(TimerSettings settings) async {
    timerSettings = settings;
    await repository.saveTimerSettings(settings);
    notifyListeners();
  }

  // --- WORKOUT LIFECYCLE MANAGEMENT ---

  /// 1. Start Workout Session
  Future<ActiveWorkoutProgress> startWorkoutSession({
    required String planId,
    int selectedDay = 1,
  }) async {
    if (planId.trim().isEmpty) {
      throw ValidationException.missingPlan('شناسه برنامه تمرینی الزامی است.');
    }
    final plan = workoutPlans.where((p) => p.id == planId).firstOrNull;
    if (plan == null) {
      throw ValidationException.missingPlan(
        'برنامه تمرینی با شناسه $planId یافت نشد.',
      );
    }

    final existingDraft = await getActiveWorkoutDraft(planId);
    if (existingDraft != null) {
      return existingDraft;
    }

    final exerciseSets = <String, List<ActiveWorkoutSet>>{};
    final exerciseRestSeconds = <String, int>{};

    final dayExercises =
        plan.exercises.where((e) => e.dayOfWeek == selectedDay).toList();
    final targetExercises =
        dayExercises.isNotEmpty ? dayExercises : plan.exercises;

    for (final pe in targetExercises) {
      exerciseSets[pe.id] = List.generate(
        pe.targetSets > 0 ? pe.targetSets : 3,
        (idx) => ActiveWorkoutSet(
          setNumber: idx + 1,
          targetReps: pe.targetReps > 0 ? pe.targetReps : 10,
          targetWeightKg: pe.targetWeightKg >= 0 ? pe.targetWeightKg : 0.0,
          actualReps: pe.targetReps > 0 ? pe.targetReps : 10,
          actualWeightKg: pe.targetWeightKg >= 0 ? pe.targetWeightKg : 0.0,
          isCompleted: false,
        ),
      );
      exerciseRestSeconds[pe.id] = pe.restSeconds > 0 ? pe.restSeconds : 60;
    }

    final progress = ActiveWorkoutProgress(
      planId: plan.id,
      selectedDay: selectedDay,
      startTimeEpoch: DateTime.now().millisecondsSinceEpoch,
      exerciseSets: exerciseSets,
      exerciseRestSeconds: exerciseRestSeconds,
    );

    await saveActiveWorkoutDraft(progress);
    notifyListeners();
    return progress;
  }

  /// 2. Add Exercise to Active Workout Session
  Future<ActiveWorkoutProgress> addExerciseToActiveWorkout({
    required String planId,
    required WorkoutPlanExercise exercise,
  }) async {
    final draft = await getActiveWorkoutDraft(planId);
    if (draft == null) {
      throw const StateTransitionException(
        'جلسه تمرین فعالی برای افزودن حرکت وجود ندارد.',
      );
    }

    final updatedSets =
        Map<String, List<ActiveWorkoutSet>>.from(draft.exerciseSets);
    final updatedRest = Map<String, int>.from(draft.exerciseRestSeconds);

    if (!updatedSets.containsKey(exercise.id)) {
      updatedSets[exercise.id] = List.generate(
        exercise.targetSets > 0 ? exercise.targetSets : 3,
        (idx) => ActiveWorkoutSet(
          setNumber: idx + 1,
          targetReps: exercise.targetReps > 0 ? exercise.targetReps : 10,
          targetWeightKg:
              exercise.targetWeightKg >= 0 ? exercise.targetWeightKg : 0.0,
          actualReps: exercise.targetReps > 0 ? exercise.targetReps : 10,
          actualWeightKg:
              exercise.targetWeightKg >= 0 ? exercise.targetWeightKg : 0.0,
          isCompleted: false,
        ),
      );
      updatedRest[exercise.id] =
          exercise.restSeconds > 0 ? exercise.restSeconds : 60;
    }

    final updatedDraft = draft.copyWith(
      exerciseSets: updatedSets,
      exerciseRestSeconds: updatedRest,
    );

    await saveActiveWorkoutDraft(updatedDraft);
    notifyListeners();
    return updatedDraft;
  }

  /// 3. Add Set to Active Exercise
  Future<ActiveWorkoutProgress> addSetToActiveExercise({
    required String planId,
    required String planExerciseId,
    int? targetReps,
    double? targetWeightKg,
  }) async {
    final draft = await getActiveWorkoutDraft(planId);
    if (draft == null) {
      throw const StateTransitionException('جلسه تمرین فعال یافت نشد.');
    }

    final updatedSets =
        Map<String, List<ActiveWorkoutSet>>.from(draft.exerciseSets);
    final currentSets =
        List<ActiveWorkoutSet>.from(updatedSets[planExerciseId] ?? []);

    final lastSet = currentSets.isNotEmpty ? currentSets.last : null;
    final reps = targetReps ?? lastSet?.targetReps ?? 10;
    final weight = targetWeightKg ?? lastSet?.targetWeightKg ?? 0.0;

    if (reps <= 0) {
      throw ValidationException.invalidSets(
        'تعداد تکرار هدف باید بیشتر از صفر باشد.',
      );
    }
    if (weight < 0) {
      throw ValidationException.invalidSets('وزنه هدف نمی‌تواند منفی باشد.');
    }

    currentSets.add(
      ActiveWorkoutSet(
        setNumber: currentSets.length + 1,
        targetReps: reps,
        targetWeightKg: weight,
        actualReps: reps,
        actualWeightKg: weight,
        isCompleted: false,
      ),
    );

    updatedSets[planExerciseId] = currentSets;
    final updatedDraft = draft.copyWith(exerciseSets: updatedSets);

    await saveActiveWorkoutDraft(updatedDraft);
    notifyListeners();
    return updatedDraft;
  }

  /// 4. Edit Active Set
  Future<ActiveWorkoutProgress> editActiveSet({
    required String planId,
    required String planExerciseId,
    required int setNumber,
    int? actualReps,
    double? actualWeightKg,
    bool? isCompleted,
  }) async {
    final draft = await getActiveWorkoutDraft(planId);
    if (draft == null) {
      throw const StateTransitionException('جلسه تمرین فعال یافت نشد.');
    }

    final updatedSets =
        Map<String, List<ActiveWorkoutSet>>.from(draft.exerciseSets);
    final currentSets =
        List<ActiveWorkoutSet>.from(updatedSets[planExerciseId] ?? []);

    final idx = currentSets.indexWhere((s) => s.setNumber == setNumber);
    if (idx < 0) {
      throw ValidationException.invalidSets(
        'ست شماره $setNumber برای این حرکت یافت نشد.',
      );
    }

    if (actualReps != null && actualReps < 0) {
      throw ValidationException.invalidSets('تعداد تکرار نمی‌تواند منفی باشد.');
    }
    if (actualWeightKg != null && actualWeightKg < 0) {
      throw ValidationException.invalidSets('وزنه ست نمی‌تواند منفی باشد.');
    }

    final old = currentSets[idx];
    currentSets[idx] = old.copyWith(
      actualReps: actualReps ?? old.actualReps,
      actualWeightKg: actualWeightKg ?? old.actualWeightKg,
      isCompleted: isCompleted ?? old.isCompleted,
    );

    updatedSets[planExerciseId] = currentSets;
    final updatedDraft = draft.copyWith(exerciseSets: updatedSets);

    await saveActiveWorkoutDraft(updatedDraft);
    notifyListeners();
    return updatedDraft;
  }

  /// 5. Delete Set from Active Exercise
  Future<ActiveWorkoutProgress> deleteSetFromActiveExercise({
    required String planId,
    required String planExerciseId,
    required int setNumber,
  }) async {
    final draft = await getActiveWorkoutDraft(planId);
    if (draft == null) {
      throw const StateTransitionException('جلسه تمرین فعال یافت نشد.');
    }

    final updatedSets =
        Map<String, List<ActiveWorkoutSet>>.from(draft.exerciseSets);
    final currentSets =
        List<ActiveWorkoutSet>.from(updatedSets[planExerciseId] ?? []);

    final idx = currentSets.indexWhere((s) => s.setNumber == setNumber);
    if (idx < 0) {
      throw ValidationException.invalidSets(
        'ست شماره $setNumber برای حذف یافت نشد.',
      );
    }

    currentSets.removeAt(idx);

    for (int i = 0; i < currentSets.length; i++) {
      currentSets[i] = currentSets[i].copyWith(setNumber: i + 1);
    }

    updatedSets[planExerciseId] = currentSets;
    final updatedDraft = draft.copyWith(exerciseSets: updatedSets);

    await saveActiveWorkoutDraft(updatedDraft);
    notifyListeners();
    return updatedDraft;
  }

  /// 6. Start Rest Timer
  Future<void> startRestTimer({int? seconds, String? exerciseName}) async {
    final duration = seconds ?? timerSettings.defaultRestSeconds;
    if (duration <= 0) {
      throw const ValidationException(
        'مدت زمان استراحت باید بیشتر از صفر باشد.',
        code: 'INVALID_DURATION',
      );
    }
    await WorkoutTimerService().start(
      duration,
      exerciseName: exerciseName ?? 'استراحت',
    );
  }

  /// 7. Pause Workout Session
  Future<ActiveWorkoutProgress> pauseWorkoutSession(String planId) async {
    final draft = await getActiveWorkoutDraft(planId);
    if (draft == null) {
      throw const StateTransitionException('جلسه تمرین فعال یافت نشد.');
    }
    if (draft.isPaused) {
      throw const StateTransitionException(
        'جلسه تمرین در حال حاضر در وضعیت مکث قرار دارد.',
      );
    }

    final elapsed = ((DateTime.now().millisecondsSinceEpoch -
                draft.startTimeEpoch) ~/
            1000)
        .clamp(0, 86400);

    final updated = draft.copyWith(
      isPaused: true,
      pausedElapsedSeconds: elapsed,
    );

    await saveActiveWorkoutDraft(updated);
    notifyListeners();
    return updated;
  }

  /// 8. Resume Workout Session
  Future<ActiveWorkoutProgress> resumeWorkoutSession(String planId) async {
    final draft = await getActiveWorkoutDraft(planId);
    if (draft == null) {
      throw const StateTransitionException('جلسه تمرین فعال یافت نشد.');
    }
    if (!draft.isPaused) {
      throw const StateTransitionException(
        'جلسه تمرین در حال حاضر فعال است و متوقف نیست.',
      );
    }

    final newStartTime = DateTime.now()
        .subtract(Duration(seconds: draft.pausedElapsedSeconds))
        .millisecondsSinceEpoch;

    final updated = draft.copyWith(
      isPaused: false,
      startTimeEpoch: newStartTime,
      pausedElapsedSeconds: 0,
    );

    await saveActiveWorkoutDraft(updated);
    notifyListeners();
    return updated;
  }

  /// 9. Cancel Workout Session
  Future<void> cancelWorkoutSession(String planId) async {
    await clearActiveWorkoutDraft(planId);
    await WorkoutTimerService().cancel();
    notifyListeners();
  }

  /// 10. Complete Workout Session
  Future<WorkoutLog> completeWorkoutSession({
    required WorkoutPlan plan,
    required double totalVolumeKg,
    required int completedSets,
    required List<WorkoutSetLog> setLogs,
    required int durationMinutes,
  }) async {
    // 1. Validation: Plan
    if (plan.id.trim().isEmpty) {
      throw ValidationException.missingPlan(
        'برنامه تمرینی نامعتبر است (شناسه برنامه یافت نشد).',
      );
    }

    // 2. Validation: Completed Sets & Set Count
    if (completedSets <= 0 || setLogs.isEmpty) {
      throw ValidationException.emptyWorkout(
        'امکان ثبت جلسه تمرین بدون ست تکمیل‌شده وجود ندارد.',
      );
    }
    if (completedSets != setLogs.length) {
      throw ValidationException.invalidSets(
        'تعداد ست‌های تکمیل‌شده با تعداد لاگ‌های ثبت‌شده همخوانی ندارد ($completedSets در برابر ${setLogs.length}).',
      );
    }

    // 3. Validation: Set values
    for (final set in setLogs) {
      if (set.reps <= 0) {
        throw ValidationException.invalidSets(
          'تعداد تکرار در تمامی ست‌های تکمیل‌شده باید حداقل ۱ باشد.',
        );
      }
      if (set.weightKg < 0) {
        throw ValidationException.invalidSets(
          'وزنه ست‌ها نمی‌تواند عدد منفی باشد.',
        );
      }
      if (set.exerciseName.trim().isEmpty) {
        throw ValidationException.invalidSets(
          'نام حرکت برای تمامی ست‌های ثبت‌شده الزامی است.',
        );
      }
      if (set.setNumber <= 0) {
        throw ValidationException.invalidSets(
          'شماره ست باید یک عدد مثبت باشد.',
        );
      }
    }

    // 4. Duplicate Completion Prevention
    if (_isCompletingWorkoutSession) {
      throw StateTransitionException.alreadyCompleting();
    }

    final actualVolumeKg = setLogs.fold<double>(
      0.0,
      (volume, set) => volume + (set.weightKg * set.reps),
    );

    if ((totalVolumeKg - actualVolumeKg).abs() > 0.5) {
      throw ValidationException.invalidSets(
        'مجموع تناژ اعلام‌شده با مجموع ست‌های ثبت‌شده مغایرت دارد.',
      );
    }

    final sessionKey =
        '${plan.id}_${todayDateString}_${completedSets}_${actualVolumeKg.toStringAsFixed(1)}';
    final now = DateTime.now();
    if (_lastCompletedSessionKey == sessionKey &&
        _lastCompletedSessionTime != null &&
        now.difference(_lastCompletedSessionTime!).inSeconds < 5) {
      throw StateTransitionException.alreadyCompleted();
    }

    _isCompletingWorkoutSession = true;
    notifyListeners();

    try {
      final safeDuration = durationMinutes > 0 ? durationMinutes : 1;

      final log = WorkoutLog(
        id: IdGenerator.workoutLog(),
        planId: plan.id,
        planTitle: plan.titleFa,
        date: todayDateString,
        durationMinutes: safeDuration,
        totalVolumeKg: actualVolumeKg,
        completedSets: completedSets,
        isHomeWorkout: plan.isHomeWorkout,
        timestamp: now.millisecondsSinceEpoch,
        sets: setLogs,
      );

      try {
        await repository.saveWorkoutLog(log);
        workoutLogs = await repository.getWorkoutLogs();
      } catch (e) {
        throw StorageException(
          'خطا در ذخیره‌سازی جلسه تمرین در دیتابیس: $e',
          details: e,
        );
      }

      try {
        await clearActiveWorkoutDraft(plan.id);
      } catch (_) {
        // Non-critical cleanup
      }

      final streak = calculateWorkoutStreak();
      if (profileRepository != null) {
        try {
          final profile = await profileRepository!.getProfile();
          final updated = profile.copyWith(
            streakDays: streak,
            totalWorkoutsCompleted: profile.totalWorkoutsCompleted + 1,
          );
          await profileRepository!.saveProfile(updated);
        } catch (e) {
          throw StorageException(
            'خطا در به‌روزرسانی پروفایل کاربر: $e',
            details: e,
          );
        }
      }

      if (onWorkoutCompleted != null) {
        await onWorkoutCompleted!(streak, (profileRepository != null) ? 1 : 0);
      }

      _lastCompletedSessionKey = sessionKey;
      _lastCompletedSessionTime = now;

      notifyListeners();
      return log;
    } finally {
      _isCompletingWorkoutSession = false;
      notifyListeners();
    }
  }

  int calculateWorkoutStreak() {
    final workoutDates = workoutLogs.map((log) => log.date).toSet();
    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    if (!workoutDates.contains(DateFormat('yyyy-MM-dd').format(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (workoutDates.contains(DateFormat('yyyy-MM-dd').format(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
