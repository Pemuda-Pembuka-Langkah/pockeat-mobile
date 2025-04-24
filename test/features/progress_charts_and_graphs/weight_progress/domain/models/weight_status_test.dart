// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';

void main() {
  group('WeightStatus', () {
    test('should properly initialize all fields with normal values', () {
      // Arrange
      const double currentWeight = 73.0;
      const double weightLoss = 2.5;
      const double progressToGoal = 0.71;
      const double exerciseContribution = 0.45;
      const double dietContribution = 0.55;
      const double bmiValue = 22.5;
      const String bmiCategory = 'Healthy';

      // Act
      final weightStatus = WeightStatus(
        currentWeight: currentWeight,
        weightLoss: weightLoss,
        progressToGoal: progressToGoal,
        exerciseContribution: exerciseContribution,
        dietContribution: dietContribution,
        bmiValue: bmiValue,
        bmiCategory: bmiCategory,
      );

      // Assert
      expect(weightStatus.currentWeight, equals(currentWeight));
      expect(weightStatus.weightLoss, equals(weightLoss));
      expect(weightStatus.progressToGoal, equals(progressToGoal));
      expect(weightStatus.exerciseContribution, equals(exerciseContribution));
      expect(weightStatus.dietContribution, equals(dietContribution));
      expect(weightStatus.bmiValue, equals(bmiValue));
      expect(weightStatus.bmiCategory, equals(bmiCategory));
    });

    test('should properly initialize with zero values', () {
      // Arrange
      const double currentWeight = 0.0;
      const double weightLoss = 0.0;
      const double progressToGoal = 0.0;
      const double exerciseContribution = 0.0;
      const double dietContribution = 0.0;
      const double bmiValue = 0.0;
      const String bmiCategory = '';

      // Act
      final weightStatus = WeightStatus(
        currentWeight: currentWeight,
        weightLoss: weightLoss,
        progressToGoal: progressToGoal,
        exerciseContribution: exerciseContribution,
        dietContribution: dietContribution,
        bmiValue: bmiValue,
        bmiCategory: bmiCategory,
      );

      // Assert
      expect(weightStatus.currentWeight, equals(0.0));
      expect(weightStatus.weightLoss, equals(0.0));
      expect(weightStatus.progressToGoal, equals(0.0));
      expect(weightStatus.exerciseContribution, equals(0.0));
      expect(weightStatus.dietContribution, equals(0.0));
      expect(weightStatus.bmiValue, equals(0.0));
      expect(weightStatus.bmiCategory, equals(''));
    });

    test('should handle various BMI categories', () {
      // Test different BMI categories
      final underweightStatus = WeightStatus(
        currentWeight: 45.0,
        weightLoss: 0.0,
        progressToGoal: 0.0,
        exerciseContribution: 0.5,
        dietContribution: 0.5,
        bmiValue: 17.5,
        bmiCategory: 'Underweight',
      );
      
      final overweightStatus = WeightStatus(
        currentWeight: 85.0,
        weightLoss: -2.0,
        progressToGoal: 0.25,
        exerciseContribution: 0.7,
        dietContribution: 0.3,
        bmiValue: 27.8,
        bmiCategory: 'Overweight',
      );
      
      final obeseStatus = WeightStatus(
        currentWeight: 98.0,
        weightLoss: 0.0,
        progressToGoal: 0.1,
        exerciseContribution: 0.8,
        dietContribution: 0.2,
        bmiValue: 32.5,
        bmiCategory: 'Obese',
      );

      // Assert
      expect(underweightStatus.bmiCategory, equals('Underweight'));
      expect(overweightStatus.bmiCategory, equals('Overweight'));
      expect(obeseStatus.bmiCategory, equals('Obese'));
    });

    test('should handle extreme values and decimal precision', () {
      // Arrange - testing with precise decimal values
      const double currentWeight = 120.75;
      const double weightLoss = -10.25; // negative weight loss = weight gain
      const double progressToGoal = 0.999;
      const double exerciseContribution = 0.333;
      const double dietContribution = 0.667;
      const double bmiValue = 40.123;
      const String bmiCategory = 'Severely Obese';

      // Act
      final weightStatus = WeightStatus(
        currentWeight: currentWeight,
        weightLoss: weightLoss,
        progressToGoal: progressToGoal,
        exerciseContribution: exerciseContribution,
        dietContribution: dietContribution,
        bmiValue: bmiValue,
        bmiCategory: bmiCategory,
      );

      // Assert
      expect(weightStatus.currentWeight, equals(120.75));
      expect(weightStatus.weightLoss, equals(-10.25));
      expect(weightStatus.progressToGoal, equals(0.999));
      expect(weightStatus.exerciseContribution, equals(0.333));
      expect(weightStatus.dietContribution, equals(0.667));
      expect(weightStatus.bmiValue, equals(40.123));
      expect(weightStatus.bmiCategory, equals('Severely Obese'));
    });
  });
}
