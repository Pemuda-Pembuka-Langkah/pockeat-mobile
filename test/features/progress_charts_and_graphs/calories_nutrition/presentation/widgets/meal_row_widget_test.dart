import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/meal_row_widget.dart';

void main() {
  group('MealRowWidget', () {
    // Test meal data
    final testMeal = Meal(
      name: 'Breakfast',
      calories: 450,
      totalCalories: 2000,
      time: '8:00 AM',
      color: const Color(0xFF4ECDC4), // Teal color
    );

    testWidgets('renders meal information correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: testMeal),
          ),
        ),
      );

      // Assert - verify text elements are displayed correctly
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('450 kcal'), findsOneWidget);
      expect(find.text('22%'), findsOneWidget); // 450/2000 = 0.225 = 22% when rounded down
    });

    testWidgets('applies correct text styles', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: testMeal),
          ),
        ),
      );

      // Assert - verify meal name styling
      final nameText = tester.widget<Text>(find.text('Breakfast'));
      expect(nameText.style?.fontSize, equals(14));
      expect(nameText.style?.color, equals(Colors.black87));
      expect(nameText.style?.fontWeight, equals(FontWeight.w500));

      // Verify time styling
      final timeText = tester.widget<Text>(find.text('8:00 AM'));
      expect(timeText.style?.fontSize, equals(12));
      expect(timeText.style?.color, equals(Colors.black54));

      // Verify calories styling
      final caloriesText = tester.widget<Text>(find.text('450 kcal'));
      expect(caloriesText.style?.fontSize, equals(14));
      expect(caloriesText.style?.fontWeight, equals(FontWeight.w500));
      expect(caloriesText.style?.color, equals(testMeal.color));

      // Verify percentage styling
      final percentageText = tester.widget<Text>(find.text('22%'));
      expect(percentageText.style?.fontSize, equals(12));
      expect(percentageText.style?.color, equals(Colors.black54));
    });

    testWidgets('creates correct layout structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: testMeal),
          ),
        ),
      );

      // Verify the Column is the root widget
      expect(find.byType(Column), findsOneWidget);

      // Verify there are three Rows
      expect(find.byType(Row), findsNWidgets(3)); // Main Row, nested Row for name/time, and progress Row

      // Use byWidgetPredicate to find SizedBox with height 8
      final sizedBoxWithHeight8 = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 8
      );
      expect(sizedBoxWithHeight8, findsOneWidget);

      // Use byWidgetPredicate to find SizedBoxes with width 8
      final sizedBoxWithWidth8 = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 8
      );
      expect(sizedBoxWithWidth8, findsNWidgets(2)); // One between name/time, one between progress/percentage
    });

    testWidgets('renders LinearProgressIndicator with correct properties', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: testMeal),
          ),
        ),
      );

      // Verify LinearProgressIndicator exists and has correct properties
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );

      expect(progressIndicator.value, equals(testMeal.percentage)); // 450/2000 = 0.225
      expect(progressIndicator.backgroundColor, equals(testMeal.color.withOpacity(0.1)));
      
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(testMeal.color));
      
      expect(progressIndicator.minHeight, equals(4));
    });

    testWidgets('wraps LinearProgressIndicator in ClipRRect with correct border radius', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: testMeal),
          ),
        ),
      );

      // Verify ClipRRect exists and has correct properties
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, equals(BorderRadius.circular(4)));
    });

    testWidgets('handles different meal percentages correctly', (WidgetTester tester) async {
      // Test with different meal percentages
      final smallMeal = Meal(
        name: 'Snack',
        calories: 100,
        totalCalories: 2000,
        time: '3:00 PM',
        color: Colors.orange,
      );

      final largeMeal = Meal(
        name: 'Dinner',
        calories: 800,
        totalCalories: 2000,
        time: '7:00 PM',
        color: Colors.purple,
      );

      // Render small meal
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: smallMeal),
          ),
        ),
      );

      // Verify the percentage is displayed correctly
      expect(find.text('5%'), findsOneWidget); // 100/2000 = 0.05 = 5%

      // Verify progress indicator value
      var progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(smallMeal.percentage));

      // Render large meal
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: largeMeal),
          ),
        ),
      );
      await tester.pump();

      // Verify the percentage is displayed correctly
      expect(find.text('40%'), findsOneWidget); // 800/2000 = 0.4 = 40%

      // Verify progress indicator value
      progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(largeMeal.percentage));
    });

    testWidgets('handles extremely large percentage values correctly', (WidgetTester tester) async {
      // Test with a meal that exceeds the total calories
      final excessiveMeal = Meal(
        name: 'Feast',
        calories: 2500,
        totalCalories: 2000,
        time: '6:00 PM',
        color: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: excessiveMeal),
          ),
        ),
      );

      // Verify the percentage is displayed correctly
      expect(find.text('125%'), findsOneWidget); // 2500/2000 = 1.25 = 125%

      // Verify progress indicator value
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(excessiveMeal.percentage)); // Should be 1.25
    });

    testWidgets('handles zero percentage values correctly', (WidgetTester tester) async {
      // Test with a meal that has zero calories
      final zeroMeal = Meal(
        name: 'Water',
        calories: 0,
        totalCalories: 2000,
        time: '9:00 AM',
        color: Colors.blue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealRowWidget(meal: zeroMeal),
          ),
        ),
      );

      // Verify the percentage is displayed correctly
      expect(find.text('0%'), findsOneWidget); // 0/2000 = 0 = 0%

      // Verify progress indicator value
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(zeroMeal.percentage)); // Should be 0.0
    });
  });
}