import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/nutrition_stat_widget.dart';

void main() {
  group('NutritionStatWidget', () {
    // Test data
    final consumedStat = NutritionStat(
      label: 'Consumed',
      value: '1,850',
      color: const Color(0xFFFF6B6B), // Pink color
    );

    final burnedStat = NutritionStat(
      label: 'Burned',
      value: '450',
      color: const Color(0xFF4ECDC4), // Green color
    );

    testWidgets('renders label correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: consumedStat),
          ),
        ),
      );

      // Assert
      expect(find.text('Consumed'), findsOneWidget);
    });

    testWidgets('renders value correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: consumedStat),
          ),
        ),
      );

      // Assert
      expect(find.text('1,850'), findsOneWidget);
    });

    testWidgets('renders kcal unit text', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: consumedStat),
          ),
        ),
      );

      // Assert
      expect(find.text('kcal'), findsOneWidget);
    });

    testWidgets('applies correct text styles for label', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: consumedStat),
          ),
        ),
      );

      // Find label text
      final labelText = tester.widget<Text>(find.text('Consumed'));
      
      // Assert label styling
      expect(labelText.style?.color, equals(Colors.black54));
      expect(labelText.style?.fontSize, equals(14));
    });

    testWidgets('applies correct text styles for value', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: consumedStat),
          ),
        ),
      );

      // Find value text
      final valueText = tester.widget<Text>(find.text('1,850'));
      
      // Assert value styling
      expect(valueText.style?.color, equals(consumedStat.color));
      expect(valueText.style?.fontSize, equals(20));
      expect(valueText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('applies correct text styles for unit', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: consumedStat),
          ),
        ),
      );

      // Find unit text
      final unitText = tester.widget<Text>(find.text('kcal'));
      
      // Assert unit styling
      expect(unitText.style?.color, equals(Colors.black54));
      expect(unitText.style?.fontSize, equals(12));
    });

    testWidgets('has correct vertical layout with spacing', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: consumedStat),
          ),
        ),
      );

      // Find the SizedBox for spacing
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      
      // Assert spacing
      expect(sizedBox.height, equals(4));
    });

    testWidgets('includes minus sign for "Burned" label', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: burnedStat),
          ),
        ),
      );

      // Assert
      expect(find.text('-'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);
    });

    testWidgets('does not include minus sign for non-"Burned" label', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: consumedStat),
          ),
        ),
      );

      // Assert
      expect(find.text('-'), findsNothing);
      expect(find.text('1,850'), findsOneWidget);
    });

    testWidgets('renders Row containing value with correct children', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: burnedStat),
          ),
        ),
      );

      // Find the row containing the value
      final rowFinder = find.ancestor(
        of: find.text('450'),
        matching: find.byType(Row),
      );
      
      expect(rowFinder, findsOneWidget);
      
      // Verify row contains both minus sign and value for "Burned"
      final row = tester.widget<Row>(rowFinder);
      expect(row.children.length, equals(2)); // Minus sign and value text
    });

    testWidgets('renders with different stat values', (WidgetTester tester) async {
      // Test with a different stat
      final netStat = NutritionStat(
        label: 'Net',
        value: '1,400',
        color: const Color(0xFFFF6B6B), // Pink color
      );

      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionStatWidget(stat: netStat),
          ),
        ),
      );

      // Assert
      expect(find.text('Net'), findsOneWidget);
      expect(find.text('1,400'), findsOneWidget);
      expect(find.text('-'), findsNothing); // No minus sign for "Net"
    });
  });
}