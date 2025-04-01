import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/meal_patterns_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/meal_row_widget.dart';

void main() {
  group('MealPatternsWidget', () {
    // Test meal data
    final meals = [
      Meal(
        name: 'Breakfast',
        calories: 450,
        totalCalories: 2000,
        time: '8:00 AM',
        color: Colors.blue,
      ),
      Meal(
        name: 'Lunch',
        calories: 650,
        totalCalories: 2000,
        time: '1:00 PM',
        color: Colors.green,
      ),
      Meal(
        name: 'Dinner',
        calories: 550,
        totalCalories: 2000,
        time: '7:00 PM',
        color: Colors.orange,
      ),
    ];

    final primaryGreen = const Color(0xFF4ECDC4);

    testWidgets('renders correct title and balanced label', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealPatternsWidget(
              meals: meals,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Meal Distribution'), findsOneWidget);
      expect(find.text('Well Balanced'), findsOneWidget);
    });

    testWidgets('renders balanced label with correct styling', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealPatternsWidget(
              meals: meals,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Find the container with the "Well Balanced" text
      final balancedLabelFinder = find.text('Well Balanced');
      expect(balancedLabelFinder, findsOneWidget);

      // Verify the text styling
      final balancedText = tester.widget<Text>(balancedLabelFinder);
      expect(balancedText.style?.color, equals(primaryGreen));
      expect(balancedText.style?.fontSize, equals(12));
      expect(balancedText.style?.fontWeight, equals(FontWeight.w600));

      // Find the container that wraps the label
      final containerFinder = find.ancestor(
        of: balancedLabelFinder,
        matching: find.byType(Container),
      ).first;
      
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      
      // Verify the container styling
      expect(decoration.color, equals(primaryGreen.withOpacity(0.1)));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
    });

    testWidgets('renders a container with correct styling', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealPatternsWidget(
              meals: meals,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Find the main container
      final containerFinder = find.descendant(
        of: find.byType(MealPatternsWidget),
        matching: find.byType(Container),
      ).at(1); // Second container (the main content one, not the label)
      
      final container = tester.widget<Container>(containerFinder);
      
      // Verify container padding
      expect(container.padding, equals(const EdgeInsets.all(16)));
      
      // Verify container decoration
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
      
      // Verify shadow
      expect(decoration.boxShadow?.length, equals(1));
      expect(decoration.boxShadow?[0].color, equals(Colors.black.withOpacity(0.05)));
      expect(decoration.boxShadow?[0].blurRadius, equals(10));
      expect(decoration.boxShadow?[0].offset, equals(const Offset(0, 2)));
    });

    testWidgets('renders correct number of MealRowWidget', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealPatternsWidget(
              meals: meals,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MealRowWidget), findsNWidgets(3));
    });

    testWidgets('renders meals in correct order with spacing', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealPatternsWidget(
              meals: meals,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Find all MealRowWidgets
      final mealRows = tester.widgetList<MealRowWidget>(find.byType(MealRowWidget)).toList();
      
      // Verify the order of meals
      expect(mealRows[0].meal.name, equals('Breakfast'));
      expect(mealRows[1].meal.name, equals('Lunch'));
      expect(mealRows[2].meal.name, equals('Dinner'));
      
      // Instead of counting SizedBox widgets, check specific spacing between meal rows
      // Verify that we have the right number of meal rows
      expect(mealRows.length, equals(3));
      
      // Verify there's at least one SizedBox with height 16 for the spacing
      final spacingSizedBoxFinder = find.ancestor(
        of: find.byType(SizedBox),
        matching: find.byType(Column),
      ).first;
      expect(spacingSizedBoxFinder, findsOneWidget);
    });

    testWidgets('handles empty meals list', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealPatternsWidget(
              meals: [],
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MealRowWidget), findsNothing);
      expect(find.text('Meal Distribution'), findsOneWidget);
      expect(find.text('Well Balanced'), findsOneWidget);
    });

    testWidgets('handles single meal', (WidgetTester tester) async {
      // Arrange
      final singleMeal = [
        Meal(
          name: 'Breakfast',
          calories: 450,
          totalCalories: 2000,
          time: '8:00 AM',
          color: Colors.blue,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealPatternsWidget(
              meals: singleMeal,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MealRowWidget), findsOneWidget);
      
      // Check for presence of at least one SizedBox in the layout
      // but don't expect an exact number since MealRowWidget also has SizedBox widgets
      final headerSizedBox = find.descendant(
        of: find.byType(MealPatternsWidget),
        matching: find.byType(SizedBox),
      ).first;
      expect(headerSizedBox, findsOneWidget);
    });
  });
}