// Central vector taxonomy, enums, and handcrafted SVG path definitions
// for the GymBro athletic iconography and equipment illustration system.
//
// Designed to eliminate primitive polygon approximations in favor of
// optically balanced, human-crafted Bézier geometry matching Figma standards.

class GymBroIconPaths {
  GymBroIconPaths._();

  /// Handcrafted athletic dumbbell icon path (24x24 viewport, 2dp stroke)
  static const String dumbbell =
      'M 6.5 6.5 C 5.5 5.5, 4 6, 3.5 7.5 L 3.5 9 C 3.5 10.5, 4.5 11.5, 6 12 '
      'L 12 6 C 11.5 4.5, 10.5 3.5, 9 3.5 L 7.5 3.5 C 6 4, 5.5 5.5, 6.5 6.5 Z '
      'M 8 16 L 16 8 '
      'M 17.5 17.5 C 18.5 18.5, 20 18, 20.5 16.5 L 20.5 15 C 20.5 13.5, 19.5 12.5, 18 12 '
      'L 12 18 C 12.5 19.5, 13.5 20.5, 15 20.5 L 16.5 20.5 C 18 20, 18.5 18.5, 17.5 17.5 Z';

  /// Precision stopwatch timer icon path (24x24 viewport)
  static const String timer =
      'M 12 21 C 7.58 21, 4 17.42, 4 13 C 4 8.58, 7.58 5, 12 5 C 16.42 5, 20 8.58, 20 13 '
      'C 20 17.42, 16.42 21, 12 21 Z '
      'M 12 2 L 12 5 '
      'M 10 2 L 14 2 '
      'M 12 13 L 12 8 '
      'M 12 13 L 15.5 15.5';

  /// Athletic split chronometer stopwatch path (24x24 viewport)
  static const String stopwatch =
      'M 12 22 C 7.03 22, 3 17.97, 3 13 C 3 8.03, 7.03 4, 12 4 C 16.97 4, 21 8.03, 21 13 '
      'C 21 17.97, 16.97 22, 12 22 Z '
      'M 10 2 L 14 2 '
      'M 12 2 L 12 4 '
      'M 18 6.5 L 19.5 5 '
      'M 12 13 L 12 8 '
      'M 12 13 L 16 13';

  /// Athletic nutrition apple with curved leaf cut-out
  static const String nutrition =
      'M 12 6.5 C 10.5 4.5, 7.5 4.8, 6.2 7 C 4.2 10.5, 5.5 16.5, 9.5 18.2 '
      'C 11 18.8, 11.8 18.2, 12 18.2 C 12.2 18.2, 13 18.8, 14.5 18.2 '
      'C 18.5 16.5, 19.8 10.5, 17.8 7 C 16.5 4.8, 13.5 4.5, 12 6.5 Z '
      'M 12 5.5 C 12.5 3.5, 14.5 2.5, 16 2.5';

  /// AI Coach 4-point neural sparkle with satellite nodes
  static const String aiCoach =
      'M 12 3 C 12 7.5, 13.2 10.8, 17.5 12 C 13.2 13.2, 12 16.5, 12 21 '
      'C 12 16.5, 10.8 13.2, 6.5 12 C 10.8 10.8, 12 7.5, 12 3 Z '
      'M 19 4 C 19 5.5, 19.5 6.5, 21 7 C 19.5 7.5, 19 8.5, 19 10 C 19 8.5, 18.5 7.5, 17 7 C 18.5 6.5, 19 5.5, 19 4 Z';

  /// Personal record / trophy crest path
  static const String personalRecord =
      'M 7 4 L 17 4 L 16 11 C 15.2 13.5, 13.2 15, 12 15 C 10.8 15, 8.8 13.5, 8 11 Z '
      'M 7 6 C 4.5 6, 4 9.5, 7.5 10.5 '
      'M 17 6 C 19.5 6, 20 9.5, 16.5 10.5 '
      'M 12 15 L 12 18 M 8 18 L 16 18 M 7 21 L 17 21';

  /// Weekly calendar schedule path with workout focus
  static const String calendar =
      'M 4 7 C 4 5.34, 5.34 4, 7 4 L 17 4 C 18.66 4, 20 5.34, 20 7 L 20 18 '
      'C 20 19.66, 18.66 21, 17 21 L 7 21 C 5.34 21, 4 19.66, 4 18 Z '
      'M 4 9 L 20 9 '
      'M 8 2 L 8 5 M 16 2 L 16 5 '
      'M 8 13 L 10 13 M 14 13 L 16 13 M 8 17 L 10 17 M 14 17 L 16 17';

  /// Surging analytics trendline with milestone node
  static const String progress =
      'M 3 19 L 21 19 '
      'M 4 15 L 9 10 L 13 14 L 19 7 '
      'M 15 7 L 19 7 L 19 11';

