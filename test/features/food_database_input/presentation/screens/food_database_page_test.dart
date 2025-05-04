// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/food_database_page.dart';
import 'package:pockeat/features/food_database_input/services/food/food_database_service.dart';

class MockNutritionDatabaseService extends Mock
    implements NutritionDatabaseServiceInterface {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Create a fake class for FoodAnalysisResult to use with registerFallbackValue
class FoodAnalysisResultFake extends Fake implements FoodAnalysisResult {}

// Create fake classes for List<FoodAnalysisResult> and Map<String, dynamic>
class FoodAnalysisResultListFake extends Fake
    implements List<FoodAnalysisResult> {}

class MapStringDynamicFake extends Fake implements Map<String, dynamic> {}

void main() {
  late MockNutritionDatabaseService mockNutritionService;
  late MockNavigatorObserver mockNavigatorObserver;
  final getIt = GetIt.instance;

  // Register fallback values
  setUpAll(() {
    registerFallbackValue(FoodAnalysisResultFake());
    registerFallbackValue(FoodAnalysisResultListFake());
    registerFallbackValue(MapStringDynamicFake());
  });

  // Test data
  final testFoodAnalysis1 = FoodAnalysisResult(
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
  );

  final testFoodAnalysis2 = FoodAnalysisResult(
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
  );

  // Test meal
  final testMeal = FoodAnalysisResult(
    id: 'meal_local_123',
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
    ),
    warnings: [],
    additionalInformation: {'is_meal': true},
    timestamp: DateTime.now(),
  );

  setUp(() {
    mockNutritionService = MockNutritionDatabaseService();
    mockNavigatorObserver = MockNavigatorObserver();

    // Register mock service
    if (getIt.isRegistered<NutritionDatabaseServiceInterface>()) {
      getIt.unregister<NutritionDatabaseServiceInterface>();
    }
    getIt.registerSingleton<NutritionDatabaseServiceInterface>(
        mockNutritionService);

    // Setup mock methods
    when(() => mockNutritionService.getAllFoods(
            limit: any(named: 'limit'), offset: any(named: 'offset')))
        .thenAnswer((_) async => [testFoodAnalysis1, testFoodAnalysis2]);

    when(() => mockNutritionService.searchFoods(any()))
        .thenAnswer((_) async => [testFoodAnalysis1]);

    when(() => mockNutritionService.createLocalMeal(any(), any(),
            additionalInformation: any(named: 'additionalInformation')))
        .thenReturn(testMeal);

    when(() => mockNutritionService.saveMealToFirebase(any()))
        .thenAnswer((_) async => 'saved_meal_id');
  });

  tearDown(() {
    if (getIt.isRegistered<NutritionDatabaseServiceInterface>()) {
      getIt.unregister<NutritionDatabaseServiceInterface>();
    }
  });

  testWidgets('NutritionDatabasePage should render all tabs correctly',
      (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(
      MaterialApp(
        home: const NutritionDatabasePage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
    await tester.pumpAndSettle();

    // Find tab bar and verify it exists
    expect(find.byType(TabBar), findsOneWidget);

    // Verify the tab titles exist (there may be multiple instances of "Search" text)
    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('Meal'), findsOneWidget);

    // Should start with the search tab active - verify search field is visible
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Search tab should show results when searching',
      (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(
      MaterialApp(
        home: const NutritionDatabasePage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
    await tester.pumpAndSettle();

    // Enter search text
    await tester.enterText(find.byType(TextField), 'apple');

    // Find and tap the search button
    final searchButton = find.widgetWithText(ElevatedButton, 'Search');
    expect(searchButton, findsOneWidget);
    await tester.tap(searchButton);
    await tester.pumpAndSettle();

    // Verify search was called
    verify(() => mockNutritionService.searchFoods('apple')).called(1);

    // Results should be displayed
    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets(
      'Selected tab should display empty state when no foods are selected',
      (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(
      MaterialApp(
        home: const NutritionDatabasePage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Selected tab
    await tester.tap(find.text('Selected'));
    await tester.pumpAndSettle();

    // Should show empty state
    expect(find.text('No foods selected yet'), findsOneWidget);
  });

  testWidgets('Meal tab should display empty state when no meal is created',
      (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(
      MaterialApp(
        home: const NutritionDatabasePage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Meal tab
    await tester.tap(find.text('Meal'));
    await tester.pumpAndSettle();

    // Should show empty state
    expect(find.text('No meal created yet'), findsOneWidget);
  });
}
