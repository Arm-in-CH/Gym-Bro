import '../core/storage/safe_cast.dart';

class WorkoutLog {
  final String id;
  final String planId;
  final String planTitle;
  final String date;
  final int durationMinutes;
  final double totalVolumeKg;
  final int completedSets;
  final bool isHomeWorkout;
  final int timestamp;
  final List<WorkoutSetLog> sets;

  WorkoutLog({
    required this.id,
    required this.planId,
    required this.planTitle,
    required this.date,
    required this.durationMinutes,
    required this.totalVolumeKg,
    required this.completedSets,
    this.isHomeWorkout = false,
    required this.timestamp,
    this.sets = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'planTitle': planTitle,
        'date': date,
        'durationMinutes': durationMinutes,
        'totalVolumeKg': totalVolumeKg,
        'completedSets': completedSets,
        'isHomeWorkout': isHomeWorkout,
        'timestamp': timestamp,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: SafeCast.toStringVal(json['id']),
        planId: SafeCast.toStringVal(json['planId']),
        planTitle: SafeCast.toStringVal(json['planTitle']),
        date: SafeCast.toStringVal(json['date']),
        durationMinutes: SafeCast.toInt(json['durationMinutes'], 45),
        totalVolumeKg: SafeCast.toDouble(json['totalVolumeKg'], 0.0),
        completedSets: SafeCast.toInt(json['completedSets'], 0),
        isHomeWorkout: SafeCast.toBool(json['isHomeWorkout']),
        timestamp: SafeCast.toInt(
          json['timestamp'],
          DateTime.now().millisecondsSinceEpoch,
        ),
        sets: (json['sets'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map((s) => WorkoutSetLog.fromJson(s))
                .toList() ??
            [],
      );
}

class WorkoutSetLog {
  final String id;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double weightKg;

  WorkoutSetLog({
    required this.id,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseName': exerciseName,
        'setNumber': setNumber,
        'reps': reps,
        'weightKg': weightKg,
      };

  factory WorkoutSetLog.fromJson(Map<String, dynamic> json) => WorkoutSetLog(
        id: SafeCast.toStringVal(json['id']),
        exerciseName: SafeCast.toStringVal(json['exerciseName']),
        setNumber: SafeCast.toInt(json['setNumber'], 1),
        reps: SafeCast.toInt(json['reps'], 10),
        weightKg: SafeCast.toDouble(json['weightKg'], 0.0),
      );
}
