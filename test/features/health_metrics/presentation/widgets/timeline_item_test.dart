import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/timeline_item.dart';

void main() {
  group('TimelineItem', () {
    testWidgets('should render correctly with required props', (WidgetTester tester) async {
      // Arrange
      const String day = 'Day 1';
      const String message = 'Account created';
      const IconData icon = Icons.check_circle;
      const Color color = Colors.green;
      final Color textDarkColor = Colors.black;
      final Color textLightColor = Colors.grey;

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineItem(
              day: day,
              message: message,
              icon: icon,
              color: color,
              textDarkColor: textDarkColor,
              textLightColor: textLightColor,
            ),
          ),
        ),
      );

      // Assert - verify widget displays correct content
      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Account created'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Verify timeline connector is displayed (when not isLast)
      expect(find.byType(Container), findsAtLeastNWidgets(2));
    });

    testWidgets('should handle isLast prop correctly', (WidgetTester tester) async {
      // Arrange
      const String day = 'Day 7';
      const String message = 'Trial ended';
      const IconData icon = Icons.timer_off;
      const Color color = Colors.red;
      final Color textDarkColor = Colors.black;
      final Color textLightColor = Colors.grey;

      // Act - build widget with isLast=true and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineItem(
              day: day,
              message: message,
              icon: icon,
              color: color,
              isLast: true,
              textDarkColor: textDarkColor,
              textLightColor: textLightColor,
            ),
          ),
        ),
      );

      // Assert - verify content is displayed correctly
      expect(find.text('Day 7'), findsOneWidget);
      expect(find.text('Trial ended'), findsOneWidget);
      expect(find.byIcon(Icons.timer_off), findsOneWidget);
    });

    testWidgets('should apply provided colors correctly', (WidgetTester tester) async {
      // Arrange
      const String day = 'Day 2';
      const String message = 'Starting your journey';
      const IconData icon = Icons.directions_run;
      const Color customColor = Colors.purple;
      final Color customTextDark = Colors.indigo;
      final Color customTextLight = Colors.blue;

      // Act - build widget with custom colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineItem(
              day: day,
              message: message,
              icon: icon,
              color: customColor,
              textDarkColor: customTextDark,
              textLightColor: customTextLight,
            ),
          ),
        ),
      );

      // Assert - verify content is displayed with correct colors
      expect(find.text('Day 2'), findsOneWidget);
      expect(find.text('Starting your journey'), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
      
      // Verify icon has the expected color
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.directions_run));
      expect(iconWidget.color, equals(customColor));
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Arrange
      const String day = 'Day 3';
      const String message = 'Progress check';
      const IconData icon = Icons.trending_up;
      const Color color = Colors.blue;
      final Color textDarkColor = Colors.black;
      final Color textLightColor = Colors.grey;

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineItem(
              day: day,
              message: message,
              icon: icon,
              color: color,
              textDarkColor: textDarkColor,
              textLightColor: textLightColor,
            ),
          ),
        ),
      );

      // Assert - verify basic widget hierarchy exists
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      
      // Verify the content is displayed correctly
      expect(find.text('Day 3'), findsOneWidget);
      expect(find.text('Progress check'), findsOneWidget);
    });
  });
}
