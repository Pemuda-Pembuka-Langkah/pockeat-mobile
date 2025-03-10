import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/food_entry_form_page.dart';

void main() {
  group('FoodEntryForm Basic Widget Tests', () {
    testWidgets('Form has all required input fields with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
      // Verify fields exist
      expect(find.byKey(const ValueKey('foodNameField')), findsOneWidget);
      expect(find.byKey(const ValueKey('descriptionField')), findsOneWidget);
      expect(find.byKey(const ValueKey('ingredientsField')), findsOneWidget);
      expect(find.byKey(const ValueKey('weightField')), findsOneWidget);
      expect(find.byKey(const ValueKey('saveButton')), findsOneWidget);

      // Verify text field styling
      final TextField foodNameField = tester.widget<TextField>(
        find.byKey(const ValueKey('foodNameField'))
      );
      final InputDecoration decoration = foodNameField.decoration!;
      
      expect(decoration.filled, true);
      expect(decoration.fillColor, Colors.white);
      expect((decoration.border as OutlineInputBorder).borderRadius, 
        BorderRadius.circular(12));
      expect(decoration.labelStyle?.color, Colors.black54);
    });

    testWidgets('Save button has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));

      final ElevatedButton saveButton = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('saveButton'))
      );
      
      final ButtonStyle? style = saveButton.style;
      final backgroundColor = style?.backgroundColor?.resolve({});
      expect(backgroundColor, const Color(0xFF4ECDC4));

      final Text buttonText = tester.widget<Text>(find.text('Save'));
      expect(buttonText.style?.fontSize, 16);
      expect(buttonText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('Success message has correct styling', (WidgetTester tester) async {
      bool onSavedCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodEntryForm(
              onSaved: (FoodEntry entry) {
                onSavedCalled = true;
              },
            ),
          ),
        ),
      );

      // Fill in valid data
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Test Food');
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Test Description');
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), 'Test Ingredients');
      await tester.enterText(find.byKey(const ValueKey('weightField')), '100');

      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Food entry is saved successfully!'), findsOneWidget);
      
      final Text successText = tester.widget<Text>(
        find.text('Food entry is saved successfully!')
      );
      expect(successText.style?.color, const Color(0xFF4ECDC4));
      expect(successText.style?.fontWeight, FontWeight.w600);
      expect(successText.textAlign, TextAlign.center);
      
      expect(onSavedCalled, true);
    });

    testWidgets('Can input short text in all fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Nasi Goreng');
      expect(find.text('Nasi Goreng'), findsOneWidget);
      
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Homemade fried rice with vegetables');
      expect(find.text('Homemade fried rice with vegetables'), findsOneWidget);
      
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), 'Rice, carrots, peas, egg, soy sauce');
      expect(find.text('Rice, carrots, peas, egg, soy sauce'), findsOneWidget);
      
      await tester.enterText(find.byKey(const ValueKey('weightField')), '300');
      expect(find.text('300'), findsOneWidget);
    });
    
    testWidgets('Can input long text descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
      final longDescription = 'I had nasi goreng for lunch today, it consisted of fried rice with various vegetables including carrots, peas, and corn. The rice was flavored with sweet soy sauce and a bit of chili. It also contained small pieces of chicken and some scrambled eggs mixed throughout. The portion was quite large and I couldn\'t finish it all in one sitting.';
      
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), longDescription);
      await tester.pump();
      
      expect(find.text(longDescription), findsOneWidget);
    });
    
    testWidgets('Form scrolls to accommodate long inputs', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Nasi Goreng Special');
      
      final longDescription = 'I had nasi goreng for lunch today, it consisted of fried rice with various vegetables including carrots, peas, and corn. The rice was flavored with sweet soy sauce and a bit of chili. It also contained small pieces of chicken and some scrambled eggs mixed throughout. The portion was quite large and I couldn\'t finish it all in one sitting.';
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), longDescription);
      
      final longIngredients = 'White rice (250g), carrots (50g), green peas (30g), sweet corn (30g), chicken breast (100g), eggs (2), sweet soy sauce (3 tbsp), regular soy sauce (1 tbsp), salt (1 tsp), pepper (1/2 tsp), vegetable oil (2 tbsp), garlic (3 cloves), shallots (5), red chili (2), green onions (3 stalks)';
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), longIngredients);
      
      await tester.enterText(find.byKey(const ValueKey('weightField')), '450');

      await tester.dragFrom(
        tester.getCenter(find.byKey(const ValueKey('ingredientsField'))),
        const Offset(0, -300),
      );
      await tester.pump();
      
      expect(find.byKey(const ValueKey('saveButton')), findsOneWidget);
    });
    
    testWidgets('Widget disposes controllers when removed', (WidgetTester tester) async {
      bool showForm = true;
      late StateSetter builderSetState;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              builderSetState = setState;
              return showForm 
                ? const FoodEntryForm() 
                : const Text('Form removed');
            },
          ),
        ),
      );
      
      expect(find.byType(FoodEntryForm), findsOneWidget);
      
      builderSetState(() {
        showForm = false;
      });

      await tester.pumpAndSettle();
      
      expect(find.byType(FoodEntryForm), findsNothing);
      expect(find.text('Form removed'), findsOneWidget);
      
    });
  });

  group('FoodEntryForm Validation Tests', () {
    testWidgets('Shows error message with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump();

      final TextField foodNameField = tester.widget<TextField>(
        find.byKey(const ValueKey('foodNameField'))
      );
      final InputDecoration decoration = foodNameField.decoration!;
      
      expect(decoration.errorStyle?.color, const Color(0xFFFF6B6B));
      expect((decoration.errorBorder as OutlineInputBorder).borderSide.color, 
        const Color(0xFFFF6B6B));
      expect((decoration.errorBorder as OutlineInputBorder).borderSide.width, 2.0);
    });

    testWidgets('Shows error message when required fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump(); 
      await tester.pump(); 
      await tester.pump(); 

      expect(find.text('Please insert food name'), findsOneWidget);
      expect(find.text('Please insert food description'), findsOneWidget);
      expect(find.text('Please insert food ingredients'), findsOneWidget);
      expect(find.text('Please enter a valid number'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });

    testWidgets('Shows error when food name text exceeds maximum word count', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm(maxFoodNameWords: 20))));

      final longFoodName = 'Grilled herb-marinated chicken breast with roasted garlic mashed potatoes, sautéed buttered asparagus, honey-glazed baby carrots, creamy mushroom sauce, and a side of freshly baked whole wheat bread with homemade basil pesto spread, served alongside a refreshing mixed berry yogurt parfait with granola and a drizzle of organic wildflower honey.';

      await tester.enterText(find.byKey(const ValueKey('foodNameField')), longFoodName);      
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Test Description');
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), 'Test Ingredients');      
      await tester.enterText(find.byKey(const ValueKey('weightField')), '100');

      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Food name exceeds maximum word count (20)'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });

    testWidgets('Shows error when description text exceeds maximum word count', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm(maxDescriptionWords: 50))));

      final longDescription = 'For breakfast, I had a bowl of oatmeal with sliced bananas, honey, and a sprinkle of cinnamon. Alongside, I drank a cup of black coffee. Later, for lunch, I ate grilled salmon with steamed broccoli, brown rice, and a side of fresh avocado salad. In the evening, I had a hearty vegetable soup with carrots, potatoes, and lentils, accompanied by whole wheat toast. I also snacked on almonds, yogurt, and an apple throughout the day. Staying hydrated, I drank plenty of water and a cup of green tea before bedtime to help with digestion and relaxation.';
      
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Test Food');      
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), longDescription);
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), 'Test Ingredients');      
      await tester.enterText(find.byKey(const ValueKey('weightField')), '100');

      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Description exceeds maximum word count (50)'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });

    testWidgets('Shows error when ingredients text exceeds maximum word count', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm(maxIngredientWords: 50))));

      final longIngredients = 'For breakfast, I had a bowl of oatmeal with sliced bananas, honey, and a sprinkle of cinnamon. Alongside, I drank a cup of black coffee. Later, for lunch, I ate grilled salmon with steamed broccoli, brown rice, and a side of fresh avocado salad. In the evening, I had a hearty vegetable soup with carrots, potatoes, and lentils, accompanied by whole wheat toast. I also snacked on almonds, yogurt, and an apple throughout the day. Staying hydrated, I drank plenty of water and a cup of green tea before bedtime to help with digestion and relaxation.';
      
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Test Food');      
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Test Description');
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), longIngredients);      
      await tester.enterText(find.byKey(const ValueKey('weightField')), '100');

      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Ingredients exceeds maximum word count (50)'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });
    
    testWidgets('Shows error when weight is not a valid number', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Test Food');      
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Test Description');
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), 'Test Ingredients');      
      await tester.enterText(find.byKey(const ValueKey('weightField')), 'not-a-number');

      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Please enter a valid number'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);
    });
    
    testWidgets('Shows error when weight is less than or equal to 0', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Test Food');      
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Test Description');
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), 'Test Ingredients');      
      await tester.enterText(find.byKey(const ValueKey('weightField')), '0');

      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Weight must be greater than 0'), findsOneWidget);
      expect(find.text('Food entry is saved successfully!'), findsNothing);

      await tester.enterText(find.byKey(const ValueKey('weightField')), '-10');
      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pump();

      expect(find.text('Weight must be greater than 0'), findsOneWidget);
    });
  });
  
  group('FoodEntryForm Successful Submission Tests', () {
    testWidgets('Successfully submits form with valid inputs', (WidgetTester tester) async {
      FoodEntry? savedFoodEntry;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FoodEntryForm(
            onSaved: (entry) {
              savedFoodEntry = entry;
            },
          ),
        ),
      ));
      
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Nasi Goreng');
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Fried rice with vegetables');
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), 'Rice, vegetables, soy sauce');
      await tester.enterText(find.byKey(const ValueKey('weightField')), '300');

      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pumpAndSettle();

      expect(find.text('Food entry is saved successfully!'), findsOneWidget);
      
      expect(savedFoodEntry, isNotNull);
      expect(savedFoodEntry?.foodName, 'Nasi Goreng');
      expect(savedFoodEntry?.description, 'Fried rice with vegetables');
      expect(savedFoodEntry?.ingredients, 'Rice, vegetables, soy sauce');
      expect(savedFoodEntry?.weight, 300);
    });
    
    testWidgets('Successfully submits form with weightRequired=false', (WidgetTester tester) async {
      FoodEntry? savedFoodEntry;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FoodEntryForm(
            weightRequired: false,
            onSaved: (entry) {
              savedFoodEntry = entry;
            },
          ),
        ),
      ));
      
      await tester.enterText(find.byKey(const ValueKey('foodNameField')), 'Fruit Salad');
      await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Mixed fresh fruits');
      await tester.enterText(find.byKey(const ValueKey('ingredientsField')), 'Apple, banana, orange');

      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pumpAndSettle();

      expect(find.text('Food entry is saved successfully!'), findsOneWidget);
      
      expect(savedFoodEntry, isNotNull);
      expect(savedFoodEntry?.foodName, 'Fruit Salad');
      expect(savedFoodEntry?.description, 'Mixed fresh fruits');
      expect(savedFoodEntry?.ingredients, 'Apple, banana, orange');
      expect(savedFoodEntry?.weight, isNull);
    });
  });
}