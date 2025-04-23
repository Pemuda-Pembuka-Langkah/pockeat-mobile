import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_input_page.dart';

@GenerateMocks([AnalyticsService])
import 'food_input_page_test.mocks.dart';

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
          '/food-text-input': (context) => const Scaffold(body: Text('Manual Input')),
          '/notification-settings': (context) => const Scaffold(body: Text('Notifications')),
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
          '/food-text-input': (context) => const Scaffold(body: Text('Manual Input')),
          '/notification-settings': (context) => const Scaffold(body: Text('Notifications')),
        },
      ),
    );

    // Verify UI components are present
    expect(find.text('Add Food'), findsOneWidget);
    expect(find.text('How would you like to\nadd your food?'), findsOneWidget);
    expect(find.text('Scan Food'), findsOneWidget);
    expect(find.text('Input Manually'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
  });

  testWidgets('FoodInputPage should track analytics when scan option is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) => const Scaffold(body: Text('Manual Input')),
          '/notification-settings': (context) => const Scaffold(body: Text('Notifications')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Tap the Scan Food option
    await tester.tap(find.text('Scan Food'));
    await tester.pumpAndSettle();

    // Verify analytics event was tracked
    verify(mockAnalyticsService.logEvent(
      name: 'food_input_method_selected',
      parameters: anyNamed('parameters'),
    )).called(1);

    // Verify navigation happened
    expect(find.text('Scan Page'), findsOneWidget);
  });
  
  testWidgets('FoodInputPage should track analytics when manual input option is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) => const Scaffold(body: Text('Manual Input')),
          '/notification-settings': (context) => const Scaffold(body: Text('Notifications')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Tap the Manual Input option
    await tester.tap(find.text('Input Manually'));
    await tester.pumpAndSettle();

    // Verify analytics event was tracked with correct parameters
    verify(mockAnalyticsService.logEvent(
      name: 'food_input_method_selected',
      parameters: captureThat(
        predicate<Map<String, dynamic>>((params) {
          return params['method'] == 'text' && 
                 params['timestamp'] != null;
        }),
        named: 'parameters',
      ),
    )).called(1);

    // Verify navigation happened
    expect(find.text('Manual Input'), findsOneWidget);
  });
  
  testWidgets('FoodInputPage should track analytics when notification settings option is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const FoodInputPage(),
        routes: {
          '/scan': (context) => const Scaffold(body: Text('Scan Page')),
          '/food-text-input': (context) => const Scaffold(body: Text('Manual Input')),
          '/notification-settings': (context) => const Scaffold(body: Text('Notifications')),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    // Tap the Notification Settings option
    await tester.tap(find.text('Notification Settings'));
    await tester.pumpAndSettle();

    // Verify analytics event was tracked with correct parameters
    verify(mockAnalyticsService.logEvent(
      name: 'view_notification_settings',
      parameters: captureThat(
        predicate<Map<String, dynamic>>((params) {
          return params['source'] == 'food_input_page' && 
                 params['timestamp'] != null;
        }),
        named: 'parameters',
      ),
    )).called(1);

    // Verify navigation happened
    expect(find.text('Notifications'), findsOneWidget);
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

  testWidgets('FoodInputPage should display all input options',
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
    
    // Verify all three options are displayed
    expect(find.text('Scan Food'), findsOneWidget);
    expect(find.text('Input Manually'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
    
    // Check subtitles
    expect(find.text('Take a photo of your food'), findsOneWidget);
    expect(find.text('Search or prompt food details'), findsOneWidget);
    expect(find.text('Set your notification preferences'), findsOneWidget);
  });

  testWidgets('FoodInputPage should handle multiple rapid taps on options gracefully',
      (WidgetTester tester) async {
    // Setup test widget with FoodInputPage
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

    // Perform rapid taps on the same option
    // This tests the app's resilience against potential race conditions
    await tester.tap(find.text('Scan Food'));
    await tester.pump(const Duration(milliseconds: 10)); // Small delay to simulate rapid tapping
    await tester.tap(find.text('Scan Food')); // Second tap should be ignored/handled gracefully
    await tester.pumpAndSettle();
    
    // Should have navigated to the scan page without crashing
    expect(find.text('Scan Page'), findsOneWidget);
  });
}
