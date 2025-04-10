import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';

void main() {
  group('ExerciseData', () {
    test('should create an instance with the given date and value', () {
      // Arrange
      const String testDate = 'Monday';
      const double testValue = 320.5;
      
      // Act
      final exerciseData = ExerciseData(testDate, testValue);
      
      // Assert
      expect(exerciseData, isNotNull);
      expect(exerciseData, isA<ExerciseData>());
      expect(exerciseData.date, equals(testDate));
      expect(exerciseData.value, equals(testValue));
    });

    test('should handle integer values for value by converting to double', () {
      // Arrange
      const String testDate = 'Tuesday';
      const int testValue = 500; // Integer value
      
      // Act
      final exerciseData = ExerciseData(testDate, testValue.toDouble());
      
      // Assert
      expect(exerciseData.date, equals(testDate));
      expect(exerciseData.value, equals(500.0)); // Should be converted to double
      expect(exerciseData.value, isA<double>());
    });

    test('should handle empty string for date', () {
      // Arrange
      const String testDate = '';
      const double testValue = 150.0;
      
      // Act
      final exerciseData = ExerciseData(testDate, testValue);
      
      // Assert
      expect(exerciseData.date, equals(''));
      expect(exerciseData.value, equals(testValue));
    });
    
    test('should handle zero values', () {
      // Arrange
      const String testDate = 'Sunday';
      const double testValue = 0.0;
      
      // Act
      final exerciseData = ExerciseData(testDate, testValue);
      
      // Assert
      expect(exerciseData.date, equals(testDate));
      expect(exerciseData.value, equals(0.0));
    });
    
    test('should handle negative values', () {
      // Arrange - Even though negative values don't make physical sense, 
      // the model should still accept them to avoid runtime errors
      const String testDate = 'Friday';
      const double testValue = -100.0;
      
      // Act
      final exerciseData = ExerciseData(testDate, testValue);
      
      // Assert
      expect(exerciseData.date, equals(testDate));
      expect(exerciseData.value, equals(testValue));
    });

    test('should handle week labels for monthly view', () {
      // Arrange
      const String testDate = 'Week 3';
      const double testValue = 1500.0;
      
      // Act
      final exerciseData = ExerciseData(testDate, testValue);
      
      // Assert
      expect(exerciseData.date, equals(testDate));
      expect(exerciseData.value, equals(testValue));
    });
  });
}