import '../../models/exercise.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_log.dart';
import '../../models/active_workout_progress.dart';
import '../../models/timer_settings.dart';
import '../storage/local_storage_service.dart';

abstract class IWorkoutRepository {
  Future<List<WorkoutPlan>> getWorkoutPlans();
  Future<WorkoutPlan?> getWorkoutPlanById(String id);
  Future<void> saveWorkoutPlan(WorkoutPlan plan);
  Future<void> saveWorkoutPlans(List<WorkoutPlan> plans);
  Future<void> deleteWorkoutPlan(String id);

  Future<List<Exercise>> getExercises();
  Future<Exercise?> getExerciseById(String id);
  Future<void> saveExercise(Exercise exercise);
  Future<void> deleteExercise(String id);

  Future<List<WorkoutLog>> getWorkoutLogs();
  Future<WorkoutLog?> getWorkoutLogById(String id);
  Future<void> saveWorkoutLog(WorkoutLog log);
  Future<void> deleteWorkoutLog(String id);

  Future<ActiveWorkoutProgress?> getActiveWorkoutProgress(String planId);
  Future<void> saveActiveWorkoutProgress(ActiveWorkoutProgress progress);
  Future<void> clearActiveWorkoutProgress(String planId);

  Future<TimerSettings> getTimerSettings();
  Future<void> saveTimerSettings(TimerSettings settings);
}

class LocalWorkoutRepository implements IWorkoutRepository {
  final LocalStorageService storage;

  LocalWorkoutRepository({required this.storage});

  @override
  Future<List<WorkoutPlan>> getWorkoutPlans() async {
    return storage.getWorkoutPlans();
  }

  @override
  Future<WorkoutPlan?> getWorkoutPlanById(String id) async {
    final plans = storage.getWorkoutPlans();
    try {
      return plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    await storage.saveWorkoutPlan(plan);
  }

  @override
  Future<void> saveWorkoutPlans(List<WorkoutPlan> plans) async {
    await storage.saveWorkoutPlans(plans);
  }

  @override
  Future<void> deleteWorkoutPlan(String id) async {
    await storage.deleteWorkoutPlan(id);
  }

  @override
  Future<List<Exercise>> getExercises() async {
    return storage.getExercises();
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final exercises = storage.getExercises();
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveExercise(Exercise exercise) async {
    await storage.saveExercise(exercise);
  }

  @override
  Future<void> deleteExercise(String id) async {
    await storage.deleteExercise(id);
  }

  @override
  Future<List<WorkoutLog>> getWorkoutLogs() async {
    return storage.getWorkoutLogs();
  }

  @override
  Future<WorkoutLog?> getWorkoutLogById(String id) async {
    final logs = storage.getWorkoutLogs();
    try {
      return logs.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    await storage.saveWorkoutLog(log);
  }

  @override
  Future<void> deleteWorkoutLog(String id) async {
    await storage.deleteWorkoutLog(id);
  }

  @override
  Future<ActiveWorkoutProgress?> getActiveWorkoutProgress(String planId) async {
    return storage.getActiveWorkoutProgress(planId);
  }

  @override
  Future<void> saveActiveWorkoutProgress(ActiveWorkoutProgress progress) async {
    await storage.saveActiveWorkoutProgress(progress);
  }

  @override
  Future<void> clearActiveWorkoutProgress(String planId) async {
    await storage.clearActiveWorkoutProgress(planId);
  }

  @override
  Future<TimerSettings> getTimerSettings() async {
    return storage.getTimerSettings();
  }

  @override
  Future<void> saveTimerSettings(TimerSettings settings) async {
    await storage.saveTimerSettings(settings);
  }
}
