import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/selected_foods_tab.dart';

void main() {
  late TextEditingController mealNameController;
  late List<TextEditingController> componentCountControllers;

  final formKey = GlobalKey<FormState>();

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
      vitaminsAndMinerals: {'vitamin_c': 4.6},
    ),
    ingredients: [Ingredient(name: 'Apple', servings: 52.0)],
    warnings: [],
    additionalInformation: {'database_id': 1},
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
      vitaminsAndMinerals: {'vitamin_c': 8.7},
    ),
    ingredients: [Ingredient(name: 'Banana', servings: 89.0)],
    warnings: [],
    additionalInformation: {'database_id': 2},
  );

  setUp(() {
    mealNameController = TextEditingController();
    componentCountControllers = [
      TextEditingController(text: '1'),
      TextEditingController(text: '1'),
    ];
  });

  tearDown(() {
    mealNameController.dispose();
    for (var controller in componentCountControllers) {
      controller.dispose();
    }
  });

  group('SelectedFoodsTab', () {
    testWidgets('should display empty state when no foods selected',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedFoodsTab(
              mealNameController: mealNameController,
              selectedFoods: const [],
              componentCountControllers: const [],
              portionValues: const {},
              formKey: formKey,
              onCreateMeal: () {},
              onClearAll: () {},
              onRemoveFood: (_) {},
              onAdjustPortion: (_, __) {},
              onGoToSearchTab: () {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No foods selected'), findsOneWidget);
      expect(find.text('Go to search tab to add foods'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display selected foods list when foods are selected',
        (WidgetTester tester) async {
      // Arrange
      final selectedFoods = [testFood1, testFood2];
      final Map<int, double> portionValues = {0: 52.0, 1: 89.0};

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedFoodsTab(
              mealNameController: mealNameController,
              selectedFoods: selectedFoods,
              componentCountControllers: componentCountControllers,
              portionValues: portionValues,
              formKey: formKey,
              onCreateMeal: () {},
              onClearAll: () {},
              onRemoveFood: (_) {},
              onAdjustPortion: (_, __) {},
              onGoToSearchTab: () {},
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
      expect(find.text('Create Meal'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2)); // One slider per food
      expect(find.byType(TextField), findsWidgets); // Component counts
      expect(find.byKey(const Key('mealNameField')), findsOneWidget);
    });

    testWidgets('should call onCreateMeal when Create Meal button is pressed',
        (WidgetTester tester) async {
      // Arrange
      final selectedFoods = [testFood1, testFood2];
      final Map<int, double> portionValues = {0: 52.0, 1: 89.0};

      bool createMealCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedFoodsTab(
              mealNameController: mealNameController,
              selectedFoods: selectedFoods,
              componentCountControllers: componentCountControllers,
              portionValues: portionValues,
              formKey: formKey,
              onCreateMeal: () {
                createMealCalled = true;
              },
              onClearAll: () {},
              onRemoveFood: (_) {},
              onAdjustPortion: (_, __) {},
              onGoToSearchTab: () {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Enter meal name
      await tester.enterText(
          find.byKey(const Key('mealNameField')), 'Test Meal');
      await tester.pumpAndSettle();

      // Press Create Meal button
      await tester.tap(find.text('Create Meal'));
      await tester.pumpAndSettle();

      // Assert
      expect(createMealCalled, true);
      expect(mealNameController.text, 'Test Meal');
    });

    testWidgets('should call onClearAll when Clear All button is pressed',
        (WidgetTester tester) async {
      // Arrange
      final selectedFoods = [testFood1, testFood2];
      final Map<int, double> portionValues = {0: 52.0, 1: 89.0};

      bool clearAllCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedFoodsTab(
              mealNameController: mealNameController,
              selectedFoods: selectedFoods,
              componentCountControllers: componentCountControllers,
              portionValues: portionValues,
              formKey: formKey,
              onCreateMeal: () {},
              onClearAll: () {
                clearAllCalled = true;
              },
              onRemoveFood: (_) {},
              onAdjustPortion: (_, __) {},
              onGoToSearchTab: () {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Press Clear All button
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Assert
      expect(clearAllCalled, true);
    });

    testWidgets('should call onRemoveFood when delete button is pressed',
        (WidgetTester tester) async {
      // Arrange
      final selectedFoods = [testFood1, testFood2];
      final Map<int, double> portionValues = {0: 52.0, 1: 89.0};

      int? removedFoodIndex;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedFoodsTab(
              mealNameController: mealNameController,
              selectedFoods: selectedFoods,
              componentCountControllers: componentCountControllers,
              portionValues: portionValues,
              formKey: formKey,
              onCreateMeal: () {},
              onClearAll: () {},
              onRemoveFood: (index) {
                removedFoodIndex = index;
              },
              onAdjustPortion: (_, __) {},
              onGoToSearchTab: () {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Press the first delete button
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Assert
      expect(removedFoodIndex, 0);
    });

    testWidgets('should call onAdjustPortion when slider is moved',
        (WidgetTester tester) async {
      // Arrange
      final selectedFoods = [testFood1];
      final Map<int, double> portionValues = {0: 52.0};

      int? adjustedFoodIndex;
      double? adjustedPortion;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedFoodsTab(
              mealNameController: mealNameController,
              selectedFoods: selectedFoods,
              componentCountControllers: [TextEditingController(text: '1')],
              portionValues: portionValues,
              formKey: formKey,
              onCreateMeal: () {},
              onClearAll: () {},
              onRemoveFood: (_) {},
              onAdjustPortion: (index, portion) {
                adjustedFoodIndex = index;
                adjustedPortion = portion;
              },
              onGoToSearchTab: () {},
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Find the slider and adjust it
      final Finder slider = find.byType(Slider);
      await tester.drag(slider, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Assert
      expect(adjustedFoodIndex, 0);
      expect(adjustedPortion, isNotNull);
      expect(adjustedPortion, greaterThan(52.0)); // Portion should increase
    });

    testWidgets('should call onGoToSearchTab when search button is pressed',
        (WidgetTester tester) async {
      // Arrange
      bool goToSearchTabCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedFoodsTab(
              mealNameController: mealNameController,
              selectedFoods: const [],
              componentCountControllers: const [],
              portionValues: const {},
              formKey: formKey,
              onCreateMeal: () {},
              onClearAll: () {},
              onRemoveFood: (_) {},
              onAdjustPortion: (_, __) {},
              onGoToSearchTab: () {
                goToSearchTabCalled = true;
              },
              primaryYellow: const Color(0xFFFFE893),
              primaryPink: const Color(0xFFFF6B6B),
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Press Search button
      await tester.tap(find.text('Search Food'));
      await tester.pumpAndSettle();

      // Assert
      expect(goToSearchTabCalled, true);
    });

    testWidgets('should show validation error when meal name is empty',
        (WidgetTester tester) async {
      // Arrange
      final selectedFoods = [testFood1, testFood2];
      final Map<int, double> portionValues = {0: 52.0, 1: 89.0};

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return SelectedFoodsTab(
                  mealNameController: mealNameController,
                  selectedFoods: selectedFoods,
                  componentCountControllers: componentCountControllers,
                  portionValues: portionValues,
                  formKey: formKey,
                  onCreateMeal: () {},
                  onClearAll: () {},
                  onRemoveFood: (_) {},
                  onAdjustPortion: (_, __) {},
                  onGoToSearchTab: () {},
                  primaryYellow: const Color(0xFFFFE893),
                  primaryPink: const Color(0xFFFF6B6B),
                  primaryGreen: const Color(0xFF4ECDC4),
                );
              },
            ),
          ),
        ),
      );

      // Try to create meal without entering a name
      await tester.tap(find.text('Create Meal'));
      await tester.pumpAndSettle();

      // Assert - should show validation error
      expect(find.text('Please enter a meal name'), findsOneWidget);
    });
  });
}
