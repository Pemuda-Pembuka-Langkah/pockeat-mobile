import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/nutrition_page.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutrition_app_bar.dart';
import 'dart:io';

class MockFoodScanPhotoService extends Mock implements FoodScanPhotoService {}

class MockFile extends Mock implements File {}

void main() {
  const testImagePath = 'test/assets/test_image.jpg';
  late Widget nutritionPage;
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

    nutritionPage = MaterialApp(
      home: NutritionPage(imagePath: testImagePath),
    );
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
    await tester.pumpWidget(nutritionPage);
    await tester.pumpAndSettle();

    // Verify that the app bar title is displayed
    expect(find.byType(NutritionAppBar), findsOneWidget);

    // Verify that the food title is displayed
    expect(find.byKey(const Key('food_title')), findsOneWidget);

    // Verify that calories are displayed
    expect(find.byKey(const Key('food_calories')), findsOneWidget);
    expect(find.byKey(const Key('food_calories_text')), findsOneWidget);

    // Verify that Nutritional Information section is present
    expect(find.text('Nutritional Information'), findsOneWidget);

    // Verify that macro nutrients are displayed
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Carbs'), findsOneWidget);
    expect(find.text('Fat'), findsOneWidget);

    // Verify that bottom sheet buttons are present
    expect(find.text('Add to Log'), findsOneWidget);
  });

  testWidgets('NutritionPage should handle scroll events',
      (WidgetTester tester) async {
    await tester.pumpWidget(nutritionPage);
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(nutritionPage);
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    // Verify navigation
    expect(didPop, isTrue);
  });

  testWidgets('Bottom sheet buttons should be tappable',
      (WidgetTester tester) async {
    await tester.pumpWidget(nutritionPage);
    await tester.pumpAndSettle();

    // Tap Add to Log button
    await tester.tap(find.byKey(const Key('add_to_log_button')));
    await tester.pump();

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
