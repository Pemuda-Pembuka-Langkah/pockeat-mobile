// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:pockeat/features/food_text_input/presentation/widgets/food_entry_form_page.dart';
// import 'package:pockeat/features/food_text_input/presentation/pages/food_text_input_page.dart';

// void main() {
//   testWidgets('FoodTextInputPage UI Test', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       const MaterialApp(
//         home: FoodTextInputPage(),
//       ),
//     );

//     // Verify the AppBar title
//     expect(find.text('Add Food Details'), findsOneWidget);
    
//     // Verify the instruction text
//     expect(find.text('Enter your food details'), findsOneWidget);

//     // Verify FoodEntryForm is present
//     expect(find.byType(FoodEntryForm), findsOneWidget);

//     // Verify back button exists
//     expect(find.byIcon(Icons.arrow_back), findsOneWidget);

//     // Tap the back button
//     await tester.tap(find.byIcon(Icons.arrow_back));
//     await tester.pumpAndSettle();
//   });
// }