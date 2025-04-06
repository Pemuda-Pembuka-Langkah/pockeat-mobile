import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/presentation/screens/food_detail_page.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';

@GenerateMocks([FoodScanRepository, FoodTextInputRepository])
import 'food_detail_page_test.mocks.dart';

void main() {
  late MockFoodScanRepository mockRepository;
  late MockFoodTextInputRepository mockTextInputRepository;

  setUp(() {
    mockRepository = MockFoodScanRepository();
    mockTextInputRepository = MockFoodTextInputRepository();
  });

  final testFood = FoodLogHistoryItem(
    id: 'food1',
    title: 'Chicken Salad',
    subtitle: '350 calories',
    timestamp: DateTime.now(),
    calories: 350,
    imageUrl: 'https://example.com/image1.jpg',
    sourceId: 'source1',
  );

  final testFoodAnalysis = FoodAnalysisResult(
    id: 'source1',
    foodName: 'Chicken Salad',
    foodImageUrl: 'https://example.com/image1.jpg',
    timestamp: DateTime.now(),
    nutritionInfo: NutritionInfo(
      calories: 350,
      protein: 20,
      carbs: 15,
      fat: 12,
      sodium: 300,
      sugar: 5,
      fiber: 3,
    ),
    ingredients: [
      Ingredient(name: 'Chicken', servings: 1.0),
      Ingredient(name: 'Lettuce', servings: 0.5),
      Ingredient(name: 'Tomato', servings: 0.25),
      Ingredient(name: 'Olive Oil', servings: 0.1),
    ],
    warnings: ['Contains allergens: eggs'],
  );

  Widget createFoodDetailPage() {
    return MaterialApp(
      home: FoodDetailPage(
        foodId: testFood.sourceId!,
        foodRepository: mockRepository,
        foodTextInputRepository: mockTextInputRepository, // Added missing parameter
      ),
    );
  }

  group('FoodDetailPage', () {
    testWidgets('should display food details', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getById(testFood.sourceId!))
          .thenAnswer((_) async => testFoodAnalysis);

      // Act
      await tester.pumpWidget(createFoodDetailPage());
      await tester.pumpAndSettle();

      // Assert - Check food name is displayed
      expect(find.text('Chicken Salad'), findsOneWidget);

      // Check calories are displayed (in the calories indicator)
      expect(find.text('350 calories'), findsOneWidget);

      // Check ingredient is displayed
      expect(find.text('Chicken'), findsOneWidget);

      // Check warning is displayed
      expect(find.text('Contains allergens: eggs'), findsOneWidget);
    });

    testWidgets('should display loading state', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getById(testFood.sourceId!)).thenAnswer((_) async {
        return testFoodAnalysis;
      });

      // Act - Only pump once to capture the loading state
      await tester.pumpWidget(createFoodDetailPage());

      // Assert - initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state when food not found',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getById(testFood.sourceId!))
          .thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createFoodDetailPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Food entry not found'), findsOneWidget);
    });

    testWidgets('should display error state when exception occurs',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getById(testFood.sourceId!)).thenAnswer((_) async {
        throw Exception('Failed to load food');
      });

      // Act
      await tester.pumpWidget(createFoodDetailPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error loading data'), findsOneWidget);
    });

    testWidgets('should delete food when delete button is pressed',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getById(testFood.sourceId!))
          .thenAnswer((_) async => testFoodAnalysis);
      when(mockRepository.deleteById(testFood.sourceId!))
          .thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: FoodDetailPage(
            foodId: testFood.sourceId!,
            foodRepository: mockRepository,
            foodTextInputRepository: mockTextInputRepository, // Added missing parameter
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the delete button
      final deleteButton = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Find and tap the confirm button in the dialog
      final confirmButton = find.widgetWithText(ElevatedButton, 'Delete');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify the repository method was called
      verify(mockRepository.deleteById(testFood.sourceId!)).called(1);
    });

    testWidgets('should handle delete food entry exception',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getById('food1'))
          .thenAnswer((_) async => testFoodAnalysis);
      when(mockRepository.deleteById('food1'))
          .thenThrow(Exception('Delete error'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: FoodDetailPage(
            foodId: 'food1',
            foodRepository: mockRepository,
            foodTextInputRepository: mockTextInputRepository, // Added missing parameter
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Error: Exception: Delete error'), findsOneWidget);
    });

    testWidgets('should show empty state message when ingredients are empty',
        (WidgetTester tester) async {
      // Arrange
      final foodWithNoIngredients = FoodAnalysisResult(
        id: 'source1',
        foodName: 'Chicken Salad',
        foodImageUrl: 'https://example.com/image1.jpg',
        timestamp: DateTime.now(),
        nutritionInfo: NutritionInfo(
          calories: 350,
          protein: 20,
          carbs: 15,
          fat: 12,
          sodium: 300,
          sugar: 5,
          fiber: 3,
        ),
        ingredients: [],
        warnings: [],
      );

      when(mockRepository.getById('source1'))
          .thenAnswer((_) async => foodWithNoIngredients);

      // Act
      await tester.pumpWidget(createFoodDetailPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No ingredients information available'), findsOneWidget);
    });
  });
}
