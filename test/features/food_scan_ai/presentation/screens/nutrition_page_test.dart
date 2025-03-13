import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/nutrition_page.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutrition_app_bar.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_loading.dart';
import 'dart:io';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_error.dart';

class MockFoodScanPhotoService extends Mock implements FoodScanPhotoService {}

class MockFile extends Mock implements File {}

void main() {
  const testImagePath = 'test/assets/test_image.jpg';
  late Widget nutritionPage;
  late MockFoodScanPhotoService mockFoodScanPhotoService;
  late FoodAnalysisResult testFoodResult;
  late FoodAnalysisResult correctedFoodResult;

  setUpAll(() {
    // Register fallback value for File
    registerFallbackValue(MockFile());
    // Register fallback values for correctFoodAnalysis parameters
    registerFallbackValue(FoodAnalysisResult(
      foodName: '',
      ingredients: [],
      nutritionInfo: NutritionInfo(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sodium: 0,
        sugar: 0,
        fiber: 0,
      ),
      warnings: [],
    ));
    registerFallbackValue('');
  });

  setUp(() {
    // Initialize mock service
    mockFoodScanPhotoService = MockFoodScanPhotoService();

    // Set up test food analysis result
    testFoodResult = FoodAnalysisResult(
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
    );
    
    // Set up corrected food analysis result
    correctedFoodResult = FoodAnalysisResult(
      foodName: 'Corrected Food',
      ingredients: [
        Ingredient(name: 'Corrected Ingredient', servings: 2),
        Ingredient(name: 'New Ingredient', servings: 1),
      ],
      nutritionInfo: NutritionInfo(
        calories: 300,
        protein: 15,
        carbs: 25,
        fat: 15,
        sodium: 120,
        sugar: 8,
        fiber: 6,
      ),
      warnings: [],
    );

    // Setup mock to return valid data
    when(() => mockFoodScanPhotoService.analyzeFoodPhoto(any()))
        .thenAnswer((_) async => testFoodResult);
        
    // Setup mock for correction
    when(() => mockFoodScanPhotoService.correctFoodAnalysis(any(), any()))
        .thenAnswer((_) async => correctedFoodResult);

    // Register mock service to GetIt
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
    // Clean up GetIt after each test
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
    
    // Verify correction button is present
    expect(find.text('Correct Analysis'), findsOneWidget);
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

  testWidgets('NutritionPage should show error screen when analysis fails',
      (WidgetTester tester) async {
    // Setup mock to throw an error
    when(() => mockFoodScanPhotoService.analyzeFoodPhoto(any()))
        .thenThrow(Exception('Failed to analyze food'));

    // Create a new instance with the error-throwing mock
    final errorPage = MaterialApp(
      home: NutritionPage(imagePath: testImagePath),
    );

    await tester.pumpWidget(errorPage);
    await tester.pumpAndSettle();

    // Verify error screen is displayed
    expect(find.byType(FoodAnalysisError), findsOneWidget);
    
    // Verify error message components are displayed
    expect(find.text('Makanan Tidak Terdeteksi'), findsOneWidget);
    expect(
      find.text('AI kami tidak dapat mengidentifikasi makanan dalam foto. Pastikan makanan terlihat jelas dan coba lagi.'),
      findsOneWidget,
    );
    
    // Verify tips section is displayed
    expect(find.text('Tips untuk Foto yang Lebih Baik:'), findsOneWidget);
    
    // Verify buttons are present
    expect(find.text('Foto Ulang'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
  });
  
  // New tests for correction functionality
  testWidgets('Correction button opens correction dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(nutritionPage);
    await tester.pumpAndSettle();

    // Verify correction button is present
    expect(find.text('Correct Analysis'), findsOneWidget);
    
    // Tap the correction button
    await tester.tap(find.text('Correct Analysis'));
    await tester.pumpAndSettle();
    
    // Verify dialog appears
    expect(find.text('Current analysis:'), findsOneWidget);
    expect(find.text('Food: Test Food'), findsOneWidget);
    expect(find.text('Enter your correction:'), findsOneWidget);
    expect(find.text('Submit Correction'), findsOneWidget);
  });
  
  testWidgets('Correction dialog submits data and shows loading state',
      (WidgetTester tester) async {
    // Create a new instance to isolate this test
    final testPage = MaterialApp(
      home: NutritionPage(imagePath: testImagePath),
    );
    
    await tester.pumpWidget(testPage);
    await tester.pumpAndSettle();
    
    // Tap the correction button
    await tester.tap(find.text('Correct Analysis'));
    await tester.pumpAndSettle();
    
    // Enter correction text
    await tester.enterText(find.byType(TextField), 'This is brown rice');
    
    // Submit the correction
    await tester.tap(find.text('Submit Correction'));
    await tester.pump(); // Start animation
    
    // Dialog should be closing now, verify service was called
    verify(() => mockFoodScanPhotoService.correctFoodAnalysis(any(), 'This is brown rice')).called(1);
    
    // Now we should see loading state
    await tester.pump(); // Continue animation
    expect(find.byType(FoodAnalysisLoading), findsOneWidget);
    
    // Wait for the correction to complete
    await tester.pump(const Duration(milliseconds: 100));
    
    // Loading should finish, updated data should be shown
    await tester.pumpAndSettle();
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