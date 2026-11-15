import '../core/storage/safe_cast.dart';

class NutritionPlan {
  final String id;
  final int dailyCalories;
  final int targetProteinG;
  final int targetCarbsG;
  final int targetFatG;
  final int targetWaterMl;

  NutritionPlan({
    required this.id,
    this.dailyCalories = 2650,
    this.targetProteinG = 165,
    this.targetCarbsG = 300,
    this.targetFatG = 70,
    this.targetWaterMl = 3500,
  });

  NutritionPlan copyWith({
    String? id,
    int? dailyCalories,
    int? targetProteinG,
    int? targetCarbsG,
    int? targetFatG,
    int? targetWaterMl,
  }) {
    return NutritionPlan(
      id: id ?? this.id,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetFatG: targetFatG ?? this.targetFatG,
      targetWaterMl: targetWaterMl ?? this.targetWaterMl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dailyCalories': dailyCalories,
        'targetProteinG': targetProteinG,
        'targetCarbsG': targetCarbsG,
        'targetFatG': targetFatG,
        'targetWaterMl': targetWaterMl,
      };

  factory NutritionPlan.fromJson(Map<String, dynamic> json) => NutritionPlan(
        id: SafeCast.toStringVal(json['id'], 'plan_armin_1'),
        dailyCalories: SafeCast.toInt(json['dailyCalories'], 2650),
        targetProteinG: SafeCast.toInt(json['targetProteinG'], 165),
        targetCarbsG: SafeCast.toInt(json['targetCarbsG'], 300),
        targetFatG: SafeCast.toInt(json['targetFatG'], 70),
        targetWaterMl: SafeCast.toInt(json['targetWaterMl'], 3500),
      );
}
