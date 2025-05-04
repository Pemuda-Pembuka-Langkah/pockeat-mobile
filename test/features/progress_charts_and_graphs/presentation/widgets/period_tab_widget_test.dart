// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_tab_widget.dart';

void main() {
  group('PeriodTabWidget', () {
    // Helper function to create the test widget
    Widget createWidget({
      String title = 'Week',
      bool isSelected = false,
      Color selectedColor = Colors.blue,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Row(  // Menggunakan Row sebagai parent widget untuk Expanded
            children: [
              PeriodTabWidget(
                title: title,
                isSelected: isSelected,
                selectedColor: selectedColor,
                onTap: onTap ?? () {},
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('renders correctly with default values', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Verify title is rendered
      expect(find.text('Week'), findsOneWidget);
      
      // Find the container
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ));
      
      // Verify default styling (not selected)
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.color, Colors.transparent);
      expect(boxDecoration.boxShadow, null);
      
      // Verify default text style (not selected)
      final text = tester.widget<Text>(find.text('Week'));
      expect(text.style!.color, Colors.black54);
      expect(text.style!.fontWeight, FontWeight.w500);
      expect(text.style!.fontSize, 13);
    });
    
    testWidgets('renders correctly when selected', (WidgetTester tester) async {
      const Color testColor = Colors.purple;
      await tester.pumpWidget(createWidget(
        isSelected: true,
        selectedColor: testColor,
      ));
      
      // Find the container
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ));
      
      // Verify selected styling
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.color, Colors.white);
      expect(boxDecoration.boxShadow, isNotNull);
      expect(boxDecoration.boxShadow!.length, 1);
      expect(boxDecoration.boxShadow![0].color, Colors.black.withOpacity(0.05));
      expect(boxDecoration.boxShadow![0].blurRadius, 4);
      expect(boxDecoration.boxShadow![0].offset, const Offset(0, 2));
      
      // Verify selected text style
      final text = tester.widget<Text>(find.text('Week'));
      expect(text.style!.color, testColor);
      expect(text.style!.fontWeight, FontWeight.w600);
    });
    
    testWidgets('has proper border radius', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Find the container
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ));
      
      // Verify border radius
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.borderRadius, BorderRadius.circular(8));
    });
    
    testWidgets('handles different title strings', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(title: 'Month'));
      
      // Verify title is rendered
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Week'), findsNothing);
      
      // Test with another title
      await tester.pumpWidget(createWidget(title: 'All Time'));
      await tester.pump();
      
      // Verify new title is rendered
      expect(find.text('All Time'), findsOneWidget);
      expect(find.text('Month'), findsNothing);
    });
    
    testWidgets('handles tap correctly', (WidgetTester tester) async {
      bool tapHandled = false;
      
      await tester.pumpWidget(createWidget(
        onTap: () {
          tapHandled = true;
        },
      ));
      
      // Perform tap
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      
      // Verify tap was handled
      expect(tapHandled, true);
    });
    
    testWidgets('uses Expanded for flexible width', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Verify Expanded widget is used
      expect(find.byType(Expanded), findsOneWidget);
      
      // Verify Expanded is the parent of GestureDetector
      final finder = find.ancestor(
        of: find.byType(GestureDetector),
        matching: find.byType(Expanded),
      );
      expect(finder, findsOneWidget);
    });
    
    testWidgets('text has proper alignment', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Verify text alignment
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textAlign, TextAlign.center);
    });
    
    testWidgets('container has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Verify container padding
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ));
      expect(container.padding, const EdgeInsets.symmetric(vertical: 8));
    });
    
    testWidgets('works with different colors', (WidgetTester tester) async {
      const Color testColor = Colors.amber;
      
      await tester.pumpWidget(createWidget(
        isSelected: true,
        selectedColor: testColor,
      ));
      
      // Verify text color changes correctly
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.color, testColor);
    });
    
    testWidgets('handles state transition from unselected to selected', (WidgetTester tester) async {
      // Start with unselected
      await tester.pumpWidget(createWidget(isSelected: false));
      
      // Verify unselected state
      Container container = tester.widget<Container>(find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ));
      
      BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);
      expect(decoration.boxShadow, null);
      
      // Change to selected
      await tester.pumpWidget(createWidget(isSelected: true));
      await tester.pumpAndSettle();
      
      // Verify selected state
      container = tester.widget<Container>(find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ));
      
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.boxShadow, isNotNull);
    });
  });
}
