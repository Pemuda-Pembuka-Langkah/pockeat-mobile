// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/bmi_section.dart';

void main() {
  // Test colors
  final Color testBlue = Colors.blue;
  final Color testGreen = Colors.green;
  final Color testYellow = Colors.yellow;
  final Color testPink = Colors.pink;
  
  Widget createWidgetUnderTest({String bmiValue = "24.3", bool isLoading = false}) {
    return MaterialApp(
      home: Scaffold(
        body: BMISection(
          primaryBlue: testBlue,
          primaryGreen: testGreen,
          primaryYellow: testYellow,
          primaryPink: testPink,
          bmiValue: bmiValue,
          isLoading: isLoading,
        ),
      ),
    );
  }
  
  group('BMISection', () {
    testWidgets('renders all UI components correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Verify title is displayed
      expect(find.text('Your BMI'), findsOneWidget);
      
      // Verify BMI value is displayed
      expect(find.text('24.3'), findsOneWidget);
      
      // Verify description text - using RegExp to handle potential whitespace
      expect(find.textContaining(RegExp(r'Your weight is')), findsOneWidget);
      
      // Verify BMI category labels are displayed (note: we expect 2 "Healthy" texts)
      expect(find.text('Underweight'), findsOneWidget);
      expect(find.text('Healthy'), findsNWidgets(2)); // One in badge, one in categories
      expect(find.text('Overweight'), findsOneWidget);
      expect(find.text('Obese'), findsOneWidget);
      
      // Verify the badge exists
      final badgeContainer = find.descendant(
        of: find.byType(Row).first,
        matching: find.byType(Container),
      ).evaluate().last; // Last container is the badge
      
      expect(badgeContainer, isNotNull);
    });

    testWidgets('shows loading state correctly', (WidgetTester tester) async {
      // Build the widget with loading state
      await tester.pumpWidget(createWidgetUnderTest(isLoading: true));
      
      // Verify loading text is displayed
      expect(find.text('Loading...'), findsOneWidget);
      
      // Verify BMI value is NOT displayed
      expect(find.text('24.3'), findsNothing);
    });

    testWidgets('handles N/A state correctly', (WidgetTester tester) async {
      // Build the widget with N/A value
      await tester.pumpWidget(createWidgetUnderTest(bmiValue: "N/A"));
      
      // Verify N/A is displayed
      expect(find.text('N/A'), findsOneWidget);
      
      // Still shows "Healthy" as default category
      expect(find.text('Healthy'), findsNWidgets(2));
    });

    testWidgets('handles Error state correctly', (WidgetTester tester) async {
      // Build the widget with Error value
      await tester.pumpWidget(createWidgetUnderTest(bmiValue: "Error"));
      
      // Verify Error is displayed
      expect(find.text('Error'), findsOneWidget);
      
      // Still shows "Healthy" as default category
      expect(find.text('Healthy'), findsNWidgets(2));
    });
    
    testWidgets('uses provided colors for BMI category indicators', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Find the row that contains the category indicators
      final categoryRow = find.byWidgetPredicate((widget) => 
        widget is Row && 
        widget.mainAxisAlignment == MainAxisAlignment.spaceBetween
      );
      
      expect(categoryRow, findsOneWidget);
      
      // Get the Row widget
      final row = tester.widget<Row>(categoryRow);
      
      // Check there are 4 items in the row (one for each BMI category)
      expect(row.children.length, 4);
      
      // Find all circle indicators within their category rows
      final indicators = tester.widgetList<Container>(
        find.descendant(
          of: categoryRow,
          matching: find.byWidgetPredicate((widget) => 
            widget is Container && 
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle
          ),
        ),
      ).toList();
      
      expect(indicators.length, 4); // Should find 4 circle indicators
      
      // Check each indicator has the correct color
      final colors = indicators.map((container) => 
        (container.decoration as BoxDecoration).color
      ).toList();
      
      expect(colors[0], testBlue);
      expect(colors[1], testGreen);
      expect(colors[2], testYellow);
      expect(colors[3], testPink);
    });
    
    testWidgets('builds the gradient bar with provided colors', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Find the container with the gradient
      final gradientContainer = find.descendant(
        of: find.byType(Column),
        matching: find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient != null
        ),
      );
      
      expect(gradientContainer, findsOneWidget);
      
      // Get the Container widget
      final container = tester.widget<Container>(gradientContainer);
      
      // Get the BoxDecoration
      final decoration = container.decoration as BoxDecoration;
      
      // Verify gradient colors
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors[0], testBlue);
      expect(gradient.colors[1], testGreen);
      expect(gradient.colors[2], testYellow);
      expect(gradient.colors[3], testPink);
    });
    
    testWidgets('creates BMI marker at correct position', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Find the Positioned widget (BMI marker)
      final positioned = find.byType(Positioned);
      expect(positioned, findsOneWidget);
      
      final widget = tester.widget<Positioned>(positioned);
      
      // Verify its properties
      expect(widget.left, isNotNull);
      expect(widget.top, 0);
      expect(widget.bottom, 0);
      
      // Check that the positioned widget contains a black indicator
      final positionedContainer = find.descendant(
        of: positioned,
        matching: find.byType(Container),
      );
      
      expect(positionedContainer, findsOneWidget);
      
      // Get the Container widget 
      final container = tester.widget<Container>(positionedContainer);
      expect(container.color, Colors.black);
    });

    group('displays correct BMI categories', () {
      testWidgets('for Underweight', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(bmiValue: "18.0"));
        expect(find.text('Underweight'), findsNWidgets(2)); // One in badge, one in categories
      });

      testWidgets('for Healthy', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(bmiValue: "22.5"));
        expect(find.text('Healthy'), findsNWidgets(2)); // One in badge, one in categories
      });

      testWidgets('for Overweight', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(bmiValue: "27.5"));
        expect(find.text('Overweight'), findsNWidgets(2)); // One in badge, one in categories
      });

      testWidgets('for Obese', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(bmiValue: "32.0"));
        expect(find.text('Obese'), findsNWidgets(2)); // One in badge, one in categories
      });
    });
  });
}