import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/bmi_section.dart';

void main() {
  // Test colors
  final Color testBlue = Colors.blue;
  final Color testGreen = Colors.green;
  final Color testYellow = Colors.yellow;
  final Color testPink = Colors.pink;
  
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BMISection(
          primaryBlue: testBlue,
          primaryGreen: testGreen,
          primaryYellow: testYellow,
          primaryPink: testPink,
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
      
      // Another way to verify is to check if the widget tree matches
      // what we expect from the BMI section's build method by finding
      // a black container with width 3 as defined in the source code
      final markerContainer = find.descendant(
        of: positioned,
        matching: find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.color == Colors.black
        ),
      );
      expect(markerContainer, findsOneWidget);
    });
    
    testWidgets('_buildBMICategory creates correct structure', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Find the child rows created by _buildBMICategory
      // We need to find them inside the main row that has MainAxisAlignment.spaceBetween
      final mainRow = find.byWidgetPredicate((widget) => 
        widget is Row && 
        widget.mainAxisAlignment == MainAxisAlignment.spaceBetween
      );
      
      // Get the main row widget
      final mainRowWidget = tester.widget<Row>(mainRow);
      
      // Check that the main row has 4 children (each created by _buildBMICategory)
      expect(mainRowWidget.children.length, 4);
      
      // Verify that each child is a Row widget
      for (var i = 0; i < mainRowWidget.children.length; i++) {
        expect(mainRowWidget.children[i], isA<Row>());
        
        // Get the category row
        final categoryRow = mainRowWidget.children[i] as Row;
        
        // Verify structure: Container + SizedBox + Text
        expect(categoryRow.children.length, 3);
        expect(categoryRow.children[0], isA<Container>());
        expect(categoryRow.children[1], isA<SizedBox>());
        expect(categoryRow.children[2], isA<Text>());
        
        // Check container is a circle
        final container = categoryRow.children[0] as Container;
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, BoxShape.circle);
        
        // Verify color is one of our test colors
        expect(
          [testBlue, testGreen, testYellow, testPink].contains(decoration.color),
          isTrue,
          reason: 'Category indicator ${i+1} should use one of the test colors'
        );
      }
    });
  });
}