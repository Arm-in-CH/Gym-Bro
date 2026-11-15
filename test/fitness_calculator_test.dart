import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/core/algorithms/fitness_calculator.dart';

void main() {
  group('MetabolicEngine Unit Tests', () {
    test('calculateBmr: computes accurately for male and female', () {
      // 80kg, 180cm, 25 years old male
      // (10 * 80) + (6.25 * 180) - (5 * 25) + 5 = 800 + 1125 - 125 + 5 = 1805.0
      final bmrMale = MetabolicEngine.calculateBmr(
        weightKg: 80,
        heightCm: 180,
        ageYears: 25,
        sex: BiologicalSex.male,
      );
      expect(bmrMale, 1805.0);

      // 60kg, 165cm, 30 years old female
      // (10 * 60) + (6.25 * 165) - (5 * 30) - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
      final bmrFemale = MetabolicEngine.calculateBmr(
        weightKg: 60,
        heightCm: 165,
        ageYears: 30,
        sex: BiologicalSex.female,
      );
      expect(bmrFemale, 1320.25);
    });

    test('calculateBmr: throws ArgumentError on invalid negative or out of bounds inputs', () {
      expect(
        () => MetabolicEngine.calculateBmr(
          weightKg: -70,
          heightCm: 175,
          ageYears: 25,
          sex: BiologicalSex.male,
        ),
        throwsArgumentError,
      );

      expect(
        () => MetabolicEngine.calculateBmr(
          weightKg: 70,
          heightCm: 0,
          ageYears: 25,
          sex: BiologicalSex.male,
        ),
        throwsArgumentError,
      );

      expect(
        () => MetabolicEngine.calculateBmr(
          weightKg: 70,
          heightCm: 175,
          ageYears: -5,
          sex: BiologicalSex.male,
        ),
        throwsArgumentError,
      );
    });

    test('calculateTdee: scales BMR correctly with ActivityLevel multipliers', () {
      final tdee = MetabolicEngine.calculateTdee(
        weightKg: 80,
        heightCm: 180,
        ageYears: 25,
        sex: BiologicalSex.male,
        activityLevel: ActivityLevel.moderatelyActive, // 1.55
      );
      // 1805 * 1.55 = 2797.75
      expect(tdee, 2797.75);
    });

    test('partitionMacros: partitions correctly for fat loss, maintenance, and muscle gain', () {
      const tdee = 2500.0;
      const weight = 80.0;

      // Fat loss (20% deficit -> 2000 kcal)
      final fatLoss = MetabolicEngine.partitionMacros(
        tdee: tdee,
        weightKg: weight,
        goal: FitnessGoal.fatLoss,
      );
      expect(fatLoss.totalCalories, 2000);
      expect(fatLoss.proteinGrams, 176.0); // 80 * 2.2 = 176g -> 704 kcal
      expect(fatLoss.fatGrams, 64.0); // 80 * 0.8 = 64g -> 576 kcal
      expect(fatLoss.carbsGrams, 180.0); // (2000 - 704 - 576) / 4 = 720 / 4 = 180g

      // Muscle gain (10% surplus -> 2750 kcal)
      final muscleGain = MetabolicEngine.partitionMacros(
        tdee: tdee,
        weightKg: weight,
        goal: FitnessGoal.muscleGain,
      );
      expect(muscleGain.totalCalories, 2750);
      expect(muscleGain.proteinGrams, 176.0); // 80 * 2.2 = 176g -> 704 kcal
      expect(muscleGain.fatGrams, 80.0); // 80 * 1.0 = 80g -> 720 kcal
      expect(muscleGain.carbsGrams, 331.5); // (2750 - 704 - 720) / 4 = 1326 / 4 = 331.5g
    });
  });

  group('StrengthEngine Unit Tests', () {
    test('calculate1RmBrzycki: computes 1RM correctly', () {
      // 100kg for 1 rep should be 100.0
      expect(StrengthEngine.calculate1RmBrzycki(weightKg: 100, reps: 1), 100.0);

      // 100kg for 5 reps: 100 / (1.0278 - (0.0278 * 5)) = 100 / (1.0278 - 0.139) = 100 / 0.8888 = 112.51
      final oneRm5Reps = StrengthEngine.calculate1RmBrzycki(weightKg: 100, reps: 5);
      expect(oneRm5Reps, 112.51);

      // 80kg for 10 reps: 80 / (1.0278 - (0.0278 * 10)) = 80 / 0.7498 = 106.6951... -> 106.7
      final oneRm10Reps = StrengthEngine.calculate1RmBrzycki(weightKg: 80, reps: 10);
      expect(oneRm10Reps, 106.7);
    });

    test('calculate1RmBrzycki: throws ArgumentError on non-positive weight, non-positive reps, or >=37 reps', () {
      expect(
        () => StrengthEngine.calculate1RmBrzycki(weightKg: -50, reps: 5),
        throwsArgumentError,
      );
      expect(
        () => StrengthEngine.calculate1RmBrzycki(weightKg: 100, reps: 0),
        throwsArgumentError,
      );
      expect(
        () => StrengthEngine.calculate1RmBrzycki(weightKg: 100, reps: 37),
        throwsArgumentError,
      );
    });

    test('calculateTrainingPercentages: returns standard 65%, 75%, 85%, 95% map', () {
      final percentages = StrengthEngine.calculateTrainingPercentages(
        weightKg: 100,
        reps: 1, // 1RM is 100kg
      );

      expect(percentages.keys, containsAll([65, 75, 85, 95]));
      expect(percentages[65], 65.0);
      expect(percentages[75], 75.0);
      expect(percentages[85], 85.0);
      expect(percentages[95], 95.0);
    });

    test('calculateTrainingPercentages: supports custom training percentages', () {
      final percentages = StrengthEngine.calculateTrainingPercentages(
        weightKg: 100,
        reps: 1,
        customPercentages: [0.50, 0.70, 0.90],
      );

      expect(percentages.keys, containsAll([50, 70, 90]));
      expect(percentages[50], 50.0);
      expect(percentages[70], 70.0);
      expect(percentages[90], 90.0);
    });
  });
}
