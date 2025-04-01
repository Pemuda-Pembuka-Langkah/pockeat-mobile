import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_item.dart';

void main() {
  group('InsightItem', () {
    test('should create an instance with the provided values', () {
      // Arrange
      final IconData icon = CupertinoIcons.chart_bar_fill;
      const String title = 'Macro Distribution';
      const String description = 'Protein: 15% (Target: 20-25%)';
      const String action = 'Add lean proteins to meals';

      // Act
      final insightItem = InsightItem(
        icon: icon,
        title: title,
        description: description,
        action: action,
      );

      // Assert
      expect(insightItem, isA<InsightItem>());
      expect(insightItem.icon, equals(icon));
      expect(insightItem.title, equals(title));
      expect(insightItem.description, equals(description));
      expect(insightItem.action, equals(action));
    });

    test('should create multiple instances with different values', () {
      // Create multiple instances with different values
      final item1 = InsightItem(
        icon: CupertinoIcons.chart_bar_fill,
        title: 'Macro Distribution',
        description: 'Protein: 15% (Target: 20-25%)',
        action: 'Add lean proteins to meals',
      );
      
      final item2 = InsightItem(
        icon: CupertinoIcons.graph_circle_fill,
        title: 'Calorie Timing',
        description: '60% calories before 4 PM',
        action: 'Better distribute daily calories',
      );
      
      final item3 = InsightItem(
        icon: CupertinoIcons.arrow_up_right_circle_fill,
        title: 'Workout Efficiency',
        description: 'HIIT burns 30% more calories',
        action: 'Increase HIIT frequency to 3x/week',
      );

      // Verify each instance has the correct properties
      expect(item1.icon, CupertinoIcons.chart_bar_fill);
      expect(item1.title, 'Macro Distribution');
      expect(item1.description, 'Protein: 15% (Target: 20-25%)');
      expect(item1.action, 'Add lean proteins to meals');

      expect(item2.icon, CupertinoIcons.graph_circle_fill);
      expect(item2.title, 'Calorie Timing');
      expect(item2.description, '60% calories before 4 PM');
      expect(item2.action, 'Better distribute daily calories');

      expect(item3.icon, CupertinoIcons.arrow_up_right_circle_fill);
      expect(item3.title, 'Workout Efficiency');
      expect(item3.description, 'HIIT burns 30% more calories');
      expect(item3.action, 'Increase HIIT frequency to 3x/week');
    });
  });
}