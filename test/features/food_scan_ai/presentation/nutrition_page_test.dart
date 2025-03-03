import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_scan_ai/presentation/nutrition_page.dart';
import 'package:flutter/cupertino.dart';

void main() {
  const testImagePath = 'test/assets/test_image.jpg';

  testWidgets('NutritionPage should render correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NutritionPage(imagePath: testImagePath),
      ),
    );

    // Verify that the app bar title is displayed
    expect(find.text('Nutrition Analysis'), findsOneWidget);

    // Verify that the food title is displayed
    expect(find.byKey(const Key('food_title')), findsOneWidget);

    // Verify that the portion info is displayed
    expect(find.byKey(const Key('food_portion')), findsOneWidget);

    // Verify that the score is displayed
    expect(find.byKey(const Key('food_score')), findsOneWidget);
    expect(find.byKey(const Key('food_score_text')), findsOneWidget);

    // Verify that calories are displayed
    expect(find.byKey(const Key('food_calories')), findsOneWidget);
    expect(find.byKey(const Key('food_calories_text')), findsOneWidget);
    expect(find.byKey(const Key('food_calories_goal')), findsOneWidget);

    // Verify that AI Analysis section is present
    expect(find.text('AI Analysis'), findsOneWidget);

    // Verify that Nutritional Information section is present
    expect(find.text('Nutritional Information'), findsOneWidget);

    // Verify that macro nutrients are displayed
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Carbs'), findsOneWidget);
    expect(find.text('Fat'), findsOneWidget);

    // Verify that bottom sheet buttons are present
    expect(find.text('Fix'), findsOneWidget);
    expect(find.text('Add to Log'), findsOneWidget);
  });

  testWidgets('NutritionPage should handle scroll events',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NutritionPage(imagePath: testImagePath),
      ),
    );

    // Initial state - app bar should be transparent
    tester.widget<Scaffold>(find.byType(Scaffold));
    final initialAppBar =
        tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(initialAppBar.backgroundColor, equals(Colors.transparent));

    // Scroll down
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pump();

    // After scrolling - app bar should have primaryYellow color
    final scrolledAppBar =
        tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(scrolledAppBar.backgroundColor, equals(const Color(0xFFFFE893)));
  });

  testWidgets('NutritionPage should display all nutrient sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NutritionPage(imagePath: testImagePath),
      ),
    );

    // Verify additional nutrients are displayed
    expect(find.text('Fiber'), findsOneWidget);
    expect(find.text('Sugar'), findsOneWidget);
    expect(find.text('Sodium'), findsOneWidget);
    expect(find.text('Iron'), findsOneWidget);

    // Verify diet tags are displayed
    expect(find.text('High Protein'), findsOneWidget);
    expect(find.text('Low Sugar'), findsOneWidget);
    expect(find.text('Contains Gluten'), findsOneWidget);
  });

  testWidgets('NutritionPage navigation should work correctly',
      (WidgetTester tester) async {
    bool didPop = false;

    await tester.pumpWidget(
      MaterialApp(
        home: NutritionPage(imagePath: testImagePath),
        navigatorObservers: [
          MockNavigatorObserver(onPop: () => didPop = true),
        ],
      ),
    );

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    // Verify navigation
    expect(didPop, isTrue);
  });

  testWidgets('Action buttons should be tappable', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NutritionPage(imagePath: testImagePath),
      ),
    );

    // Verify share button is tappable
    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoButton),
        matching: find.byIcon(CupertinoIcons.share),
      ),
    );
    await tester.pump();

    // Verify more options button is tappable
    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoButton),
        matching: find.byIcon(CupertinoIcons.ellipsis),
      ),
    );
    await tester.pump();

    // Note: Since onPressed is empty, we're just verifying the buttons can be tapped
    // Add more specific assertions here when the button actions are implemented
  });

  testWidgets('Bottom sheet buttons should be tappable',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NutritionPage(imagePath: testImagePath),
      ),
    );

    // Tap Fix button
    await tester.tap(find.byKey(const Key('fix_button')));
    await tester.pump();

    // Tap Add to Log button  
    await tester.tap(find.byKey(const Key('add_to_log_button')));
    await tester.pump();

    // Verify buttons were tapped
    expect(find.byKey(const Key('fix_button')), findsOneWidget);
    expect(find.byKey(const Key('add_to_log_button')), findsOneWidget);
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  final Function onPop;

  MockNavigatorObserver({required this.onPop});

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop();
    super.didPop(route, previousRoute);
  }
}
