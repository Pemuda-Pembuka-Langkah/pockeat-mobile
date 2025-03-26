import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/recommendation_item.dart';

void main() {
  group('RecommendationItem', () {
    test('should create an instance with the provided values', () {
      // Arrange
      final IconData icon = CupertinoIcons.arrow_up_circle_fill;
      const String text = 'Increase protein at breakfast (target: 25-30g)';
      const String detail = 'Try eggs, Greek yogurt, or protein shake';
      final Color color = Colors.pink;

      // Act
      final recommendationItem = RecommendationItem(
        icon: icon,
        text: text,
        detail: detail,
        color: color,
      );

      // Assert
      expect(recommendationItem, isA<RecommendationItem>());
      expect(recommendationItem.icon, equals(icon));
      expect(recommendationItem.text, equals(text));
      expect(recommendationItem.detail, equals(detail));
      expect(recommendationItem.color, equals(color));
    });

    test('should create multiple instances with different values', () {
      // Create multiple instances with different values
      final item1 = RecommendationItem(
        icon: CupertinoIcons.arrow_up_circle_fill,
        text: 'Increase protein at breakfast (target: 25-30g)',
        detail: 'Try eggs, Greek yogurt, or protein shake',
        color: Colors.pink,
      );
      
      final item2 = RecommendationItem(
        icon: CupertinoIcons.timer,
        text: 'Schedule workouts between 4-6 PM',
        detail: 'Research shows improved performance during this window',
        color: Colors.blue,
      );
      
      final item3 = RecommendationItem(
        icon: CupertinoIcons.bed_double_fill,
        text: 'Improve sleep quality with a cool bedroom (65-68°F)',
        detail: 'Lower temperatures promote deeper sleep cycles',
        color: Colors.purple,
      );

      // Verify each instance has the correct properties
      expect(item1.icon, CupertinoIcons.arrow_up_circle_fill);
      expect(item1.text, 'Increase protein at breakfast (target: 25-30g)');
      expect(item1.detail, 'Try eggs, Greek yogurt, or protein shake');
      expect(item1.color, Colors.pink);

      expect(item2.icon, CupertinoIcons.timer);
      expect(item2.text, 'Schedule workouts between 4-6 PM');
      expect(item2.detail, 'Research shows improved performance during this window');
      expect(item2.color, Colors.blue);

      expect(item3.icon, CupertinoIcons.bed_double_fill);
      expect(item3.text, 'Improve sleep quality with a cool bedroom (65-68°F)');
      expect(item3.detail, 'Lower temperatures promote deeper sleep cycles');
      expect(item3.color, Colors.purple);
    });
  });
}