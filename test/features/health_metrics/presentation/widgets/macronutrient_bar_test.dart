import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/macronutrient_bar.dart';

void main() {
  group('MacronutrientBar', () {
    final Map<String, double> testMacros = {
      'Protein': 120,
      'Carbs': 200,
      'Fat': 80,
    };
    
    final Color defaultColor = Colors.green;
    final Color textDarkColor = Colors.black87;

    testWidgets('should render all macronutrients', (WidgetTester tester) async {
      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacronutrientBar(
              macros: testMacros,
              defaultColor: defaultColor,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify macros are displayed
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
      
      // Verify gram values are displayed
      expect(find.text('120 g'), findsOneWidget);
      expect(find.text('200 g'), findsOneWidget);
      expect(find.text('80 g'), findsOneWidget);
    });

    testWidgets('should use default colors when no custom colors provided', (WidgetTester tester) async {
      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacronutrientBar(
              macros: testMacros,
              defaultColor: defaultColor,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - check for colored circles
      final circles = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(MacronutrientBar),
          matching: find.byWidgetPredicate((widget) => 
            widget is Container && 
            widget.decoration is BoxDecoration && 
            (widget.decoration as BoxDecoration).shape == BoxShape.circle
          ),
        ),
      );
      
      // Verify we have 3 colored circles for the macros
      expect(circles.length, equals(3));
      
      // Note: We can't directly access container.width or container.height
      // as these are constructor parameters, not accessible properties
    });

    testWidgets('should handle custom colors', (WidgetTester tester) async {
      // Arrange - custom colors for each macro
      final Map<String, Color> customColors = {
        'Protein': Colors.blue,
        'Carbs': Colors.red,
        'Fat': Colors.orange,
      };

      // Act - build widget with custom colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacronutrientBar(
              macros: testMacros,
              defaultColor: defaultColor,
              textDarkColor: textDarkColor,
              customColors: customColors,
            ),
          ),
        ),
      );

      // Assert - verify macros are displayed
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
    });

    testWidgets('should handle empty macros', (WidgetTester tester) async {
      // Act - build widget with empty macros
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacronutrientBar(
              macros: {},
              defaultColor: defaultColor,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify no items are displayed
      expect(find.text('Protein'), findsNothing);
      expect(find.text('Carbs'), findsNothing);
      expect(find.text('Fat'), findsNothing);
    });

    testWidgets('should handle zero values gracefully', (WidgetTester tester) async {
      // Arrange - macros with zero values
      final Map<String, double> zeroMacros = {
        'Protein': 0,
        'Carbs': 0,
        'Fat': 0,
      };

      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacronutrientBar(
              macros: zeroMacros,
              defaultColor: defaultColor,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify macros names are displayed
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
      
      // Verify all gram values show 0
      expect(find.text('0 g'), findsNWidgets(3));
      
      // Check that progress bars have zero width for 0 values
      // (Actually they'll have a small width because of the container, but the colored part will be minimal)
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacronutrientBar(
              macros: testMacros,
              defaultColor: defaultColor,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify widget hierarchy
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsAtLeastNWidgets(3)); // At least one Row per macro
      expect(find.byType(Stack), findsAtLeastNWidgets(3)); // One Stack per macro for the progress bar
      
      // Each macro should have two containers for the progress bars (background and filled)
      final progressContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(Stack),
          matching: find.byType(Container),
        ),
      );
      
      // Should be at least 6 containers (2 per macro x 3 macros)
      expect(progressContainers.length, greaterThanOrEqualTo(6));
    });
  });
}
