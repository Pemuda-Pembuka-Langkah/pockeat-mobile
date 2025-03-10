import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_scan_ai/presentation/nutrition_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'dart:io';

class MockFoodScanPhotoService extends Mock implements FoodScanPhotoService {}
class MockFile extends Mock implements File {}

void main() {
  const testImagePath = 'test/assets/test_image.jpg';
  late MockFoodScanPhotoService mockFoodScanPhotoService;

  setUpAll(() {
    // Daftarkan fallback value untuk File
    registerFallbackValue(MockFile());
  });

  setUp(() {
    // Inisialisasi mock service
    mockFoodScanPhotoService = MockFoodScanPhotoService();
    
    // Setup mock untuk mengembalikan data valid
    when(() => mockFoodScanPhotoService.analyzeFoodPhoto(any()))
        .thenAnswer((_) async => FoodAnalysisResult(
          foodName: 'Test Food',
          ingredients: [Ingredient(name: 'Test Ingredient', servings: 1)],
          nutritionInfo: NutritionInfo(
            calories: 250,
            protein: 10,
            carbs: 30,
            fat: 12,
            sodium: 100,
            sugar: 10,
            fiber: 5,
          ),
          warnings: [],
        ));
    
    // Daftarkan mock service ke GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<FoodScanPhotoService>()) {
      getIt.unregister<FoodScanPhotoService>();
    }
    getIt.registerSingleton<FoodScanPhotoService>(mockFoodScanPhotoService);

  });

  tearDown(() {
    // Bersihkan GetIt setelah setiap test
    final getIt = GetIt.instance;
    if (getIt.isRegistered<FoodScanPhotoService>()) {
      getIt.unregister<FoodScanPhotoService>();
    }
  });

  testWidgets('NutritionPage should render correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
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
      MaterialApp(
        home: NutritionPage(imagePath: testImagePath),
      ),
    );

    // Initial state - app bar should be transparent
    tester.widget<Scaffold>(find.byType(Scaffold));

    final initialAppBar =
        tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(initialAppBar.backgroundColor, equals(Colors.transparent));

    // Scroll down
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pump();

    // After scrolling - app bar should have primaryYellow color
    final scrolledAppBar =
        tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(scrolledAppBar.backgroundColor, equals(const Color(0xFFFFE893)));
  });

  testWidgets('NutritionPage should display all nutrient sections',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: NutritionPage(imagePath: testImagePath),
      ),
    );

    // Verify additional nutrients are displayed
    expect(find.text('Fiber'), findsOneWidget);
    expect(find.text('Sugar'), findsOneWidget);
    expect(find.text('Sodium'), findsOneWidget);

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
      MaterialApp(
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
