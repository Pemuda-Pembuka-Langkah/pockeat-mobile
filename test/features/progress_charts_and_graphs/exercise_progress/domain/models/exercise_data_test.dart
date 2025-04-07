import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';

void main() {
  group('ExerciseData', () {
    test('should create an instance with the given day and calories', () {
      // Arrange
      const String testDay = 'Monday';
      const double testCalories = 320.5;
      
      // Act
      final exerciseData = ExerciseData(testDay, testCalories);
      
      // Assert
      expect(exerciseData, isNotNull);
      expect(exerciseData, isA<ExerciseData>());
      expect(exerciseData.day, equals(testDay));
      expect(exerciseData.calories, equals(testCalories));
    });

    test('should handle integer values for calories by converting to double', () {
      // Arrange
      const String testDay = 'Tuesday';
      const int testCalories = 500; // Integer value
      
      // Act
      final exerciseData = ExerciseData(testDay, testCalories.toDouble());
      
      // Assert
      expect(exerciseData.day, equals(testDay));
      expect(exerciseData.calories, equals(500.0)); // Should be converted to double
      expect(exerciseData.calories, isA<double>());
    });

    test('should handle empty string for day', () {
      // Arrange
      const String testDay = '';
      const double testCalories = 150.0;
      
      // Act
      final exerciseData = ExerciseData(testDay, testCalories);
      
      // Assert
      expect(exerciseData.day, equals(''));
      expect(exerciseData.calories, equals(testCalories));
    });
    
    test('should handle zero calories', () {
      // Arrange
      const String testDay = 'Sunday';
      const double testCalories = 0.0;
      
      // Act
      final exerciseData = ExerciseData(testDay, testCalories);
      
      // Assert
      expect(exerciseData.day, equals(testDay));
      expect(exerciseData.calories, equals(0.0));
    });
    
    test('should handle negative calories', () {
      // Arrange - Even though negative calories don't make physical sense, 
      // the model should still accept them to avoid runtime errors
      const String testDay = 'Friday';
      const double testCalories = -100.0;
      
      // Act
      final exerciseData = ExerciseData(testDay, testCalories);
      
      // Assert
      expect(exerciseData.day, equals(testDay));
      expect(exerciseData.calories, equals(testCalories));
    });

    test('should allow creation with abbreviations as day', () {
      // Arrange
      const String testDay = 'M';
      const double testCalories = 250.0;
      
      // Act
      final exerciseData = ExerciseData(testDay, testCalories);
      
      // Assert
      expect(exerciseData.day, equals(testDay));
      expect(exerciseData.calories, equals(testCalories));
    });
  });
}