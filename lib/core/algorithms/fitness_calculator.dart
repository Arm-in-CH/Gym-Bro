/// Pure Dart Fitness Calculation Engines
/// Contains mathematical models for metabolic rates, macro partitioning,
/// 1RM estimation, and percentage-based loading without Flutter/UI dependencies.
library fitness_calculator;

/// Biological sex enumeration for metabolic computations.
enum BiologicalSex {
  male,
  female,
}

/// Physical activity level multiplier aligned with scientific metabolic standards.
enum ActivityLevel {
  sedentary(1.2),
  lightlyActive(1.375),
  moderatelyActive(1.55),
  veryActive(1.725),
  extraActive(1.9);

  final double multiplier;
  const ActivityLevel(this.multiplier);
}

/// Athletic dietary goal determining calorie adjustment and macronutrient distribution.
enum FitnessGoal {
  fatLoss,
  maintenance,
  muscleGain,
}

/// Immutable data container holding macronutrient split targets in grams and calories.
class MacroPartition {
  final int totalCalories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final int proteinCalories;
  final int carbsCalories;
  final int fatCalories;

  const MacroPartition({
    required this.totalCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.proteinCalories,
    required this.carbsCalories,
    required this.fatCalories,
  });

  @override
  String toString() =>
      'MacroPartition(Total: $totalCalories kcal, P: ${proteinGrams.toStringAsFixed(1)}g ($proteinCalories kcal), C: ${carbsGrams.toStringAsFixed(1)}g ($carbsCalories kcal), F: ${fatGrams.toStringAsFixed(1)}g ($fatCalories kcal))';
}

/// Scientific engine for Basal Metabolic Rate (BMR), Total Daily Energy Expenditure (TDEE),
/// and goal-specific macronutrient partitioning.
class MetabolicEngine {
  MetabolicEngine._();

  /// Calculates Basal Metabolic Rate (BMR) using the Mifflin-St Jeor Equation.
  ///
  /// Formula:
  /// - Men: BMR = (10 * weight_kg) + (6.25 * height_cm) - (5 * age) + 5
  /// - Women: BMR = (10 * weight_kg) + (6.25 * height_cm) - (5 * age) - 161
  ///
  /// Throws [ArgumentError] if any input falls outside physiological boundaries.
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required BiologicalSex sex,
  }) {
    if (weightKg <= 0 || weightKg > 500) {
      throw ArgumentError.value(
        weightKg,
        'weightKg',
        'Weight must be positive and within realistic biological limits (0-500 kg).',
      );
    }
    if (heightCm <= 0 || heightCm > 300) {
      throw ArgumentError.value(
        heightCm,
        'heightCm',
        'Height must be positive and within realistic biological limits (0-300 cm).',
      );
    }
    if (ageYears <= 0 || ageYears > 130) {
      throw ArgumentError.value(
        ageYears,
        'ageYears',
        'Age must be positive and within realistic biological limits (1-130 years).',
      );
    }

    final base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * ageYears);
    switch (sex) {
      case BiologicalSex.male:
        return base + 5.0;
      case BiologicalSex.female:
        return base - 161.0;
    }
  }

  /// Calculates Total Daily Energy Expenditure (TDEE) by scaling BMR by physical activity multiplier.
  static double calculateTdee({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required BiologicalSex sex,
    required ActivityLevel activityLevel,
  }) {
    final bmr = calculateBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      ageYears: ageYears,
      sex: sex,
    );
    return bmr * activityLevel.multiplier;
  }

  /// Calculates precise macronutrient targets (Protein, Carbs, Fat) from TDEE and body weight based on athletic goal.
  ///
  /// Caloric adjustments:
  /// - Fat Loss: 20% caloric deficit (0.80 * TDEE)
  /// - Maintenance: 0% caloric adjustment (1.00 * TDEE)
  /// - Muscle Gain: 10% caloric surplus (1.10 * TDEE)
  ///
  /// Macro density breakdown:
  /// - Protein: 4 kcal/gram (Fat Loss: 2.2g/kg, Maintenance: 2.0g/kg, Muscle Gain: 2.2g/kg)
  /// - Fat: 9 kcal/gram (0.9g/kg to 1.0g/kg based on hormonal health baseline)
  /// - Carbohydrates: 4 kcal/gram (fills remaining caloric allowance)
  static MacroPartition partitionMacros({
    required double tdee,
    required double weightKg,
    required FitnessGoal goal,
  }) {
    if (tdee <= 0) {
      throw ArgumentError.value(tdee, 'tdee', 'TDEE must be strictly positive.');
    }
    if (weightKg <= 0) {
      throw ArgumentError.value(weightKg, 'weightKg', 'Weight must be strictly positive.');
    }

    // Determine target total calories based on objective
    final double targetCaloriesDbl;
    final double proteinPerKg;
    final double fatPerKg;

    switch (goal) {
      case FitnessGoal.fatLoss:
        targetCaloriesDbl = tdee * 0.80; // 20% deficit
        proteinPerKg = 2.2;              // High protein to spare lean muscle mass during deficit
        fatPerKg = 0.8;                  // Controlled dietary fats for endocrine health
        break;
      case FitnessGoal.maintenance:
        targetCaloriesDbl = tdee * 1.00;
        proteinPerKg = 2.0;
        fatPerKg = 0.9;
        break;
      case FitnessGoal.muscleGain:
        targetCaloriesDbl = tdee * 1.10; // 10% clean surplus
        proteinPerKg = 2.2;
        fatPerKg = 1.0;
        break;
    }

    final targetCalories = targetCaloriesDbl.round();

    // 1. Protein calculation (4 kcal/g)
    final proteinGrams = weightKg * proteinPerKg;
    final proteinCalories = (proteinGrams * 4.0).round();

    // 2. Fat calculation (9 kcal/g)
    final fatGrams = weightKg * fatPerKg;
    final fatCalories = (fatGrams * 9.0).round();

    // 3. Carbohydrates calculation (remaining calories / 4 kcal/g)
    final remainingCalories = targetCalories - proteinCalories - fatCalories;
    final carbsCalories = remainingCalories > 0 ? remainingCalories : 0;
    final carbsGrams = carbsCalories / 4.0;

    return MacroPartition(
      totalCalories: targetCalories,
      proteinGrams: double.parse(proteinGrams.toStringAsFixed(1)),
      carbsGrams: double.parse(carbsGrams.toStringAsFixed(1)),
      fatGrams: double.parse(fatGrams.toStringAsFixed(1)),
      proteinCalories: proteinCalories,
      carbsCalories: carbsCalories,
      fatCalories: fatCalories,
    );
  }
}