  /// Athletic muscular avatar profile path
  static const String profile =
      'M 12 11 C 14.21 11, 16 9.21, 16 7 C 16 4.79, 14.21 3, 12 3 C 9.79 3, 8 4.79, 8 7 '
      'C 8 9.21, 9.79 11, 12 11 Z '
      'M 5 20 C 5 16.5, 8 14, 12 14 C 16 14, 19 16.5, 19 20';

  /// Precision 6-tooth mechanical settings gear
  static const String settings =
      'M 12 15 C 13.66 15, 15 13.66, 15 12 C 15 10.34, 13.66 9, 12 9 C 10.34 9, 9 10.34, 9 12 '
      'C 9 13.66, 10.34 15, 12 15 Z '
      'M 19.4 13 A 7.8 7.8 0 0 0 19.4 11 L 21.3 9.5 L 19.4 6.2 L 17.1 7.1 '
      'A 7.5 7.5 0 0 0 15.4 5.5 L 15 3.1 L 11.2 3.1 L 10.8 5.5 '
      'A 7.5 7.5 0 0 0 9.1 7.1 L 6.8 6.2 L 4.9 9.5 L 6.8 11 '
      'A 7.8 7.8 0 0 0 6.8 13 L 4.9 14.5 L 6.8 17.8 L 9.1 16.9 '
      'A 7.5 7.5 0 0 0 10.8 18.5 L 11.2 20.9 L 15 20.9 L 15.4 18.5 '
      'A 7.5 7.5 0 0 0 17.1 16.9 L 19.4 17.8 L 21.3 14.5 Z';

  /// Gym marketplace pro store awning
  static const String marketplace =
      'M 3 9 L 21 9 L 20 19 C 20 20.1, 19.1 21, 18 21 L 6 21 C 4.9 21, 4 20.1, 4 19 Z '
      'M 2 9 L 4 4 L 20 4 L 22 9 Z '
      'M 10 13 L 14 13 M 12 11 L 12 15';

  /// Fluid dynamic water drop
  static const String water =
      'M 12 3 C 12 3, 6 10, 6 14.5 C 6 17.8, 8.7 20.5, 12 20.5 C 15.3 20.5, 18 17.8, 18 14.5 '
      'C 18 10, 12 3, 12 3 Z';

  /// Triple-tongue metabolic streak flame
  static const String flame =
      'M 12 2 C 12 2, 7 8, 7 13.5 C 7 17.1, 9.2 20, 12 20 C 14.8 20, 17 17.1, 17 13.5 '
      'C 17 10.5, 15 9, 15 9 C 15 9, 14.5 11, 13.5 11.5 C 12.5 12, 11 11, 12 8 C 12.5 6.5, 12 2, 12 2 Z';
}

enum GymBroEquipmentType {
  dumbbell,
  barbell,
  weightPlate,
  kettlebell,
  resistanceBand,
  benchPress,
  treadmill,
  exerciseBike,
  cableMachine,
  pullUpBar,
  legPress,
  smithMachine,
  gymMachine,
}

extension GymBroEquipmentTypeX on GymBroEquipmentType {
  static GymBroEquipmentType fromString(String? val) {
    if (val == null) return GymBroEquipmentType.dumbbell;
    final lower = val.toLowerCase();
    if (lower.contains('barbell') || lower.contains('هالتر')) return GymBroEquipmentType.barbell;
    if (lower.contains('dumbbell') || lower.contains('دمبل')) return GymBroEquipmentType.dumbbell;
    if (lower.contains('kettlebell') || lower.contains('کتل')) return GymBroEquipmentType.kettlebell;
    if (lower.contains('plate') || lower.contains('صفحه')) return GymBroEquipmentType.weightPlate;
    if (lower.contains('cable') || lower.contains('سیم‌کش') || lower.contains('کابل')) return GymBroEquipmentType.cableMachine;
    if (lower.contains('pull') || lower.contains('بارفیکس')) return GymBroEquipmentType.pullUpBar;
    if (lower.contains('bench') || lower.contains('نیمکت') || lower.contains('پرس')) return GymBroEquipmentType.benchPress;
    if (lower.contains('leg') || lower.contains('پا')) return GymBroEquipmentType.legPress;
    if (lower.contains('smith') || lower.contains('اسمیت')) return GymBroEquipmentType.smithMachine;
    if (lower.contains('treadmill') || lower.contains('تردمیل')) return GymBroEquipmentType.treadmill;
    if (lower.contains('bike') || lower.contains('دوچرخه')) return GymBroEquipmentType.exerciseBike;
    if (lower.contains('band') || lower.contains('کش')) return GymBroEquipmentType.resistanceBand;
    return GymBroEquipmentType.gymMachine;
  }
}

enum GymBroMuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  abs,
  obliques,
  quadriceps,
  hamstrings,
  calves,
  glutes,
}

