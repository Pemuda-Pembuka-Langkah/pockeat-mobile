import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/nutrient_row_widget.dart';

void main() {
  group('NutrientRowWidget', () {
    // Sample test data
    final testNutrient = MicroNutrient(
      nutrient: 'Fiber',
      current: '12g',
      target: '25g',
      progress: 0.48,
      color: const Color(0xFF4ECDC4), // Green color
    );

    testWidgets('renders nutrient information correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: testNutrient),
          ),
        ),
      );

      // Assert - verify text elements are displayed correctly
      expect(find.text('Fiber'), findsOneWidget);
      expect(find.text('12g / 25g'), findsOneWidget);
    });

    testWidgets('applies correct text styles', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: testNutrient),
          ),
        ),
      );

      // Verify nutrient name styling
      final nameText = tester.widget<Text>(find.text('Fiber'));
      expect(nameText.style?.fontSize, equals(14));
      expect(nameText.style?.color, equals(Colors.black87));

      // Verify value styling
      final valueText = tester.widget<Text>(find.text('12g / 25g'));
      expect(valueText.style?.fontSize, equals(14));
      expect(valueText.style?.fontWeight, equals(FontWeight.w500));
      expect(valueText.style?.color, equals(Colors.black54));
    });

    testWidgets('creates container with correct padding and decoration', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: testNutrient),
          ),
        ),
      );

      // Find the container
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      // Verify padding
      expect(container.padding, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));

      // Verify decoration
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isA<Border>());
      
      final border = decoration.border as Border;
      expect(border.bottom, isA<BorderSide>());
      expect(border.bottom.color, equals(Colors.black12));
      expect(border.bottom.width, equals(1.0)); // Default width
    });

    testWidgets('creates layout with correct row structure and flex factors', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: testNutrient),
          ),
        ),
      );

      // Find all expanded widgets
      final expandedWidgets = tester.widgetList<Expanded>(find.byType(Expanded)).toList();
      
      // Verify there are 3 Expanded widgets with correct flex factors
      expect(expandedWidgets.length, equals(3));
      expect(expandedWidgets[0].flex, equals(2)); // Nutrient name
      expect(expandedWidgets[1].flex, equals(2)); // Current/target
      expect(expandedWidgets[2].flex, equals(3)); // Progress indicator
    });

    testWidgets('renders LinearProgressIndicator with correct properties', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: testNutrient),
          ),
        ),
      );

      // Find the LinearProgressIndicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );

      // Verify properties
      expect(progressIndicator.value, equals(testNutrient.progress));
      expect(progressIndicator.backgroundColor, equals(testNutrient.color.withOpacity(0.1)));
      
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(testNutrient.color));
      
      expect(progressIndicator.minHeight, equals(4));
    });

    testWidgets('wraps LinearProgressIndicator in ClipRRect with correct border radius', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: testNutrient),
          ),
        ),
      );

      // Find the ClipRRect
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      
      // Verify border radius
      expect(clipRRect.borderRadius, equals(BorderRadius.circular(4)));
    });

    testWidgets('handles different progress values correctly', (WidgetTester tester) async {
      // Test with different progress values
      final lowProgressNutrient = MicroNutrient(
        nutrient: 'Vitamin C',
        current: '30mg',
        target: '90mg',
        progress: 0.33,
        color: Colors.orange,
      );

      final highProgressNutrient = MicroNutrient(
        nutrient: 'Iron',
        current: '15mg',
        target: '18mg',
        progress: 0.83,
        color: Colors.purple,
      );

      final completeProgressNutrient = MicroNutrient(
        nutrient: 'Calcium',
        current: '1000mg',
        target: '1000mg',
        progress: 1.0,
        color: Colors.blue,
      );

      // Test low progress
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: lowProgressNutrient),
          ),
        ),
      );

      var progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(0.33));

      // Test high progress
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: highProgressNutrient),
          ),
        ),
      );
      await tester.pump();

      progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(0.83));

      // Test complete progress
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: completeProgressNutrient),
          ),
        ),
      );
      await tester.pump();

      progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(1.0));
    });

    testWidgets('handles different nutrient formats correctly', (WidgetTester tester) async {
      // Test with different nutrient formats
      final decimalNutrient = MicroNutrient(
        nutrient: 'Zinc',
        current: '8.5mg',
        target: '11mg',
        progress: 0.77,
        color: Colors.teal,
      );

      // Test decimal values
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientRowWidget(nutrient: decimalNutrient),
          ),
        ),
      );

      expect(find.text('Zinc'), findsOneWidget);
      expect(find.text('8.5mg / 11mg'), findsOneWidget);
    });
  });
}