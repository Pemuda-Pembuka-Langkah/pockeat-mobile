import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/calorie_summary_card.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_title_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/ingredients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutritional_info_section.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';
import 'package:pockeat/features/saved_meals/presentation/screens/saved_meal_detail_page.dart';
import 'package:pockeat/features/saved_meals/presentation/widgets/saved_meal_bottom_action_bar.dart';

import 'saved_meal_detail_page_test.mocks.dart';

@GenerateMocks([SavedMealService, NavigatorObserver])
void main() {
  late MockSavedMealService mockSavedMealService;
  late MockNavigatorObserver mockNavigatorObserver;
  late SavedMeal testSavedMeal;
  late FoodAnalysisResult testFoodAnalysis;

  setUp(() {
    mockSavedMealService = MockSavedMealService();
    mockNavigatorObserver = MockNavigatorObserver();

    // Create test data
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
      vitaminsAndMinerals: {
        'vitamin_a': 10.0,
        'vitamin_c': 20.0,
        'calcium': 15.0,
        'iron': 8.0,
      },
    );

    testFoodAnalysis = FoodAnalysisResult(
      id: 'analysis-1',
      foodName: 'Grilled Chicken Salad',
      ingredients: [
        Ingredient(name: 'Chicken', servings: 1.0),
        Ingredient(name: 'Lettuce', servings: 0.5),
        Ingredient(name: 'Tomato', servings: 0.3),
        Ingredient(name: 'Cucumber', servings: 0.2),
        Ingredient(name: 'Olive Oil', servings: 0.1),
      ],
      nutritionInfo: nutritionInfo,
      warnings: ['High protein'],
      healthScore: 8.5,
    );

    testSavedMeal = SavedMeal(
      id: 'meal-1',
      userId: 'user123',
      name: 'My Grilled Chicken Salad',
      foodAnalysis: testFoodAnalysis,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  });

  testWidgets('SavedMealDetailPage displays loading indicator initially',
      (WidgetTester tester) async {
    // Arrange - Use a Completer to control the timing
    final completer = Completer<SavedMeal>();

    when(mockSavedMealService.getSavedMeal('meal-1'))
        .thenAnswer((_) => completer.future);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealDetailPage(
          savedMealId: 'meal-1',
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future before test ends to avoid pending timers
    completer.complete(testSavedMeal);
    await tester.pump();
  });

  testWidgets('SavedMealDetailPage displays meal details when loaded',
      (WidgetTester tester) async {
    // Arrange
    when(mockSavedMealService.getSavedMeal('meal-1'))
        .thenAnswer((_) async => testSavedMeal);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealDetailPage(
          savedMealId: 'meal-1',
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    // Use multiple pumps instead of pumpAndSettle to avoid timeout
    await tester.pump(); // Start the future
    await tester.pump(); // Resolve the future
    await tester.pump(); // Build UI with data

    // Assert - Check various content sections
    expect(find.byType(FoodTitleSection), findsOneWidget);
    expect(find.byType(CalorieSummaryCard), findsOneWidget);
    expect(find.byType(NutritionalInfoSection), findsOneWidget);
    expect(find.byType(IngredientsSection), findsOneWidget);
    expect(find.byType(SavedMealBottomActionBar), findsOneWidget);
  });

  testWidgets('SavedMealDetailPage handles null meal result',
      (WidgetTester tester) async {
    // Arrange - Return a resolved null future
    when(mockSavedMealService.getSavedMeal('non-existent-meal'))
        .thenAnswer((_) async => null);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealDetailPage(
          savedMealId: 'non-existent-meal',
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    // Use multiple pumps instead of pumpAndSettle to avoid timeout
    await tester.pump(); // Start the future
    await tester.pump(); // Resolve the future
    await tester.pump(); // Build UI with data

    // Assert - Should not show bottom action bar when meal is not found
    expect(find.byType(SavedMealBottomActionBar), findsNothing);
  });

  testWidgets('SavedMealDetailPage handles error when loading meal',
      (WidgetTester tester) async {
    // Arrange - Throw an exception when getSavedMeal is called
    when(mockSavedMealService.getSavedMeal('meal-1'))
        .thenThrow(Exception('Failed to load meal'));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealDetailPage(
          savedMealId: 'meal-1',
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    // Use multiple pumps instead of pumpAndSettle to avoid timeout
    await tester.pump(); // Start the future
    await tester.pump(); // Process the exception
    await tester.pump(); // Build UI with error state

    // Assert - Should not show bottom action bar when there's an error
    expect(find.byType(SavedMealBottomActionBar), findsNothing);
  });

  testWidgets(
      'SavedMealDetailPage shows delete confirmation dialog when delete button is pressed',
      (WidgetTester tester) async {
    // Arrange
    when(mockSavedMealService.getSavedMeal('meal-1'))
        .thenAnswer((_) async => testSavedMeal);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealDetailPage(
          savedMealId: 'meal-1',
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    // Use multiple pumps instead of pumpAndSettle
    await tester.pump(); // Start the future
    await tester.pump(); // Resolve the future
    await tester.pump(); // Build UI with data

    // Tap the delete button in the app bar
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump(); // Show dialog

    // Assert - Confirmation dialog should appear
    expect(find.text('Delete Saved Meal'), findsOneWidget);
    expect(
        find.text(
            'Are you sure you want to delete this meal? This action cannot be undone.'),
        findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('SavedMealDetailPage updates UI when food analysis is corrected',
      (WidgetTester tester) async {
    // Arrange
    when(mockSavedMealService.getSavedMeal('meal-1'))
        .thenAnswer((_) async => testSavedMeal);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SavedMealDetailPage(
          savedMealId: 'meal-1',
          savedMealService: mockSavedMealService,
        ),
      ),
    );

    // Use multiple pumps instead of pumpAndSettle
    await tester.pump(); // Start the future
    await tester.pump(); // Resolve the future
    await tester.pump(); // Build UI with data

    // Create a corrected food analysis
    final correctedNutritionInfo = testFoodAnalysis.nutritionInfo.copyWith(
      calories: 350,
      protein: 30,
    );

    final correctedFoodAnalysis = testFoodAnalysis.copyWith(
      foodName: 'Corrected Chicken Salad',
      nutritionInfo: correctedNutritionInfo,
    );

    // Find the bottom action bar
    final bottomActionBar = tester.widget<SavedMealBottomActionBar>(
        find.byType(SavedMealBottomActionBar));

    // Simulate a correction by calling the onAnalysisCorrected callback
    bottomActionBar.onAnalysisCorrected?.call(correctedFoodAnalysis);
    await tester.pump(); // Process state update
    await tester.pump(); // Update UI

    // Assert - Food name should be updated
    expect(find.text('Corrected Chicken Salad'), findsOneWidget);
  });
}
