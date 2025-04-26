// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';

void main() {
  group('WeightData', () {
    test('should create an instance with the given parameters', () {
      // Arrange
      const String testLabel = 'Week 1';
      const double testWeight = 75.5;
      const int testCaloriesBurned = 1200;
      const int testExerciseMinutes = 180;
      const String testDominantExercise = 'Running';
      
      // Act
      final weightData = WeightData(
        testLabel, 
        testWeight, 
        testCaloriesBurned,
        testExerciseMinutes,
        testDominantExercise
      );
      
      // Assert
      expect(weightData, isNotNull);
      expect(weightData, isA<WeightData>());
      expect(weightData.label, equals(testLabel));
      expect(weightData.weight, equals(testWeight));
      expect(weightData.caloriesBurned, equals(testCaloriesBurned));
      expect(weightData.exerciseMinutes, equals(testExerciseMinutes));
      expect(weightData.dominantExercise, equals(testDominantExercise));
    });

    test('should handle empty string for label and dominantExercise', () {
      // Arrange
      const String testLabel = '';
      const double testWeight = 70.0;
      const int testCaloriesBurned = 500;
      const int testExerciseMinutes = 60;
      const String testDominantExercise = '';
      
      // Act
      final weightData = WeightData(
        testLabel, 
        testWeight, 
        testCaloriesBurned,
        testExerciseMinutes,
        testDominantExercise
      );
      
      // Assert
      expect(weightData.label, equals(''));
      expect(weightData.weight, equals(testWeight));
      expect(weightData.caloriesBurned, equals(testCaloriesBurned));
      expect(weightData.exerciseMinutes, equals(testExerciseMinutes));
      expect(weightData.dominantExercise, equals(''));
    });
    
    test('should handle zero values for numeric fields', () {
      // Arrange
      const String testLabel = 'Week 2';
      const double testWeight = 0.0;
      const int testCaloriesBurned = 0;
      const int testExerciseMinutes = 0;
      const String testDominantExercise = 'None';
      
      // Act
      final weightData = WeightData(
        testLabel, 
        testWeight, 
        testCaloriesBurned,
        testExerciseMinutes,
        testDominantExercise
      );
      
      // Assert
      expect(weightData.label, equals(testLabel));
      expect(weightData.weight, equals(0.0));
      expect(weightData.caloriesBurned, equals(0));
      expect(weightData.exerciseMinutes, equals(0));
      expect(weightData.dominantExercise, equals(testDominantExercise));
    });
    
    test('should handle negative values for numeric fields', () {
      // Arrange - Even though negative values don't make physical sense, 
      // the model should still handle them gracefully
      const String testLabel = 'Week 3';
      const double testWeight = -1.5;
      const int testCaloriesBurned = -100;
      const int testExerciseMinutes = -30;
      const String testDominantExercise = 'Invalid';
      
      // Act
      final weightData = WeightData(
        testLabel, 
        testWeight, 
        testCaloriesBurned,
        testExerciseMinutes,
        testDominantExercise
      );
      
      // Assert
      expect(weightData.label, equals(testLabel));
      expect(weightData.weight, equals(-1.5));
      expect(weightData.caloriesBurned, equals(-100));
      expect(weightData.exerciseMinutes, equals(-30));
      expect(weightData.dominantExercise, equals(testDominantExercise));
    });

    test('should handle maximum reasonable values', () {
      // Arrange - Testing with very large but reasonable values
      const String testLabel = 'Maximum Test';
      const double testWeight = 500.0; // Unrealistic but should be handled
      const int testCaloriesBurned = 10000;
      const int testExerciseMinutes = 1440; // 24 hours in minutes
      const String testDominantExercise = 'Marathon';
      
      // Act
      final weightData = WeightData(
        testLabel, 
        testWeight, 
        testCaloriesBurned,
        testExerciseMinutes,
        testDominantExercise
      );
      
      // Assert
      expect(weightData.label, equals(testLabel));
      expect(weightData.weight, equals(500.0));
      expect(weightData.caloriesBurned, equals(10000));
      expect(weightData.exerciseMinutes, equals(1440));
      expect(weightData.dominantExercise, equals(testDominantExercise));
    });
    
    test('should handle decimals in weight with precision', () {
      // Arrange
      const String testLabel = 'Precision Test';
      const double testWeight = 72.345;
      const int testCaloriesBurned = 1800;
      const int testExerciseMinutes = 200;
      const String testDominantExercise = 'Mixed';
      
      // Act
      final weightData = WeightData(
        testLabel, 
        testWeight, 
        testCaloriesBurned,
        testExerciseMinutes,
        testDominantExercise
      );
      
      // Assert
      expect(weightData.label, equals(testLabel));
      expect(weightData.weight, equals(72.345));
      expect(weightData.caloriesBurned, equals(testCaloriesBurned));
      expect(weightData.exerciseMinutes, equals(testExerciseMinutes));
      expect(weightData.dominantExercise, equals(testDominantExercise));
    });
    
    test('should handle special characters in string fields', () {
      // Arrange
      const String testLabel = 'Week-1/2 @2023';
      const double testWeight = 68.7;
      const int testCaloriesBurned = 1500;
      const int testExerciseMinutes = 150;
      const String testDominantExercise = 'Cardio & Strength';
      
      // Act
      final weightData = WeightData(
        testLabel, 
        testWeight, 
        testCaloriesBurned,
        testExerciseMinutes,
        testDominantExercise
      );
      
      // Assert
      expect(weightData.label, equals('Week-1/2 @2023'));
      expect(weightData.weight, equals(68.7));
      expect(weightData.caloriesBurned, equals(1500));
      expect(weightData.exerciseMinutes, equals(150));
      expect(weightData.dominantExercise, equals('Cardio & Strength'));
    });
  });
}
