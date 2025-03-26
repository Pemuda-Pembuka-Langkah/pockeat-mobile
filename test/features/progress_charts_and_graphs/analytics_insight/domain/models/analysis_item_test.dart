import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';

void main() {
  group('AnalysisItem', () {
    test('should create an instance with the provided values', () {
      // Arrange
      const String title = 'Exercise vs. Diet Impact';
      const String value = '40% Exercise, 60% Diet';
      const String trend = 'Balanced approach';
      final Color color = Colors.green;

      // Act
      final analysisItem = AnalysisItem(
        title: title,
        value: value,
        trend: trend,
        color: color,
      );

      // Assert
      expect(analysisItem, isA<AnalysisItem>());
      expect(analysisItem.title, equals(title));
      expect(analysisItem.value, equals(value));
      expect(analysisItem.trend, equals(trend));
      expect(analysisItem.color, equals(color));
    });

    test('should create multiple instances with different values', () {
      // Create multiple instances with different values
      final item1 = AnalysisItem(
        title: 'Exercise Impact',
        value: '40%',
        trend: 'Positive',
        color: Colors.green,
      );
      
      final item2 = AnalysisItem(
        title: 'Diet Impact',
        value: '60%',
        trend: 'Neutral',
        color: Colors.blue,
      );
      
      final item3 = AnalysisItem(
        title: 'Recovery Quality',
        value: 'Optimal',
        trend: 'Improving',
        color: Colors.purple,
      );

      // Verify each instance has the correct properties
      expect(item1.title, 'Exercise Impact');
      expect(item1.value, '40%');
      expect(item1.trend, 'Positive');
      expect(item1.color, Colors.green);

      expect(item2.title, 'Diet Impact');
      expect(item2.value, '60%');
      expect(item2.trend, 'Neutral');
      expect(item2.color, Colors.blue);

      expect(item3.title, 'Recovery Quality');
      expect(item3.value, 'Optimal');
      expect(item3.trend, 'Improving');
      expect(item3.color, Colors.purple);
    });
  });
}