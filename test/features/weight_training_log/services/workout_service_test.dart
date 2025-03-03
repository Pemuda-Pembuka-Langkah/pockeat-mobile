import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/models/exercise.dart';
import 'package:pockeat/features/weight_training_log/services/workout_service.dart';

void main() {
  group('Workout Service', () {
    final exercise1 = Exercise(
      name: 'Bench Press',
      bodyPart: 'Upper Body',
      metValue: 5.0,
      sets: [
        ExerciseSet(weight: 50, reps: 10, duration: 30),
        ExerciseSet(weight: 60, reps: 8, duration: 30),
      ],
    );

    final exercise2 = Exercise(
      name: 'Squats',
      bodyPart: 'Lower Body',
      metValue: 6.0,
      sets: [
        ExerciseSet(weight: 70, reps: 5, duration: 20),
      ],
    );

    final emptyExercise = Exercise(
      name: 'Empty Exercise',
      bodyPart: 'None',
      metValue: 4.0,
      sets: [],
    );

    final exercises = [exercise1, exercise2];

    // [Positive Case] Kalkulasi nomral
    test('calculateExerciseVolume returns correct volume', () {
      expect(calculateExerciseVolume(exercise1), 980.00);
    });

    test('calculateTotalVolume returns sum of exercise volumes', () {
      expect(calculateTotalVolume(exercises), 1330.00);
    });

    test('calculateEstimatedCalories returns expected calories', () {
      expect(calculateEstimatedCalories(exercises), closeTo(595.485, 0.1));
    });

    test('calculateTotalSets returns correct number', () {
      expect(calculateTotalSets(exercises), 3);
    });

    test('calculateTotalReps returns correct total reps', () {
      expect(calculateTotalReps(exercises), 23);
    });

    test('calculateTotalDuration returns correct total duration', () {
      expect(calculateTotalDuration(exercises), 80);
    });

    test('calculateExerciseCalories returns expected calories for single exercise', () {
      expect(calculateExerciseCalories(exercise1), closeTo(425.25, 0.1));
      expect(calculateExerciseCalories(exercise2), closeTo(170.235, 0.1));
    });

    /// [Negative Case] Input Tidak Wajar
    test('calculateExerciseVolume returns 0 for exercise with no sets', () {
      expect(calculateExerciseVolume(emptyExercise), 0.0);
    });

    test('calculateExerciseCalories returns 0 for exercise with no sets', () {
      expect(calculateExerciseCalories(emptyExercise), 0.0);
    });
    test('calculateExerciseVolume handles zero weight and zero reps correctly', () {
      final zeroWeightExercise = Exercise(
        name: 'Zero Weight',
        bodyPart: 'Test',
        metValue: 4.0,
        sets: [
          ExerciseSet(weight: 0, reps: 0, duration: 10),
          ExerciseSet(weight: 50, reps: 0, duration: 10),
        ],
      );
      expect(calculateExerciseVolume(zeroWeightExercise), 0.0);
    });

    // [Edge Cases] Nilai Ekstrem
    test('calculateExerciseCalories handles very high weight and reps correctly', () {
      final highIntensityExercise = Exercise(
        name: 'High Intensity',
        bodyPart: 'Full Body',
        metValue: 10.0,
        sets: [
          ExerciseSet(weight: 500, reps: 100, duration: 120),
        ],
      );
      expect(calculateExerciseCalories(highIntensityExercise), greaterThan(5000.0));
    });

    test('calculateExerciseCalories handles zero duration correctly', () {
      final noDurationExercise = Exercise(
        name: 'No Duration',
        bodyPart: 'Test',
        metValue: 5.0,
        sets: [
          ExerciseSet(weight: 50, reps: 10, duration: 0),
        ],
      );
      expect(calculateExerciseCalories(noDurationExercise), greaterThan(0.0));
    });

    test('calculateTotalVolume handles empty list correctly', () {
      expect(calculateTotalVolume([]), 0.0);
    });

    test('calculateEstimatedCalories handles empty list correctly', () {
      expect(calculateEstimatedCalories([]), 0.0);
    });

    test('calculateTotalSets handles empty list correctly', () {
      expect(calculateTotalSets([]), 0);
    });

    test('calculateTotalReps handles empty list correctly', () {
      expect(calculateTotalReps([]), 0);
    });

    test('calculateTotalDuration handles empty list correctly', () {
      expect(calculateTotalDuration([]), 0.0);
    });
  });
}