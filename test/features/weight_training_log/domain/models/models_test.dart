import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/models/models.dart';
import 'package:pockeat/features/weight_training_log/domain/models/exercise.dart' as actual_exercise;
import 'package:pockeat/features/weight_training_log/domain/models/exercise_factory.dart' as actual_factory;
import 'package:pockeat/features/weight_training_log/domain/models/user_constanta.dart' as actual_constanta;

void main() {
  group('Models exports', () {
    test('should export Exercise correctly', () {
      // Create instances of both types to verify they are the same type
      final directExercise = actual_exercise.Exercise(
        name: 'Test',
        bodyPart: 'Test',
        metValue: 1.0,
      );
      
      // This will only compile if Exercise is properly exported
      final exportedExercise = Exercise(
        name: 'Test',
        bodyPart: 'Test',
        metValue: 1.0,
      );
      
      expect(directExercise.runtimeType, exportedExercise.runtimeType);
    });

    test('should export ExerciseSet correctly', () {
      final directSet = actual_exercise.ExerciseSet(
        weight: 10.0,
        reps: 10,
        duration: 30.0,
      );
      
      // This will only compile if ExerciseSet is properly exported via Exercise
      final exportedSet = ExerciseSet(
        weight: 10.0,
        reps: 10,
        duration: 30.0,
      );
      
      expect(directSet.runtimeType, exportedSet.runtimeType);
    });

    test('should export ExerciseFactory correctly', () {
      // Verify types match
      expect(actual_factory.ExerciseFactory, ExerciseFactory);
    });

    test('should export UserConstanta correctly', () {
      // Verify types match
      expect(actual_constanta.UserConstanta, UserConstanta);
      
      // Verify static fields are accessible
      expect(UserConstanta.gender, 'Male');
      expect(UserConstanta.weight, 70.0);
      expect(UserConstanta.height, 175.0);
    });
  });
}