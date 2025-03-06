import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/models/exercise.dart';

void main() {
  group('Exercise Model', () {
    test('should create an Exercise with default id and empty sets when none provided', () {
      final exercise = Exercise(
        name: 'Bench Press',
        bodyPart: 'Upper Body',
        metValue: 5.0,
      );
      expect(exercise.name, 'Bench Press');
      expect(exercise.bodyPart, 'Upper Body');
      expect(exercise.metValue, 5.0);
      expect(exercise.sets, isEmpty);
      expect(exercise.id, isNotNull);
    });

    test('should create an Exercise with provided sets', () {
      final set = ExerciseSet(weight: 50, reps: 10, duration: 30);
      final exercise = Exercise(
        name: 'Squats',
        bodyPart: 'Lower Body',
        metValue: 6.0,
        sets: [set],
      );
      expect(exercise.sets, isNotEmpty);
      expect(exercise.sets.first.weight, 50);
    });

    test('should create an Exercise with provided id', () {
      final exercise = Exercise(
        id: 'custom-id',
        name: 'Deadlift',
        bodyPart: 'Full Body',
        metValue: 8.0,
      );
      expect(exercise.id, 'custom-id');
    });

    test('should convert Exercise to JSON correctly', () {
      final set = ExerciseSet(weight: 60, reps: 12, duration: 45);
      final exercise = Exercise(
        id: 'exercise-123',
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 4.5,
        sets: [set],
      );

      final json = exercise.toJson();
      
      expect(json['id'], 'exercise-123');
      expect(json['name'], 'Bench Press');
      expect(json['bodyPart'], 'Chest');
      expect(json['metValue'], 4.5);
      expect(json['sets'], isA<List>());
      expect(json['sets'].length, 1);
      expect(json['sets'][0]['weight'], 60);
      expect(json['sets'][0]['reps'], 12);
      expect(json['sets'][0]['duration'], 45);
    });

    test('should create an Exercise from JSON correctly', () {
      final json = {
        'id': 'exercise-456',
        'name': 'Pull Ups',
        'bodyPart': 'Upper Body',
        'metValue': 5.0,
        'sets': [
          {'weight': 5.0, 'reps': 12, 'duration': 15.0}
        ],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, 'exercise-456');
      expect(exercise.name, 'Pull Ups');
      expect(exercise.bodyPart, 'Upper Body');
      expect(exercise.metValue, 5.0);
      expect(exercise.sets.length, 1);
      expect(exercise.sets.first.weight, 5.0);
      expect(exercise.sets.first.reps, 12);
      expect(exercise.sets.first.duration, 15.0);
    });

    test('should create an Exercise from JSON when sets is null', () {
      final json = {
        'id': 'exercise-789',
        'name': 'Lunges',
        'bodyPart': 'Legs',
        'metValue': 4.0,
        'sets': null,
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, 'exercise-789');
      expect(exercise.name, 'Lunges');
      expect(exercise.bodyPart, 'Legs');
      expect(exercise.metValue, 4.0);
      expect(exercise.sets, isEmpty);
    });

    test('should create an Exercise from JSON when sets is empty', () {
      final json = {
        'id': 'exercise-101',
        'name': 'Push Ups',
        'bodyPart': 'Chest',
        'metValue': 3.8,
        'sets': [],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, 'exercise-101');
      expect(exercise.name, 'Push Ups');
      expect(exercise.bodyPart, 'Chest');
      expect(exercise.metValue, 3.8);
      expect(exercise.sets, isEmpty);
    });
  });

  group('ExerciseSet Model', () {
    test('should create an ExerciseSet with given values', () {
      final set = ExerciseSet(weight: 60, reps: 8, duration: 20);
      expect(set.weight, 60);
      expect(set.reps, 8);
      expect(set.duration, 20);
    });

    test('should throw ArgumentError if any value is 0 or negative', () {
      expect(() => ExerciseSet(weight: 0, reps: 10, duration: 20), throwsA(isA<AssertionError>()));
      expect(() => ExerciseSet(weight: -1, reps: 10, duration: 20), throwsA(isA<AssertionError>()));
      expect(() => ExerciseSet(weight: 50, reps: 0, duration: 20), throwsA(isA<AssertionError>()));
      expect(() => ExerciseSet(weight: 50, reps: -1, duration: 20), throwsA(isA<AssertionError>()));
      expect(() => ExerciseSet(weight: 50, reps: 10, duration: 0), throwsA(isA<AssertionError>()));
      expect(() => ExerciseSet(weight: 50, reps: 10, duration: -1), throwsA(isA<AssertionError>()));
    });

    test('should convert ExerciseSet to JSON correctly', () {
      final set = ExerciseSet(weight: 75, reps: 5, duration: 60);
      final json = set.toJson();
      
      expect(json['weight'], 75);
      expect(json['reps'], 5);
      expect(json['duration'], 60);
    });

    test('should create ExerciseSet from JSON correctly', () {
      final json = {'weight': 85.5, 'reps': 6, 'duration': 45.5};
      final set = ExerciseSet.fromJson(json);
      
      expect(set.weight, 85.5);
      expect(set.reps, 6);
      expect(set.duration, 45.5);
    });

    test('should throw ArgumentError if any value is 0 or negative in JSON', () {
      expect(
        () => ExerciseSet.fromJson({'weight': 0, 'reps': 10, 'duration': 30}),
        throwsArgumentError,
      );
      expect(
        () => ExerciseSet.fromJson({'weight': 50, 'reps': 0, 'duration': 30}),
        throwsArgumentError,
      );
      expect(
        () => ExerciseSet.fromJson({'weight': 50, 'reps': 10, 'duration': 0}),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError if any value is null in JSON', () {
      expect(
        () => ExerciseSet.fromJson({'weight': null, 'reps': 10, 'duration': 30}),
        throwsArgumentError,
      );
      expect(
        () => ExerciseSet.fromJson({'weight': 50, 'reps': null, 'duration': 30}),
        throwsArgumentError,
      );
      expect(
        () => ExerciseSet.fromJson({'weight': 50, 'reps': 10, 'duration': null}),
        throwsArgumentError,
      );
    });
  });
}