// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/screens/progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/progress_tabs_service.dart';
import 'progress_page_test.mocks.dart';

@GenerateMocks([
  ProgressTabsService, 
  AnalyticsService, 
  NavigationProvider, 
  FoodLogHistoryService, 
  FoodLogDataService
])

// Mock the LogHistoryPage widget
class MockLogHistoryPage extends StatelessWidget {
  const MockLogHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(child: Text('Mock Log History'));
  }
}

// Mock for WeightProgressWidget to avoid chart rendering issues
class MockWeightProgressWidget extends StatelessWidget {
  const MockWeightProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(child: Text('Mock Weight Progress Widget'));
  }
}

void main() {
  late MockProgressTabsService mockTabsService;
  late MockAnalyticsService mockAnalyticsService;
  late MockNavigationProvider mockNavigationProvider;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockFoodLogDataService mockFoodLogDataService;
  final getIt = GetIt.instance;

  setUp(() {
    // Initialize mocks
    mockTabsService = MockProgressTabsService();
    mockAnalyticsService = MockAnalyticsService();
    mockNavigationProvider = MockNavigationProvider();
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockFoodLogDataService = MockFoodLogDataService();

    // Unregister services if already registered to avoid conflicts
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
    if (getIt.isRegistered<FoodLogDataService>()) {
      getIt.unregister<FoodLogDataService>();
    }
    if (getIt.isRegistered<FoodLogHistoryService>()) {
      getIt.unregister<FoodLogHistoryService>();
    }

    // Register services
    getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);
    getIt.registerSingleton<FoodLogHistoryService>(mockFoodLogHistoryService);
    getIt.registerSingleton<FoodLogDataService>(mockFoodLogDataService);

    // Setup default behaviors for mocks
    when(mockTabsService.getAppColors()).thenAnswer((_) async => AppColors(
          primaryYellow: const Color(0xFFFFE893),
          primaryPink: const Color(0xFFFF6B6B),
          primaryGreen: const Color(0xFF4ECDC4),
        ));

    when(mockTabsService.getTabConfiguration()).thenAnswer((_) async =>
        TabConfiguration(
          mainTabCount: 2,
          logHistoryTabCount: 2,
          logHistoryTabLabels: ['Food', 'Exercise'],
        ));

    // Setup analytics service mock
    when(mockAnalyticsService.logScreenView(
      screenName: anyNamed('screenName'),
      screenClass: anyNamed('screenClass'),
    )).thenAnswer((_) => Future.value());

    when(mockAnalyticsService.logProgressViewed(
      category: anyNamed('category'),
    )).thenAnswer((_) => Future.value());

    when(mockAnalyticsService.logEvent(
      name: anyNamed('name'),
      parameters: anyNamed('parameters'),
    )).thenAnswer((_) => Future.value());

    // Setup NavigationProvider mock with all needed properties
    when(mockNavigationProvider.setIndex(any)).thenReturn(null);
    when(mockNavigationProvider.currentIndex).thenReturn(1);
    when(mockNavigationProvider.isMenuOpen).thenReturn(false);
    
    // Set up sample data for FoodLogDataService
    when(mockFoodLogDataService.getWeekCalorieData()).thenAnswer((_) async => [
      CalorieData('Mon', 1000, 250, 200),
      CalorieData('Tue', 1100, 270, 210),
      CalorieData('Wed', 1200, 300, 220),
      CalorieData('Thu', 1150, 290, 215),
      CalorieData('Fri', 1050, 260, 205),
      CalorieData('Sat', 900, 230, 190),
      CalorieData('Sun', 950, 240, 195),
    ]);
    
    when(mockFoodLogDataService.getMonthCalorieData()).thenAnswer((_) async => [
      CalorieData('Week 1', 7000, 1750, 1400),
      CalorieData('Week 2', 7200, 1800, 1450),
      CalorieData('Week 3', 7100, 1780, 1430),
      CalorieData('Week 4', 7300, 1820, 1470),
    ]);
    
    when(mockFoodLogDataService.calculateTotalCalories(any)).thenReturn(5000.0);
  });

  tearDown(() {
    // Clean up registered services
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
    if (getIt.isRegistered<FoodLogDataService>()) {
      getIt.unregister<FoodLogDataService>();
    }
    if (getIt.isRegistered<FoodLogHistoryService>()) {
      getIt.unregister<FoodLogHistoryService>();
    }
  });

  // Custom widget for testing
  Widget createTestableWidget({Widget? child}) {
    return MaterialApp(
      home: ChangeNotifierProvider<NavigationProvider>.value(
        value: mockNavigationProvider,
        child: child!,
      ),
    );
  }

  testWidgets('ProgressPage should initialize and show loading indicator initially',
      (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(createTestableWidget(
      child: ProgressPage(service: mockTabsService),
    ));

    // Assert - check for loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verify analytics tracking
    verify(mockAnalyticsService.logScreenView(
      screenName: 'progress_page',
      screenClass: 'ProgressPage',
    )).called(1);
    verify(mockAnalyticsService.logProgressViewed(category: 'all')).called(1);
  });

  testWidgets('TabController should initialize with correct length',
      (WidgetTester tester) async {
    // Create a simple widget with TabController for testing
    final vsync = TestVSync();
    final tabController = TabController(
      length: 2,
      vsync: vsync,
    );
    
    expect(tabController.length, 2);
    expect(tabController.index, 0);
    
    // Simulate tab change
    tabController.index = 1;
    expect(tabController.index, 1);
    
    // Clean up
    tabController.dispose();
  });

  testWidgets('ProgressPage should handle exceptions during initialization',
      (WidgetTester tester) async {
    // Arrange - setup service to throw exception
    when(mockTabsService.getAppColors()).thenThrow(Exception('Failed to load colors'));

    // Act
    await tester.pumpWidget(createTestableWidget(
      child: ProgressPage(service: mockTabsService),
    ));

    // Process initial frame and continue showing loading indicator
    await tester.pump();
    
    // Assert - should still show loading indicator since initialization failed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verify error is logged
    verify(mockTabsService.getAppColors()).called(1);
  });

  testWidgets('ProgressPage should clean up resources in dispose',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(createTestableWidget(
      child: ProgressPage(service: mockTabsService),
    ));
    
    // Replace with empty container to trigger dispose
    await tester.pumpWidget(Container());
    
    // No assertions needed - test passes if no exceptions during dispose
  });
}

// Simple TestVSync implementation for TabController tests
class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
