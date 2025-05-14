// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/presentation/widgets/saved_meal_card.dart';

void main() {
  late SavedMeal testSavedMeal;
  final nutritionInfo = NutritionInfo(
    calories: 250,
    protein: 20,
    carbs: 30,
    fat: 10,
    sodium: 150,
    fiber: 5,
    sugar: 8,
    saturatedFat: 3,
  );

  final foodAnalysis = FoodAnalysisResult(
    id: 'test-analysis-id',
    foodName: 'Test Food',
    ingredients: [
      Ingredient(name: 'Ingredient 1', servings: 1.0),
      Ingredient(name: 'Ingredient 2', servings: 2.0),
      Ingredient(name: 'Ingredient 3', servings: 1.5),
      Ingredient(name: 'Ingredient 4', servings: 0.5),
    ],
    nutritionInfo: nutritionInfo,
    warnings: ['High sodium', 'High sugar'],
    healthScore: 7.5,
  );

  setUp(() {
    testSavedMeal = SavedMeal(
      id: 'test-id',
      userId: 'user123',
      name: 'Test Meal Name',
      foodAnalysis: foodAnalysis,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  testWidgets('SavedMealCard displays meal name and food name',
      (WidgetTester tester) async {
    // Arrange - Create a widget test with required parameters
    bool tapped = false;

    // Act - Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: testSavedMeal,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Assert - Check that the meal name and food name are displayed
    expect(find.text('Test Meal Name'), findsOneWidget);
    expect(find.text('Test Food'), findsOneWidget);
  });

  testWidgets('SavedMealCard displays nutrition indicators',
      (WidgetTester tester) async {
    // Arrange - Create a widget test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: testSavedMeal,
            onTap: () {},
          ),
        ),
      ),
    );

    // Assert - Check that the nutrition indicators are displayed
    expect(find.text('P: 20g'), findsOneWidget); // Protein
    expect(find.text('C: 30g'), findsOneWidget); // Carbs
    expect(find.text('F: 10g'), findsOneWidget); // Fat
  });
  testWidgets('SavedMealCard displays calories and health score',
      (WidgetTester tester) async {
    // Arrange - Create a widget test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: testSavedMeal,
            onTap: () {},
          ),
        ),
      ),
    );

    // Assert - Check that calories and health score are displayed
    expect(find.text('Health: 7.5'), findsOneWidget); // Health score with decimal
    expect(find.text('250 cal'), findsOneWidget); // Calories
  });
  testWidgets('SavedMealCard displays icon with star badge',
      (WidgetTester tester) async {
    // Arrange - Create a widget test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: testSavedMeal,
            onTap: () {},
          ),
        ),
      ),
    );

    // Assert - Check that the icon and star badge are displayed
    expect(find.byIcon(Icons.fastfood), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('SavedMealCard handles tap event', (WidgetTester tester) async {
    // Arrange - Create a widget test with tap tracking
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: testSavedMeal,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Act - Tap the card
    await tester.tap(find.byType(InkWell));
    await tester.pump();

    // Assert - Check that the tap event was triggered
    expect(tapped, isTrue);
  });
  testWidgets('SavedMealCard displays date in proper format',
      (WidgetTester tester) async {
    // Arrange - Create a saved meal with a fixed date
    final fixedDateMeal = SavedMeal(
      id: 'test-id',
      userId: 'user123',
      name: 'Test Meal Name',
      foodAnalysis: foodAnalysis,
      createdAt: DateTime(2023, 5, 15), // May 15, 2023
      updatedAt: DateTime(2023, 5, 15),
    );

    // Act - Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: fixedDateMeal,
            onTap: () {},
          ),
        ),
      ),
    );

    // Assert - Check that date is formatted correctly
    expect(find.text('15 May'), findsOneWidget);
  });
}
