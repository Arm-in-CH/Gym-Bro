import '../core/storage/safe_cast.dart';

class WorkoutPlan {
  final String id;
  final String titleFa;
  final String titleEn;
  final String descriptionFa;
  final String splitType;
  final bool isHomeWorkout;
  final int daysPerWeek;
  final String difficulty;
  final List<WorkoutPlanExercise> exercises;

  WorkoutPlan({
    required this.id,
    required this.titleFa,
    required this.titleEn,
    required this.descriptionFa,
    required this.splitType,
    this.isHomeWorkout = false,
    this.daysPerWeek = 3,
    this.difficulty = 'متوسط',
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleFa': titleFa,
        'titleEn': titleEn,
        'descriptionFa': descriptionFa,
        'splitType': splitType,
        'isHomeWorkout': isHomeWorkout,
        'daysPerWeek': daysPerWeek,
        'difficulty': difficulty,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
        id: SafeCast.toStringVal(json['id']),
        titleFa: SafeCast.toStringVal(json['titleFa']),
        titleEn: SafeCast.toStringVal(json['titleEn']),
        descriptionFa: SafeCast.toStringVal(json['descriptionFa']),
        splitType: SafeCast.toStringVal(json['splitType']),
        isHomeWorkout: SafeCast.toBool(json['isHomeWorkout']),
        daysPerWeek: SafeCast.toInt(json['daysPerWeek'], 3),
        difficulty: SafeCast.toStringVal(json['difficulty'], 'متوسط'),
        exercises: (json['exercises'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map((e) => WorkoutPlanExercise.fromJson(e))
                .toList() ??
            [],
      );

  WorkoutPlan copyWith({
    String? id,
    String? titleFa,
    String? titleEn,
    String? descriptionFa,
    String? splitType,
    bool? isHomeWorkout,
    int? daysPerWeek,
    String? difficulty,
    List<WorkoutPlanExercise>? exercises,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      titleFa: titleFa ?? this.titleFa,
      titleEn: titleEn ?? this.titleEn,
      descriptionFa: descriptionFa ?? this.descriptionFa,
      splitType: splitType ?? this.splitType,
      isHomeWorkout: isHomeWorkout ?? this.isHomeWorkout,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      difficulty: difficulty ?? this.difficulty,
      exercises: exercises ?? this.exercises,
    );
  }
}

class WorkoutPlanExercise {
  final String id;
  final String planId;
  final String exerciseId;
  final int dayOfWeek;
  final String dayNameFa;
  final int orderInDay;
  final int targetSets;
  final int targetReps;
  final double targetWeightKg;
  final int restSeconds;

  WorkoutPlanExercise({
    required this.id,
    required this.planId,
    required this.exerciseId,
    required this.dayOfWeek,
    required this.dayNameFa,
    required this.orderInDay,
    required this.targetSets,
    required this.targetReps,
    required this.targetWeightKg,
    this.restSeconds = 60,
  });

  WorkoutPlanExercise copyWith({
    String? id,
    String? planId,
    String? exerciseId,
    int? dayOfWeek,
    String? dayNameFa,
    int? orderInDay,
    int? targetSets,
    int? targetReps,
    double? targetWeightKg,
    int? restSeconds,
  }) {
    return WorkoutPlanExercise(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      exerciseId: exerciseId ?? this.exerciseId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayNameFa: dayNameFa ?? this.dayNameFa,
      orderInDay: orderInDay ?? this.orderInDay,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'exerciseId': exerciseId,
        'dayOfWeek': dayOfWeek,
        'dayNameFa': dayNameFa,
        'orderInDay': orderInDay,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'targetWeightKg': targetWeightKg,
        'restSeconds': restSeconds,
      };

  factory WorkoutPlanExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutPlanExercise(
        id: SafeCast.toStringVal(json['id']),
        planId: SafeCast.toStringVal(json['planId']),
        exerciseId: SafeCast.toStringVal(json['exerciseId']),
        dayOfWeek: SafeCast.toInt(json['dayOfWeek'], 1),
        dayNameFa: SafeCast.toStringVal(json['dayNameFa']),
        orderInDay: SafeCast.toInt(json['orderInDay'], 1),
        targetSets: SafeCast.toInt(json['targetSets'], 3),
        targetReps: SafeCast.toInt(json['targetReps'], 10),
        targetWeightKg: SafeCast.toDouble(json['targetWeightKg'], 0.0),
        restSeconds: SafeCast.toInt(json['restSeconds'], 60),
      );
}

class ActiveWorkoutSet {
  final int setNumber;
  final int targetReps;
  final double targetWeightKg;
  int actualReps;
  double actualWeightKg;
  bool isCompleted;

  ActiveWorkoutSet({
    required this.setNumber,
    required this.targetReps,
    required this.targetWeightKg,
    required this.actualReps,
    required this.actualWeightKg,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'targetReps': targetReps,
        'targetWeightKg': targetWeightKg,
        'actualReps': actualReps,
        'actualWeightKg': actualWeightKg,
        'isCompleted': isCompleted,
      };

  factory ActiveWorkoutSet.fromJson(Map<String, dynamic> json) =>
      ActiveWorkoutSet(
        setNumber: SafeCast.toInt(json['setNumber'], 1),
        targetReps: SafeCast.toInt(json['targetReps'], 10),
        targetWeightKg: SafeCast.toDouble(json['targetWeightKg'], 0.0),
        actualReps: SafeCast.toInt(json['actualReps'], 10),
        actualWeightKg: SafeCast.toDouble(json['actualWeightKg'], 0.0),
        isCompleted: SafeCast.toBool(json['isCompleted']),
      );

  ActiveWorkoutSet copyWith({
    int? setNumber,
    int? targetReps,
    double? targetWeightKg,
    int? actualReps,
    double? actualWeightKg,
    bool? isCompleted,
  }) {
    return ActiveWorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      actualReps: actualReps ?? this.actualReps,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
