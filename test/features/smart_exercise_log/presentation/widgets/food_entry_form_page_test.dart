import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/food_entry_form_page.dart';

void main() {
  group('FoodEntryForm Basic Widget Tests', () {
    testWidgets('Form has all required input fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm()));
      
      expect(find.byKey(ValueKey('foodNameField')), findsOneWidget);
      expect(find.byKey(ValueKey('descriptionField')), findsOneWidget);
      expect(find.byKey(ValueKey('ingredientsField')), findsOneWidget);
      expect(find.byKey(ValueKey('weightField')), findsOneWidget);
      expect(find.byKey(ValueKey('saveButton')), findsOneWidget);
    });
    
    testWidgets('Can input short text in all fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm()));
      
      await tester.enterText(find.byKey(ValueKey('foodNameField')), 'Nasi Goreng');
      expect(find.text('Nasi Goreng'), findsOneWidget);
      
      await tester.enterText(find.byKey(ValueKey('descriptionField')), 'Homemade fried rice with vegetables');
      expect(find.text('Homemade fried rice with vegetables'), findsOneWidget);
      
      await tester.enterText(find.byKey(ValueKey('ingredientsField')), 'Rice, carrots, peas, egg, soy sauce');
      expect(find.text('Rice, carrots, peas, egg, soy sauce'), findsOneWidget);
      
      await tester.enterText(find.byKey(ValueKey('weightField')), '300');
      expect(find.text('300'), findsOneWidget);
    });
    
    testWidgets('Can input long text descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm()));
      
      final longDescription = 'I had nasi goreng for lunch today, it consisted of fried rice with various vegetables including carrots, peas, and corn. The rice was flavored with sweet soy sauce and a bit of chili. It also contained small pieces of chicken and some scrambled eggs mixed throughout. The portion was quite large and I couldn\'t finish it all in one sitting.';
      
      await tester.enterText(find.byKey(ValueKey('descriptionField')), longDescription);
      
      await tester.pump();
      
      expect(find.text(longDescription), findsOneWidget);
    });
    
    testWidgets('Form scrolls to accommodate long inputs', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm()));
      
      await tester.enterText(find.byKey(ValueKey('foodNameField')), 'Nasi Goreng Special');
      
      final longDescription = 'I had nasi goreng for lunch today, it consisted of fried rice with various vegetables including carrots, peas, and corn. The rice was flavored with sweet soy sauce and a bit of chili. It also contained small pieces of chicken and some scrambled eggs mixed throughout. The portion was quite large and I couldn\'t finish it all in one sitting.';
      await tester.enterText(find.byKey(ValueKey('descriptionField')), longDescription);
      
      final longIngredients = 'White rice (250g), carrots (50g), green peas (30g), sweet corn (30g), chicken breast (100g), eggs (2), sweet soy sauce (3 tbsp), regular soy sauce (1 tbsp), salt (1 tsp), pepper (1/2 tsp), vegetable oil (2 tbsp), garlic (3 cloves), shallots (5), red chili (2), green onions (3 stalks)';
      await tester.enterText(find.byKey(ValueKey('ingredientsField')), longIngredients);
      
      await tester.enterText(find.byKey(ValueKey('weightField')), '450');

      await tester.dragFrom(
        tester.getCenter(find.byKey(ValueKey('ingredientsField'))),
        const Offset(0, -300),
      );
      await tester.pump();
      
      expect(find.byKey(ValueKey('saveButton')), findsOneWidget);
    });
  });

    group('FoodEntryForm Edge Case Tests', () {
    testWidgets('Shows error message when required fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm()));
      
      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Please insert food name'), findsOneWidget);
      expect(find.text('Please insert food description'), findsOneWidget);
      expect(find.text('Please insert food ingredients'), findsOneWidget);

      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });
    
    testWidgets('Shows error when food name text excedds maximum word count', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm(maxFoodNameWords: 20)));

      final longFoodName = 'Grilled herb-marinated chicken breast with roasted garlic mashed potatoes, sautéed buttered asparagus, honey-glazed baby carrots, creamy mushroom sauce, and a side of freshly baked whole wheat bread with homemade basil pesto spread, served alongside a refreshing mixed berry yogurt parfait with granola and a drizzle of organic wildflower honey.';

      await tester.enterText(find.byKey(ValueKey('foodNameField')), longFoodName);      
      await tester.enterText(find.byKey(ValueKey('descriptionField')), 'Test Description');
      await tester.enterText(find.byKey(ValueKey('ingredientsField')), 'Test Ingredients');      
      await tester.enterText(find.byKey(ValueKey('weightField')), '100');

      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Food name exceeds maximum word count (20)'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });

    testWidgets('Shows error when description text exceeds maximum word count', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm(maxDescriptionWords: 50)));

      final longDescription = 'For breakfast, I had a bowl of oatmeal with sliced bananas, honey, and a sprinkle of cinnamon. Alongside, I drank a cup of black coffee. Later, for lunch, I ate grilled salmon with steamed broccoli, brown rice, and a side of fresh avocado salad. In the evening, I had a hearty vegetable soup with carrots, potatoes, and lentils, accompanied by whole wheat toast. I also snacked on almonds, yogurt, and an apple throughout the day. Staying hydrated, I drank plenty of water and a cup of green tea before bedtime to help with digestion and relaxation.';

      await tester.enterText(find.byKey(ValueKey('foodNameField')), 'Test Food');      
      await tester.enterText(find.byKey(ValueKey('descriptionField')), longDescription);
      await tester.enterText(find.byKey(ValueKey('ingredientsField')), 'Test Ingredients');      
      await tester.enterText(find.byKey(ValueKey('weightField')), '100');

      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Description exceeds maximum word count (50)'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });

    testWidgets('Shows error when ingredients text excedds maximum word count', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm(maxIngredientWords: 50)));

      final longIngredients = 'For breakfast, I had a bowl of oatmeal with sliced bananas, honey, and a sprinkle of cinnamon. Alongside, I drank a cup of black coffee. Later, for lunch, I ate grilled salmon with steamed broccoli, brown rice, and a side of fresh avocado salad. In the evening, I had a hearty vegetable soup with carrots, potatoes, and lentils, accompanied by whole wheat toast. I also snacked on almonds, yogurt, and an apple throughout the day. Staying hydrated, I drank plenty of water and a cup of green tea before bedtime to help with digestion and relaxation.';

      await tester.enterText(find.byKey(ValueKey('foodNameField')), 'Test Food');      
      await tester.enterText(find.byKey(ValueKey('descriptionField')), 'Test Description');
      await tester.enterText(find.byKey(ValueKey('ingredientsField')), longIngredients);      
      await tester.enterText(find.byKey(ValueKey('weightField')), '100');

      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Ingredients exceeds maximum word count (50)'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });

    testWidgets('Can save when weight field is empty', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm(weightRequired: false)));
      
      await tester.enterText(find.byKey(ValueKey('foodNameField')), 'Test Food');
      await tester.enterText(find.byKey(ValueKey('descriptionField')), 'Simple description');
      await tester.enterText(find.byKey(ValueKey('ingredientsField')), 'Test ingredients');
      
      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();
      
      expect(find.text('Food entry is saved successfully!'), findsOneWidget);
    });

    testWidgets('Shows error for invalid weight values', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm()));
      
      await tester.enterText(find.byKey(ValueKey('foodNameField')), 'Test Food');
      await tester.enterText(find.byKey(ValueKey('descriptionField')), 'Simple description');
      await tester.enterText(find.byKey(ValueKey('ingredientsField')), 'Test ingredients');
      await tester.enterText(find.byKey(ValueKey('weightField')), 'abc');
      
      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();
      
      expect(find.text('Please enter a valid number'), findsOneWidget);
      
      await tester.enterText(find.byKey(ValueKey('weightField')), '-50');
      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();
      
      expect(find.text('Weight cannot be negative'), findsOneWidget);
    });

    testWidgets('Handles different letter cases correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: FoodEntryForm()));
      
      final mixedCaseText = 'NaSi GoReNg with VeGetAblEs';
      
      await tester.enterText(find.byKey(ValueKey('foodNameField')), mixedCaseText);
      await tester.enterText(find.byKey(ValueKey('descriptionField')), 'Simple description');
      await tester.enterText(find.byKey(ValueKey('ingredientsField')), 'Test ingredients');
      await tester.enterText(find.byKey(ValueKey('weightField')), '100');
      
      await tester.pump();
      
      expect(find.text(mixedCaseText), findsOneWidget);
      
      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();
      
      expect(find.text('Food entry is saved successfully!'), findsOneWidget);
    });
  });
}