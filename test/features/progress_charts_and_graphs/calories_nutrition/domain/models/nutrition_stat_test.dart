import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';

void main() {
  group('NutritionStat', () {
    test('should create a NutritionStat with the correct properties', () {
      // Arrange
      const label = 'Consumed';
      const value = '1,850';
      const color = Colors.pink;

      // Act
      final nutritionStat = NutritionStat(
        label: label,
        value: value,
        color: color,
      );

      // Assert
      expect(nutritionStat.label, equals(label));
      expect(nutritionStat.value, equals(value));
      expect(nutritionStat.color, equals(color));
    });

    test('should create a NutritionStat with empty value', () {
      // Arrange
      const label = 'Burned';
      const value = '';
      const color = Colors.green;

      // Act
      final nutritionStat = NutritionStat(
        label: label,
        value: value,
        color: color,
      );

      // Assert
      expect(nutritionStat.label, equals(label));
      expect(nutritionStat.value, equals(value));
      expect(nutritionStat.color, equals(color));
    });

    test('should create a NutritionStat with numeric value', () {
      // Arrange
      const label = 'Net';
      const value = '450';
      const color = Colors.orange;

      // Act
      final nutritionStat = NutritionStat(
        label: label,
        value: value,
        color: color,
      );

      // Assert
      expect(nutritionStat.label, equals(label));
      expect(nutritionStat.value, equals(value));
      expect(nutritionStat.color, equals(color));
    });

    test('should create a NutritionStat with different color formats', () {
      // Arrange
      const label = 'Protein';
      const value = '75g';
      final color = Color(0xFFFF6B6B); // Using hex value for color

      // Act
      final nutritionStat = NutritionStat(
        label: label,
        value: value,
        color: color,
      );

      // Assert
      expect(nutritionStat.label, equals(label));
      expect(nutritionStat.value, equals(value));
      expect(nutritionStat.color, equals(color));
    });

    test('should create a NutritionStat with long formatted value', () {
      // Arrange
      const label = 'Total';
      const value = '2,345,678';
      const color = Colors.blue;

      // Act
      final nutritionStat = NutritionStat(
        label: label,
        value: value,
        color: color,
      );

      // Assert
      expect(nutritionStat.label, equals(label));
      expect(nutritionStat.value, equals(value));
      expect(nutritionStat.color, equals(color));
    });
  });
}