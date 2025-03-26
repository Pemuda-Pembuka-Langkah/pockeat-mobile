import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';

void main() {
  group('CalorieData', () {
    test('should create CalorieData with the correct properties', () {
      // Arrange
      const day = 'Monday';
      const calories = 2500.0;

      // Act
      final calorieData = CalorieData(day, calories);

      // Assert
      expect(calorieData.day, equals(day));
      expect(calorieData.calories, equals(calories));
    });

    test('should handle empty day string', () {
      // Arrange
      const day = '';
      const calories = 1800.0;

      // Act
      final calorieData = CalorieData(day, calories);

      // Assert
      expect(calorieData.day, equals(day));
      expect(calorieData.calories, equals(calories));
    });

    test('should handle zero calories', () {
      // Arrange
      const day = 'Tuesday';
      const calories = 0.0;

      // Act
      final calorieData = CalorieData(day, calories);

      // Assert
      expect(calorieData.day, equals(day));
      expect(calorieData.calories, equals(calories));
    });

    test('should handle negative calories', () {
      // Arrange
      const day = 'Wednesday';
      const calories = -500.0; // Represents a calorie deficit

      // Act
      final calorieData = CalorieData(day, calories);

      // Assert
      expect(calorieData.day, equals(day));
      expect(calorieData.calories, equals(calories));
    });
    
    test('should handle large calorie values', () {
      // Arrange
      const day = 'Thursday';
      const calories = 10000.0; // Very high calorie day

      // Act
      final calorieData = CalorieData(day, calories);

      // Assert
      expect(calorieData.day, equals(day));
      expect(calorieData.calories, equals(calories));
    });

    test('should handle abbreviated day names', () {
      // Arrange
      const day = 'M';
      const calories = 2100.0;

      // Act
      final calorieData = CalorieData(day, calories);

      // Assert
      expect(calorieData.day, equals(day));
      expect(calorieData.calories, equals(calories));
    });

    test('should handle week format', () {
      // Arrange
      const day = 'Week 1';
      const calories = 2150.0;

      // Act
      final calorieData = CalorieData(day, calories);

      // Assert
      expect(calorieData.day, equals(day));
      expect(calorieData.calories, equals(calories));
    });
  });
}