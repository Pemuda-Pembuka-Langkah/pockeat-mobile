// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
// import 'package:pockeat/features/food_text_input/presentation/widgets/food_entry_form_page.dart';

// void main() {
//   group('FoodEntryForm Widget Tests', () {
//     testWidgets('Form has required input field with correct styling', (WidgetTester tester) async {
//       await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
//       expect(find.byKey(const ValueKey('descriptionField')), findsOneWidget);
      
//       final TextField descriptionField = tester.widget<TextField>(
//         find.byKey(const ValueKey('descriptionField')),
//       );
//       final InputDecoration decoration = descriptionField.decoration!;
      
//       expect(decoration.filled, true);
//       expect(decoration.fillColor, Colors.white);
//       expect((decoration.border as OutlineInputBorder).borderRadius, 
//         BorderRadius.circular(12));
//       expect(decoration.labelStyle?.color, Colors.black54);
//     });

//     testWidgets('Save button works correctly', (WidgetTester tester) async {
//       FoodEntry? savedFoodEntry;
      
//       await tester.pumpWidget(MaterialApp(
//         home: Scaffold(
//           body: FoodEntryForm(
//             onSaved: (entry) {
//               savedFoodEntry = entry;
//             },
//           ),
//         ),
//       ));
      
//       await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Test food description');
//       await tester.tap(find.text('Save & Analyze Food'));
//       await tester.pumpAndSettle();

//       expect(savedFoodEntry, isNotNull);
//       expect(savedFoodEntry!.foodDescription, 'Test food description');
//     });

//     testWidgets('Displays error message for empty input', (WidgetTester tester) async {
//       await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
//       await tester.tap(find.text('Save & Analyze Food'));
//       await tester.pump();
      
//       expect(find.textContaining('Please insert food description'), findsOneWidget);
//     });

//     testWidgets('Handles long text input correctly', (WidgetTester tester) async {
//       await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
//       final longDescription = 'This is a long description of a food item that contains multiple words and is meant to test the text field input handling for long content. It should be properly displayed and not truncated in the UI.';
//       await tester.enterText(find.byKey(const ValueKey('descriptionField')), longDescription);
//       await tester.pump();
      
//       expect(find.text(longDescription), findsOneWidget);
//     });

//     testWidgets('Form resets properly after saving', (WidgetTester tester) async {
//       await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodEntryForm())));
      
//       await tester.enterText(find.byKey(const ValueKey('descriptionField')), 'Some food description');
//       await tester.tap(find.text('Save & Analyze Food'));
//       await tester.pumpAndSettle();
      
//       expect(find.textContaining('Food entry saved successfully!'), findsOneWidget);
//       expect(find.text('Some food description'), findsOneWidget);
//     });
//   });
// }