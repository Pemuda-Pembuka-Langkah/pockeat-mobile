import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/screens/progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/progress_tabs_service.dart';
import 'package:provider/provider.dart';

// Generate mocks BEFORE class declarations
@GenerateMocks([ProgressTabsService, AnalyticsService, NavigationProvider])
import 'progress_page_test.mocks.dart';

// Mock the LogHistoryPage widget
class MockLogHistoryPage extends StatelessWidget {
  const MockLogHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(child: Text('Mock Log History'));
  }
}

// Mock for the AppBarWidget to avoid widget loading issues
class MockAppBarWidget extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onCalendarPressed;

  const MockAppBarWidget({
    super.key,
    required this.colors,
    required this.onCalendarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(title: Text('Mock App Bar'));
  }
}

// Mock for CustomBottomNavBar to avoid widget loading issues
class MockCustomBottomNavBar extends StatelessWidget {
  const MockCustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 50);
  }
}

void main() {
  late MockProgressTabsService mockTabsService;
  late MockAnalyticsService mockAnalyticsService;
  late MockNavigationProvider mockNavigationProvider;
  final getIt = GetIt.instance;

  setUp(() {
    mockTabsService = MockProgressTabsService();
    mockAnalyticsService = MockAnalyticsService();
    mockNavigationProvider = MockNavigationProvider();

    // Setup mocks in GetIt
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
    getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);

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
  });

  tearDown(() {
    // Clean up registered services
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
  });

  // Custom widget for testing to avoid actual dependencies
  Widget createTestableWidget({Widget? child}) {
    return MaterialApp(
      home: ChangeNotifierProvider<NavigationProvider>.value(
        value: mockNavigationProvider,
        child: child!,
      ),
    );
  }

  // Simple test that just verifies initialization without trying to render actual UI
  testWidgets('ProgressPage should initialize and show loading indicator initially',
      (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(createTestableWidget(
      child: ProgressPage(service: mockTabsService),
    ));

    // Assert - just check for loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verify analytics tracking
    verify(mockAnalyticsService.logScreenView(
      screenName: 'progress_page',
      screenClass: 'ProgressPage',
    )).called(1);
    verify(mockAnalyticsService.logProgressViewed(category: 'all')).called(1);
  });

  // Testing the standalone UnifiedInsightsWidget is simpler and more reliable
  testWidgets('UnifiedInsightsWidget should render correctly',
      (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(MaterialApp(
      home: const UnifiedInsightsWidget(),
    ));

    // Assert
    expect(find.text('Progress Insights'), findsOneWidget);
    expect(find.text('Unified Progress Insights'), findsOneWidget);
    expect(find.text('This section is being redesigned to show all your progress metrics in one place'), findsOneWidget);
    expect(find.byIcon(Icons.construction), findsOneWidget);
  });

  testWidgets('TabController should handle tab changes correctly',
      (WidgetTester tester) async {
    // This is a simple test just for the TabController behavior
    final vsync = TestVSync();
    final tabController = TabController(
      length: 2,
      vsync: vsync,
    );
    
    // Simulate tab change
    tabController.index = 1;
    
    // Verify the tab controller updates the index
    expect(tabController.index, 1);
  });

  // Test that exceptions are handled properly
  testWidgets('ProgressPage should handle exceptions during initialization',
      (WidgetTester tester) async {
    // Arrange - setup service to throw exception
    when(mockTabsService.getAppColors()).thenThrow(Exception('Failed to load colors'));

    // Act
    await tester.pumpWidget(createTestableWidget(
      child: ProgressPage(service: mockTabsService),
    ));

    // Pump a few frames but don't use pumpAndSettle to avoid timeout
    await tester.pump(); // Process initial build
    await tester.pump(const Duration(milliseconds: 50)); // Process futures

    // Assert - should still show loading indicator since initialization failed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // A simpler test for dispose to ensure no exceptions
  testWidgets('ProgressPage should clean up resources in dispose',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(createTestableWidget(
      child: ProgressPage(service: mockTabsService),
    ));
    
    // Replace with empty container to trigger dispose
    await tester.pumpWidget(Container());
    
    // No need for assertions - test passes if no exceptions during dispose
  });
}

// Simple TestVSync implementation for TabController tests
class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}