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
    expect(
        find.text('Health: 7.5'), findsOneWidget); // Health score with decimal
    expect(find.text('250 cal'), findsOneWidget); // Calories
  });

  testWidgets(
      'SavedMealCard displays correct health score color for high score',
      (WidgetTester tester) async {
    // Create saved meal with high health score (>=7)
    final highScoreMeal = SavedMeal(
      id: 'high-score-id',
      userId: 'user123',
      name: 'High Score Meal',
      foodAnalysis: FoodAnalysisResult(
        id: 'high-analysis-id',
        foodName: 'High Score Food',
        ingredients: [],
        nutritionInfo: nutritionInfo,
        warnings: [],
        healthScore: 8.5, // High score
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: highScoreMeal,
            onTap: () {},
          ),
        ),
      ),
    );

    // Find the health score text
    final healthScoreWidget =
        tester.widget<Text>(find.textContaining('Health: 8.5'));

    // Check that the color is green (primaryGreen = Color(0xFF4ECDC4))
    expect((healthScoreWidget.style?.color), const Color(0xFF4ECDC4));
  });

  testWidgets(
      'SavedMealCard displays correct health score color for medium score',
      (WidgetTester tester) async {
    // Create saved meal with medium health score (>=4 and <7)
    final mediumScoreMeal = SavedMeal(
      id: 'medium-score-id',
      userId: 'user123',
      name: 'Medium Score Meal',
      foodAnalysis: FoodAnalysisResult(
        id: 'medium-analysis-id',
        foodName: 'Medium Score Food',
        ingredients: [],
        nutritionInfo: nutritionInfo,
        warnings: [],
        healthScore: 5.5, // Medium score
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: mediumScoreMeal,
            onTap: () {},
          ),
        ),
      ),
    );

    // Find the health score text
    final healthScoreWidget =
        tester.widget<Text>(find.textContaining('Health: 5.5'));

    // Check that the color is orange (primaryOrange = Color(0xFFFF9800))
    expect((healthScoreWidget.style?.color), const Color(0xFFFF9800));
  });

  testWidgets('SavedMealCard displays correct health score color for low score',
      (WidgetTester tester) async {
    // Create saved meal with low health score (<4)
    final lowScoreMeal = SavedMeal(
      id: 'low-score-id',
      userId: 'user123',
      name: 'Low Score Meal',
      foodAnalysis: FoodAnalysisResult(
        id: 'low-analysis-id',
        foodName: 'Low Score Food',
        ingredients: [],
        nutritionInfo: nutritionInfo,
        warnings: [],
        healthScore: 2.5, // Low score
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedMealCard(
            savedMeal: lowScoreMeal,
            onTap: () {},
          ),
        ),
      ),
    );

    // Find the health score text
    final healthScoreWidget =
        tester.widget<Text>(find.textContaining('Health: 2.5'));

    // Check that the color is pink (primaryPink = Color(0xFFFF6B6B))
    expect((healthScoreWidget.style?.color), const Color(0xFFFF6B6B));
  });
  group('Health score coloring', () {
    testWidgets('uses correct color for different health score ranges',
        (WidgetTester tester) async {
      // Test high score (>=7) - should be green
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SavedMealCard(
              savedMeal: SavedMeal(
                id: 'test-id-high',
                userId: 'user123',
                name: 'High Score Meal',
                foodAnalysis: FoodAnalysisResult(
                  id: 'test-analysis-id-high',
                  foodName: 'Test Food High',
                  ingredients: [],
                  nutritionInfo: nutritionInfo,
                  warnings: [],
                  healthScore: 7.0, // Boundary case
                ),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the health score text and verify green color
      final highScoreText = find.text('Health: 7.0');
      expect(highScoreText, findsOneWidget);

      // Find the container that holds the health score
      final highScoreContainer = tester.widget<Container>(find
          .ancestor(
            of: highScoreText,
            matching: find.byType(Container),
          )
          .first);

      // Check decoration color (primaryGreen = 0xFF4ECDC4)
      final highScoreDecoration =
          highScoreContainer.decoration as BoxDecoration;
      expect((highScoreDecoration.color as Color).value,
          const Color(0xFF4ECDC4).withOpacity(0.1).value);

      // Now test medium score (>=4 and <7) - should be orange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SavedMealCard(
              savedMeal: SavedMeal(
                id: 'test-id-medium',
                userId: 'user123',
                name: 'Medium Score Meal',
                foodAnalysis: FoodAnalysisResult(
                  id: 'test-analysis-id-medium',
                  foodName: 'Test Food Medium',
                  ingredients: [],
                  nutritionInfo: nutritionInfo,
                  warnings: [],
                  healthScore: 5.0, // Middle of medium range
                ),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the health score text and verify orange color
      final mediumScoreText = find.text('Health: 5.0');
      expect(mediumScoreText, findsOneWidget);

      // Find the container that holds the health score
      final mediumScoreContainer = tester.widget<Container>(find
          .ancestor(
            of: mediumScoreText,
            matching: find.byType(Container),
          )
          .first);

      // Check decoration color (primaryOrange = 0xFFFF9800)
      final mediumScoreDecoration =
          mediumScoreContainer.decoration as BoxDecoration;
      expect((mediumScoreDecoration.color as Color).value,
          const Color(0xFFFF9800).withOpacity(0.1).value);

      // Finally test low score (<4) - should be pink
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SavedMealCard(
              savedMeal: SavedMeal(
                id: 'test-id-low',
                userId: 'user123',
                name: 'Low Score Meal',
                foodAnalysis: FoodAnalysisResult(
                  id: 'test-analysis-id-low',
                  foodName: 'Test Food Low',
                  ingredients: [],
                  nutritionInfo: nutritionInfo,
                  warnings: [],
                  healthScore: 3.0, // Low range
                ),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the health score text and verify pink color
      final lowScoreText = find.text('Health: 3.0');
      expect(lowScoreText, findsOneWidget);

      // Find the container that holds the health score
      final lowScoreContainer = tester.widget<Container>(find
          .ancestor(
            of: lowScoreText,
            matching: find.byType(Container),
          )
          .first);

      // Check decoration color (primaryPink = 0xFFFF6B6B)
      final lowScoreDecoration = lowScoreContainer.decoration as BoxDecoration;
      expect((lowScoreDecoration.color as Color).value,
          const Color(0xFFFF6B6B).withOpacity(0.1).value);
    });
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
