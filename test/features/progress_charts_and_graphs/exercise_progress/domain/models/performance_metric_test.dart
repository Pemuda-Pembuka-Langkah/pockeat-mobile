import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';

void main() {
  group('PerformanceMetric', () {
    test('should create a PerformanceMetric instance with the provided values', () {
      // Arrange
      const String label = 'Consistency';
      const String value = '92%';
      const String subtext = 'Last week: 87%';
      const int colorValue = 0xFFFF6B6B;
      const IconData icon = Icons.trending_up;

      // Act
      final performanceMetric = PerformanceMetric(
        label: label,
        value: value,
        subtext: subtext,
        colorValue: colorValue,
        icon: icon,
      );

      // Assert
      expect(performanceMetric.label, equals(label));
      expect(performanceMetric.value, equals(value));
      expect(performanceMetric.subtext, equals(subtext));
      expect(performanceMetric.colorValue, equals(colorValue));
      expect(performanceMetric.icon, equals(icon));
    });

    test('should handle empty strings', () {
      // Arrange
      const String label = '';
      const String value = '';
      const String subtext = '';
      const int colorValue = 0xFF4ECDC4;
      const IconData icon = Icons.speed;

      // Act
      final performanceMetric = PerformanceMetric(
        label: label,
        value: value,
        subtext: subtext,
        colorValue: colorValue,
        icon: icon,
      );

      // Assert
      expect(performanceMetric.label, isEmpty);
      expect(performanceMetric.value, isEmpty);
      expect(performanceMetric.subtext, isEmpty);
      expect(performanceMetric.colorValue, equals(colorValue));
      expect(performanceMetric.icon, equals(icon));
    });

    test('should handle different icon data types', () {
      // Arrange
      const String label = 'Streak';
      const String value = '14';
      const String subtext = 'Personal best';
      const int colorValue = 0xFFFFE893;
      const IconData icon = Icons.local_fire_department;

      // Act
      final performanceMetric = PerformanceMetric(
        label: label,
        value: value,
        subtext: subtext,
        colorValue: colorValue,
        icon: icon,
      );

      // Assert
      expect(performanceMetric.icon, equals(icon));
    });

    test('should handle different color values', () {
      // Arrange
      const String label = 'Recovery';
      const String value = '95%';
      const String subtext = 'Optimal';
      const int colorValue = 0xFF000000;  // Black
      const IconData icon = Icons.battery_charging_full;

      // Act
      final performanceMetric = PerformanceMetric(
        label: label,
        value: value,
        subtext: subtext,
        colorValue: colorValue,
        icon: icon,
      );

      // Assert
      expect(performanceMetric.colorValue, equals(colorValue));
    });
  });
}