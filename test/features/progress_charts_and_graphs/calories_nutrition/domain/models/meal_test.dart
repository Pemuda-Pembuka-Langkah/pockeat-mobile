import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';

void main() {
  group('Meal', () {
    test('should create a Meal with the correct properties', () {
      // Arrange
      const name = 'Breakfast';
      const calories = 500;
      const totalCalories = 2000;
      const time = '8:00 AM';
      const color = Colors.blue;

      // Act
      final meal = Meal(
        name: name,
        calories: calories,
        totalCalories: totalCalories,
        time: time,
        color: color,
      );

      // Assert
      expect(meal.name, equals(name));
      expect(meal.calories, equals(calories));
      expect(meal.totalCalories, equals(totalCalories));
      expect(meal.time, equals(time));
      expect(meal.color, equals(color));
    });

    test('should calculate percentage correctly', () {
      // Arrange
      final meal = Meal(
        name: 'Lunch',
        calories: 500,
        totalCalories: 2000,
        time: '12:00 PM',
        color: Colors.green,
      );

      // Act
      final percentage = meal.percentage;

      // Assert
      expect(percentage, equals(0.25)); // 500/2000 = 0.25
    });

    test('should handle zero totalCalories', () {
      // Arrange
      final meal = Meal(
        name: 'Snack',
        calories: 200,
        totalCalories: 0,
        time: '3:00 PM',
        color: Colors.orange,
      );

      // Act & Assert
      // In Dart, division by zero with doubles returns double.infinity
      expect(meal.percentage, equals(double.infinity));
    });

    test('should handle maximum values', () {
      // Arrange
      final meal = Meal(
        name: 'Dinner',
        calories: 2000,
        totalCalories: 2000,
        time: '7:00 PM',
        color: Colors.red,
      );

      // Act
      final percentage = meal.percentage;

      // Assert
      expect(percentage, equals(1.0)); // 2000/2000 = 1.0
    });

    test('should handle values greater than total', () {
      // Arrange
      final meal = Meal(
        name: 'Feast',
        calories: 3000,
        totalCalories: 2000,
        time: '8:00 PM',
        color: Colors.purple,
      );

      // Act
      final percentage = meal.percentage;

      // Assert
      expect(percentage, equals(1.5)); // 3000/2000 = 1.5
    });
  });
}