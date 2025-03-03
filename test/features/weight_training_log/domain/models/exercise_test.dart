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
  });

  group('ExerciseSet Model', () {
    test('should create an ExerciseSet with given values', () {
      final set = ExerciseSet(weight: 60, reps: 8, duration: 20);
      expect(set.weight, 60);
      expect(set.reps, 8);
      expect(set.duration, 20);
    });
  });
}