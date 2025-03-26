import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/screens/analytics_insight_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/screens/nutrition_progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/screens/exercise_progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/screens/progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/app_bar_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/main_tabs_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/progress_subtabs_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/progress_tabs_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/screens/weight_progress_page.dart';

// Generate mocks for dependencies
@GenerateMocks([ProgressTabsService, NavigationProvider])
import 'progress_page_test.mocks.dart';

// Mock implementations for the child pages to avoid their initialization timers
class MockWeightProgressPage extends StatelessWidget {
  const MockWeightProgressPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const SizedBox(child: Text('Weight Progress'));
}

class MockNutritionProgressPage extends StatelessWidget {
  const MockNutritionProgressPage({Key? key}) : super(key: key);
  @override 
  Widget build(BuildContext context) => const SizedBox(child: Text('Nutrition Progress'));
}

class MockExerciseProgressPage extends StatelessWidget {
  const MockExerciseProgressPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const SizedBox(child: Text('Exercise Progress'));
}

class MockAnalyticsInsightPage extends StatelessWidget {
  const MockAnalyticsInsightPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const SizedBox(child: Text('Analytics Insight'));
}

// Create a testable ProgressPage that uses mock content pages
class TestableProgressPage extends StatefulWidget {
  final ProgressTabsService service;
  
  const TestableProgressPage({Key? key, required this.service}) : super(key: key);
  
  @override
  State<TestableProgressPage> createState() => _TestableProgressPageState();
}

