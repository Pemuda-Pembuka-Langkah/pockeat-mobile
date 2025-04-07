import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';

void main() {
  group('MetricItem', () {
    test('should create an instance with the provided values', () {
      // Arrange
      const String label = 'Health Score';
      const String value = '92';
      const String subtext = '↑ 5 points';
      final Color color = Colors.green;

      // Act
      final metricItem = MetricItem(
        label: label,
        value: value,
        subtext: subtext,
        color: color,
      );

      // Assert
      expect(metricItem, isA<MetricItem>());
      expect(metricItem.label, equals(label));
      expect(metricItem.value, equals(value));
      expect(metricItem.subtext, equals(subtext));
      expect(metricItem.color, equals(color));
    });

    test('should create multiple instances with different values', () {
      // Create multiple instances with different values
      final item1 = MetricItem(
        label: 'Health Score',
        value: '92',
        subtext: '↑ 5 points',
        color: Colors.green,
      );
      
      final item2 = MetricItem(
        label: 'Consistency',
        value: '8.5',
        subtext: 'Top 15%',
        color: Colors.blue,
      );
      
      final item3 = MetricItem(
        label: 'Streak',
        value: '5',
        subtext: 'days',
        color: Colors.orange,
      );

      // Verify each instance has the correct properties
      expect(item1.label, 'Health Score');
      expect(item1.value, '92');
      expect(item1.subtext, '↑ 5 points');
      expect(item1.color, Colors.green);

      expect(item2.label, 'Consistency');
      expect(item2.value, '8.5');
      expect(item2.subtext, 'Top 15%');
      expect(item2.color, Colors.blue);

      expect(item3.label, 'Streak');
      expect(item3.value, '5');
      expect(item3.subtext, 'days');
      expect(item3.color, Colors.orange);
    });
  });
}