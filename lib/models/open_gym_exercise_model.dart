import 'package:flutter/foundation.dart';

/// Represents the visual muscle engagement mapping for body map rendering.
@immutable
class ExerciseMuscleMap {
  final List<String>? primaries;
  final List<String>? secondaries;
  final String? bodyPart;
  final Map<String, double>? weights;

  const ExerciseMuscleMap({
    this.primaries,
    this.secondaries,
    this.bodyPart,
    this.weights,
  });

  factory ExerciseMuscleMap.fromJson(Map<String, Object?> json) {
    final rawPrimaries = json['primaries'] as List<Object?>?;
    final rawSecondaries = json['secondaries'] as List<Object?>?;
    final rawWeights = json['weights'] as Map<String, Object?>?;

    return ExerciseMuscleMap(
      primaries: rawPrimaries?.map((e) => e.toString()).toList(),
      secondaries: rawSecondaries?.map((e) => e.toString()).toList(),
      bodyPart: json['bodyPart'] as String?,
      weights: rawWeights?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, Object?> toJson() {
    final map = <String, Object?>{};
    if (primaries != null) map['primaries'] = primaries;
    if (secondaries != null) map['secondaries'] = secondaries;
    if (bodyPart != null) map['bodyPart'] = bodyPart;
    if (weights != null) map['weights'] = weights;
    return map;
  }

  ExerciseMuscleMap copyWith({
    List<String>? primaries,
    List<String>? secondaries,
    String? bodyPart,
    Map<String, double>? weights,
  }) {
    return ExerciseMuscleMap(
      primaries: primaries ?? this.primaries,
      secondaries: secondaries ?? this.secondaries,
      bodyPart: bodyPart ?? this.bodyPart,
      weights: weights ?? this.weights,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseMuscleMap &&
          runtimeType == other.runtimeType &&
          listEquals(primaries, other.primaries) &&
          listEquals(secondaries, other.secondaries) &&
          bodyPart == other.bodyPart &&
          mapEquals(weights, other.weights);

  @override
  int get hashCode => Object.hash(
        primaries == null ? null : Object.hashAll(primaries!),
        secondaries == null ? null : Object.hashAll(secondaries!),
        bodyPart,
        weights == null ? null : Object.hashAll(weights!.entries),
      );
}

/// Strongly-typed immutable model representing an exercise from the openGym catalogue.
/// Complies strictly with zero `dynamic` usage, type safety, and openGym catalogue schemas.
@immutable
class ExerciseModel {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String? machineKind;
  final String target;
  final List<String> secondaryMuscles;
  final String? category;
  final bool hold;
  final String? track;
  final List<String>? needs;
  final String description;
  final List<String> instructions;
  final ExerciseMuscleMap? muscleMap;
  final String? femaleVariant;
  final String? maleVariant;
  final String? variantOf;
  final String? textSource;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    this.machineKind,
    required this.target,
    this.secondaryMuscles = const <String>[],
    this.category,
    this.hold = false,
    this.track,
    this.needs,
    this.description = '',
    this.instructions = const <String>[],
    this.muscleMap,
    this.femaleVariant,
    this.maleVariant,
    this.variantOf,
    this.textSource,
  });

  /// Factory constructor to parse openGym exercise JSON with zero `dynamic`.
  factory ExerciseModel.fromJson(Map<String, Object?> json) {
    final rawSecondary = json['secondaryMuscles'] as List<Object?>?;
    final rawInstructions = json['instructions'] as List<Object?>?;
    final rawNeeds = json['needs'] as List<Object?>?;
    final rawMuscleMap = json['muscleMap'] as Map<String, Object?>?;

    return ExerciseModel(
      id: (json['id'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      bodyPart: (json['bodyPart'] as String?)?.trim() ?? '',
      equipment: (json['equipment'] as String?)?.trim() ?? '',
      machineKind: json['machineKind'] as String?,
      target: (json['target'] as String?)?.trim() ?? '',
      secondaryMuscles: rawSecondary != null
          ? rawSecondary.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList()
          : const <String>[],
      category: json['category'] as String?,
      hold: json['hold'] == true,
      track: json['track'] as String?,
      needs: rawNeeds?.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList(),
      description: (json['description'] as String?)?.trim() ?? '',
      instructions: rawInstructions != null
          ? rawInstructions.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList()
          : const <String>[],
      muscleMap: rawMuscleMap != null ? ExerciseMuscleMap.fromJson(rawMuscleMap) : null,
      femaleVariant: json['femaleVariant'] as String?,
      maleVariant: json['maleVariant'] as String?,
      variantOf: json['variantOf'] as String?,
      textSource: json['textSource'] as String?,
    );
  }

  /// Serializes the exercise into a strict JSON-compatible Map with zero `dynamic`.
  Map<String, Object?> toJson() {
    final map = <String, Object?>{
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'equipment': equipment,
      'target': target,
      'secondaryMuscles': secondaryMuscles,
      'description': description,
      'instructions': instructions,
    };

    if (machineKind != null) map['machineKind'] = machineKind;
    if (category != null) map['category'] = category;
    if (hold) map['hold'] = true;
    if (track != null) map['track'] = track;
    if (needs != null && needs!.isNotEmpty) map['needs'] = needs;
    if (muscleMap != null) map['muscleMap'] = muscleMap!.toJson();
    if (femaleVariant != null) map['femaleVariant'] = femaleVariant;
    if (maleVariant != null) map['maleVariant'] = maleVariant;
    if (variantOf != null) map['variantOf'] = variantOf;
    if (textSource != null) map['textSource'] = textSource;

    return map;
  }

  /// URL of the static WebP illustration in openGym media repository.
  String get stillImageUrl =>
      'https://raw.githubusercontent.com/DuarteSantos8/openGym/main/catalogue/media/still/$id.webp';

  /// URL of the animated 180px MP4 demonstration clip in openGym media repository.
  String get clipVideoUrl =>
      'https://raw.githubusercontent.com/DuarteSantos8/openGym/main/catalogue/media/clip/$id.mp4';

  /// Whether the exercise is tracked by time rather than repetitions (e.g. plank).
  bool get isIsometric => hold;

  /// Whether the exercise is logged by distance in meters (e.g. sled push, farmer carry).
  bool get isDistanceTracked => track == 'distance';

  /// Returns a copy of this model with updated values.
  ExerciseModel copyWith({
    String? id,
    String? name,
    String? bodyPart,
    String? equipment,
    String? machineKind,
    String? target,
    List<String>? secondaryMuscles,
    String? category,
    bool? hold,
    String? track,
    List<String>? needs,
    String? description,
    List<String>? instructions,
    ExerciseMuscleMap? muscleMap,
    String? femaleVariant,
    String? maleVariant,
    String? variantOf,
    String? textSource,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      equipment: equipment ?? this.equipment,
      machineKind: machineKind ?? this.machineKind,
      target: target ?? this.target,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      category: category ?? this.category,
      hold: hold ?? this.hold,
      track: track ?? this.track,
      needs: needs ?? this.needs,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      muscleMap: muscleMap ?? this.muscleMap,
      femaleVariant: femaleVariant ?? this.femaleVariant,
      maleVariant: maleVariant ?? this.maleVariant,
      variantOf: variantOf ?? this.variantOf,
      textSource: textSource ?? this.textSource,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          bodyPart == other.bodyPart &&
          equipment == other.equipment &&
          machineKind == other.machineKind &&
          target == other.target &&
          listEquals(secondaryMuscles, other.secondaryMuscles) &&
          category == other.category &&
          hold == other.hold &&
          track == other.track &&
          listEquals(needs, other.needs) &&
          description == other.description &&
          listEquals(instructions, other.instructions) &&
          muscleMap == other.muscleMap &&
          femaleVariant == other.femaleVariant &&
          maleVariant == other.maleVariant &&
          variantOf == other.variantOf &&
          textSource == other.textSource;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        bodyPart,
        equipment,
        machineKind,
        target,
        Object.hashAll(secondaryMuscles),
        category,
        hold,
        track,
        needs == null ? null : Object.hashAll(needs!),
        description,
        Object.hashAll(instructions),
        muscleMap,
        femaleVariant,
        maleVariant,
        variantOf,
        textSource,
      );

  @override
  String toString() => 'ExerciseModel(id: $id, name: $name, bodyPart: $bodyPart, equipment: $equipment, target: $target)';
}