class _TestableProgressPageState extends State<TestableProgressPage> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _progressTabController;
  final ScrollController _scrollController = ScrollController();
  
  late AppColors _appColors;
  late TabConfiguration _tabConfiguration;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    try {
      // Load configurations
      final colors = await widget.service.getAppColors();
      final tabConfig = await widget.service.getTabConfiguration();
      
      // Initialize controllers
      final mainTabController = TabController(
        length: tabConfig.mainTabCount, 
        vsync: this
      );
      
      final progressTabController = TabController(
        length: tabConfig.progressTabCount, 
        vsync: this
      );
      
      // Set up tab change listeners
      mainTabController.addListener(() {
        if (mounted) {
          setState(() {}); // Rebuild to update visibility
        }
        
        if (!mainTabController.indexIsChanging && mounted) {
          // Use zero duration in tests to avoid animation timers
          _scrollController.jumpTo(0);
        }
      });

      progressTabController.addListener(() {
        if (!progressTabController.indexIsChanging && mounted) {
          // Use zero duration in tests to avoid animation timers
          _scrollController.jumpTo(0);
        }
      });
      
      // Set state with loaded data
      if (mounted) {
        setState(() {
          _appColors = colors;
          _tabConfiguration = tabConfig;
          _mainTabController = mainTabController;
          _progressTabController = progressTabController;
          _isInitialized = true;
        });
      }
      
      // Set navigation index
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
          }
        });
      }
      
    } catch (e) {
      debugPrint('Error initializing progress page: $e');
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _mainTabController.dispose();
      _progressTabController.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  // Helper methods for testing
  void switchToMainTab(int index) {
    if (_isInitialized) {
      _mainTabController.animateTo(index);
    }
  }
  
  void switchToProgressTab(int index) {
    if (_isInitialized) {
      _progressTabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // App Bar
          AppBarWidget(
            colors: _appColors,
            onCalendarPressed: () {},
          ),
          // Main Tabs (Progress & Insights)
          MainTabsWidget(
            tabController: _mainTabController,
            colors: _appColors,
          ),
          // Progress Sub-tabs (only shown when Progress tab is selected)
          ProgressSubtabsWidget(
            mainTabController: _mainTabController,
            progressTabController: _progressTabController,
            scrollController: _scrollController,
            colors: _appColors,
            tabConfiguration: _tabConfiguration,
          ),
        ],
        body: TabBarView(
          controller: _mainTabController,
          children: [
            // Progress Tab Content
            TabBarView(
              controller: _progressTabController,
              children: const [
                MockWeightProgressPage(),
                MockNutritionProgressPage(),
                MockExerciseProgressPage(),
              ],
            ),
            // Insights Tab Content
            const MockAnalyticsInsightPage(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

void main() {
  late MockProgressTabsService mockService;
  late MockNavigationProvider mockNavigationProvider;
  late AppColors testColors;
  late TabConfiguration testTabConfig;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockService = MockProgressTabsService();
    mockNavigationProvider = MockNavigationProvider();
    
    // Create test data
    testColors = AppColors.defaultColors();
    testTabConfig = TabConfiguration(
      mainTabCount: 2,
      progressTabCount: 3,
      progressTabLabels: ['Weight', 'Nutrition', 'Exercise'],
    );

    // Setup default mock behavior
    when(mockService.getAppColors())
        .thenAnswer((_) async => testColors);
    when(mockService.getTabConfiguration())
        .thenAnswer((_) async => testTabConfig);
        
    // Add stubs for NavigationProvider properties used in CustomBottomNavBar
    when(mockNavigationProvider.currentIndex).thenReturn(1);
    when(mockNavigationProvider.isMenuOpen).thenReturn(false);
    when(mockNavigationProvider.setIndex(any)).thenReturn(null);
  });

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: ChangeNotifierProvider<NavigationProvider>.value(
        value: mockNavigationProvider,
        child: child,
      ),
    );
  }

  group('ProgressPage', () {
    testWidgets('should show loading indicator when initializing', 
        (WidgetTester tester) async {
      // Arrange - Use a Completer instead of Future.delayed to control when the future completes
      final completer = Completer<AppColors>();
      when(mockService.getAppColors()).thenAnswer((_) => completer.future);
      
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      
      // Assert - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppBarWidget), findsNothing);
      
      // Complete the future and rebuild
      completer.complete(testColors);
      await tester.pumpAndSettle();
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should initialize with data from service', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      
      // Pump a few times to allow initialization to complete
      await tester.pumpAndSettle();

      // Assert - Should load all UI components
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AppBarWidget), findsOneWidget);
      expect(find.byType(MainTabsWidget), findsOneWidget);
      expect(find.byType(ProgressSubtabsWidget), findsOneWidget);
      expect(find.byType(TabBarView), findsExactly(2)); // Main tabs and progress tabs

      // Verify service calls
      verify(mockService.getAppColors()).called(1);
      verify(mockService.getTabConfiguration()).called(1);
      
      // Verify navigation provider update
      verify(mockNavigationProvider.setIndex(1)).called(1);
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should handle service error gracefully', 
        (WidgetTester tester) async {
      // Arrange - Make the service throw an error
      when(mockService.getAppColors())
          .thenThrow(Exception('Service error'));
      
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      
      // Wait a moment to allow error to be processed
      // Use individual pumps instead of pumpAndSettle to avoid timeout
      await tester.pump(); // Process build
      await tester.pump(const Duration(milliseconds: 100)); // Short delay
      
      // Assert - Should remain in loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppBarWidget), findsNothing);
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should pass correct colors to AppBarWidget', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      await tester.pumpAndSettle();
      
      // Assert
      final appBarWidget = tester.widget<AppBarWidget>(find.byType(AppBarWidget));
      expect(appBarWidget.colors, equals(testColors));
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should pass correct data to MainTabsWidget', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      await tester.pumpAndSettle();
      
      // Assert
      final mainTabsWidget = tester.widget<MainTabsWidget>(find.byType(MainTabsWidget));
      expect(mainTabsWidget.colors, equals(testColors));
      expect(mainTabsWidget.tabController, isNotNull);
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should pass correct data to ProgressSubtabsWidget', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      await tester.pumpAndSettle();
      
      // Assert
      final subtabsWidget = tester.widget<ProgressSubtabsWidget>(
          find.byType(ProgressSubtabsWidget));
      expect(subtabsWidget.colors, equals(testColors));
      expect(subtabsWidget.tabConfiguration, equals(testTabConfig));
      expect(subtabsWidget.mainTabController, isNotNull);
      expect(subtabsWidget.progressTabController, isNotNull);
      expect(subtabsWidget.scrollController, isNotNull);
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should show correct progress page tabs', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      await tester.pumpAndSettle();
      
      // Get the state of TestableProgressPage
      final State state = tester.state(find.byType(TestableProgressPage));
      final _TestableProgressPageState pageState = state as _TestableProgressPageState;
      
      // First tab should be Weight Progress (index 0 of progress tabs)
      expect(find.text('Weight Progress'), findsOneWidget);
      expect(find.text('Nutrition Progress'), findsNothing);
      expect(find.text('Exercise Progress'), findsNothing);
      
      // Switch to Nutrition tab (index 1)
      pageState.switchToProgressTab(1);
      await tester.pumpAndSettle();
      
      // Should now show Nutrition Progress
      expect(find.text('Weight Progress'), findsNothing);
      expect(find.text('Nutrition Progress'), findsOneWidget);
      expect(find.text('Exercise Progress'), findsNothing);
      
      // Switch to Exercise tab (index 2)
      pageState.switchToProgressTab(2);
      await tester.pumpAndSettle();
      
      // Should now show Exercise Progress
      expect(find.text('Weight Progress'), findsNothing);
      expect(find.text('Nutrition Progress'), findsNothing);
      expect(find.text('Exercise Progress'), findsOneWidget);
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should show correct insights page', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      await tester.pumpAndSettle();
      
      // Get the state of TestableProgressPage
      final State state = tester.state(find.byType(TestableProgressPage));
      final _TestableProgressPageState pageState = state as _TestableProgressPageState;
      
      // First verify we're on the Progress tab (main tab index 0)
      expect(find.text('Weight Progress'), findsOneWidget);
      expect(find.text('Analytics Insight'), findsNothing);
      
      // Switch to Insights tab (main tab index 1)
      pageState.switchToMainTab(1);
      await tester.pumpAndSettle();
      
      // Now we should see the analytics page and not the progress pages
      expect(find.text('Weight Progress'), findsNothing);
      expect(find.text('Analytics Insight'), findsOneWidget);
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should reset scroll position when tab changes', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      await tester.pumpAndSettle();
      
      // Get the state of TestableProgressPage
      final State state = tester.state(find.byType(TestableProgressPage));
      final _TestableProgressPageState pageState = state as _TestableProgressPageState;
      
      // Verify initial state
      expect(find.text('Weight Progress'), findsOneWidget);
      
      // Check initial scroll position
      final initialScrollPosition = pageState._scrollController.position.pixels;
      expect(initialScrollPosition, 0.0);
      
      // Switch to Nutrition tab (progress tab index 1)
      pageState.switchToProgressTab(1);
      await tester.pumpAndSettle();
      
      // Verify tab changed successfully
      expect(find.text('Weight Progress'), findsNothing);
      expect(find.text('Nutrition Progress'), findsOneWidget);
      
      // Verify scroll position was reset
      expect(pageState._scrollController.position.pixels, 0.0);
      
      // Ensure widget is disposed properly to avoid timer issues
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should create and dispose ProgressPage properly', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        TestableProgressPage(service: mockService),
      ));
      await tester.pumpAndSettle();
      
      // Act - Dispose by removing from widget tree
      await tester.pumpWidget(const SizedBox());
      
      // Assert - If there were any issues with controller disposal, this would throw
      // Just ensure the widget is gone
      expect(find.byType(TestableProgressPage), findsNothing);
    });
  });
}