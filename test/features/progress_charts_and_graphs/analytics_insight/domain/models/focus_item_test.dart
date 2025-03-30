import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';

void main() {
  group('FocusItem', () {
    test('should create an instance with the provided values', () {
      // Arrange
      final IconData icon = CupertinoIcons.heart_fill;
      const String title = 'Complete your protein target';
      const String subtitle = '15g remaining to reach 120g daily goal';
      final Color color = Colors.red;

      // Act
      final focusItem = FocusItem(
        icon: icon,
        title: title,
        subtitle: subtitle,
        color: color,
      );

      // Assert
      expect(focusItem, isA<FocusItem>());
      expect(focusItem.icon, equals(icon));
      expect(focusItem.title, equals(title));
      expect(focusItem.subtitle, equals(subtitle));
      expect(focusItem.color, equals(color));
    });

    test('should create multiple instances with different values', () {
      // Create multiple instances with different values
      final item1 = FocusItem(
        icon: CupertinoIcons.heart_fill,
        title: 'Complete your protein target',
        subtitle: '15g remaining to reach 120g daily goal',
        color: Colors.red,
      );
      
      final item2 = FocusItem(
        icon: CupertinoIcons.flame_fill,
        title: 'Hit your exercise goal',
        subtitle: '20 minutes left for today\'s target',
        color: Colors.green,
      );
      
      final item3 = FocusItem(
        icon: CupertinoIcons.star_fill,
        title: 'Meet your step goal',
        subtitle: '2,500 steps remaining',
        color: Colors.blue,
      );

      // Verify each instance has the correct properties
      expect(item1.icon, CupertinoIcons.heart_fill);
      expect(item1.title, 'Complete your protein target');
      expect(item1.subtitle, '15g remaining to reach 120g daily goal');
      expect(item1.color, Colors.red);

      expect(item2.icon, CupertinoIcons.flame_fill);
      expect(item2.title, 'Hit your exercise goal');
      expect(item2.subtitle, '20 minutes left for today\'s target');
      expect(item2.color, Colors.green);

      expect(item3.icon, CupertinoIcons.star_fill);
      expect(item3.title, 'Meet your step goal');
      expect(item3.subtitle, '2,500 steps remaining');
      expect(item3.color, Colors.blue);
    });
  });
}