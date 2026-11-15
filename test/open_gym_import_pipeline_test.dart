import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/core/storage/database_seeder.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/open_gym_exercise_model.dart';

void main() {
  group('OpenGym DatabaseSeeder Pipeline Integration Tests', () {
    test('1. convertOpenGymExercise maps openGym model to GymBro Exercise with Persian taxonomy', () {
      const openGym = ExerciseModel(
        id: '0025',
        name: 'barbell bench press',
        bodyPart: 'chest',
        equipment: 'barbell',
        target: 'pectorals',
        secondaryMuscles: ['triceps', 'front delts'],
        description: 'Classic flat bench press.',
        instructions: ['Lie on bench.', 'Press barbell up.'],
      );

      final converted = DatabaseSeeder.convertOpenGymExercise(
        openGym,
        nameFa: 'پرس سینه هالتر',
        instructionsFa: 'روی نیمکت صاف دراز کشیده و میله را بالا ببرید.',
      );

      expect(converted.id, equals('opengym_0025'));
      expect(converted.nameEn, equals('barbell bench press'));
      expect(converted.nameFa, equals('پرس سینه هالتر'));
      expect(converted.equipment, equals('Barbell'));
      expect(converted.equipmentFa, equals('هالتر'));
      expect(converted.muscleGroup, equals('chest'));
      expect(converted.muscleGroupFa, equals('سینه'));
      expect(converted.instructionsFa, contains('روی نیمکت صاف دراز کشیده'));
      expect(converted.isBodyweight, isFalse);
    });

    test('2. mergeOpenGymCatalogue avoids duplicate exercises by normalized name and ID', () {
      final existing = [
        Exercise(
          id: 'ex_squat',
          nameEn: 'Barbell Back Squat',
          nameFa: 'اسکوات هالتر',
          muscleGroup: 'Legs',
          muscleGroupFa: 'چهارسر ران و سرینی',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa: 'هالتر روی کول...',
        ),
      ];

      final catalogue = [
        // Duplicate movement (same normalized name):
        const ExerciseModel(
          id: '0040',
          name: 'barbell back squat',
          bodyPart: 'upper legs',
          equipment: 'barbell',
          target: 'quads',
        ),
        // New movement:
        const ExerciseModel(
          id: '0100',
          name: 'dumbbell incline bench press',
          bodyPart: 'chest',
          equipment: 'dumbbell',
          target: 'pectorals',
        ),
      ];

      final merged = DatabaseSeeder.mergeOpenGymCatalogue(
        existingExercises: existing,
        openGymCatalogue: catalogue,
      );

      // Should keep existing squat, skip duplicate openGym squat, and add new dumbbell press
      expect(merged.length, equals(2));
      expect(merged.first.id, equals('ex_squat'));
      expect(merged.last.id, equals('opengym_0100'));
      expect(merged.last.nameEn, equals('dumbbell incline bench press'));
    });

    test('3. filterByAvailableEquipment correctly isolates matching exercises', () {
      final list = [
        Exercise(
          id: '1',
          nameEn: 'Push-up',
          nameFa: 'شنا سوئدی',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Bodyweight',
          equipmentFa: 'وزن بدن',
          instructionsFa: '...',
          isBodyweight: true,
        ),
        Exercise(
          id: '2',
          nameEn: 'Dumbbell Curl',
          nameFa: 'جلوبازو دمبل',
          muscleGroup: 'Arms',
          muscleGroupFa: 'جلو بازو',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa: '...',
        ),
        Exercise(
          id: '3',
          nameEn: 'Cable Crossover',
          nameFa: 'کراس اور سیم‌کش',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Cable',
          equipmentFa: 'سیم‌کش',
          instructionsFa: '...',
        ),
      ];

      // User has only Dumbbell and Home (bodyweight always included)
      final homeFiltered = DatabaseSeeder.filterByAvailableEquipment(
        exercises: list,
        availableEquipment: {'دمبل'},
      );

      expect(homeFiltered.length, equals(2));
      expect(homeFiltered.map((e) => e.nameEn), containsAll(['Push-up', 'Dumbbell Curl']));
      expect(homeFiltered.map((e) => e.nameEn), isNot(contains('Cable Crossover')));
    });

    test('4. searchExercises matches Persian and English terms in parallel', () {
      final list = [
        Exercise(
          id: '1',
          nameEn: 'Barbell Deadlift',
          nameFa: 'ددلیفت هالتر',
          muscleGroup: 'Back',
          muscleGroupFa: 'پشت و زیربغل',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa: '...',
        ),
        Exercise(
          id: '2',
          nameEn: 'Leg Press',
          nameFa: 'پرس پا دستگاه',
          muscleGroup: 'Legs',
          muscleGroupFa: 'چهارسر ران و باسن',
          equipment: 'Machine',
          equipmentFa: 'دستگاه پرس پا',
          instructionsFa: '...',
        ),
      ];

      // Search in Persian
      final resultsFa = DatabaseSeeder.searchExercises(exercises: list, query: 'ددلیفت');
      expect(resultsFa.length, equals(1));
      expect(resultsFa.first.nameEn, equals('Barbell Deadlift'));

      // Search in English
      final resultsEn = DatabaseSeeder.searchExercises(exercises: list, query: 'press');
      expect(resultsEn.length, equals(1));
      expect(resultsEn.first.nameFa, equals('پرس پا دستگاه'));

      // Search by muscle in Persian
      final resultsMuscle = DatabaseSeeder.searchExercises(exercises: list, query: 'چهارسر');
      expect(resultsMuscle.length, equals(1));
      expect(resultsMuscle.first.id, equals('2'));
    });
  });
}
