import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

void main() {
  group('Exercise', () {
    late WeightLifting exercise;
    final testSets = [
      WeightLiftingSet(weight: 20.0, reps: 12, duration: 60.0),
      WeightLiftingSet(weight: 25.0, reps: 10, duration: 45.0),
    ];

    setUp(() {
      exercise = WeightLifting(
        id: 'test-id',
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 3.5,
        userId: 'test-user-id',
        sets: testSets,
      );
    });

    test('should create Exercise instance with provided values', () {
      expect(exercise.id, 'test-id');
      expect(exercise.name, 'Bench Press');
      expect(exercise.bodyPart, 'Chest');
      expect(exercise.metValue, 3.5);
      expect(exercise.sets, testSets);
    });

    test('should create Exercise with generated ID when not provided', () {
      final exerciseWithGeneratedId = WeightLifting(
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 3.5,
        userId: 'test-user-id',
      );

      expect(exerciseWithGeneratedId.id, isNotEmpty);
      expect(exerciseWithGeneratedId.id, isA<String>());
    });

    test('should create Exercise with empty sets when not provided', () {
      final exerciseWithoutSets = WeightLifting(
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 3.5,
        userId: 'test-user-id',
      );

      expect(exerciseWithoutSets.sets, []);
    });

    test('should convert Exercise to JSON', () {
      final json = exercise.toJson();
      
      expect(json['id'], 'test-id');
      expect(json['name'], 'Bench Press');
      expect(json['bodyPart'], 'Chest');
      expect(json['metValue'], 3.5);
      expect(json['sets'], isA<List>());
      expect(json['sets'].length, 2);
    });

    test('should create Exercise from JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'Bench Press',
        'bodyPart': 'Chest',
        'metValue': 3.5,
        'userId': 'test-user-id',
        'sets': [
          {'weight': 20.0, 'reps': 12, 'duration': 60.0},
          {'weight': 25.0, 'reps': 10, 'duration': 45.0},
        ],
      };

      final exerciseFromJson = WeightLifting.fromJson(json);

      expect(exerciseFromJson.id, 'test-id');
      expect(exerciseFromJson.name, 'Bench Press');
      expect(exerciseFromJson.bodyPart, 'Chest');
      expect(exerciseFromJson.metValue, 3.5);
      expect(exerciseFromJson.userId, 'test-user-id');
      expect(exerciseFromJson.sets.length, 2);
      expect(exerciseFromJson.sets[0].weight, 20.0);
      expect(exerciseFromJson.sets[0].reps, 12);
      expect(exerciseFromJson.sets[0].duration, 60.0);
      expect(exerciseFromJson.sets[1].weight, 25.0);
      expect(exerciseFromJson.sets[1].reps, 10);
      expect(exerciseFromJson.sets[1].duration, 45.0);
    });

    test('should handle empty sets in JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'Bench Press',
        'bodyPart': 'Chest',
        'metValue': 3.5,
        'userId': 'test-user-id',
        'sets': [],
      };

      final exerciseFromJson = WeightLifting.fromJson(json);
      expect(exerciseFromJson.sets, []);
    });

    test('should handle null sets in JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'Bench Press',
        'bodyPart': 'Chest',
        'metValue': 3.5,
        'userId': 'test-user-id',
      };

      final exerciseFromJson = WeightLifting.fromJson(json);
      expect(exerciseFromJson.sets, []);
    });
  });

  group('ExerciseSet', () {
    test('should create ExerciseSet instance with provided values', () {
      final exerciseSet = WeightLiftingSet(weight: 20.0, reps: 12, duration: 60.0);
      
      expect(exerciseSet.weight, 20.0);
      expect(exerciseSet.reps, 12);
      expect(exerciseSet.duration, 60.0);
    });

    test('should throw assertion error for non-positive weight', () {
      expect(
        () => WeightLiftingSet(weight: 0.0, reps: 12, duration: 60.0),
        throwsA(isA<AssertionError>()),
      );
      
      expect(
        () => WeightLiftingSet(weight: -5.0, reps: 12, duration: 60.0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw assertion error for non-positive reps', () {
      expect(
        () => WeightLiftingSet(weight: 20.0, reps: 0, duration: 60.0),
        throwsA(isA<AssertionError>()),
      );
      
      expect(
        () => WeightLiftingSet(weight: 20.0, reps: -5, duration: 60.0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw assertion error for non-positive duration', () {
      expect(
        () => WeightLiftingSet(weight: 20.0, reps: 12, duration: 0.0),
        throwsA(isA<AssertionError>()),
      );
      
      expect(
        () => WeightLiftingSet(weight: 20.0, reps: 12, duration: -30.0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should convert ExerciseSet to JSON', () {
      final exerciseSet = WeightLiftingSet(weight: 20.0, reps: 12, duration: 60.0);
      final json = exerciseSet.toJson();
      
      expect(json['weight'], 20.0);
      expect(json['reps'], 12);
      expect(json['duration'], 60.0);
    });

    test('should create ExerciseSet from JSON', () {
      final json = {
        'weight': 20.0,
        'reps': 12,
        'duration': 60.0,
      };

      final exerciseSet = WeightLiftingSet.fromJson(json);
      
      expect(exerciseSet.weight, 20.0);
      expect(exerciseSet.reps, 12);
      expect(exerciseSet.duration, 60.0);
    });

    test('should throw ArgumentError if any field is missing in JSON', () {
      expect(
        () => WeightLiftingSet.fromJson({'reps': 12, 'duration': 60.0}),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => WeightLiftingSet.fromJson({'weight': 20.0, 'duration': 60.0}),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => WeightLiftingSet.fromJson({'weight': 20.0, 'reps': 12}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError for non-positive values in JSON', () {
      expect(
        () => WeightLiftingSet.fromJson({'weight': 0.0, 'reps': 12, 'duration': 60.0}),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => WeightLiftingSet.fromJson({'weight': 20.0, 'reps': 0, 'duration': 60.0}),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => WeightLiftingSet.fromJson({'weight': 20.0, 'reps': 12, 'duration': 0.0}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}