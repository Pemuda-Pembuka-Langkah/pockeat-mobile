import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';

void main() {
  group('CalorieData', () {
    test('should create a CalorieData instance with required parameters', () {
      // Arrange & Act
      final calorieData = CalorieData('Monday', 50.0, 100.0, 30.0);
      
      // Assert
      expect(calorieData.day, 'Monday');
      expect(calorieData.protein, 50.0);
      expect(calorieData.carbs, 100.0);
      expect(calorieData.fats, 30.0);
      expect(calorieData.calories, 0.0); // Default value when not provided
    });
    
    test('should create a CalorieData instance with all parameters including calories', () {
      // Arrange & Act
      final calorieData = CalorieData('Tuesday', 60.0, 120.0, 40.0, 1080.0);
      
      // Assert
      expect(calorieData.day, 'Tuesday');
      expect(calorieData.protein, 60.0);
      expect(calorieData.carbs, 120.0);
      expect(calorieData.fats, 40.0);
      expect(calorieData.calories, 1080.0);
    });

    test('should handle different data types correctly', () {
      // Arrange & Act
      final calorieData = CalorieData('Weekend', 0.0, 0.0, 0.0, 0.0);
      
      // Assert
      expect(calorieData.day, isA<String>());
      expect(calorieData.protein, isA<double>());
      expect(calorieData.carbs, isA<double>());
      expect(calorieData.fats, isA<double>());
      expect(calorieData.calories, isA<double>());
    });
  });
}