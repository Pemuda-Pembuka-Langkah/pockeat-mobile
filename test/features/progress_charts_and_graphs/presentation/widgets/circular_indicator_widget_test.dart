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
      expect(find.byType(Container), findsNWidgets(2)); // Outer container and icon container
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text(testLabel), findsOneWidget);
      expect(find.text(testValue), findsOneWidget);
      
      // Verify icon is rendered with correct properties
      final iconFinder = find.byIcon(testIcon);
      expect(iconFinder, findsOneWidget);
      final Icon iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, testColor);
      expect(iconWidget.size, 32); // Updated size from 28 to 32
      
      // Verify circle container's background color
      final circleContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CircularIndicatorWidget),
          matching: find.byWidgetPredicate(
            (widget) => widget is Container && 
                      widget.decoration is BoxDecoration && 
                      (widget.decoration as BoxDecoration).shape == BoxShape.circle
          ),
        ),
      );
      
      final BoxDecoration decoration = circleContainer.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect((decoration.color as Color).alpha, (testColor.withOpacity(0.1)).alpha);
      expect((decoration.color as Color).red, (testColor.withOpacity(0.1)).red);
      expect((decoration.color as Color).green, (testColor.withOpacity(0.1)).green);
      expect((decoration.color as Color).blue, (testColor.withOpacity(0.1)).blue);
      
      // In new implementation, there's no border
      expect(decoration.border, isNull);
      
      // Verify text styles
      final labelText = tester.widget<Text>(find.text(testLabel));
      expect(labelText.style!.fontSize, 14);
      expect(labelText.style!.color, Colors.grey);
      expect(labelText.style!.fontWeight, FontWeight.w500);
      
      final valueText = tester.widget<Text>(find.text(testValue));
      expect(valueText.style!.fontSize, 18);
      expect(valueText.style!.fontWeight, FontWeight.bold);
      // Value text no longer has color defined in the style
      expect(valueText.style!.color, isNull);
    });

    testWidgets('properly handles onTap callback', (WidgetTester tester) async {
      bool callbackCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Tap Me',
                value: 'Value',
                icon: Icons.touch_app,
                color: Colors.orange,
                onTap: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Initially the callback hasn't been called
      expect(callbackCalled, false);
      
      // Tap on the widget
      await tester.tap(find.byType(CircularIndicatorWidget));
      await tester.pump();
      
      // Verify callback was called
      expect(callbackCalled, true);
    });
    
    testWidgets('does nothing when tapped with null onTap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'No Action',
                value: 'Value',
                icon: Icons.not_interested,
                color: Colors.grey,
                onTap: null,
              ),
            ),
          ),
        ),
      );

      // Should not throw when tapped
      await tester.tap(find.byType(CircularIndicatorWidget));
      await tester.pump();
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
      expect(decoration.borderRadius, BorderRadius.circular(12)); // Updated from 16 to 12
      expect(decoration.color, Colors.white);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow![0].color, Colors.black.withOpacity(0.05)); // Updated opacity
      expect(decoration.boxShadow![0].blurRadius, 10);
      expect(decoration.boxShadow![0].offset, const Offset(0, 4)); // Updated from 2 to 4
    });

    testWidgets('has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Test',
                value: 'Value',
                icon: Icons.check,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Find the main container
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Column),
          matching: find.byType(Container),
        ).first,
      );
      
      // Check padding
      expect(container.padding, const EdgeInsets.symmetric(vertical: 16, horizontal: 8));
    });

    testWidgets('has proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Test',
                value: 'Value',
                icon: Icons.check,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Find SizedBox heights
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      
      // First SizedBox (between icon and label)
      expect(sizedBoxes[0].height, 32.0);
      
      // Second SizedBox (between label and value)
      expect(sizedBoxes[1].height, 16.0);
    });
    
    testWidgets('uses correct icon container size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Test',
                value: 'Value',
                icon: Icons.check,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Find the icon container
      final iconContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CircularIndicatorWidget),
          matching: find.byWidgetPredicate(
            (widget) => widget is Container && 
                      widget.decoration is BoxDecoration && 
                      (widget.decoration as BoxDecoration).shape == BoxShape.circle
          ),
        ),
      );
      
      // Check constraints instead of direct width/height
      // Container doesn't expose width/height as getters, but passes them as constraints to the child
      expect(iconContainer.constraints?.minWidth, 64);
      expect(iconContainer.constraints?.minHeight, 64);
    });
  });
}