extension GymBroMuscleGroupX on GymBroMuscleGroup {
  static GymBroMuscleGroup fromString(String? val) {
    if (val == null) return GymBroMuscleGroup.chest;
    final lower = val.toLowerCase();
    if (lower.contains('chest') || lower.contains('pectoral') || lower.contains('سینه')) return GymBroMuscleGroup.chest;
    if (lower.contains('back') || lower.contains('lat') || lower.contains('trap') || lower.contains('spinae') || lower.contains('پشت') || lower.contains('زیربغل')) return GymBroMuscleGroup.back;
    if (lower.contains('shoulder') || lower.contains('deltoid') || lower.contains('سرشانه') || lower.contains('دلتوئید')) return GymBroMuscleGroup.shoulders;
    if (lower.contains('bicep') || lower.contains('جلوبازو')) return GymBroMuscleGroup.biceps;
    if (lower.contains('tricep') || lower.contains('پشت‌بازو')) return GymBroMuscleGroup.triceps;
    if (lower.contains('forearm') || lower.contains('wrist') || lower.contains('ساعد')) return GymBroMuscleGroup.forearms;
    if (lower.contains('abs') || lower.contains('waist') || lower.contains('abdominal') || lower.contains('شکم')) return GymBroMuscleGroup.abs;
    if (lower.contains('oblique') || lower.contains('پهلو')) return GymBroMuscleGroup.obliques;
    if (lower.contains('quad') || lower.contains('ران') || lower.contains('چهارسر')) return GymBroMuscleGroup.quadriceps;
    if (lower.contains('hamstring') || lower.contains('همسترینگ') || lower.contains('پشت پا')) return GymBroMuscleGroup.hamstrings;
    if (lower.contains('calve') || lower.contains('calf') || lower.contains('ساق')) return GymBroMuscleGroup.calves;
    if (lower.contains('glute') || lower.contains('باسن') || lower.contains('سرینی')) return GymBroMuscleGroup.glutes;
    return GymBroMuscleGroup.chest;
  }
}

enum GymBroMuscleActivation {
  /// Major target muscle (Neon Lime #CCFF00)
  primary,

  /// Stabilizer / assisting muscle (Warm Gold #F59E0B)
  secondary,

  /// Neutral / resting muscle (Dark Slate Metallic)
  inactive,
}

enum GymBroNutritionType {
  protein,
  carbs,
  fat,
  calories,
  water,
  fruits,
  vegetables,
  meat,
  eggs,
  rice,
  supplements,
  foodScanner,
  fallback,
}

extension GymBroNutritionTypeX on GymBroNutritionType {
  static GymBroNutritionType fromString(String? val) {
    if (val == null) return GymBroNutritionType.fallback;
    final lower = val.toLowerCase();
    if (lower.contains('protein') || lower.contains('پروتئین') || lower.contains('مرغ') || lower.contains('فیله')) {
      return GymBroNutritionType.protein;
    }
    if (lower.contains('carb') || lower.contains('کربوهیدرات') || lower.contains('نان') || lower.contains('جو')) {
      return GymBroNutritionType.carbs;
    }
    if (lower.contains('fat') || lower.contains('چربی') || lower.contains('آووکادو') || lower.contains('زیتون')) {
      return GymBroNutritionType.fat;
    }
    if (lower.contains('calor') || lower.contains('کالری') || lower.contains('انرژی')) {
      return GymBroNutritionType.calories;
    }
    if (lower.contains('water') || lower.contains('آب') || lower.contains('هیدرات')) {
      return GymBroNutritionType.water;
    }
    if (lower.contains('fruit') || lower.contains('میوه') || lower.contains('سیب') || lower.contains('موز')) {
      return GymBroNutritionType.fruits;
    }
    if (lower.contains('veg') || lower.contains('سبزی') || lower.contains('سالاد') || lower.contains('بروکلی')) {
      return GymBroNutritionType.vegetables;
    }
    if (lower.contains('meat') || lower.contains('گوشت') || lower.contains('استیک')) {
      return GymBroNutritionType.meat;
    }
    if (lower.contains('egg') || lower.contains('تخم‌مرغ')) {
      return GymBroNutritionType.eggs;
    }
    if (lower.contains('rice') || lower.contains('برنج') || lower.contains('کته')) {
      return GymBroNutritionType.rice;
    }
    if (lower.contains('supp') || lower.contains('مکمل') || lower.contains('شیکر') || lower.contains('وی') || lower.contains('کراتین')) {
      return GymBroNutritionType.supplements;
    }
    if (lower.contains('scan') || lower.contains('اسکن')) {
      return GymBroNutritionType.foodScanner;
    }
    return GymBroNutritionType.fallback;
  }
}

enum GymBroDashboardIconType {
  workout,
  trainingPlans,
  exerciseHistory,
  timer,
  stopwatch,
  calendar,
  progress,
  statistics,
  personalRecord,
  notification,
  profile,
  settings,
  achievements,
  goals,
  focusedTraining,
  homeMode,
  aiCoach,
}

enum GymBroNavIconType {
  home,
  workout,
  nutrition,
  marketplace,
  profile,
  aiCoach,
}
