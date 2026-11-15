import '../core/storage/safe_cast.dart';

class Exercise {
  final String id;
  final String nameEn;
  final String nameFa;
  final String muscleGroup;
  final String muscleGroupFa;
  final String equipment;
  final String equipmentFa;
  final String instructionsFa;
  final String? videoUrl;
  final bool isBodyweight;
  final String? homeEquivalentId;
  final List<String>? secondaryMuscles;
  final String? targetMuscle;
  final String? gifUrl;

  Exercise({
    required this.id,
    required this.nameEn,
    required this.nameFa,
    required this.muscleGroup,
    required this.muscleGroupFa,
    required this.equipment,
    required this.equipmentFa,
    required this.instructionsFa,
    this.videoUrl,
    this.isBodyweight = false,
    this.homeEquivalentId,
    this.secondaryMuscles,
    this.targetMuscle,
    this.gifUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameEn': nameEn,
        'nameFa': nameFa,
        'muscleGroup': muscleGroup,
        'muscleGroupFa': muscleGroupFa,
        'equipment': equipment,
        'equipmentFa': equipmentFa,
        'instructionsFa': instructionsFa,
        'videoUrl': videoUrl,
        'isBodyweight': isBodyweight,
        'homeEquivalentId': homeEquivalentId,
        'secondaryMuscles': secondaryMuscles,
        'targetMuscle': targetMuscle,
        'gifUrl': gifUrl,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: SafeCast.toStringVal(json['id']),
        nameEn: SafeCast.toStringVal(json['nameEn']),
        nameFa: SafeCast.toStringVal(json['nameFa']),
        muscleGroup: SafeCast.toStringVal(json['muscleGroup']),
        muscleGroupFa: SafeCast.toStringVal(json['muscleGroupFa']),
        equipment: SafeCast.toStringVal(json['equipment']),
        equipmentFa: SafeCast.toStringVal(json['equipmentFa']),
        instructionsFa: SafeCast.toStringVal(json['instructionsFa']),
        videoUrl: SafeCast.toStringOrNull(json['videoUrl']),
        isBodyweight: SafeCast.toBool(json['isBodyweight']),
        homeEquivalentId: SafeCast.toStringOrNull(json['homeEquivalentId']),
        secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
            ?.map((e) => SafeCast.toStringVal(e))
            .toList(),
        targetMuscle: SafeCast.toStringOrNull(json['targetMuscle']),
        gifUrl: SafeCast.toStringOrNull(json['gifUrl']),
      );

  /// Intelligent anatomical primary target muscle with specific sub-muscle labeling
  String get primaryMuscleFa {
    if (targetMuscle != null && targetMuscle!.trim().isNotEmpty) {
      return targetMuscle!;
    }
    return muscleGroupFa;
  }

  /// Intelligent anatomical secondary / assisting muscles based on biomechanics
  List<String> get resolvedSecondaryMusclesFa {
    if (secondaryMuscles != null && secondaryMuscles!.isNotEmpty) {
      return secondaryMuscles!;
    }
    final mg = muscleGroup.toLowerCase();
    final name = (nameEn + nameFa).toLowerCase();

    if (mg.contains('chest') || name.contains('سینه')) {
      return const ['پشت‌بازو (Triceps)', 'سرشانه قدامی (Anterior Deltoid)'];
    }
    if (mg.contains('back') || name.contains('پشت') || name.contains('زیربغل')) {
      return const ['جلوبازو (Biceps)', 'کول و ذوزنقه‌ای (Traps)', 'فیله کمر'];
    }
    if (mg.contains('shoulder') || name.contains('سرشانه')) {
      return const ['پشت‌بازو (Triceps)', 'بخش بالایی کول (Upper Traps)'];
    }
    if (mg.contains('arm') || name.contains('بازو')) {
      if (name.contains('tricep') || name.contains('پشت‌بازو') || name.contains('پشت بازو')) {
        return const ['سرشانه قدامی', 'ساعد'];
      }
      return const ['ساعد و مچ دست (Brachioradialis)', 'براکیالیس'];
    }
    if (mg.contains('leg') || name.contains('پا') || name.contains('ران')) {
      if (name.contains('rdl') || name.contains('curl') || name.contains('پشت پا') || name.contains('همسترینگ')) {
        return const ['سرینی و باسن (Glutes)', 'فیله کمر (Lower Back)'];
      }
      return const ['سرینی (Glutes)', 'همسترینگ', 'ساق پا (Calves)'];
    }
    if (mg.contains('core') || name.contains('شکم')) {
      return const ['مورب شکمی (Obliques)', 'عضلات دنده‌ای (Serratus)'];
    }
    if (mg.contains('calv') || name.contains('ساق')) {
      return const ['عضله نعلی (Soleus)', 'مچ پا'];
    }
    return const ['عضلات تثبیت‌کننده مرکزی (Stabilizers)'];
  }

  /// Estimated difficulty rating (مبتدی, متوسط, پیشرفته)
  String get difficultyFa {
    final eq = equipment.toLowerCase();
    final n = (nameEn + nameFa).toLowerCase();
    if (eq.contains('barbell') || n.contains('هالتر') || n.contains('deadlift') || n.contains('squat') || n.contains('ددلیفت')) {
      return 'پیشرفته';
    }
    if (eq.contains('machine') || eq.contains('دستگاه') || isBodyweight) {
      return 'مبتدی';
    }
    return 'متوسط';
  }
}
