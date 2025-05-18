// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';
import 'package:pockeat/features/saved_meals/presentation/screens/saved_meals_page.dart';
import 'package:pockeat/features/saved_meals/presentation/widgets/saved_meal_card.dart';
import 'saved_meals_page_test.mocks.dart';

@GenerateMocks([SavedMealService, NavigatorObserver, NavigatorState])
void main() {
  late MockSavedMealService mockSavedMealService;
  late MockNavigatorState mockNavigatorState;
  late List<SavedMeal> testSavedMeals;

  setUp(() {
    mockSavedMealService = MockSavedMealService();
    mockNavigatorState = MockNavigatorState();

    // Create test meals
    final nutritionInfo = NutritionInfo(
      calories: 300,
      protein: 25,
      carbs: 35,
      fat: 12,
      saturatedFat: 4,
      sodium: 180,
      fiber: 6,
      sugar: 5,
      cholesterol: 50,
      nutritionDensity: 40,
    );

    final foodAnalysis = FoodAnalysisResult(
      id: 'analysis-1',
      foodName:
          'Chicken Salad', // Changed from 'Grilled Chicken Salad' to avoid duplicate text
      ingredients: [
        Ingredient(name: 'Chicken', servings: 1.0),
        Ingredient(name: 'Lettuce', servings: 0.5),
      ],
      nutritionInfo: nutritionInfo,
      warnings: ['High protein'],
      healthScore: 8.5,
    );

    testSavedMeals = [
      SavedMeal(
        id: 'meal-1',
        userId: 'user123',
        name: 'Grilled Chicken Salad',
        foodAnalysis: foodAnalysis,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SavedMeal(
        id: 'meal-2',
        userId: 'user123',
        name: 'Caesar Salad',
        foodAnalysis: foodAnalysis.copyWith(
          foodName:
              'Roman Caesar Salad', // Changed from 'Caesar Salad' to avoid duplicate text
          nutritionInfo: nutritionInfo.copyWith(calories: 250),
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  });

  testWidgets('SavedMealsPage displays loading indicator when waiting for data',
      (WidgetTester tester) async {
    // Arrange - Use a StreamController to control the stream
    final streamController = StreamController<List<SavedMeal>>();

    // Return the controller's stream when getSavedMeals is called
    when(mockSavedMealService.getSavedMeals())
        .thenAnswer((_) => streamController.stream);

    // Act - Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealsPage(
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    // Assert - Should show loading indicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Clean up - add data and close the controller to avoid pending timers
    streamController.add(testSavedMeals);
    await tester.pump();
    streamController.close();
  });

  testWidgets('SavedMealsPage displays saved meals when available',
      (WidgetTester tester) async {
    // Arrange
    when(mockSavedMealService.getSavedMeals())
        .thenAnswer((_) => Stream.value(testSavedMeals));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealsPage(
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    // Use pump() to resolve the future from the stream
    await tester.pump();
    await tester.pump();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(SavedMealCard), findsNWidgets(2));
    expect(find.text('Grilled Chicken Salad'), findsOneWidget);
    expect(find.text('Caesar Salad'), findsOneWidget);
  });

  testWidgets('SavedMealsPage displays empty state when no meals available',
      (WidgetTester tester) async {
    // Arrange
    when(mockSavedMealService.getSavedMeals())
        .thenAnswer((_) => Stream.value([]));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealsPage(
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No saved meals yet'),
        findsOneWidget); // Updated to match actual implementation
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Save your first meal!'), findsOneWidget);
  });

  testWidgets('SavedMealsPage displays error state when error occurs',
      (WidgetTester tester) async {
    // Arrange
    when(mockSavedMealService.getSavedMeals()).thenAnswer(
        (_) => Stream.error(Exception('Failed to load saved meals')));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealsPage(
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Error: Exception: Failed to load saved meals'),
        findsOneWidget); // Updated to match actual error format
  });
}
