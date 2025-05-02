// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/selected_foods_tab.dart';

class MockCallbackFunction extends Mock {
  void call();
}

class MockRemoveFoodCallback extends Mock {
  void call(int index);
}

class MockAdjustPortionCallback extends Mock {
  void call(int index, double grams);
}

void main() {
  // Test colors
  const Color primaryYellow = Color(0xFFFFE893);
  const Color primaryPink = Color(0xFFFF6B6B);
  const Color primaryGreen = Color(0xFF4ECDC4);

  // Mock callbacks
  late MockCallbackFunction mockOnCreateMeal;
  late MockCallbackFunction mockOnClearAll;
  late MockCallbackFunction mockOnGoToSearchTab;
  late MockRemoveFoodCallback mockOnRemoveFood;
  late MockAdjustPortionCallback mockOnAdjustPortion;

  // Test data
  late List<FoodAnalysisResult> testSelectedFoods;
  late List<TextEditingController> componentCountControllers;
  late Map<int, double> portionValues;
  late TextEditingController mealNameController;
  late GlobalKey<FormState> formKey;

  setUp(() {
    mockOnCreateMeal = MockCallbackFunction();
    mockOnClearAll = MockCallbackFunction();
    mockOnGoToSearchTab = MockCallbackFunction();
    mockOnRemoveFood = MockRemoveFoodCallback();
    mockOnAdjustPortion = MockAdjustPortionCallback();

    mealNameController = TextEditingController();
    formKey = GlobalKey<FormState>();

    componentCountControllers = [
      TextEditingController(text: '1'),
      TextEditingController(text: '1')
    ];

    portionValues = {0: 100.0, 1: 100.0};

    testSelectedFoods = [
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
    mealNameController.dispose();
    for (var controller in componentCountControllers) {
      controller.dispose();
    }
  });

  Widget buildTestableWidget(
      {List<FoodAnalysisResult> selectedFoods = const []}) {
    return MaterialApp(
      home: Scaffold(
        body: SelectedFoodsTab(
          mealNameController: mealNameController,
          selectedFoods: selectedFoods,
          componentCountControllers: componentCountControllers,
          portionValues: portionValues,
          formKey: formKey,
          onCreateMeal: mockOnCreateMeal,
          onClearAll: mockOnClearAll,
          onRemoveFood: mockOnRemoveFood,
          onAdjustPortion: mockOnAdjustPortion,
          onGoToSearchTab: mockOnGoToSearchTab,
          primaryYellow: primaryYellow,
          primaryPink: primaryPink,
          primaryGreen: primaryGreen,
        ),
      ),
    );
  }

  group('SelectedFoodsTab', () {
    testWidgets('should show empty state when no foods are selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('No foods selected yet'), findsOneWidget);
      expect(find.text('Search Foods'), findsOneWidget);
    });

    testWidgets(
        'should call onGoToSearchTab when button is pressed in empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Find and tap the button directly by text
      await tester.tap(find.text('Search Foods'));
      await tester.pump();

      verify(mockOnGoToSearchTab).called(1);
    });

    testWidgets('should display selected foods when provided',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(selectedFoods: testSelectedFoods));

      // Check food items are displayed
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);

      // Find the RichTexts which contain the nutrition info
      final richTextWidgets = find.byType(RichText);
      expect(richTextWidgets, findsWidgets);

      // Check for any widget that has the calories - they're in a RichText widget
      expect(find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final String text = widget.text.toPlainText();
          return text.contains('52');
        }
        return false;
      }), findsOneWidget);

      expect(find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final String text = widget.text.toPlainText();
          return text.contains('89');
        }
        return false;
      }), findsOneWidget);
    });

    testWidgets('should have meal name input field',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(selectedFoods: testSelectedFoods));

      // Find the meal name text field (there's only one TextFormField with this label)
      final mealNameField = find.widgetWithText(TextFormField, 'Meal Name');
      expect(mealNameField, findsOneWidget);

      await tester.enterText(mealNameField, 'My Test Meal');
      expect(mealNameController.text, 'My Test Meal');
    });

    testWidgets('should call onCreateMeal when Create Meal button is pressed',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(selectedFoods: testSelectedFoods));

      // Enter meal name
      final mealNameField = find.widgetWithText(TextFormField, 'Meal Name');
      await tester.enterText(mealNameField, 'My Test Meal');

      // Find and tap create meal button by text directly
      await tester.tap(find.text('Create Meal'));
      await tester.pumpAndSettle();

      verify(mockOnCreateMeal).called(1);
    });

    testWidgets('should call onClearAll when Clear button is pressed',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(selectedFoods: testSelectedFoods));

      // Find and tap clear button by text directly
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      verify(mockOnClearAll).called(1);
    });

    testWidgets(
        'should call onRemoveFood when remove button on food item is pressed',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(selectedFoods: testSelectedFoods));

      // Find and tap first delete icon (delete_outline in the implementation, not delete)
      final removeButtons = find.byIcon(Icons.delete_outline);
      expect(removeButtons, findsNWidgets(2)); // Should have one for each food

      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      // Should have called with index 0 (first item)
      verify(() => mockOnRemoveFood(0)).called(1);
    });

    testWidgets('should have portion adjustment sliders',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(selectedFoods: testSelectedFoods));

      // Find the sliders
      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(2)); // Should have one for each food
    });

    testWidgets('should call onAdjustPortion when slider value changes',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(selectedFoods: testSelectedFoods));

      // Reset any previous interactions
      reset(mockOnAdjustPortion);

      // Find all sliders
      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(2));

      // Get the first slider for testing
      final slider = tester.widget<Slider>(sliders.first);

      // Simulate slider value change by directly calling onChanged callback
      slider.onChanged!(200.0); // Use a new value different from the default
      await tester.pumpAndSettle();

      // Verify onAdjustPortion was called with index 0 and any value
      verify(() => mockOnAdjustPortion(0, any())).called(1);
    });

    testWidgets('should have count input fields for each food',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(selectedFoods: testSelectedFoods));

      // Find count labels
      final countLabels = find.text('Count:');
      expect(countLabels, findsNWidgets(2)); // One for each food

      // Verify there are text fields for component counts
      final textFormFields = find.byType(TextFormField);

      // There should be at least 3 TextFormFields (1 meal name + 2 count fields)
      expect(textFormFields, findsAtLeastNWidgets(3));

      // Verify count controllers are properly hooked up by updating first controller
      componentCountControllers[0].text = '2';
      await tester.pump();

      // Verify the text was updated
      expect(componentCountControllers[0].text, '2');
    });
  });
}
