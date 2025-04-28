// // Flutter imports:
// import 'package:flutter/material.dart';

// // Package imports:
// import 'package:flutter_test/flutter_test.dart';

// // Project imports:
// import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';

// void main() {
//   const primaryGreen = Color(0xFF4ECDC4);
//   const warningYellow = Color(0xFFF4D03F);

//   group('DietTagsSection', () {
//     testWidgets('displays safety tag when warnings list is empty',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: DietTagsSection(
//               warnings: const [],
//               primaryGreen: primaryGreen,
//               warningYellow: warningYellow,
//             ),
//           ),
//         ),
//       );

//       // Verify section title is displayed
//       expect(find.text('Warnings'), findsOneWidget);

//       // Verify safety tag is displayed
//       expect(find.text('The food is safe for consumption'), findsOneWidget);

//       // Verify no warning tags are displayed
//       expect(
//           find.byWidgetPredicate((widget) =>
//               widget is Container &&
//               widget.child is Text &&
//               (widget.child as Text).data != 'The food is safe for consumption'),
//           findsNothing);
//     });

//     testWidgets('displays warning tags when warnings list is not empty',
//         (WidgetTester tester) async {
//       final warnings = [
//         'Contains allergens',
//         'High in sugar',
//         'May contain traces of nuts'
//       ];

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: DietTagsSection(
//               warnings: warnings,
//               primaryGreen: primaryGreen,
//               warningYellow: warningYellow,
//             ),
//           ),
//         ),
//       );

//       // Verify section title is displayed
//       expect(find.text('Warnings'), findsOneWidget);

//       // Verify safety tag is NOT displayed
//       expect(find.text('The food is safe for consumption'), findsNothing);

//       // Verify all warning tags are displayed
//       for (final warning in warnings) {
//         expect(find.text(warning), findsOneWidget);
//       }
//     });

//     testWidgets('uses correct colors for safety tag',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: DietTagsSection(
//               warnings: const [],
//               primaryGreen: primaryGreen,
//               warningYellow: warningYellow,
//             ),
//           ),
//         ),
//       );

//       // Find the safety tag container
//       final safetyContainer = tester.widget<Container>(
//         find.ancestor(
//           of: find.text('The food is safe for consumption'),
//           matching: find.byType(Container),
//         ),
//       );

//       // Verify container decoration uses primaryGreen
//       final decoration = safetyContainer.decoration as BoxDecoration;
//       expect(decoration.color, equals(primaryGreen.withOpacity(0.1)));
//       expect(
//           decoration.border,
//           equals(Border.all(color: primaryGreen.withOpacity(0.3))));
//     });

//     testWidgets('uses correct colors for warning tags',
//         (WidgetTester tester) async {
//       final warnings = ['Contains allergens'];

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: DietTagsSection(
//               warnings: warnings,
//               primaryGreen: primaryGreen,
//               warningYellow: warningYellow,
//             ),
//           ),
//         ),
//       );

//       // Find the warning tag container
//       final warningContainer = tester.widget<Container>(
//         find.ancestor(
//           of: find.text('Contains allergens'),
//           matching: find.byType(Container),
//         ),
//       );

//       // Verify container decoration uses warningYellow
//       final decoration = warningContainer.decoration as BoxDecoration;
//       expect(decoration.color, equals(warningYellow.withOpacity(0.1)));
//       expect(
//           decoration.border,
//           equals(Border.all(color: warningYellow.withOpacity(0.3))));
//     });

//     testWidgets('handles multiple warning tags with proper layout',
//         (WidgetTester tester) async {
//       final warnings = List.generate(10, (index) => 'Warning ${index + 1}');

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: SingleChildScrollView(
//               child: DietTagsSection(
//                 warnings: warnings,
//                 primaryGreen: primaryGreen,
//                 warningYellow: warningYellow,
//               ),
//             ),
//           ),
//         ),
//       );

//       // Verify all warning tags are displayed
//       for (final warning in warnings) {
//         expect(find.text(warning), findsOneWidget);
//       }

//       // Verify Wrap widget is used for layout
//       expect(find.byType(Wrap), findsOneWidget);
//     });

//     testWidgets('has correct padding and spacing',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: DietTagsSection(
//               warnings: const [],
//               primaryGreen: primaryGreen,
//               warningYellow: warningYellow,
//             ),
//           ),
//         ),
//       );

//       // Find the main padding widget
//       final paddingWidget = tester.widget<Padding>(
//         find.byType(Padding).first,
//       );

//       // Verify padding values
//       expect(
//           paddingWidget.padding,
//           equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));

//       // Verify spacing between title and content
//       expect(find.byType(SizedBox), findsOneWidget);
//       final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
//       expect(sizedBox.height, equals(12));
//     });

//     testWidgets('has correct text styles',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: DietTagsSection(
//               warnings: const [],
//               primaryGreen: primaryGreen,
//               warningYellow: warningYellow,
//             ),
//           ),
//         ),
//       );

//       // Verify title text style
//       final titleText = tester.widget<Text>(find.text('Warnings'));
//       expect(titleText.style?.fontSize, equals(20));
//       expect(titleText.style?.fontWeight, equals(FontWeight.w600));
//       expect(titleText.style?.color, equals(Colors.black87));

//       // Verify safety tag text style
//       final safetyText = tester.widget<Text>(
//           find.text('The food is safe for consumption'));
//       expect(safetyText.style?.fontSize, equals(14));
//       expect(safetyText.style?.fontWeight, equals(FontWeight.w500));
//       expect(safetyText.style?.color, equals(Colors.black87));
//     });
//   });
// } 
