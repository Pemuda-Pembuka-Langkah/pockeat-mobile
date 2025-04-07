import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_summary_card.dart';

// Mock classes
class MockFoodAnalysisResult extends Mock implements FoodAnalysisResult {}

class MockNutritionInfo extends Mock implements NutritionInfo {}

class MockIngredient extends Mock implements Ingredient {}

void main() {
  late MockFoodAnalysisResult foodAnalysis;
  late MockNutritionInfo nutritionInfo;
  late List<MockIngredient> ingredients;
  late List<String> warnings;

  setUp(() {
    // Set up nutrition info mock
    nutritionInfo = MockNutritionInfo();
    when(() => nutritionInfo.calories).thenReturn(320);
    when(() => nutritionInfo.carbs).thenReturn(40);
    when(() => nutritionInfo.protein).thenReturn(25);
    when(() => nutritionInfo.fat).thenReturn(10);
    when(() => nutritionInfo.sodium).thenReturn(500);
    when(() => nutritionInfo.fiber).thenReturn(8);
    when(() => nutritionInfo.sugar).thenReturn(12);

    // Set up ingredients mock
    ingredients = List.generate(3, (index) {
      final ingredient = MockIngredient();
      when(() => ingredient.name).thenReturn('Ingredient ${index + 1}');
      when(() => ingredient.servings).thenReturn(1.0);
      return ingredient;
    });

    // Set up warning messages
    warnings = ['High sodium content'];

    // Set up food analysis mock
    foodAnalysis = MockFoodAnalysisResult();
    when(() => foodAnalysis.foodName).thenReturn('Chicken Salad');
    when(() => foodAnalysis.nutritionInfo).thenReturn(nutritionInfo);
    when(() => foodAnalysis.ingredients).thenReturn(ingredients);
    when(() => foodAnalysis.warnings).thenReturn(warnings);
    when(() => foodAnalysis.foodImageUrl)
        .thenReturn('https://example.com/image.jpg');
  });

  group('FoodSummaryCard', () {
    testWidgets('renders correctly with complete food data',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FoodSummaryCard(
                cardKey: cardKey,
                food: foodAnalysis,
              ),
            ),
          ),
        ),
      );

      // Verify structural elements
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('Chicken Salad'), findsOneWidget);
      expect(find.text('320 cal'), findsOneWidget);

      // Verify macronutrient values
      expect(find.text('40 g'), findsOneWidget); // Carbs
      expect(find.text('25 g'), findsOneWidget); // Protein
      expect(find.text('10 g'), findsOneWidget); // Fat

      // Verify additional nutrient values
      expect(find.text('500 mg'), findsOneWidget); // Sodium
      expect(find.text('8 g'), findsOneWidget); // Fiber
      expect(find.text('12 g'), findsOneWidget); // Sugar

      // Verify warning message
      expect(find.text('High sodium content'), findsOneWidget);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders correctly without warning messages',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Update food analysis to have no warnings
      when(() => foodAnalysis.warnings).thenReturn([]);

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FoodSummaryCard(
                cardKey: cardKey,
                food: foodAnalysis,
              ),
            ),
          ),
        ),
      );

      // Verify basic elements are present
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('Chicken Salad'), findsOneWidget);

      // Verify warning container is not present
      expect(find.text('High sodium content'), findsNothing);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('calculates macronutrient percentages correctly',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Set up nutrition info with specific values to test percentage calculation
      when(() => nutritionInfo.carbs).thenReturn(50); // 50%
      when(() => nutritionInfo.protein).thenReturn(30); // 30%
      when(() => nutritionInfo.fat).thenReturn(20); // 20%

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FoodSummaryCard(
                cardKey: cardKey,
                food: foodAnalysis,
              ),
            ),
          ),
        ),
      );

      // Verify macro values
      expect(find.text('50 g'), findsOneWidget); // Carbs
      expect(find.text('30 g'), findsOneWidget); // Protein
      expect(find.text('20 g'), findsOneWidget); // Fat

      // Verify macro labels
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('handles zero macronutrient values gracefully',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Set up nutrition info with zero values
      when(() => nutritionInfo.carbs).thenReturn(0);
      when(() => nutritionInfo.protein).thenReturn(0);
      when(() => nutritionInfo.fat).thenReturn(0);

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FoodSummaryCard(
                cardKey: cardKey,
                food: foodAnalysis,
              ),
            ),
          ),
        ),
      );

      // Verify macro values show zero
      expect(
          find.text('0 g'), findsNWidgets(3)); // All three macros should be 0

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders branding elements correctly',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FoodSummaryCard(
                cardKey: cardKey,
                food: foodAnalysis,
              ),
            ),
          ),
        ),
      );

      // Verify branding elements
      expect(find.text('PockEat'), findsOneWidget);
      expect(find.text('tracked with PockEat'), findsOneWidget);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });
  });
}
