import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/meal_details_tab.dart';

void main() {
  // Test data
  final testMeal = FoodAnalysisResult(
    id: 'meal_local_123',
    foodName: 'Test Meal',
    nutritionInfo: NutritionInfo(
      calories: 141.0,
      protein: 1.4,
      carbs: 37.0,
      fat: 0.5,
      saturatedFat: 0.1,
      sodium: 2.0,
      fiber: 5.0,
      sugar: 22.0,
      cholesterol: 0.0,
      nutritionDensity: 7.8,
      vitaminsAndMinerals: {
        'vitamin_c': 13.3,
        'vitamin_a': 15.0,
        'calcium': 20.0,
        'iron': 5.0,
      },
    ),
    ingredients: [
      Ingredient(name: 'Apple', servings: 52.0),
      Ingredient(name: 'Banana', servings: 89.0),
    ],
    warnings: ['High sugar content'],
    timestamp: DateTime(2025, 4, 27, 10, 30),
    additionalInformation: {
      'is_meal': true,
      'component_count': 2,
      'components': [
        {'food_id': '1', 'name': 'Apple', 'portion': 100.0, 'count': 1},
        {'food_id': '2', 'name': 'Banana', 'portion': 100.0, 'count': 1},
      ],
    },
  );

  // Test selected foods
  final testSelectedFoods = [
    FoodAnalysisResult(
      id: 'food_1',
      foodName: 'Apple',
      nutritionInfo: NutritionInfo(
        calories: 52.0,
        protein: 0.3,
        carbs: 14.0,
        fat: 0.2,
        saturatedFat: 0.0,
        sodium: 1.0,
        fiber: 2.4,
        sugar: 10.0,
        cholesterol: 0.0,
        nutritionDensity: 8.2,
        vitaminsAndMinerals: {'vitamin_c': 4.6},
      ),
      ingredients: [Ingredient(name: 'Apple', servings: 52.0)],
      warnings: [],
      additionalInformation: {},
    ),
    FoodAnalysisResult(
      id: 'food_2',
      foodName: 'Banana',
      nutritionInfo: NutritionInfo(
        calories: 89.0,
        protein: 1.1,
        carbs: 23.0,
        fat: 0.3,
        saturatedFat: 0.1,
        sodium: 1.0,
        fiber: 2.6,
        sugar: 12.0,
        cholesterol: 0.0,
        nutritionDensity: 7.5,
        vitaminsAndMinerals: {'vitamin_c': 8.7},
      ),
      ingredients: [Ingredient(name: 'Banana', servings: 89.0)],
      warnings: [],
      additionalInformation: {},
    ),
  ];

  group('MealDetailsTab', () {
    testWidgets('should display empty state when no meal is created',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: null,
              selectedFoods: [],
              isLoading: false,
              onSaveMeal: () {},
              onClearMeal: () {},
              onGoToCreateMeal: () {},
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No meal created yet'), findsOneWidget);
      expect(
          find.text('Go to "Selected" tab to create a meal'), findsOneWidget);
      expect(find.text('Create Meal'), findsOneWidget);
    });

    testWidgets('should display meal details when a meal is created',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: testMeal,
              selectedFoods: testSelectedFoods,
              isLoading: false,
              onSaveMeal: () {},
              onClearMeal: () {},
              onGoToCreateMeal: () {},
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Meal'), findsOneWidget);
      expect(find.text('141 cal'), findsOneWidget);
      expect(find.text('Carbs: 37.0g'), findsOneWidget);
      expect(find.text('Protein: 1.4g'), findsOneWidget);
      expect(find.text('Fat: 0.5g'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Save to Database'), findsOneWidget);
      expect(find.text('Clear Meal'), findsOneWidget);
    });

    testWidgets('should display nutrition distribution pie chart',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: testMeal,
              selectedFoods: testSelectedFoods,
              isLoading: false,
              onSaveMeal: () {},
              onClearMeal: () {},
              onGoToCreateMeal: () {},
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Nutrition Distribution'), findsOneWidget);
      // Check for legend items
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
    });

    testWidgets('should display warnings when present',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: testMeal,
              selectedFoods: testSelectedFoods,
              isLoading: false,
              onSaveMeal: () {},
              onClearMeal: () {},
              onGoToCreateMeal: () {},
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('High sugar content'), findsOneWidget);
    });

    testWidgets('should display loading indicator when saving',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: testMeal,
              selectedFoods: testSelectedFoods,
              isLoading: true,
              onSaveMeal: () {},
              onClearMeal: () {},
              onGoToCreateMeal: () {},
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Save button should be disabled
      final saveButton = tester.widget<ElevatedButton>(
        find.text('Save to Database').first,
      );
      expect(saveButton.enabled, isFalse);
    });

    testWidgets('should call onSaveMeal when save button is pressed',
        (WidgetTester tester) async {
      // Arrange
      bool saveMealCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: testMeal,
              selectedFoods: testSelectedFoods,
              isLoading: false,
              onSaveMeal: () {
                saveMealCalled = true;
              },
              onClearMeal: () {},
              onGoToCreateMeal: () {},
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Press save button
      await tester.tap(find.text('Save to Database'));
      await tester.pumpAndSettle();

      // Assert
      expect(saveMealCalled, isTrue);
    });

    testWidgets('should call onClearMeal when clear button is pressed',
        (WidgetTester tester) async {
      // Arrange
      bool clearMealCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: testMeal,
              selectedFoods: testSelectedFoods,
              isLoading: false,
              onSaveMeal: () {},
              onClearMeal: () {
                clearMealCalled = true;
              },
              onGoToCreateMeal: () {},
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Press clear button
      await tester.tap(find.text('Clear Meal'));
      await tester.pumpAndSettle();

      // Assert
      expect(clearMealCalled, isTrue);
    });

    testWidgets(
        'should call onGoToCreateMeal when create meal button is pressed',
        (WidgetTester tester) async {
      // Arrange
      bool goToCreateMealCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: null, // Empty state
              selectedFoods: [],
              isLoading: false,
              onSaveMeal: () {},
              onClearMeal: () {},
              onGoToCreateMeal: () {
                goToCreateMealCalled = true;
              },
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Press create meal button
      await tester.tap(find.text('Create Meal'));
      await tester.pumpAndSettle();

      // Assert
      expect(goToCreateMealCalled, isTrue);
    });

    testWidgets('should display vitamins and minerals when expanded',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealDetailsTab(
              currentMeal: testMeal,
              selectedFoods: testSelectedFoods,
              isLoading: false,
              onSaveMeal: () {},
              onClearMeal: () {},
              onGoToCreateMeal: () {},
              formatDate: (date) => '2025-04-27 10:30',
              formatNutrientName: (name) => name.toUpperCase(),
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Expand vitamins & minerals section
      await tester.tap(find.text('Vitamins & Minerals'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('VITAMIN_C'), findsOneWidget);
      expect(find.text('VITAMIN_A'), findsOneWidget);
      expect(find.text('CALCIUM'), findsOneWidget);
      expect(find.text('IRON'), findsOneWidget);
    });
  });
}
