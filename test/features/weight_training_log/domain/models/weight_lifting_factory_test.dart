import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting_factory.dart';

void main() {
  group('ExerciseFactory', () {
    test('should create Exercise from Map using fromMap', () {
      final map = {
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

      final exercise = WeightLiftingFactory.fromMap(map);
      
      expect(exercise.id, 'test-id');
      expect(exercise.name, 'Bench Press');
      expect(exercise.bodyPart, 'Chest');
      expect(exercise.metValue, 3.5);
      expect(exercise.userId, 'test-user-id');
      expect(exercise.sets.length, 2);
      expect(exercise.sets[0].weight, 20.0);
      expect(exercise.sets[0].reps, 12);
      expect(exercise.sets[0].duration, 60.0);
      expect(exercise.sets[1].weight, 25.0);
      expect(exercise.sets[1].reps, 10);
      expect(exercise.sets[1].duration, 45.0);
    });

    test('should create Exercise from form data with sets', () {
      final setsData = [
        {'weight': 20.0, 'reps': 12, 'duration': 60.0},
        {'weight': 25.0, 'reps': 10, 'duration': 45.0},
      ];

      final exercise = WeightLiftingFactory.fromFormData(
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 3.5,
        userId: 'test-user-id',
        setsData: setsData,
      );
      
      expect(exercise.name, 'Bench Press');
      expect(exercise.bodyPart, 'Chest');
      expect(exercise.metValue, 3.5);
      expect(exercise.userId, 'test-user-id');
      expect(exercise.sets.length, 2);
      expect(exercise.sets[0].weight, 20.0);
      expect(exercise.sets[0].reps, 12);
      expect(exercise.sets[0].duration, 60.0);
      expect(exercise.sets[1].weight, 25.0);
      expect(exercise.sets[1].reps, 10);
      expect(exercise.sets[1].duration, 45.0);
    });

    test('should create Exercise from form data without sets', () {
      final exercise = WeightLiftingFactory.fromFormData(
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 3.5,
        userId: 'test-user-id',
      );
      
      expect(exercise.name, 'Bench Press');
      expect(exercise.bodyPart, 'Chest');
      expect(exercise.metValue, 3.5);
      expect(exercise.userId, 'test-user-id');
      expect(exercise.sets, isEmpty);
    });

    test('should create Exercise with empty sets if setsData is empty', () {
      final exercise = WeightLiftingFactory.fromFormData(
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 3.5,
        userId: 'test-user-id',
        setsData: [],
      );
      
      expect(exercise.sets, isEmpty);
    });

    test('should filter out entries with null or invalid values in setsData', () {
      final setsData = [
        {'weight': null, 'reps': null, 'duration': null}, // Should be filtered out
        {'weight': 20.0, 'reps': 12, 'duration': 60.0},   // Should be included
        {'weight': 0.0, 'reps': 10, 'duration': 45.0},    // Should be filtered out (weight <= 0)
      ];

      final exercise = WeightLiftingFactory.fromFormData(
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 3.5,
        userId: 'test-user-id',
        setsData: setsData,
      );
      
      // Only one valid set should remain
      expect(exercise.sets.length, 1);
      expect(exercise.sets[0].weight, 20.0);
      expect(exercise.sets[0].reps, 12);
      expect(exercise.sets[0].duration, 60.0);
    });
  });
}