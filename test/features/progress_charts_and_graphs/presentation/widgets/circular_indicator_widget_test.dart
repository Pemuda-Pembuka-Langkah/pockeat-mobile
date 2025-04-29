// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/circular_indicator_widget.dart';

void main() {
  group('CircularIndicatorWidget', () {
    testWidgets('renders correctly with all required props', (WidgetTester tester) async {
      // Define test data
      const String testLabel = 'Steps';
      const String testValue = '8,432';
      const IconData testIcon = Icons.directions_walk;
      const Color testColor = Colors.blue;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: testLabel,
                value: testValue,
                icon: testIcon,
                color: testColor,
              ),
            ),
          ),
        ),
      );

      // Verify widget structure
      expect(find.byType(CircularIndicatorWidget), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(2));
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text(testLabel), findsOneWidget);
      expect(find.text(testValue), findsOneWidget);
      
      // Verify icon is rendered with correct properties
      final iconFinder = find.byIcon(testIcon);
      expect(iconFinder, findsOneWidget);
      final Icon iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, testColor);
      expect(iconWidget.size, 28);

      // Verify circular container properties
      final circleContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CircularIndicatorWidget),
          matching: find.byWidgetPredicate(
            (widget) => widget is Container && widget.decoration is BoxDecoration && 
                      (widget.decoration as BoxDecoration).shape == BoxShape.circle
          ),
        ),
      );
      
      final BoxDecoration decoration = circleContainer.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      
      // Corrected: Border color should be checked on the entire border, not just bottom
      final Border border = decoration.border as Border;
      expect(border.top.color, testColor);
      expect(border.top.width, 2);
      
      // Verify text styles
      final labelText = tester.widget<Text>(find.text(testLabel));
      expect(labelText.style!.fontSize, 14);
      expect(labelText.style!.color, Colors.grey[600]);
      
      final valueText = tester.widget<Text>(find.text(testValue));
      expect(valueText.style!.fontSize, 16);
      expect(valueText.style!.color, testColor);
      expect(valueText.style!.fontWeight, FontWeight.w600);
    });

    testWidgets('renders with different colors', (WidgetTester tester) async {
      // Test with red color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Calories',
                value: '2,500',
                icon: Icons.local_fire_department,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      // Verify color is applied
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.local_fire_department));
      expect(iconWidget.color, Colors.red);
      
      final valueText = tester.widget<Text>(find.text('2,500'));
      expect(valueText.style!.color, Colors.red);
      
      final circleContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CircularIndicatorWidget),
          matching: find.byWidgetPredicate(
            (widget) => widget is Container && widget.decoration is BoxDecoration && 
                      (widget.decoration as BoxDecoration).shape == BoxShape.circle
          ),
        ),
      );
      
      final BoxDecoration decoration = circleContainer.decoration as BoxDecoration;
      // Corrected: Check the top border color instead of bottom
      final border = decoration.border as Border;
      expect(border.top.color, Colors.red);
    });

    testWidgets('has proper responsive layout with different text lengths', (WidgetTester tester) async {
      // Test with very short text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'BPM',
                value: '72',
                icon: Icons.favorite,
                color: Colors.pink,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Test with very long text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Very Long Label Text That Might Wrap',
                value: '1,234,567,890',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Both should render without errors
      expect(find.byType(CircularIndicatorWidget), findsOneWidget);
    });

    testWidgets('has proper shadow and decoration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Distance',
                value: '5.4 km',
                icon: Icons.directions_run,
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );

      // Find the main container
      final outerContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Column),
          matching: find.byType(Container),
        ).first,
      );
      
      // Check its decoration
      final BoxDecoration decoration = outerContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.color, Colors.white);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow![0].color, Colors.black.withOpacity(0.1));
      expect(decoration.boxShadow![0].blurRadius, 10);
      expect(decoration.boxShadow![0].offset, const Offset(0, 2));
    });

    testWidgets('can handle theme changes', (WidgetTester tester) async {
      // Build with a dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Water',
                value: '1.5L',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // Widget should still render properly in dark theme
      expect(find.byType(CircularIndicatorWidget), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('1.5L'), findsOneWidget);
    });
  });
}
