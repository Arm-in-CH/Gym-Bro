import '../core/localization/persian_utils.dart';
import '../core/storage/safe_cast.dart';
import 'user_profile.dart';
import 'body_analytics_models.dart';

/// مدل ثبت میزان مصرف آب
class WaterLog {
  final String id;
  final String dateString;
  final int amountMl;
  final int timestamp;

  WaterLog({
    required this.id,
    required this.dateString,
    required this.amountMl,
    required this.timestamp,
  });

  WaterLog copyWith({
    String? id,
    String? dateString,
    int? amountMl,
    int? timestamp,
  }) {
    return WaterLog(
      id: id ?? this.id,
      dateString: dateString ?? this.dateString,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateString': dateString,
        'amountMl': amountMl,
        'timestamp': timestamp,
      };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        id: SafeCast.toStringVal(json['id']),
        dateString: SafeCast.toStringVal(
          json['dateString'],
          PersianUtils.toDateString(DateTime.now()),
        ),
        amountMl: SafeCast.toInt(json['amountMl'], 0),
        timestamp: SafeCast.toInt(
          json['timestamp'],
          DateTime.now().millisecondsSinceEpoch,
        ),
      );
}

/// غذای پرتکرار یا الگو برای ثبت سریع (Quick Food Template)
class QuickFoodTemplate {
  final String id;
  final String name;
  final String defaultMealType;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double portionG;
  final String category; // 'پروتئین', 'کربوهیدرات', 'سبزیجات و میوه', 'مکمل', 'لبنیات'
  final bool isFavorite;

  QuickFoodTemplate({
    required this.id,
    required this.name,
    this.defaultMealType = 'ناهار',
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.portionG = 100.0,
    this.category = 'پروتئین',
    this.isFavorite = true,
  });

  QuickFoodTemplate copyWith({
    String? id,
    String? name,
    String? defaultMealType,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? portionG,
    String? category,
    bool? isFavorite,
  }) {
    return QuickFoodTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultMealType: defaultMealType ?? this.defaultMealType,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      portionG: portionG ?? this.portionG,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'defaultMealType': defaultMealType,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'portionG': portionG,
        'category': category,
        'isFavorite': isFavorite,
      };

  factory QuickFoodTemplate.fromJson(Map<String, dynamic> json) =>
      QuickFoodTemplate(
        id: SafeCast.toStringVal(json['id']),
        name: SafeCast.toStringVal(json['name']),
        defaultMealType: SafeCast.toStringVal(json['defaultMealType'], 'ناهار'),
        calories: SafeCast.toInt(json['calories'], 0),
        proteinG: SafeCast.toDouble(json['proteinG'], 0.0),
        carbsG: SafeCast.toDouble(json['carbsG'], 0.0),
        fatG: SafeCast.toDouble(json['fatG'], 0.0),
        portionG: SafeCast.toDouble(json['portionG'], 100.0),
        category: SafeCast.toStringVal(json['category'], 'پروتئین'),
        isFavorite: SafeCast.toBool(json['isFavorite'], true),
      );
}

/// خلاصه آمار روزانه تغذیه برای نمودارهای روند هفتگی و ماهانه
class DailyNutritionSummary {
  final String dateString;
  final DateTime dateTime;
  final int totalCalories;
  final int targetCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int totalWaterMl;
  final int targetWaterMl;
  final int mealsCount;

  DailyNutritionSummary({
    required this.dateString,
    required this.dateTime,
    required this.totalCalories,
    required this.targetCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalWaterMl,
    required this.targetWaterMl,
    required this.mealsCount,
  });

  int get remainingCalories => targetCalories - totalCalories;
  int get remainingWaterMl =>
      (targetWaterMl - totalWaterMl) > 0 ? targetWaterMl - totalWaterMl : 0;
  double get calorieCompliance =>
      targetCalories > 0 ? (totalCalories / targetCalories).clamp(0.0, 2.0) : 0.0;
  double get waterCompliance =>
      targetWaterMl > 0 ? (totalWaterMl / targetWaterMl).clamp(0.0, 2.0) : 0.0;
}

/// محاسبات علمی تغذیه (Mifflin-St Jeor TDEE & Macro distribution)
class NutritionCalculator {
  /// محاسبه BMR پایه
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    String gender = 'male',
  }) {
    if (gender == 'female') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
  }

  /// ضریب فعالیت بدنی
  static double getActivityMultiplier(dynamic activityLevel) {
    if (activityLevel is ActivityLevel) {
      return activityLevel.tdeeMultiplier;
    }
    final str = activityLevel?.toString().toLowerCase() ?? '';
    if (str.contains('sedentary')) return 1.2;
    if (str.contains('light')) return 1.375;
    if (str.contains('very')) return 1.725;
    if (str.contains('extra') || str.contains('extreme')) return 1.9;
    return 1.55;
  }

  /// محاسبه کالری و درشت‌مغذی‌های پیشنهادی با توجه به پروفایل و هدف
  static Map<String, int> calculateRecommendedPlan({
    required UserProfile profile,
    int? customCalories,
  }) {
    final isFemale = profile.gender == Gender.female;
    final bmr = calculateBmr(
      weightKg: profile.weightKg > 0 ? profile.weightKg : 75.0,
      heightCm: profile.heightCm > 0 ? profile.heightCm : 178.0,
      age: profile.age > 0 ? profile.age : 26,
      gender: isFemale ? 'female' : 'male',
    );

    final multiplier = profile.activityLevel.tdeeMultiplier;
    final tdee = bmr * multiplier;

    int goalCalories;
    if (customCalories != null && customCalories > 500) {
      goalCalories = customCalories;
    } else {
      switch (profile.fitnessGoal) {
        case 'fat_loss':
          goalCalories = (tdee - 450).round();
          break;
        case 'muscle_building':
          goalCalories = (tdee + 350).round();
          break;
        case 'strength':
          goalCalories = (tdee + 200).round();
          break;
        case 'weight_maintenance':
        case 'general_fitness':
        default:
          goalCalories = tdee.round();
          break;
      }
      if (goalCalories < 1200) goalCalories = 1200;
    }

    // Protein target: ~2.0g per kg of weight (or 2.2g for muscle building)
    final weight = profile.weightKg > 0 ? profile.weightKg : 75.0;
    final proteinPerKg = profile.fitnessGoal == 'muscle_building' ? 2.2 : 2.0;
    final targetProteinG = (weight * proteinPerKg).round().clamp(80, 260);

    // Fat target: ~25% of daily calories (1g fat = 9 kcal)
    final fatCalories = goalCalories * 0.25;
    final targetFatG = (fatCalories / 9).round().clamp(40, 120);

    // Carbs target: remaining calories (1g carb = 4 kcal)
    final remainingCalories =
        goalCalories - (targetProteinG * 4) - (targetFatG * 9);
    final targetCarbsG =
        (remainingCalories / 4).round().clamp(80, 600);

    // Water target: ~40ml per kg of weight
    final targetWaterMl = (weight * 40).round().clamp(2200, 4500);

    return {
      'calories': goalCalories,
      'protein': targetProteinG,
      'carbs': targetCarbsG,
      'fat': targetFatG,
      'water': targetWaterMl,
    };
  }
}
