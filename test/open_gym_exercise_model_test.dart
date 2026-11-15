import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/models/open_gym_exercise_model.dart';

void main() {
  group('OpenGym ExerciseModel Unit Tests', () {
    test('Correctly parses complete exercise JSON (0001.json)', () {
      final json = <String, Object?>{
        'id': '0001',
        'name': '3/4 sit-up',
        'bodyPart': 'waist',
        'equipment': 'body weight',
        'target': 'abs',
        'secondaryMuscles': ['hip flexors', 'lower back'],
        'category': 'calisthenics',
        'description': 'A shortened sit-up that stops at about 45 degrees.',
        'instructions': [
          'Lie flat on your back with knees bent.',
          'Curl forward until torso is at a 45-degree angle.',
        ],
        'femaleVariant': '2476',
        'textSource': 'exercisedb',
      };

      final exercise = ExerciseModel.fromJson(json);

      expect(exercise.id, equals('0001'));
      expect(exercise.name, equals('3/4 sit-up'));
      expect(exercise.bodyPart, equals('waist'));
      expect(exercise.equipment, equals('body weight'));
      expect(exercise.target, equals('abs'));
      expect(exercise.secondaryMuscles, equals(['hip flexors', 'lower back']));
      expect(exercise.category, equals('calisthenics'));
      expect(exercise.femaleVariant, equals('2476'));
      expect(exercise.maleVariant, isNull);
      expect(exercise.hold, isFalse);
      expect(exercise.isIsometric, isFalse);
      expect(exercise.isDistanceTracked, isFalse);
      expect(
        exercise.stillImageUrl,
        equals('https://raw.githubusercontent.com/DuarteSantos8/openGym/main/catalogue/media/still/0001.webp'),
      );
      expect(
        exercise.clipVideoUrl,
        equals('https://raw.githubusercontent.com/DuarteSantos8/openGym/main/catalogue/media/clip/0001.mp4'),
      );
    });

    test('Parses machine and muscleMap fields with full type safety', () {
      final json = <String, Object?>{
        'id': '0025',
        'name': 'barbell bench press',
        'bodyPart': 'chest',
        'equipment': 'barbell',
        'target': 'pectorals',
        'secondaryMuscles': ['triceps', 'shoulders'],
        'category': 'strength',
        'hold': false,
        'needs': ['bench'],
        'description': 'The classic flat-bench press.',
        'instructions': ['Lie on a flat bench.', 'Press the bar up.'],
        'muscleMap': <String, Object?>{
          'primaries': ['chest'],
          'secondaries': ['triceps', 'front-delts'],
          'bodyPart': 'chest',
          'weights': <String, Object?>{
            'chest': 0.8,
            'triceps': 0.2,
          },
        },
      };

      final exercise = ExerciseModel.fromJson(json);

      expect(exercise.id, equals('0025'));
      expect(exercise.needs, equals(['bench']));
      expect(exercise.muscleMap, isNotNull);
      expect(exercise.muscleMap!.primaries, equals(['chest']));
      expect(exercise.muscleMap!.secondaries, equals(['triceps', 'front-delts']));
      expect(exercise.muscleMap!.bodyPart, equals('chest'));
      expect(exercise.muscleMap!.weights!['chest'], equals(0.8));
      expect(exercise.muscleMap!.weights!['triceps'], equals(0.2));

      // Test toJson round-trip
      final serialized = exercise.toJson();
      expect(serialized['id'], equals('0025'));
      expect(serialized['name'], equals('barbell bench press'));
      expect(serialized['needs'], equals(['bench']));

      final reconstituted = ExerciseModel.fromJson(serialized);
      expect(reconstituted, equals(exercise));
    });

    test('Handles isometric hold and distance track properties', () {
      final plankJson = <String, Object?>{
        'id': '0400',
        'name': 'plank',
        'bodyPart': 'waist',
        'equipment': 'body weight',
        'target': 'abs',
        'secondaryMuscles': <String>['glutes', 'shoulders'],
        'hold': true,
      };

      final plank = ExerciseModel.fromJson(plankJson);
      expect(plank.hold, isTrue);
      expect(plank.isIsometric, isTrue);
      expect(plank.isDistanceTracked, isFalse);

      final sledJson = <String, Object?>{
        'id': '0500',
        'name': 'sled push',
        'bodyPart': 'upper legs',
        'equipment': 'sled machine',
        'target': 'quads',
        'track': 'distance',
      };

      final sled = ExerciseModel.fromJson(sledJson);
      expect(sled.hold, isFalse);
      expect(sled.isIsometric, isFalse);
      expect(sled.track, equals('distance'));
      expect(sled.isDistanceTracked, isTrue);
    });

    test('Gracefully handles sparse or empty payload without exceptions', () {
      final minimalJson = <String, Object?>{
        'id': '9999',
        'name': 'custom exercise',
        'bodyPart': 'back',
        'equipment': 'dumbbell',
        'target': 'lats',
      };

      final exercise = ExerciseModel.fromJson(minimalJson);

      expect(exercise.id, equals('9999'));
      expect(exercise.name, equals('custom exercise'));
      expect(exercise.secondaryMuscles, isEmpty);
      expect(exercise.instructions, isEmpty);
      expect(exercise.description, isEmpty);
      expect(exercise.hold, isFalse);
      expect(exercise.needs, isNull);
      expect(exercise.muscleMap, isNull);
    });
  });
}
