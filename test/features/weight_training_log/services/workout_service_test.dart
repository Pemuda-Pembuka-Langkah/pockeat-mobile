import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/services/workout_service.dart';

void main() {
  group('Workout Service', () {
    final exercise1 = WeightLifting(
      name: 'Bench Press',
      bodyPart: 'Upper Body',
      metValue: 5.0,
      userId: 'test-user-id',
      sets: [
        WeightLiftingSet(weight: 50, reps: 10, duration: 30),
        WeightLiftingSet(weight: 60, reps: 8, duration: 30),
      ],
    );

    final exercise2 = WeightLifting(
      name: 'Squats',
      bodyPart: 'Lower Body',
      metValue: 6.0,
      userId: 'test-user-id',
      sets: [
        WeightLiftingSet(weight: 70, reps: 5, duration: 20),
      ],
    );

    final emptyExercise = WeightLifting(
      name: 'Empty Exercise',
      bodyPart: 'None',
      metValue: 4.0,
      userId: 'test-user-id',
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
    
    test('calculateExerciseVolume handles very low values correctly', () {
      // Instead of zero values, use minimal valid values
      final lowValueExercise = WeightLifting(
        name: 'Low Value',
        bodyPart: 'Test',
        metValue: 4.0,
        userId: 'test-user-id',
        sets: [
          WeightLiftingSet(weight: 0.1, reps: 1, duration: 0.1),
          WeightLiftingSet(weight: 0.1, reps: 1, duration: 0.1),
        ],
      );
      // Since the values are minimal but not zero, expect very small result
      expect(calculateExerciseVolume(lowValueExercise), closeTo(0.2, 0.01));
    });

    // [Edge Cases] Nilai Ekstrem
    test('calculateExerciseCalories handles very high weight and reps correctly', () {
      final highIntensityExercise = WeightLifting(
        name: 'High Intensity',
        bodyPart: 'Full Body',
        metValue: 10.0,
        userId: 'test-user-id',
        sets: [
          WeightLiftingSet(weight: 500, reps: 100, duration: 120),
        ],
      );
      expect(calculateExerciseCalories(highIntensityExercise), greaterThan(5000.0));
    });

    test('calculateExerciseCalories handles minimal duration correctly', () {
      final minimalDurationExercise = WeightLifting(
        name: 'Minimal Duration',
        bodyPart: 'Test',
        metValue: 5.0,
        userId: 'test-user-id',
        sets: [
          WeightLiftingSet(weight: 50, reps: 10, duration: 0.1),
        ],
      );
      // With minimal duration, should still produce positive calories
      expect(calculateExerciseCalories(minimalDurationExercise), greaterThan(0.0));
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