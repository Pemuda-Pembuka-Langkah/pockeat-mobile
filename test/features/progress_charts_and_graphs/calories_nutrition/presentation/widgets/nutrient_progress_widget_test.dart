import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/macro_card_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/nutrient_progress_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/nutrient_row_widget.dart';

void main() {
  group('NutrientProgressWidget', () {
    // Test data
    final macroNutrients = [
      MacroNutrient(
        label: 'Protein',
        percentage: 25,
        detail: '75g/120g',
        color: const Color(0xFFFF6B6B), // Pink color
      ),
      MacroNutrient(
        label: 'Carbs',
        percentage: 55,
        detail: '138g/250g',
        color: const Color(0xFF4ECDC4), // Green color
      ),
      MacroNutrient(
        label: 'Fat',
        percentage: 20,
        detail: '32g/65g',
        color: const Color(0xFFFFB946), // Yellow color
      ),
    ];

    final microNutrients = [
      MicroNutrient(
        nutrient: 'Fiber',
        current: '12g',
        target: '25g',
        progress: 0.48,
        color: const Color(0xFF4ECDC4), // Green color
      ),
      MicroNutrient(
        nutrient: 'Sugar',
        current: '18g',
        target: '30g',
        progress: 0.6,
        color: const Color(0xFFFF6B6B), // Pink color
      ),
      MicroNutrient(
        nutrient: 'Sodium',
        current: '1200mg',
        target: '2300mg',
        progress: 0.52,
        color: const Color(0xFFFFB946), // Yellow color
      ),
    ];

    testWidgets('renders the title correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: macroNutrients,
              microNutrients: microNutrients,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Nutrient Balance'), findsOneWidget);
      
      // Verify styling of the title
      final titleFinder = find.text('Nutrient Balance');
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.fontSize, equals(18));
      expect(titleWidget.style?.fontWeight, equals(FontWeight.w600));
      expect(titleWidget.style?.color, equals(Colors.black87));
    });

    testWidgets('renders macro nutrients correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: macroNutrients,
              microNutrients: microNutrients,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MacroCardWidget), findsNWidgets(3));
      
      // Verify each macro nutrient is displayed
      for (final macro in macroNutrients) {
        expect(find.text(macro.label), findsOneWidget);
      }
    });

    testWidgets('renders macro nutrients with correct spacing', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: macroNutrients,
              microNutrients: microNutrients,
            ),
          ),
        ),
      );

      // Assert
      // Find all horizontal SizedBox widgets with width 12
      final widthSizedBoxes = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 12,
      );
      
      // There should be 2 for spacing between 3 macro cards
      expect(widthSizedBoxes, findsNWidgets(2));
    });

    testWidgets('renders micro nutrients correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: macroNutrients,
              microNutrients: microNutrients,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(NutrientRowWidget), findsNWidgets(3));
      
      // Verify that each micro nutrient is represented
      for (var micro in microNutrients) {
        expect(find.text(micro.nutrient), findsOneWidget);
      }
    });

    testWidgets('has container with correct styling for micro nutrients', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: macroNutrients,
              microNutrients: microNutrients,
            ),
          ),
        ),
      );

      // Find the specific container that wraps micro nutrients
      // First find all containers with a Column child
      final allContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(NutrientProgressWidget),
          matching: find.byType(Container),
        ),
      ).toList();
      
      // Verify there are containers
      expect(allContainers.isNotEmpty, isTrue);
      
      // Find the container that contains NutrientRowWidgets
      // This should be the one wrapping micro nutrients
      Container microContainer = allContainers.firstWhere(
        (container) {
          final child = container.child;
          if (child is Column) {
            // Look for a Column that has NutrientRowWidget children
            return child.children.isNotEmpty && 
                   (child.children.first is NutrientRowWidget || 
                    child.children.any((widget) => widget is NutrientRowWidget));
          }
          return false;
        },
        orElse: () => allContainers.last, // fallback to the last one
      );
      
      final decoration = microContainer.decoration as BoxDecoration;
      
      // Verify container decoration
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
      
      // Verify box shadow
      expect(decoration.boxShadow?.length, equals(1));
      final shadow = decoration.boxShadow![0];
      expect(shadow.color.alpha, equals(Colors.black.withOpacity(0.05).alpha));
      expect(shadow.blurRadius, equals(10));
      expect(shadow.offset, equals(const Offset(0, 2)));
    });

    testWidgets('has correct spacing between sections', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: macroNutrients,
              microNutrients: microNutrients,
            ),
          ),
        ),
      );

      // Find specific SizedBox widgets in the NutrientProgressWidget
      final rootColumn = tester.widget<Column>(
        find.descendant(
          of: find.byType(NutrientProgressWidget),
          matching: find.byType(Column),
        ).first,
      );
      
      // Get the direct children of the root Column that are SizedBoxes
      final rootSizedBoxes = rootColumn.children.whereType<SizedBox>().toList();
      
      // We should find 2 SizedBoxes in the root column's direct children
      expect(rootSizedBoxes.length, equals(2));
      
      // Verify their heights
      expect(rootSizedBoxes[0].height, equals(16)); // After title
      expect(rootSizedBoxes[1].height, equals(20)); // Between macro and micro sections
    });

    testWidgets('handles empty macro nutrients list', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: [],
              microNutrients: microNutrients,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MacroCardWidget), findsNothing);
      expect(find.byType(NutrientRowWidget), findsNWidgets(3)); // Micro nutrients should still appear
    });

    testWidgets('handles empty micro nutrients list', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: macroNutrients,
              microNutrients: [],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MacroCardWidget), findsNWidgets(3)); // Macro nutrients should still appear
      expect(find.byType(NutrientRowWidget), findsNothing);
      
      // Find all Containers in the widget
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(NutrientProgressWidget),
          matching: find.byType(Container),
        ),
      ).toList();
      
      // Find a container with an empty Column
      bool foundEmptyContainer = false;
      for (var container in containers) {
        if (container.child is Column) {
          final column = container.child as Column;
          if (column.children.isEmpty) {
            foundEmptyContainer = true;
            break;
          }
        }
      }
      
      expect(foundEmptyContainer, isTrue, reason: 'Should find a container with an empty Column');
    });

    testWidgets('handles empty macro and micro nutrients lists', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: [],
              microNutrients: [],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MacroCardWidget), findsNothing);
      expect(find.byType(NutrientRowWidget), findsNothing);
      
      // Title should still be there
      expect(find.text('Nutrient Balance'), findsOneWidget);
    });

    testWidgets('renders single macro nutrient without spacing', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutrientProgressWidget(
              macroNutrients: [macroNutrients[0]], // Just one macro nutrient
              microNutrients: microNutrients,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MacroCardWidget), findsOneWidget);
      
      // There should be no width SizedBoxes since there's only one macro card
      final widthSizedBoxes = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 12,
      );
      expect(widthSizedBoxes, findsNothing);
    });
  });
}