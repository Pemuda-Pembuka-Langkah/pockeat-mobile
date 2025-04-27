import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/search_tab.dart';

class MockCallbacks {
  void Function() onSearch;
  void Function(FoodAnalysisResult) onFoodSelected;

  MockCallbacks({
    required this.onSearch,
    required this.onFoodSelected,
  });
}

void main() {
  late MockCallbacks mockCallbacks;
  late TextEditingController searchController;

  setUp(() {
    mockCallbacks = MockCallbacks(
      onSearch: () {},
      onFoodSelected: (_) {},
    );
    searchController = TextEditingController();
  });

  tearDown(() {
    searchController.dispose();
  });

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

  group('SearchTab', () {
    testWidgets('should display search field and button',
        (WidgetTester tester) async {
      // Arrange
      final onSearch = expectAsync0(() {}, count: 0);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTab(
              searchController: searchController,
              onSearch: onSearch,
              searchResults: const [],
              isSearching: false,
              onFoodSelected: (_) {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Enter a food name to search'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('should trigger search when button is pressed',
        (WidgetTester tester) async {
      // Arrange
      final onSearch = expectAsync0(() {}, count: 1);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTab(
              searchController: searchController,
              onSearch: onSearch,
              searchResults: const [],
              isSearching: false,
              onFoodSelected: (_) {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Enter text and press search
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.tap(find.byType(ElevatedButton));

      // No need to pump and settle here since we're using expectAsync0
    });

    testWidgets('should display loading indicator when searching',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTab(
              searchController: searchController,
              onSearch: () {},
              searchResults: const [],
              isSearching: true,
              onFoodSelected: (_) {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display search results', (WidgetTester tester) async {
      // Arrange
      final searchResults = [testFood1, testFood2];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTab(
              searchController: searchController,
              onSearch: () {},
              searchResults: searchResults,
              isSearching: false,
              onFoodSelected: (_) {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('52 cal'), findsOneWidget);
      expect(find.text('89 cal'), findsOneWidget);
    });

    testWidgets('should call onFoodSelected when a food item is tapped',
        (WidgetTester tester) async {
      // Arrange
      final searchResults = [testFood1, testFood2];
      FoodAnalysisResult? selectedFood;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTab(
              searchController: searchController,
              onSearch: () {},
              searchResults: searchResults,
              isSearching: false,
              onFoodSelected: (food) {
                selectedFood = food;
              },
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Tap on the Apple item
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedFood, equals(testFood1));
    });

    testWidgets('should display empty results message when no results',
        (WidgetTester tester) async {
      // Arrange
      searchController.text = 'nonexistent food';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTab(
              searchController: searchController,
              onSearch: () {},
              searchResults: const [],
              isSearching: false,
              onFoodSelected: (_) {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(
          find.text('No results found for "nonexistent food"'), findsOneWidget);
    });
  });
}
