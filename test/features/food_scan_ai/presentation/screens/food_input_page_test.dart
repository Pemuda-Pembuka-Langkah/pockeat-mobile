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
}
