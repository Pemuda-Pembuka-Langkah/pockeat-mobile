// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/meal_details_tab.dart';

class MockCallbackFunction extends Mock {
  void call();
}

class MockDateFormatter extends Mock {
  String call(DateTime date);
}

class MockNutrientFormatter extends Mock {
  String call(String name);
}

void main() {
  // Test colors
  const Color primaryYellow = Color(0xFFFFE893);
  const Color primaryPink = Color(0xFFFF6B6B);
  const Color primaryGreen = Color(0xFF4ECDC4);

  // Mock callbacks
  late MockCallbackFunction mockOnSaveMeal;
  late MockCallbackFunction mockOnClearMeal;
  late MockCallbackFunction mockOnGoToCreateMeal;
  late MockDateFormatter mockFormatDate;
  late MockNutrientFormatter mockFormatNutrientName;

  // Test data
  late FoodAnalysisResult testMeal;

  setUp(() {
    mockOnSaveMeal = MockCallbackFunction();
    mockOnClearMeal = MockCallbackFunction();
    mockOnGoToCreateMeal = MockCallbackFunction();
    mockFormatDate = MockDateFormatter();
    mockFormatNutrientName = MockNutrientFormatter();

    // Just return the date with no "Created " prefix to match what the widget renders
    when(() => mockFormatDate.call(any())).thenReturn('2025-04-30');
    when(() => mockFormatNutrientName.call(any()))
        .thenReturn('Formatted Nutrient');

    testMeal = FoodAnalysisResult(
      id: 'meal_test_123',
      foodName: 'Test Meal',
      ingredients: [
        Ingredient(name: 'Apple', servings: 52),
        Ingredient(name: 'Banana', servings: 89)
      ],
      nutritionInfo: NutritionInfo(
          calories: 141,
          protein: 1.4,
          carbs: 37,
          fat: 0.5,
          sodium: 2,
          fiber: 5,
          sugar: 22.6,
          vitaminsAndMinerals: {'vitamin_c': 13.3, 'calcium': 6.0}),
      warnings: ['High sugar content'],
      additionalInformation: {'is_meal': true},
      timestamp: DateTime(2025, 4, 30),
    );
  });

  Widget buildTestableWidget({
    FoodAnalysisResult? meal,
    bool isLoading = false,
  }) {
    // Use a MaterialApp with a reasonable sized surface area
    return MaterialApp(
      home: Material(
        child: SizedBox(
          width: 800,
          height: 800,
          child: SingleChildScrollView(
            child: MealDetailsTab(
              currentMeal: meal,
              selectedFoods: meal != null
                  ? [
                      FoodAnalysisResult(
                        id: 'food_1',
                        foodName: 'Apple',
                        ingredients: [Ingredient(name: 'Apple', servings: 52)],
                        nutritionInfo: NutritionInfo(
                          calories: 52,
                          protein: 0.3,
                          carbs: 14,
                          fat: 0.2,
                          sodium: 1,
                          fiber: 2.4,
                          sugar: 10.4,
                        ),
                        warnings: [],
                      ),
                      FoodAnalysisResult(
                        id: 'food_2',
                        foodName: 'Banana',
                        ingredients: [Ingredient(name: 'Banana', servings: 89)],
                        nutritionInfo: NutritionInfo(
                          calories: 89,
                          protein: 1.1,
                          carbs: 23,
                          fat: 0.3,
                          sodium: 1,
                          fiber: 2.6,
                          sugar: 12.2,
                        ),
                        warnings: [],
                      )
                    ]
                  : [],
              isLoading: isLoading,
              onSaveMeal: mockOnSaveMeal,
              onClearMeal: mockOnClearMeal,
              onGoToCreateMeal: mockOnGoToCreateMeal,
              formatDate: mockFormatDate,
              formatNutrientName: mockFormatNutrientName,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      ),
    );
  }

  group('MealDetailsTab', () {
    testWidgets('should show empty state when no meal is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(meal: null));

      expect(find.text('No meal created yet'), findsOneWidget);
      expect(find.text('Select foods and create a meal first'), findsOneWidget);
      expect(find.text('Create New Meal'), findsOneWidget);
    });

    testWidgets(
        'should call onGoToCreateMeal when button is pressed in empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(meal: null));

      await tester.tap(find.text('Create New Meal'));
      await tester.pump();

      verify(mockOnGoToCreateMeal).called(1);
    });

    testWidgets('should display meal information when meal is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(meal: testMeal));

      // Check meal name
      expect(find.text('Test Meal'), findsOneWidget);

      // Check for the formatted date - the way it's displayed in the UI is:
      // "Created " + formatDate(date)
      expect(find.textContaining('2025-04-30'), findsOneWidget);

      // Check nutrition info (use finder with NutrientItem parent for specificity)
      expect(find.text('1.40g'), findsAtLeastNWidgets(1)); // Protein
      expect(find.text('37.00g'), findsAtLeastNWidgets(1)); // Carbs
      expect(find.text('0.50g'), findsAtLeastNWidgets(1)); // Fat

      // Check warnings
      expect(find.text('Nutrition Warnings'), findsOneWidget);
      expect(find.text('High sugar content'), findsOneWidget);

      // Check meal components
      expect(find.text('Foods in this Meal'), findsOneWidget);
      expect(find.text('Apple'), findsAtLeastNWidgets(1));
      expect(find.text('Banana'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show loading state when isLoading is true',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(meal: testMeal, isLoading: true));
      expect(find.text('Saving...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('should call onClearMeal when Start Over button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(meal: testMeal));

      // Find the Start Over text and tap it
      final startOverText = find.text('Start Over');
      expect(startOverText, findsOneWidget);

      // Ensure it's visible and tap it
      await tester.ensureVisible(startOverText);
      await tester.tap(startOverText);
      await tester.pumpAndSettle();

      verify(mockOnClearMeal).called(1);
    });

    testWidgets('should expand vitamins and minerals section when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(meal: testMeal));

      // Find the ExpansionTile with title 'Vitamins & Minerals'
      final expansionTileFinder = find.ancestor(
        of: find.text('Vitamins & Minerals'),
        matching: find.byType(ExpansionTile),
      );

      // Verify it exists
      expect(expansionTileFinder, findsOneWidget);

      // Scroll to make it visible
      await tester.dragUntilVisible(
        expansionTileFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );

      // Tap to expand
      await tester.tap(expansionTileFinder);
      await tester.pumpAndSettle();

      // Now check for the formatted nutrient tags (should be visible after expansion)
      final nutrientTextFinder = find.byWidgetPredicate((widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.contains('Formatted Nutrient'));

      // We should find at least one nutrient tag
      expect(nutrientTextFinder, findsAtLeastNWidgets(1));
    });
  });
}
