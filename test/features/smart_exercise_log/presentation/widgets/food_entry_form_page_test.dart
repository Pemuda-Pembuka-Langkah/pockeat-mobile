import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/food_entry_form_page.dart';

void main() {
  group('FoodEntryForm Widget Tests', () {
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
      
      expect(find.byKey(ValueKey('saveButton')), findsOneWidget);
      
      await tester.dragFrom(
        tester.getCenter(find.byKey(ValueKey('ingredientsField'))),
        const Offset(0, -300),
      );
      await tester.pump();
      
      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();
    });
    
    testWidgets('Form can save data with long text inputs', (WidgetTester tester) async {
      bool wasSaved = false;
      FoodEntry? savedEntry;
      
      await tester.pumpWidget(MaterialApp(
        home: FoodEntryForm(
          onSave: (entry) {
            wasSaved = true;
            savedEntry = entry;
          },
        ),
      ));
      
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
      
      await tester.tap(find.byKey(ValueKey('saveButton')));
      await tester.pump();
      
      expect(wasSaved, true);
      expect(savedEntry?.foodName, 'Nasi Goreng Special');
      expect(savedEntry?.description, longDescription);
      expect(savedEntry?.ingredients, longIngredients);
      expect(savedEntry?.weight, '450');
    });
  });
}