import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/presentation/pages/food_text_input_page.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/food_entry_form_page.dart';

void main() {
  group('FoodTextInputPage Tests', () {
    testWidgets('Basic widget rendering test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FoodTextInputPage()));
      await tester.pumpAndSettle();
  
      expect(find.byType(FoodTextInputPage), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('AppBar has correct title and back button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FoodTextInputPage()));

      expect(find.text('Add Food Details'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      final Text titleWidget = tester.widget<Text>(find.text('Add Food Details'));
      expect(titleWidget.style?.color, Colors.black87);
      expect(titleWidget.style?.fontSize, 18);
      expect(titleWidget.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('Page has correct heading text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FoodTextInputPage()));

      expect(find.text('Enter your food details'), findsOneWidget);

      final Text headingWidget = tester.widget<Text>(find.text('Enter your food details'));
      expect(headingWidget.style?.fontSize, 24);
      expect(headingWidget.style?.fontWeight, FontWeight.bold);
      expect(headingWidget.style?.color, Colors.black87);
      expect(headingWidget.style?.height, 1.3);
    });

    testWidgets('Contains FoodEntryForm with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FoodTextInputPage()));

      final FoodTextInputPage page = tester.widget<FoodTextInputPage>(
        find.byType(FoodTextInputPage)
      );

      expect(find.byType(FoodEntryForm), findsOneWidget);

      // Verify the container styling
      final Container formContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byType(FoodEntryForm),
          matching: find.byType(Container),
        ).first,
      );

      final BoxDecoration decoration = formContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      
      // Verify shadow
      expect(decoration.boxShadow?.length, 1);
      expect(decoration.boxShadow?[0].color, page.primaryPink.withOpacity(0.2));
      expect(decoration.boxShadow?[0].blurRadius, 4);
      expect(decoration.boxShadow?[0].offset, const Offset(0, 2));
    });

    testWidgets('Back button navigation works', (WidgetTester tester) async {
      bool didPop = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const FoodTextInputPage(),
          navigatorObservers: [
            MockNavigatorObserver(onPop: () => didPop = true),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(didPop, true);
    });

    testWidgets('Form has correct configuration', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FoodTextInputPage()));

      final FoodEntryForm form = tester.widget<FoodEntryForm>(
        find.byType(FoodEntryForm)
      );

      expect(form.maxDescriptionWords, 100);
    });
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPop;

  MockNavigatorObserver({required this.onPop});

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop();
  }
}
