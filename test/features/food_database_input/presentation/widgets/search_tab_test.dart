// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/search_tab.dart';

class MockOnSearch extends Mock {
  void call();
}

class MockOnFoodSelected extends Mock {
  void call(FoodAnalysisResult food);
}

class FoodAnalysisResultFake extends Fake implements FoodAnalysisResult {}

void main() {
  // Test colors
  const Color primaryYellow = Color(0xFFFFE893);
  const Color primaryPink = Color(0xFFFF6B6B);
  const Color primaryGreen = Color(0xFF4ECDC4);

  // Mock callbacks
  late MockOnSearch mockOnSearch;
  late MockOnFoodSelected mockOnFoodSelected;

  // Test data
  late List<FoodAnalysisResult> testSearchResults;
  late TextEditingController searchController;

  setUpAll(() {
    // Register fallback value for FoodAnalysisResult
    registerFallbackValue(FoodAnalysisResultFake());
  });

  setUp(() {
    mockOnSearch = MockOnSearch();
    mockOnFoodSelected = MockOnFoodSelected();
    searchController = TextEditingController();

    testSearchResults = [
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
      ),
    ];
  });

  tearDown(() {
    searchController.dispose();
  });

  Widget buildTestableWidget(
      {List<FoodAnalysisResult> searchResults = const [],
      bool isSearching = false}) {
    return MaterialApp(
      home: Scaffold(
        body: SearchTab(
          searchController: searchController,
          onSearch: mockOnSearch,
          searchResults: searchResults,
          isSearching: isSearching,
          onFoodSelected: mockOnFoodSelected,
          primaryYellow: primaryYellow,
          primaryPink: primaryPink,
          primaryGreen: primaryGreen,
        ),
      ),
    );
  }

  group('SearchTab', () {
    testWidgets('should render search field correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(TextField), findsOneWidget);
      // Check for the hint text from the actual implementation
      expect(
          find.text('Search for foods (e.g., apple, chicken)'), findsOneWidget);
    });

    testWidgets('should call onSearch when search button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();

      // Find and tap search button - be more specific to avoid ambiguity
      await tester.tap(find.widgetWithText(ElevatedButton, 'Search'));
      await tester.pump();

      verify(mockOnSearch).called(1);
    });

    testWidgets(
        'should call onSearch when submit button on keyboard is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();

      // Submit with keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(mockOnSearch).called(1);
    });

    testWidgets('should show loading indicator when isSearching is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(isSearching: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Match the text that appears during searching
      expect(find.textContaining('Searching for'), findsOneWidget);
    });

    testWidgets('should show search results when provided',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(searchResults: testSearchResults));

      // Find and verify the search results
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);

      // Check for the nutrition info format that is actually used in the widget
      expect(find.textContaining('Cal: 52'), findsOneWidget);
      expect(find.textContaining('Cal: 89'), findsOneWidget);
    });

    testWidgets('should call onFoodSelected when add icon is tapped',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(searchResults: testSearchResults));

      // Find and tap the add icon next to the first food item
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pump();

      // Verify onFoodSelected was called with the correct food
      verify(() => mockOnFoodSelected(any(
          that: predicate<FoodAnalysisResult>(
              (food) => food.foodName == 'Apple')))).called(1);
    });

    testWidgets('should show empty state message when no results and no search',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(searchResults: []));

      // Text is expected to be shown when there are no search results
      expect(find.text('Search for foods to add to your meal'), findsOneWidget);
    });

    testWidgets('should show items found count with search results',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(searchResults: testSearchResults));

      // Check for the "items found" text that appears with results
      expect(find.text('2 items found'), findsOneWidget);
    });
  });
}