/// Scientific engine for 1RM (One Repetition Maximum) calculations and percentage loading zones.
class StrengthEngine {
  StrengthEngine._();

  /// Standard training percentages commonly utilized in strength programming.
  static const List<double> standardPercentages = [0.65, 0.75, 0.85, 0.95];

  /// Calculates One-Repetition Maximum (1RM) using the Matt Brzycki formula.
  ///
  /// Formula:
  /// `1RM = weight / (1.0278 - (0.0278 * reps))`
  ///
  /// Validations:
  /// - [weightKg] must be greater than 0.
  /// - [reps] must be between 1 and 36 (at 37 reps, Brzycki denominator becomes <= 0).
  ///
  /// When [reps] == 1, 1RM is mathematically equal to the lifted [weightKg].
  static double calculate1RmBrzycki({
    required double weightKg,
    required int reps,
  }) {
    if (weightKg <= 0) {
      throw ArgumentError.value(
        weightKg,
        'weightKg',
        'Weight lifted must be strictly positive.',
      );
    }
    if (reps <= 0) {
      throw ArgumentError.value(
        reps,
        'reps',
        'Repetitions must be greater than or equal to 1.',
      );
    }
    if (reps >= 37) {
      throw ArgumentError.value(
        reps,
        'reps',
        'Brzycki formula is invalid for 37 or more repetitions as denominator approaches zero/negative.',
      );
    }

    if (reps == 1) {
      return double.parse(weightKg.toStringAsFixed(2));
    }

    final oneRm = weightKg / (1.0278 - (0.0278 * reps));
    return double.parse(oneRm.toStringAsFixed(2));
  }

  /// Calculates training loads for key training intensity percentages (65%, 75%, 85%, 95%).
  ///
  /// An optional [customPercentages] list can be passed; otherwise [standardPercentages] is used.
  /// Keys in the returned map represent integer percentage values (e.g. 65, 75, 85, 95).
  /// Values represent the prescribed weight rounded to 2 decimal places.
  static Map<int, double> calculateTrainingPercentages({
    required double weightKg,
    required int reps,
    List<double>? customPercentages,
  }) {
    final oneRm = calculate1RmBrzycki(weightKg: weightKg, reps: reps);
    final percentages = customPercentages ?? standardPercentages;

    final Map<int, double> distribution = {};
    for (final pct in percentages) {
      if (pct <= 0 || pct > 1.5) {
        throw ArgumentError.value(
          pct,
          'customPercentages',
          'Percentage multiplier must be between 0.0 and 1.5 (e.g., 0.85 for 85%).',
        );
      }
      final key = (pct * 100).round();
      final targetWeight = double.parse((oneRm * pct).toStringAsFixed(2));
      distribution[key] = targetWeight;
    }

    return distribution;
  }
}
