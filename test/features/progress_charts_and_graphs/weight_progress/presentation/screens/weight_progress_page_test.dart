// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/screens/weight_progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/current_weight_card_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/goals_card_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/progress_chart_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/weekly_analysis_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/services/weight_service.dart';
import 'weight_progress_page_test.mocks.dart';

@GenerateMocks([WeightService])

void main() {
  late MockWeightService mockService;

  // Test data
  final testWeightStatus = WeightStatus(
    currentWeight: 73.0,
    weightLoss: 2.5,
    progressToGoal: 0.65,
    exerciseContribution: 0.7,
    dietContribution: 0.3,
    bmiValue: 22.5,
    bmiCategory: 'Healthy',
  );

  final testWeightGoal = WeightGoal(
    startingWeight: '75.5 kg',
    startingDate: 'Dec 1, 2024',
    targetWeight: '70.0 kg',
    targetDate: 'Mar 1, 2025',
    remainingWeight: '3.0 kg',
    daysLeft: '35 days left',
    isOnTrack: true,
    insightMessage: 'Maintaining current activity level, you\'ll reach your goal 5 days ahead of schedule!',
  );

  final testWeeklyAnalysis = WeeklyAnalysis(
    weightChange: '-1.2 kg',
    caloriesBurned: '3,500 kcal',
    progressRate: '0.3 kg/week',
    weeklyGoalPercentage: 0.75,
  );

  final testWeightData = {
    'Daily': [
      WeightData('Jan 1', 75.5, 400, 45, 'Running'),
      WeightData('Jan 2', 75.3, 350, 60, 'Weightlifting'),
      WeightData('Jan 3', 75.0, 300, 30, 'HIIT'),
    ],
    'Weekly': [
      WeightData('Week 1', 75.5, 1200, 180, 'Running'),
      WeightData('Week 2', 74.8, 1500, 210, 'Weightlifting'),
    ],
    'Monthly': [
      WeightData('Nov', 76.0, 4800, 600, 'Mixed'),
      WeightData('Dec', 75.0, 5200, 680, 'Mixed'),
      WeightData('Jan', 73.4, 6100, 830, 'Mixed'),
    ],
  };

  const testSelectedPeriod = 'Weekly';

  setUp(() {
    mockService = MockWeightService();

    // Set up default successful responses
    when(mockService.getWeightStatus()).thenAnswer((_) async => testWeightStatus);
    when(mockService.getWeightGoal()).thenAnswer((_) async => testWeightGoal);
    when(mockService.getWeeklyAnalysis()).thenAnswer((_) async => testWeeklyAnalysis);
    when(mockService.getWeightData()).thenAnswer((_) async => testWeightData);
    when(mockService.getSelectedPeriod()).thenAnswer((_) async => testSelectedPeriod);
    when(mockService.setSelectedPeriod(any)).thenAnswer((_) async => {});
  });

  // Helper function to build the widget under test
  Widget createWidget() {
    return MaterialApp(
      home: WeightProgressPage(service: mockService),
    );
  }

  group('WeightProgressPage', () {
    testWidgets('initializes and loads data on start', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());
      
      // Initial rendering with loading indicators
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      
      // Wait for futures to complete
      await tester.pumpAndSettle();
      
      // Assert - Verify service methods were called
      // Note: getWeightStatus is only called once because the same Future is used twice
      verify(mockService.getWeightStatus()).called(1);
      verify(mockService.getWeightGoal()).called(1);
      verify(mockService.getWeeklyAnalysis()).called(1);
      verify(mockService.getWeightData()).called(1);
      verify(mockService.getSelectedPeriod()).called(1);
    });

    testWidgets('renders all components when data loads successfully', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      // Assert - Check if all components are rendered
      expect(find.byType(HeaderWidget), findsOneWidget);
      expect(find.byType(CurrentWeightCardWidget), findsOneWidget);
      expect(find.byType(GoalsCardWidget), findsOneWidget);
      expect(find.byType(WeeklyAnalysisWidget), findsOneWidget);
      expect(find.byType(ProgressChartWidget), findsOneWidget);
      
      // Verify spacing elements - looking for SizedBox with height 24
      // Use findsAtLeastNWidgets instead of findsNWidgets since child widgets
      // might also contain SizedBoxes with height 24
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 24.0
        ), 
        findsAtLeastNWidgets(4)
      ); 
    });
    
    testWidgets('shows error message when WeightStatus future fails', (WidgetTester tester) async {
      // Arrange - Set up error response
      when(mockService.getWeightStatus()).thenAnswer((_) async => throw Exception('Failed to load weight status'));
      
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      // Assert - Error messages should be displayed
      expect(find.text('Error: Exception: Failed to load weight status'), findsWidgets);
    });
    
    testWidgets('shows error message when WeightGoal future fails', (WidgetTester tester) async {
      // Arrange - Set up error response
      when(mockService.getWeightGoal()).thenAnswer((_) async => throw Exception('Failed to load weight goal'));
      
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      // Assert - Error message should be displayed
      expect(find.text('Error: Exception: Failed to load weight goal'), findsOneWidget);
    });
    
    testWidgets('shows error message when WeeklyAnalysis future fails', (WidgetTester tester) async {
      // Arrange - Set up error response
      when(mockService.getWeeklyAnalysis()).thenAnswer((_) async => throw Exception('Failed to load weekly analysis'));
      
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      // Assert - Error message should be displayed
      expect(find.text('Error: Exception: Failed to load weekly analysis'), findsOneWidget);
    });
    
    testWidgets('shows error message when chart data futures fail', (WidgetTester tester) async {
      // Arrange - Set up error response
      when(mockService.getWeightData()).thenAnswer((_) async => throw Exception('Failed to load weight data'));
      
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      // Assert - Error message should be displayed
      expect(find.text('Error: Exception: Failed to load weight data'), findsOneWidget);
    });
    
    testWidgets('calls setSelectedPeriod when period is changed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      // Get the chart widget
      final progressChartWidget = tester.widget<ProgressChartWidget>(
        find.byType(ProgressChartWidget)
      );
      
      // Act - Call the onPeriodChanged callback
      progressChartWidget.onPeriodChanged('Monthly');
      
      // Allow any async operations to complete
      await tester.pumpAndSettle();
      
      // Assert - Verify service method was called with the right parameter
      verify(mockService.setSelectedPeriod('Monthly')).called(1);
    });

    testWidgets('does not call setSelectedPeriod when null period is provided', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      // Get the chart widget
      final progressChartWidget = tester.widget<ProgressChartWidget>(
        find.byType(ProgressChartWidget)
      );
      
      // Act - Call the onPeriodChanged callback with null
      progressChartWidget.onPeriodChanged(null);
      
      // Allow any async operations to complete
      await tester.pumpAndSettle();
      
      // Assert - Verify service method was NOT called
      verifyNever(mockService.setSelectedPeriod(any));
    });
    
    testWidgets('passes correct data to child widgets', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      // Act - Find all the child widgets
      final headerWidget = tester.widget<HeaderWidget>(find.byType(HeaderWidget));
      final currentWeightWidget = tester.widget<CurrentWeightCardWidget>(find.byType(CurrentWeightCardWidget));
      final goalsCardWidget = tester.widget<GoalsCardWidget>(find.byType(GoalsCardWidget));
      final weeklyAnalysisWidget = tester.widget<WeeklyAnalysisWidget>(find.byType(WeeklyAnalysisWidget));
      final progressChartWidget = tester.widget<ProgressChartWidget>(find.byType(ProgressChartWidget));
      
      // Assert - Verify correct data and colors are passed
      // Header Widget
      expect(headerWidget.weightStatus, equals(testWeightStatus));
      expect(headerWidget.primaryPink, equals(const Color(0xFFFF6B6B)));
      
      // Current Weight Widget
      expect(currentWeightWidget.weightStatus, equals(testWeightStatus));
      expect(currentWeightWidget.primaryGreen, equals(const Color(0xFF4ECDC4)));
      
      // Goals Card Widget
      expect(goalsCardWidget.weightGoal, equals(testWeightGoal));
      expect(goalsCardWidget.primaryGreen, equals(const Color(0xFF4ECDC4)));
      expect(goalsCardWidget.primaryPink, equals(const Color(0xFFFF6B6B)));
      expect(goalsCardWidget.primaryYellow, equals(const Color(0xFFFFE893)));
      
      // Weekly Analysis Widget
      expect(weeklyAnalysisWidget.weeklyAnalysis, equals(testWeeklyAnalysis));
      expect(weeklyAnalysisWidget.primaryGreen, equals(const Color(0xFF4ECDC4)));
      expect(weeklyAnalysisWidget.primaryPink, equals(const Color(0xFFFF6B6B)));
      
      // Progress Chart Widget
      expect(progressChartWidget.periodData, equals(testWeightData));
      expect(progressChartWidget.selectedPeriod, equals(testSelectedPeriod));
      expect(progressChartWidget.primaryPink, equals(const Color(0xFFFF6B6B)));
    });
    
    testWidgets('handles delays in data loading', (WidgetTester tester) async {
      // Arrange - Set up delayed responses
      final delayedFuture = Future.delayed(const Duration(milliseconds: 500));
      when(mockService.getWeightStatus()).thenAnswer((_) async {
        await delayedFuture;
        return testWeightStatus;
      });
      when(mockService.getWeightGoal()).thenAnswer((_) async {
        await delayedFuture;
        return testWeightGoal;
      });
      
      // Act - Render widget
      await tester.pumpWidget(createWidget());
      
      // Assert - Should show loading indicators initially
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      
      // Wait for enough time to trigger the animation but not complete the futures
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      
      // Wait for futures to complete
      await tester.pumpAndSettle();
      
      // Should now show the widgets instead of loading indicators
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(HeaderWidget), findsOneWidget);
      expect(find.byType(CurrentWeightCardWidget), findsOneWidget);
      expect(find.byType(GoalsCardWidget), findsOneWidget);
    });
  });
}
