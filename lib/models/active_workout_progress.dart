import 'workout_plan.dart';
import '../core/storage/safe_cast.dart';

class ActiveWorkoutProgress {
  final String planId;
  final int selectedDay;
  final int startTimeEpoch;
  final bool warmupTreadmillDone;
  final bool warmupJointsDone;
  final bool cooldownTreadmillDone;
  final bool cooldownStretchingDone;
  final Map<String, List<ActiveWorkoutSet>> exerciseSets;
  final Map<String, int> exerciseRestSeconds;
  final bool isPaused;
  final int pausedElapsedSeconds;

  ActiveWorkoutProgress({
    required this.planId,
    required this.selectedDay,
    required this.startTimeEpoch,
    this.warmupTreadmillDone = false,
    this.warmupJointsDone = false,
    this.cooldownTreadmillDone = false,
    this.cooldownStretchingDone = false,
    required this.exerciseSets,
    this.exerciseRestSeconds = const {},
    this.isPaused = false,
    this.pausedElapsedSeconds = 0,
  });

  Map<String, dynamic> toJson() {
    final setsMap = <String, dynamic>{};
    exerciseSets.forEach((key, list) {
      setsMap[key] = list.map((s) => s.toJson()).toList();
    });

    final restMap = <String, dynamic>{};
    exerciseRestSeconds.forEach((key, val) {
      restMap[key] = val;
    });

    return {
      'planId': planId,
      'selectedDay': selectedDay,
      'startTimeEpoch': startTimeEpoch,
      'warmupTreadmillDone': warmupTreadmillDone,
      'warmupJointsDone': warmupJointsDone,
      'cooldownTreadmillDone': cooldownTreadmillDone,
      'cooldownStretchingDone': cooldownStretchingDone,
      'exerciseSets': setsMap,
      'exerciseRestSeconds': restMap,
      'isPaused': isPaused,
      'pausedElapsedSeconds': pausedElapsedSeconds,
    };
  }

  factory ActiveWorkoutProgress.fromJson(Map<String, dynamic> json) {
    final rawSetsMap = json['exerciseSets'] is Map
        ? json['exerciseSets'] as Map
        : const {};
    final parsedSets = <String, List<ActiveWorkoutSet>>{};

    rawSetsMap.forEach((key, list) {
      if (list is List) {
        parsedSets[key.toString()] = list
            .whereType<Map<String, dynamic>>()
            .map((item) => ActiveWorkoutSet.fromJson(item))
            .toList();
      }
    });

    final rawRestMap = json['exerciseRestSeconds'] is Map
        ? json['exerciseRestSeconds'] as Map
        : const {};
    final parsedRest = <String, int>{};
    rawRestMap.forEach((key, val) {
      parsedRest[key.toString()] = SafeCast.toInt(val, 60);
    });

    return ActiveWorkoutProgress(
      planId: SafeCast.toStringVal(json['planId']),
      selectedDay: SafeCast.toInt(json['selectedDay'], 1),
      startTimeEpoch: SafeCast.toInt(
        json['startTimeEpoch'],
        DateTime.now().millisecondsSinceEpoch,
      ),
      warmupTreadmillDone: SafeCast.toBool(json['warmupTreadmillDone']),
      warmupJointsDone: SafeCast.toBool(json['warmupJointsDone']),
      cooldownTreadmillDone: SafeCast.toBool(json['cooldownTreadmillDone']),
      cooldownStretchingDone: SafeCast.toBool(json['cooldownStretchingDone']),
      exerciseSets: parsedSets,
      exerciseRestSeconds: parsedRest,
      isPaused: SafeCast.toBool(json['isPaused']),
      pausedElapsedSeconds: SafeCast.toInt(json['pausedElapsedSeconds'], 0),
    );
  }

  ActiveWorkoutProgress copyWith({
    String? planId,
    int? selectedDay,
    int? startTimeEpoch,
    bool? warmupTreadmillDone,
    bool? warmupJointsDone,
    bool? cooldownTreadmillDone,
    bool? cooldownStretchingDone,
    Map<String, List<ActiveWorkoutSet>>? exerciseSets,
    Map<String, int>? exerciseRestSeconds,
    bool? isPaused,
    int? pausedElapsedSeconds,
  }) {
    return ActiveWorkoutProgress(
      planId: planId ?? this.planId,
      selectedDay: selectedDay ?? this.selectedDay,
      startTimeEpoch: startTimeEpoch ?? this.startTimeEpoch,
      warmupTreadmillDone: warmupTreadmillDone ?? this.warmupTreadmillDone,
      warmupJointsDone: warmupJointsDone ?? this.warmupJointsDone,
      cooldownTreadmillDone:
          cooldownTreadmillDone ?? this.cooldownTreadmillDone,
      cooldownStretchingDone:
          cooldownStretchingDone ?? this.cooldownStretchingDone,
      exerciseSets: exerciseSets ?? this.exerciseSets,
      exerciseRestSeconds: exerciseRestSeconds ?? this.exerciseRestSeconds,
      isPaused: isPaused ?? this.isPaused,
      pausedElapsedSeconds: pausedElapsedSeconds ?? this.pausedElapsedSeconds,
    );
  }
}
