import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/recommendation_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/screens/analytics_insight_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/detailed_analysis_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/insight_card_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/performance_metrics_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/smart_recommendations_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/today_insights_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/services/analytics_service.dart';

// Generate mock for AnalyticsService
@GenerateMocks([AnalyticsService])
import 'analytics_insight_page_test.mocks.dart';

void main() {
  late MockAnalyticsService mockService;

  // Sample test data
  final testFocusItems = [
    FocusItem(
      icon: Icons.heart_broken,
      title: 'Test Focus',
      subtitle: 'Test Subtitle',
      color: Colors.red,
    )
  ];
  
  final testMetrics = [
    MetricItem(
      label: 'Test Metric',
      value: '100',
      subtext: 'Perfect score',
      color: Colors.blue,
    )
  ];
  
  final testNutritionInsights = InsightCategory(
    title: 'Nutrition',
    icon: Icons.food_bank,
    color: Colors.green,
    insights: [
      InsightItem(
        icon: Icons.check,
        title: 'Test Insight',
        description: 'Test Description',
        action: 'Test Action',
      )
    ],
  );
  
  final testExerciseInsights = InsightCategory(
    title: 'Exercise',
    icon: Icons.fitness_center,
    color: Colors.orange,
    insights: [
      InsightItem(
        icon: Icons.running_with_errors,
        title: 'Test Exercise',
        description: 'Test Description',
        action: 'Test Action',
      )
    ],
  );
  
  final testAnalysisItems = [
    AnalysisItem(
      title: 'Test Analysis',
      value: '87%',
      trend: '+5%',
      color: Colors.purple,
    )
  ];
  
  final testWeeklyPatterns = InsightCategory(
    title: 'Weekly Patterns',
    icon: Icons.calendar_today,
    color: Colors.teal,
    insights: [
      InsightItem(
        icon: Icons.trending_up,
        title: 'Test Pattern',
        description: 'Test Description',
        action: 'Test Action',
      )
    ],
  );
  
  final testRecommendations = [
    RecommendationItem(
      icon: Icons.lightbulb,
      text: 'Test Recommendation',
      detail: 'Test Detail',
      color: Colors.amber,
    )
  ];

  setUp(() {
    mockService = MockAnalyticsService();
  });

  Widget createTestWidget({required MockAnalyticsService service}) {
    return MaterialApp(
      home: AnalyticsInsightPage(service: service),
    );
  }

  group('AnalyticsInsightPage', () {
    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      // Arrange - Use Completer to keep futures pending without immediately resolving them
      final completer = Completer<List<FocusItem>>();
      when(mockService.getFocusItems()).thenAnswer((_) => completer.future);
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => Completer<List<MetricItem>>().future);
      when(mockService.getNutritionInsights()).thenAnswer((_) => Completer<InsightCategory>().future);
      when(mockService.getExerciseInsights()).thenAnswer((_) => Completer<InsightCategory>().future);
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => Completer<List<AnalysisItem>>().future);
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => Completer<InsightCategory>().future);
      when(mockService.getSmartRecommendations()).thenAnswer((_) => Completer<List<RecommendationItem>>().future);

      // Act - Just pump once to render the widget in its initial state
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Assert - CircularProgressIndicator should be visible in the center
      // FIXED: Use findsWidgets instead of findsOneWidget since there are multiple Center widgets
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      
      // Check that none of the content widgets are visible yet
      expect(find.byType(TodayInsightsWidget), findsNothing);
      expect(find.byType(PerformanceMetricsWidget), findsNothing);
      expect(find.byType(SmartRecommendationsWidget), findsNothing);
    });

    testWidgets('should render all widgets when data is loaded successfully', (WidgetTester tester) async {
      // Arrange - Using delayed futures to ensure we can capture the loading state
      final completer1 = Completer<List<FocusItem>>();
      final completer2 = Completer<List<MetricItem>>();
      final completer3 = Completer<InsightCategory>();
      final completer4 = Completer<InsightCategory>();
      final completer5 = Completer<List<AnalysisItem>>();
      final completer6 = Completer<InsightCategory>();
      final completer7 = Completer<List<RecommendationItem>>();
      
      // Setup the mock service with our completers
      when(mockService.getFocusItems()).thenAnswer((_) => completer1.future);
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => completer2.future);
      when(mockService.getNutritionInsights()).thenAnswer((_) => completer3.future);
      when(mockService.getExerciseInsights()).thenAnswer((_) => completer4.future);
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => completer5.future);
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => completer6.future);
      when(mockService.getSmartRecommendations()).thenAnswer((_) => completer7.future);

      // Act - Render the widget
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Initially we should see the loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.byType(Center), findsWidgets);
      
      // Wait for loadData method to complete
      await tester.pump();
      
      // Now we should see the SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Complete all futures with our test data
      completer1.complete(testFocusItems);
      completer2.complete(testMetrics);
      completer3.complete(testNutritionInsights);
      completer4.complete(testExerciseInsights);
      completer5.complete(testAnalysisItems);
      completer6.complete(testWeeklyPatterns);
      completer7.complete(testRecommendations);
      
      // Allow the futures to be processed
      await tester.pumpAndSettle();

      // Assert - All widgets should be rendered
      expect(find.byType(HeaderWidget), findsOneWidget);
      expect(find.byType(TodayInsightsWidget), findsOneWidget);
      expect(find.byType(PerformanceMetricsWidget), findsOneWidget);
      expect(find.byType(InsightCardWidget), findsNWidgets(3)); // 3 InsightCardWidgets
      expect(find.byType(DetailedAnalysisWidget), findsOneWidget);
      expect(find.byType(SmartRecommendationsWidget), findsOneWidget);

      // Verify widget properties
      final todayInsightsWidget = tester.widget<TodayInsightsWidget>(find.byType(TodayInsightsWidget));
      expect(todayInsightsWidget.focusItems, testFocusItems);
      expect(todayInsightsWidget.primaryPink, const Color(0xFFFF6B6B));

      final performanceMetricsWidget = tester.widget<PerformanceMetricsWidget>(find.byType(PerformanceMetricsWidget));
      expect(performanceMetricsWidget.metrics, testMetrics);

      final smartRecommendationsWidget = tester.widget<SmartRecommendationsWidget>(find.byType(SmartRecommendationsWidget));
      expect(smartRecommendationsWidget.recommendations, testRecommendations);
      expect(smartRecommendationsWidget.primaryGreen, const Color(0xFF4ECDC4));

      // No loading indicators or errors should be visible after all futures complete
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error:'), findsNothing);
    });

    testWidgets('should show error state when getFocusItems fails', (WidgetTester tester) async {
      // Arrange
      final testException = Exception('Failed to load focus items');
      when(mockService.getFocusItems()).thenAnswer((_) => Future.error(testException));
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => Future.value(testMetrics));
      when(mockService.getNutritionInsights()).thenAnswer((_) => Future.value(testNutritionInsights));
      when(mockService.getExerciseInsights()).thenAnswer((_) => Future.value(testExerciseInsights));
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => Future.value(testAnalysisItems));
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => Future.value(testWeeklyPatterns));
      when(mockService.getSmartRecommendations()).thenAnswer((_) => Future.value(testRecommendations));

      // Act
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Wait for initial loading state to complete
      await tester.pump();
      
      // Wait for SingleChildScrollView and futures to run
      await tester.pump();
      
      // Allow futures to complete
      await tester.pumpAndSettle();

      // Assert - Error state for focus items should be shown
      expect(find.text('Error: $testException'), findsOneWidget);
      
      // Other widgets should still be rendered
      expect(find.byType(PerformanceMetricsWidget), findsOneWidget);
      expect(find.byType(InsightCardWidget), findsNWidgets(3));
      expect(find.byType(DetailedAnalysisWidget), findsOneWidget);
      expect(find.byType(SmartRecommendationsWidget), findsOneWidget);
    });
    
    testWidgets('should show error state when getPerformanceMetrics fails', (WidgetTester tester) async {
      // Arrange
      final testException = Exception('Failed to load metrics');
      when(mockService.getFocusItems()).thenAnswer((_) => Future.value(testFocusItems));
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => Future.error(testException));
      when(mockService.getNutritionInsights()).thenAnswer((_) => Future.value(testNutritionInsights));
      when(mockService.getExerciseInsights()).thenAnswer((_) => Future.value(testExerciseInsights));
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => Future.value(testAnalysisItems));
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => Future.value(testWeeklyPatterns));
      when(mockService.getSmartRecommendations()).thenAnswer((_) => Future.value(testRecommendations));

      // Act
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Wait for initial loading state to complete
      await tester.pump();
      
      // Wait for SingleChildScrollView and futures to run
      await tester.pump();
      
      // Allow futures to complete
      await tester.pumpAndSettle();

      // Assert - Error state for performance metrics should be shown
      expect(find.text('Error: $testException'), findsOneWidget);
      
      // Other widgets should still be rendered
      expect(find.byType(TodayInsightsWidget), findsOneWidget);
      expect(find.byType(InsightCardWidget), findsNWidgets(3));
      expect(find.byType(DetailedAnalysisWidget), findsOneWidget);
      expect(find.byType(SmartRecommendationsWidget), findsOneWidget);
    });
    
    testWidgets('should show error state when getNutritionInsights fails', (WidgetTester tester) async {
      // Arrange
      final testException = Exception('Failed to load nutrition insights');
      when(mockService.getFocusItems()).thenAnswer((_) => Future.value(testFocusItems));
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => Future.value(testMetrics));
      when(mockService.getNutritionInsights()).thenAnswer((_) => Future.error(testException));
      when(mockService.getExerciseInsights()).thenAnswer((_) => Future.value(testExerciseInsights));
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => Future.value(testAnalysisItems));
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => Future.value(testWeeklyPatterns));
      when(mockService.getSmartRecommendations()).thenAnswer((_) => Future.value(testRecommendations));

      // Act
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Wait for initial loading state to complete
      await tester.pump();
      
      // Wait for SingleChildScrollView and futures to run
      await tester.pump();
      
      // Allow futures to complete
      await tester.pumpAndSettle();

      // Assert - Error state for nutrition insights should be shown
      expect(find.text('Error: $testException'), findsOneWidget);
      
      // Other widgets should still be rendered
      expect(find.byType(TodayInsightsWidget), findsOneWidget);
      expect(find.byType(PerformanceMetricsWidget), findsOneWidget);
      // Only 2 InsightCardWidget instances should be rendered (exercise and weekly patterns)
      expect(find.byType(InsightCardWidget), findsNWidgets(2));
      expect(find.byType(DetailedAnalysisWidget), findsOneWidget);
      expect(find.byType(SmartRecommendationsWidget), findsOneWidget);
    });
    
    testWidgets('should show error state when getExerciseInsights fails', (WidgetTester tester) async {
      // Arrange
      final testException = Exception('Failed to load exercise insights');
      when(mockService.getFocusItems()).thenAnswer((_) => Future.value(testFocusItems));
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => Future.value(testMetrics));
      when(mockService.getNutritionInsights()).thenAnswer((_) => Future.value(testNutritionInsights));
      when(mockService.getExerciseInsights()).thenAnswer((_) => Future.error(testException));
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => Future.value(testAnalysisItems));
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => Future.value(testWeeklyPatterns));
      when(mockService.getSmartRecommendations()).thenAnswer((_) => Future.value(testRecommendations));

      // Act
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Wait for initial loading state to complete
      await tester.pump();
      
      // Wait for SingleChildScrollView and futures to run
      await tester.pump();
      
      // Allow futures to complete
      await tester.pumpAndSettle();

      // Assert - Error state for exercise insights should be shown
      expect(find.text('Error: $testException'), findsOneWidget);
      
      // Other widgets should still be rendered
      expect(find.byType(TodayInsightsWidget), findsOneWidget);
      expect(find.byType(PerformanceMetricsWidget), findsOneWidget);
      // Only 2 InsightCardWidget instances should be rendered (nutrition and weekly patterns)
      expect(find.byType(InsightCardWidget), findsNWidgets(2));
      expect(find.byType(DetailedAnalysisWidget), findsOneWidget);
      expect(find.byType(SmartRecommendationsWidget), findsOneWidget);
    });
    
    testWidgets('should show error state when getDetailedAnalysis fails', (WidgetTester tester) async {
      // Arrange
      final testException = Exception('Failed to load detailed analysis');
      when(mockService.getFocusItems()).thenAnswer((_) => Future.value(testFocusItems));
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => Future.value(testMetrics));
      when(mockService.getNutritionInsights()).thenAnswer((_) => Future.value(testNutritionInsights));
      when(mockService.getExerciseInsights()).thenAnswer((_) => Future.value(testExerciseInsights));
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => Future.error(testException));
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => Future.value(testWeeklyPatterns));
      when(mockService.getSmartRecommendations()).thenAnswer((_) => Future.value(testRecommendations));

      // Act
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Wait for initial loading state to complete
      await tester.pump();
      
      // Wait for SingleChildScrollView and futures to run
      await tester.pump();
      
      // Allow futures to complete
      await tester.pumpAndSettle();

      // Assert - Error state for detailed analysis should be shown
      expect(find.text('Error: $testException'), findsOneWidget);
      
      // Other widgets should still be rendered
      expect(find.byType(TodayInsightsWidget), findsOneWidget);
      expect(find.byType(PerformanceMetricsWidget), findsOneWidget);
      expect(find.byType(InsightCardWidget), findsNWidgets(3));
      expect(find.byType(DetailedAnalysisWidget), findsNothing);
      expect(find.byType(SmartRecommendationsWidget), findsOneWidget);
    });
    
    testWidgets('should show error state when getWeeklyPatterns fails', (WidgetTester tester) async {
      // Arrange
      final testException = Exception('Failed to load weekly patterns');
      when(mockService.getFocusItems()).thenAnswer((_) => Future.value(testFocusItems));
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => Future.value(testMetrics));
      when(mockService.getNutritionInsights()).thenAnswer((_) => Future.value(testNutritionInsights));
      when(mockService.getExerciseInsights()).thenAnswer((_) => Future.value(testExerciseInsights));
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => Future.value(testAnalysisItems));
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => Future.error(testException));
      when(mockService.getSmartRecommendations()).thenAnswer((_) => Future.value(testRecommendations));

      // Act
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Wait for initial loading state to complete
      await tester.pump();
      
      // Wait for SingleChildScrollView and futures to run
      await tester.pump();
      
      // Allow futures to complete
      await tester.pumpAndSettle();

      // Assert - Error state for weekly patterns should be shown
      expect(find.text('Error: $testException'), findsOneWidget);
      
      // Other widgets should still be rendered
      expect(find.byType(TodayInsightsWidget), findsOneWidget);
      expect(find.byType(PerformanceMetricsWidget), findsOneWidget);
      // Only 2 InsightCardWidget instances should be rendered (nutrition and exercise)
      expect(find.byType(InsightCardWidget), findsNWidgets(2));
      expect(find.byType(DetailedAnalysisWidget), findsOneWidget);
      expect(find.byType(SmartRecommendationsWidget), findsOneWidget);
    });
    
    testWidgets('should show error state when getSmartRecommendations fails', (WidgetTester tester) async {
      // Arrange
      final testException = Exception('Failed to load recommendations');
      when(mockService.getFocusItems()).thenAnswer((_) => Future.value(testFocusItems));
      when(mockService.getPerformanceMetrics()).thenAnswer((_) => Future.value(testMetrics));
      when(mockService.getNutritionInsights()).thenAnswer((_) => Future.value(testNutritionInsights));
      when(mockService.getExerciseInsights()).thenAnswer((_) => Future.value(testExerciseInsights));
      when(mockService.getDetailedAnalysis()).thenAnswer((_) => Future.value(testAnalysisItems));
      when(mockService.getWeeklyPatterns()).thenAnswer((_) => Future.value(testWeeklyPatterns));
      when(mockService.getSmartRecommendations()).thenAnswer((_) => Future.error(testException));

      // Act
      await tester.pumpWidget(createTestWidget(service: mockService));
      
      // Wait for initial loading state to complete
      await tester.pump();
      
      // Wait for SingleChildScrollView and futures to run
      await tester.pump();
      
      // Allow futures to complete
      await tester.pumpAndSettle();

      // Assert - Error state for smart recommendations should be shown
      expect(find.text('Error: $testException'), findsOneWidget);
      
      // Other widgets should still be rendered
      expect(find.byType(TodayInsightsWidget), findsOneWidget);
      expect(find.byType(PerformanceMetricsWidget), findsOneWidget);
      expect(find.byType(InsightCardWidget), findsNWidgets(3));
      expect(find.byType(DetailedAnalysisWidget), findsOneWidget);
      expect(find.byType(SmartRecommendationsWidget), findsNothing);
    });
  });
}