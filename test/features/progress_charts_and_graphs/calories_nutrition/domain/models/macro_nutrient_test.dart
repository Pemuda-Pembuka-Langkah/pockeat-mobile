import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';

void main() {
  group('MacroNutrient', () {
    test('should create a MacroNutrient with the correct properties', () {
      // Arrange
      const label = 'Protein';
      const percentage = 25;
      const detail = '75g/120g';
      const color = Colors.blue;

      // Act
      final macroNutrient = MacroNutrient(
        label: label,
        percentage: percentage,
        detail: detail,
        color: color,
      );

      // Assert
      expect(macroNutrient.label, equals(label));
      expect(macroNutrient.percentage, equals(percentage));
      expect(macroNutrient.detail, equals(detail));
      expect(macroNutrient.color, equals(color));
    });

    test('should create a MacroNutrient with zero percentage', () {
      // Arrange
      const label = 'Carbs';
      const percentage = 0;
      const detail = '0g/250g';
      const color = Colors.green;

      // Act
      final macroNutrient = MacroNutrient(
        label: label,
        percentage: percentage,
        detail: detail,
        color: color,
      );

      // Assert
      expect(macroNutrient.label, equals(label));
      expect(macroNutrient.percentage, equals(percentage));
      expect(macroNutrient.detail, equals(detail));
      expect(macroNutrient.color, equals(color));
    });

    test('should create a MacroNutrient with 100% percentage', () {
      // Arrange
      const label = 'Fat';
      const percentage = 100;
      const detail = '65g/65g';
      const color = Colors.yellow;

      // Act
      final macroNutrient = MacroNutrient(
        label: label,
        percentage: percentage,
        detail: detail,
        color: color,
      );

      // Assert
      expect(macroNutrient.label, equals(label));
      expect(macroNutrient.percentage, equals(percentage));
      expect(macroNutrient.detail, equals(detail));
      expect(macroNutrient.color, equals(color));
    });

    test('should create a MacroNutrient with empty detail string', () {
      // Arrange
      const label = 'Protein';
      const percentage = 50;
      const detail = '';
      const color = Colors.red;

      // Act
      final macroNutrient = MacroNutrient(
        label: label,
        percentage: percentage,
        detail: detail,
        color: color,
      );

      // Assert
      expect(macroNutrient.label, equals(label));
      expect(macroNutrient.percentage, equals(percentage));
      expect(macroNutrient.detail, equals(detail));
      expect(macroNutrient.color, equals(color));
    });

    test('should create a MacroNutrient with different color formats', () {
      // Arrange
      const label = 'Protein';
      const percentage = 75;
      const detail = '90g/120g';
      final color = Color(0xFF4ECDC4); // Using hex value for color

      // Act
      final macroNutrient = MacroNutrient(
        label: label,
        percentage: percentage,
        detail: detail,
        color: color,
      );

      // Assert
      expect(macroNutrient.label, equals(label));
      expect(macroNutrient.percentage, equals(percentage));
      expect(macroNutrient.detail, equals(detail));
      expect(macroNutrient.color, equals(color));
    });
  });
}