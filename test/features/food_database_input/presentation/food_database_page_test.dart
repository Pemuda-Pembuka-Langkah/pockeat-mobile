import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/food_database_page.dart';
import 'package:pockeat/features/food_database_input/services/food/food_database_service.dart';

class MockNutritionDatabaseService extends Mock
    implements NutritionDatabaseServiceInterface {}

void main() {
  late MockNutritionDatabaseService mockService;
  final getIt = GetIt.instance;

  setUp(() {
    mockService = MockNutritionDatabaseService();

    // Register the mock service with GetIt
    if (GetIt.I.isRegistered<NutritionDatabaseServiceInterface>()) {
      GetIt.I.unregister<NutritionDatabaseServiceInterface>();
    }
    getIt.registerSingleton<NutritionDatabaseServiceInterface>(mockService);
  });

  tearDown(() {
    // Reset the registry
    if (GetIt.I.isRegistered<NutritionDatabaseServiceInterface>()) {
      GetIt.I.unregister<NutritionDatabaseServiceInterface>();
    }
  });

  // Test data - sample food items
  final testFood1 = FoodAnalysisResult(
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
      vitaminsAndMinerals: {
        'vitamin_c': 4.6,
      },
    ),
    ingredients: [
      Ingredient(name: 'Apple', servings: 52.0),
    ],
    warnings: [],
    additionalInformation: {
      'database_id': 1,
    },
  );

  final testFood2 = FoodAnalysisResult(
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
      vitaminsAndMinerals: {
        'vitamin_c': 8.7,
      },
    ),
    ingredients: [
      Ingredient(name: 'Banana', servings: 89.0),
    ],
    warnings: [],
    additionalInformation: {
      'database_id': 2,
    },
  );

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
      },
    ),
    ingredients: [
      Ingredient(name: 'Apple', servings: 52.0),
      Ingredient(name: 'Banana', servings: 89.0),
    ],
    warnings: [],
    timestamp: DateTime.now(),
    additionalInformation: {
      'is_meal': true,
      'component_count': 2,
    },
  );

  group('NutritionDatabasePage', () {
    testWidgets('should display search tab with search field and button',
        (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoods()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        MaterialApp(home: NutritionDatabasePage()),
      );

      // Assert
      expect(find.text('Nutrition Database'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should search for foods and display results',
        (WidgetTester tester) async {
      // Arrange
      when(mockService.searchFoods('apple'))
          .thenAnswer((_) async => [testFood1]);

      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(home: NutritionDatabasePage()),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();

      // Tap search button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      verify(mockService.searchFoods('apple')).called(1);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('52 cal'), findsOneWidget);
    });

    testWidgets('should add food to selection when tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockService.searchFoods('apple'))
          .thenAnswer((_) async => [testFood1]);

      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(home: NutritionDatabasePage()),
      );

      // Search for apple
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Tap on the food item to add it
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      // Go to Selected tab
      expect(find.text('Selected'), findsOneWidget);
      await tester.tap(find.text('Selected'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Create Meal'), findsOneWidget);
    });

    testWidgets('should create a meal from selected foods',
        (WidgetTester tester) async {
      // Arrange
      when(mockService.searchFoods('apple'))
          .thenAnswer((_) async => [testFood1]);
      when(mockService.createLocalMeal(any, any,
              additionalInformation: anyNamed('additionalInformation')))
          .thenReturn(testMeal);

      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(home: NutritionDatabasePage()),
      );

      // Search for apple
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Tap on the food item to add it
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      // Go to Selected tab
      await tester.tap(find.text('Selected'));
      await tester.pumpAndSettle();

      // Enter meal name
      await tester.enterText(
          find.byKey(const Key('mealNameField')), 'Test Meal');
      await tester.pumpAndSettle();

      // Create the meal
      await tester.tap(find.text('Create Meal'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockService.createLocalMeal(any, any,
              additionalInformation: anyNamed('additionalInformation')))
          .called(1);
      expect(find.text('Meal'), findsWidgets);
      expect(find.text('Test Meal'), findsWidgets);
    });

    testWidgets('should save meal to Firebase when requested',
        (WidgetTester tester) async {
      // Arrange
      when(mockService.searchFoods('apple'))
          .thenAnswer((_) async => [testFood1]);
      when(mockService.createLocalMeal(any, any,
              additionalInformation: anyNamed('additionalInformation')))
          .thenReturn(testMeal);
      when(mockService.saveMealToFirebase(any))
          .thenAnswer((_) async => 'meal_123');

      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(home: NutritionDatabasePage()),
      );

      // Search, add food, and create meal
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selected'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('mealNameField')), 'Test Meal');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Meal'));
      await tester.pumpAndSettle();

      // Save to Firebase
      await tester.tap(find.text('Save to Database'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockService.saveMealToFirebase(any)).called(1);
      expect(find.textContaining('Meal saved'), findsOneWidget);
    });

    testWidgets('should adjust portion of selected food',
        (WidgetTester tester) async {
      // Arrange
      when(mockService.searchFoods('apple'))
          .thenAnswer((_) async => [testFood1]);
      when(mockService.adjustPortion(any, any))
          .thenAnswer((_) async => testFood1.copyWith(
                id: 'portion_food_1_150g',
                nutritionInfo: testFood1.nutritionInfo.copyWith(calories: 78.0),
                ingredients: [Ingredient(name: 'Apple', servings: 78.0)],
                additionalInformation: {
                  ...testFood1.additionalInformation,
                  'portion_adjusted': true,
                  'adjusted_portion': 150.0,
                },
              ));

      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(home: NutritionDatabasePage()),
      );

      // Search and add food
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selected'));
      await tester.pumpAndSettle();

      // Find the slider and adjust it
      final Finder slider = find.byType(Slider);
      await tester.drag(slider, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Assert
      verify(mockService.adjustPortion(any, any)).called(1);
    });

    testWidgets('should remove food from selection',
        (WidgetTester tester) async {
      // Arrange
      when(mockService.searchFoods('apple'))
          .thenAnswer((_) async => [testFood1]);

      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(home: NutritionDatabasePage()),
      );

      // Search and add food
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selected'));
      await tester.pumpAndSettle();

      // Verify the food is added
      expect(find.text('Apple'), findsOneWidget);

      // Remove the food
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No foods selected'), findsOneWidget);
    });

    testWidgets('should clear meal when requested',
        (WidgetTester tester) async {
      // Arrange
      when(mockService.searchFoods('apple'))
          .thenAnswer((_) async => [testFood1]);
      when(mockService.createLocalMeal(any, any,
              additionalInformation: anyNamed('additionalInformation')))
          .thenReturn(testMeal);

      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(home: NutritionDatabasePage()),
      );

      // Search, add food, create meal
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selected'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('mealNameField')), 'Test Meal');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Meal'));
      await tester.pumpAndSettle();

      // Clear the meal
      await tester.tap(find.text('Clear Meal'));
      await tester.pumpAndSettle();

      // Assert - we should be back at the search tab
      expect(find.text('Enter a food name to search'), findsOneWidget);
    });
  });
}
