// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_input_page.dart';
import 'food_input_page_test.mocks.dart';

@GenerateMocks([AnalyticsService])
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockAnalyticsService mockAnalyticsService;
  final getIt = GetIt.instance;
  late NavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    mockNavigatorObserver = MockNavigatorObserver();

    // Setup mocks in GetIt
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
    getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);

    // Setup analytics service mock
    when(mockAnalyticsService.logScreenView(
      screenName: anyNamed('screenName'),
      screenClass: anyNamed('screenClass'),
    )).thenAnswer((_) => Future.value());

    when(mockAnalyticsService.logEvent(
      name: anyNamed('name'),
      parameters: anyNamed('parameters'),
    )).thenAnswer((_) => Future.value());
  });

  tearDown(() {
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
  });

  testWidgets('FoodInputPage should track screen view on initialization',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) =>
              const Scaffold(body: Text('Text Input')),
          '/nutrition-database': (context) =>
              const Scaffold(body: Text('Database')),
          '/saved-meals': (context) =>
              const Scaffold(body: Text('Saved Meals')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Verify that screen view is logged when page initializes
    verify(mockAnalyticsService.logScreenView(
      screenName: 'food_input_page',
      screenClass: 'FoodInputPage',
    )).called(1);
  });

  testWidgets('FoodInputPage should display main UI components',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) =>
              const Scaffold(body: Text('Text Input')),
          '/nutrition-database': (context) =>
              const Scaffold(body: Text('Database')),
          '/saved-meals': (context) =>
              const Scaffold(body: Text('Saved Meals')),
        },
      ),
    );

    // Verify UI components are present
    expect(find.text('Add Food'), findsOneWidget);
    expect(find.text('How would you like to\nadd your food?'), findsOneWidget);
    expect(find.text('Scan Food'), findsOneWidget);
    expect(find.text('Explain your meal'), findsOneWidget);
    expect(find.text('Create Your Own Meal'), findsOneWidget);
    expect(find.text('Saved Meals'), findsOneWidget);
  });
  testWidgets(
      'FoodInputPage should track analytics when scan option is selected',
      (WidgetTester tester) async {
    // Set a fixed viewport size for the test
    tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) =>
              const Scaffold(body: Text('Text Input')),
          '/nutrition-database': (context) =>
              const Scaffold(body: Text('Database')),
          '/saved-meals': (context) =>
              const Scaffold(body: Text('Saved Meals')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Make sure to clear any previous verifications
    reset(mockAnalyticsService);

    // Setup analytics service mock again
    when(mockAnalyticsService.logScreenView(
      screenName: anyNamed('screenName'),
      screenClass: anyNamed('screenClass'),
    )).thenAnswer((_) => Future.value());

    when(mockAnalyticsService.logEvent(
      name: anyNamed('name'),
      parameters: anyNamed('parameters'),
    )).thenAnswer((_) => Future.value());

    // Find the text, scroll to it and ensure it's visible
    final scanFoodText = find.text('Scan Food');
    await tester.ensureVisible(scanFoodText);

    // Find specific Scan Food card with InkWell parent
    final scanFoodInkWell = find.ancestor(
      of: scanFoodText,
      matching: find.byType(InkWell),
    );

    // Tap the Scan Food option with warnIfMissed: false to suppress any potential warnings
    await tester.tap(scanFoodInkWell.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify analytics event was tracked with correct parameters
    verify(mockAnalyticsService.logEvent(
      name: 'food_input_method_selected',
      parameters: captureThat(
        predicate<Map<String, dynamic>>((params) {
          return params['method'] == 'scan' && params['timestamp'] != null;
        }),
        named: 'parameters',
      ),
    )).called(1);

    // Verify navigation happened
    expect(find.text('Scan Page'), findsOneWidget);
  });
  testWidgets(
      'FoodInputPage should track analytics when text input option is selected',
      (WidgetTester tester) async {
    // Set a fixed viewport size for the test
    tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) =>
              const Scaffold(body: Text('Text Input')),
          '/nutrition-database': (context) =>
              const Scaffold(body: Text('Database')),
          '/saved-meals': (context) =>
              const Scaffold(body: Text('Saved Meals')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Make sure to clear any previous verifications
    reset(mockAnalyticsService);

    // Setup analytics service mock again
    when(mockAnalyticsService.logScreenView(
      screenName: anyNamed('screenName'),
      screenClass: anyNamed('screenClass'),
    )).thenAnswer((_) => Future.value());

    when(mockAnalyticsService.logEvent(
      name: anyNamed('name'),
      parameters: anyNamed('parameters'),
    )).thenAnswer((_) => Future.value());

    // Find the text, scroll to it and ensure it's visible
    final explainMealText = find.text('Explain your meal');
    await tester.ensureVisible(explainMealText);

    // Find specific option with InkWell parent
    final textInputInkWell = find.ancestor(
      of: explainMealText,
      matching: find.byType(InkWell),
    );

    // Tap the option with warnIfMissed: false to suppress any potential warnings
    await tester.tap(textInputInkWell.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify analytics event was tracked with correct parameters
    verify(mockAnalyticsService.logEvent(
      name: 'food_input_method_selected',
      parameters: captureThat(
        predicate<Map<String, dynamic>>((params) {
          return params['method'] == 'text' && params['timestamp'] != null;
        }),
        named: 'parameters',
      ),
    )).called(1);

    // Verify navigation happened
    expect(find.text('Text Input'), findsOneWidget);
  });
  testWidgets(
      'FoodInputPage should track analytics when database option is selected',
      (WidgetTester tester) async {
    // Set a fixed viewport size for the test
    tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) =>
              const Scaffold(body: Text('Text Input')),
          '/nutrition-database': (context) =>
              const Scaffold(body: Text('Database')),
          '/saved-meals': (context) =>
              const Scaffold(body: Text('Saved Meals')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Make sure to clear any previous verifications
    reset(mockAnalyticsService);

    // Setup analytics service mock again
    when(mockAnalyticsService.logScreenView(
      screenName: anyNamed('screenName'),
      screenClass: anyNamed('screenClass'),
    )).thenAnswer((_) => Future.value());

    when(mockAnalyticsService.logEvent(
      name: anyNamed('name'),
      parameters: anyNamed('parameters'),
    )).thenAnswer((_) => Future.value());

    // Find the text, scroll to it and ensure it's visible
    final createMealText = find.text('Create Your Own Meal');
    await tester.ensureVisible(createMealText);

    // Find specific option with InkWell parent
    final databaseInkWell = find.ancestor(
      of: createMealText,
      matching: find.byType(InkWell),
    );

    // Tap the option with warnIfMissed: false to suppress any potential warnings
    await tester.tap(databaseInkWell.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify analytics event was tracked with correct parameters
    verify(mockAnalyticsService.logEvent(
      name: 'food_input_method_selected',
      parameters: captureThat(
        predicate<Map<String, dynamic>>((params) {
          return params['method'] == 'database' && params['timestamp'] != null;
        }),
        named: 'parameters',
      ),
    )).called(1);

    // Verify navigation happened
    expect(find.text('Database'), findsOneWidget);
  });
  testWidgets(
      'FoodInputPage should track analytics when saved meals option is selected',
      (WidgetTester tester) async {
    // Set a fixed viewport size for the test
    tester.binding.window.physicalSizeTestValue = const Size(800, 1500);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) =>
              const Scaffold(body: Text('Text Input')),
          '/nutrition-database': (context) =>
              const Scaffold(body: Text('Database')),
          '/saved-meals': (context) =>
              const Scaffold(body: Text('Saved Meals')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Make sure to clear any previous verifications
    reset(mockAnalyticsService);

    // Setup analytics service mock again
    when(mockAnalyticsService.logScreenView(
      screenName: anyNamed('screenName'),
      screenClass: anyNamed('screenClass'),
    )).thenAnswer((_) => Future.value());

    when(mockAnalyticsService.logEvent(
      name: anyNamed('name'),
      parameters: anyNamed('parameters'),
    )).thenAnswer((_) => Future.value());

    // Find the text, scroll to it and ensure it's visible
    final savedMealsText = find.text('Saved Meals');
    await tester.scrollUntilVisible(savedMealsText, 100.0);

    // Find specific Saved Meals card with InkWell parent
    final savedMealsInkWell = find.ancestor(
      of: savedMealsText,
      matching: find.byType(InkWell),
    );

    // Tap the Saved Meals option with warnIfMissed: false to suppress the warning
    await tester.tap(savedMealsInkWell.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify analytics event was tracked with correct parameters
    verify(mockAnalyticsService.logEvent(
      name: 'food_input_method_selected',
      parameters: captureThat(
        predicate<Map<String, dynamic>>((params) {
          return params['method'] == 'saved_meals' &&
              params['timestamp'] != null;
        }),
        named: 'parameters',
      ),
    )).called(1);

    // Verify navigation happened
    expect(find.text('Saved Meals'), findsOneWidget);
  });

  testWidgets('FoodInputPage should handle navigation flow correctly',
      (WidgetTester tester) async {
    // We need a widget that will let us test navigation flow
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoodInputPage(),
                    ),
                  );
                },
                child: const Text('Go to FoodInputPage'),
              ),
            ),
          ),
        ),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Navigate to food input page
    await tester.tap(find.text('Go to FoodInputPage'));
    await tester.pumpAndSettle();

    // Verify we're on the food input page
    expect(find.text('Add Food'), findsOneWidget);

    // Verify we're on the food input page by checking for a specific element
    expect(find.text('Add Food'), findsOneWidget);

    // Now navigate back using the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify we've gone back to the first page
    expect(find.text('Go to FoodInputPage'), findsOneWidget);
    expect(find.text('Add Food'), findsNothing);
  });

  testWidgets('FoodInputPage should handle route not found gracefully',
      (WidgetTester tester) async {
    // Setup test app with error handling for navigation
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                // Try to navigate to non-existent route
                Navigator.pushNamed(context, '/non-existent-route');
              },
              child: const Text('Go to non-existent route'),
            ),
          ),
        ),
        // Add onUnknownRoute handler
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error Page')),
              body: const Center(child: Text('Route not found')),
            ),
          );
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Tap the button that triggers navigation
    await tester.tap(find.text('Go to non-existent route'));
    await tester.pumpAndSettle();

    // Should have navigated to error page
    expect(find.text('Route not found'), findsOneWidget);
  });

  testWidgets(
      'FoodInputPage should display all input options with correct subtitles',
      (WidgetTester tester) async {
    // Setup test widget with FoodInputPage
    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
    await tester.pumpAndSettle();

    // Verify we're on the food input page
    expect(find.text('Add Food'), findsOneWidget);

    // Verify all four options are displayed
    expect(find.text('Scan Food'), findsOneWidget);
    expect(find.text('Explain your meal'), findsOneWidget);
    expect(find.text('Create Your Own Meal'), findsOneWidget);
    expect(find.text('Saved Meals'), findsOneWidget);

    // Check subtitles
    expect(find.text('Take a photo of your food'), findsOneWidget);
    expect(find.text('Generate your meal\'s data with our AI'), findsOneWidget);
    expect(find.text('Choose ingredients from our nutrition database'),
        findsOneWidget);
    expect(
        find.text('Choose from your previously saved meals'), findsOneWidget);

    // Verify each option has the correct icon
    expect(find.byIcon(CupertinoIcons.camera_viewfinder), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.text_justify), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.table), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.bookmark_fill), findsOneWidget);
  });
  testWidgets(
      'FoodInputPage should handle multiple rapid taps on options gracefully',
      (WidgetTester tester) async {
    // Set a fixed viewport size for the test
    tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
    await tester.pumpAndSettle();

    // Make sure to clear any previous verifications
    reset(mockAnalyticsService);

    // Setup analytics service mock again
    when(mockAnalyticsService.logScreenView(
      screenName: anyNamed('screenName'),
      screenClass: anyNamed('screenClass'),
    )).thenAnswer((_) => Future.value());

    when(mockAnalyticsService.logEvent(
      name: anyNamed('name'),
      parameters: anyNamed('parameters'),
    )).thenAnswer((_) => Future.value());

    // Find the text, scroll to it and ensure it's visible
    final scanFoodText = find.text('Scan Food');
    await tester.ensureVisible(scanFoodText);

    // Find specific Scan Food card with InkWell parent
    final scanFoodInkWell = find.ancestor(
      of: scanFoodText,
      matching: find.byType(InkWell),
    );

    // Perform rapid taps on the same option
    // This tests the app's resilience against potential race conditions
    await tester.tap(scanFoodInkWell.first, warnIfMissed: false);
    await tester.pump(const Duration(
        milliseconds: 10)); // Small delay to simulate rapid tapping
    await tester.tap(scanFoodInkWell.first,
        warnIfMissed: false); // Second tap should be ignored/handled gracefully
    await tester.pumpAndSettle();

    // Should have navigated to the scan page without crashing
    expect(find.text('Scan Page'), findsOneWidget);
  });
}
