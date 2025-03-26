import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';

void main() {
  group('MicroNutrient', () {
    test('should create a MicroNutrient with the correct properties', () {
      // Arrange
      const nutrient = 'Fiber';
      const current = '12g';
      const target = '25g';
      const progress = 0.48;
      const color = Colors.green;

      // Act
      final microNutrient = MicroNutrient(
        nutrient: nutrient,
        current: current,
        target: target,
        progress: progress,
        color: color,
      );

      // Assert
      expect(microNutrient.nutrient, equals(nutrient));
      expect(microNutrient.current, equals(current));
      expect(microNutrient.target, equals(target));
      expect(microNutrient.progress, equals(progress));
      expect(microNutrient.color, equals(color));
    });

    test('should create a MicroNutrient with zero progress', () {
      // Arrange
      const nutrient = 'Sugar';
      const current = '0g';
      const target = '30g';
      const progress = 0.0;
      const color = Colors.pink;

      // Act
      final microNutrient = MicroNutrient(
        nutrient: nutrient,
        current: current,
        target: target,
        progress: progress,
        color: color,
      );

      // Assert
      expect(microNutrient.nutrient, equals(nutrient));
      expect(microNutrient.current, equals(current));
      expect(microNutrient.target, equals(target));
      expect(microNutrient.progress, equals(progress));
      expect(microNutrient.color, equals(color));
    });

    test('should create a MicroNutrient with 100% progress', () {
      // Arrange
      const nutrient = 'Vitamin C';
      const current = '90mg';
      const target = '90mg';
      const progress = 1.0;
      const color = Colors.orange;

      // Act
      final microNutrient = MicroNutrient(
        nutrient: nutrient,
        current: current,
        target: target,
        progress: progress,
        color: color,
      );

      // Assert
      expect(microNutrient.nutrient, equals(nutrient));
      expect(microNutrient.current, equals(current));
      expect(microNutrient.target, equals(target));
      expect(microNutrient.progress, equals(progress));
      expect(microNutrient.color, equals(color));
    });

    test('should create a MicroNutrient with progress greater than 1.0', () {
      // Arrange
      const nutrient = 'Sodium';
      const current = '2500mg';
      const target = '2300mg';
      const progress = 1.09;  // Exceeding the target
      const color = Colors.red;

      // Act
      final microNutrient = MicroNutrient(
        nutrient: nutrient,
        current: current,
        target: target,
        progress: progress,
        color: color,
      );

      // Assert
      expect(microNutrient.nutrient, equals(nutrient));
      expect(microNutrient.current, equals(current));
      expect(microNutrient.target, equals(target));
      expect(microNutrient.progress, equals(progress));
      expect(microNutrient.color, equals(color));
    });

    test('should create a MicroNutrient with non-standard units', () {
      // Arrange
      const nutrient = 'Calcium';
      const current = '800 mg';
      const target = '1000 mg';
      const progress = 0.8;
      final color = Color(0xFF4ECDC4); // Using hex value for color

      // Act
      final microNutrient = MicroNutrient(
        nutrient: nutrient,
        current: current,
        target: target,
        progress: progress,
        color: color,
      );

      // Assert
      expect(microNutrient.nutrient, equals(nutrient));
      expect(microNutrient.current, equals(current));
      expect(microNutrient.target, equals(target));
      expect(microNutrient.progress, equals(progress));
      expect(microNutrient.color, equals(color));
    });
  });
}