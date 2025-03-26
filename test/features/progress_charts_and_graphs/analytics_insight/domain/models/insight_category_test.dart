import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_item.dart';

void main() {
  group('InsightCategory', () {
    test('should create an instance with the provided values', () {
      // Arrange
      const String title = 'Nutrition Analysis';
      final IconData icon = CupertinoIcons.chart_pie_fill;
      final Color color = Colors.pink;
      final List<InsightItem> insights = [
        InsightItem(
          icon: CupertinoIcons.chart_bar_fill,
          title: 'Macro Distribution',
          description: 'Protein: 15% (Target: 20-25%)',
          action: 'Add lean proteins to meals',
        ),
        InsightItem(
          icon: CupertinoIcons.graph_circle_fill,
          title: 'Calorie Timing',
          description: '60% calories before 4 PM',
          action: 'Better distribute daily calories',
        ),
      ];

      // Act
      final insightCategory = InsightCategory(
        title: title,
        icon: icon,
        color: color,
        insights: insights,
      );

      // Assert
      expect(insightCategory, isA<InsightCategory>());
      expect(insightCategory.title, equals(title));
      expect(insightCategory.icon, equals(icon));
      expect(insightCategory.color, equals(color));
      expect(insightCategory.insights, equals(insights));
      expect(insightCategory.insights.length, equals(2));
    });

    test('should create multiple instances with different values', () {
      // Create first instance
      final nutritionCategory = InsightCategory(
        title: 'Nutrition Analysis',
        icon: CupertinoIcons.chart_pie_fill,
        color: Colors.red,
        insights: [
          InsightItem(
            icon: CupertinoIcons.chart_bar_fill,
            title: 'Macro Distribution',
            description: 'Protein: 15% (Target: 20-25%)',
            action: 'Add lean proteins to meals',
          ),
        ],
      );
      
      // Create second instance
      final exerciseCategory = InsightCategory(
        title: 'Exercise Impact',
        icon: CupertinoIcons.flame_fill,
        color: Colors.green,
        insights: [
          InsightItem(
            icon: CupertinoIcons.arrow_up_right_circle_fill,
            title: 'Workout Efficiency',
            description: 'HIIT burns 30% more calories',
            action: 'Increase HIIT frequency to 3x/week',
          ),
          InsightItem(
            icon: CupertinoIcons.clock_fill,
            title: 'Optimal Timing',
            description: '45-min sessions most effective',
            action: 'Maintain 45-min workout blocks',
          ),
        ],
      );
      
      // Create third instance with empty insights list
      final emptyCategory = InsightCategory(
        title: 'Weekly Patterns',
        icon: CupertinoIcons.calendar,
        color: Colors.blue,
        insights: [],
      );

      // Verify first instance properties
      expect(nutritionCategory.title, 'Nutrition Analysis');
      expect(nutritionCategory.icon, CupertinoIcons.chart_pie_fill);
      expect(nutritionCategory.color, Colors.red);
      expect(nutritionCategory.insights.length, 1);
      expect(nutritionCategory.insights[0].title, 'Macro Distribution');

      // Verify second instance properties
      expect(exerciseCategory.title, 'Exercise Impact');
      expect(exerciseCategory.icon, CupertinoIcons.flame_fill);
      expect(exerciseCategory.color, Colors.green);
      expect(exerciseCategory.insights.length, 2);
      expect(exerciseCategory.insights[0].title, 'Workout Efficiency');
      expect(exerciseCategory.insights[1].title, 'Optimal Timing');

      // Verify third instance properties (with empty insights list)
      expect(emptyCategory.title, 'Weekly Patterns');
      expect(emptyCategory.icon, CupertinoIcons.calendar);
      expect(emptyCategory.color, Colors.blue);
      expect(emptyCategory.insights, isEmpty);
    });
  });
}