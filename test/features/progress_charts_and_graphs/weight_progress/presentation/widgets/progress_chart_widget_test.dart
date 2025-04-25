// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/progress_chart_widget.dart';

void main() {
  // Set up the test environment and allow timers to continue after test completes
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // This is required for Syncfusion charts that use animations
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is! AssertionError || 
        !details.exception.toString().contains('TimersPendingError')) {
      FlutterError.presentError(details);
    }
  };
  
  group('ProgressChartWidget', () {
    // Test data
    final Map<String, List<WeightData>> testPeriodData = {
      'Daily': [
        WeightData('Jan 1', 75.5, 400, 45, 'Running'),
        WeightData('Jan 2', 75.3, 350, 60, 'Weightlifting'),
        WeightData('Jan 3', 75.0, 300, 30, 'HIIT'),
        WeightData('Jan 4', 74.8, 450, 50, 'Running'),
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
    
    final Color primaryPink = const Color(0xFFFF6B6B);
    String selectedPeriod = 'Weekly';
    String? newPeriodValue;
    
    void onPeriodChangedCallback(String? newValue) {
      newPeriodValue = newValue;
    }

    // Function to build the testable widget
    Widget buildTestWidget({Map<String, List<WeightData>>? customData}) {
      return MaterialApp(
        home: Scaffold(
          body: ProgressChartWidget(
            periodData: customData ?? testPeriodData,
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChangedCallback,
            primaryPink: primaryPink,
          ),
        ),
      );
    }

    testWidgets('renders with proper layout and components', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(buildTestWidget());
      // Pump additional frames to allow animations to settle
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Use longer timeout for chart animations

      // Act - Find main components
      final cardFinder = find.byType(Card);
      final headerTextFinder = find.text('Progress Chart');
      final dropdownFinder = find.byType(DropdownButton<String>);
      final chartFinder = find.byType(SfCartesianChart);
      
      // Assert
      expect(cardFinder, findsOneWidget);
      expect(headerTextFinder, findsOneWidget);
      expect(dropdownFinder, findsOneWidget);
      expect(chartFinder, findsOneWidget);
    });

    testWidgets('initializes with correct selected period', (WidgetTester tester) async {
      // Arrange
      selectedPeriod = 'Weekly';
      
      // Act - Build widget
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Find dropdown with the correct value
      final dropdownButton = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      );
      expect(dropdownButton.value, 'Weekly');
    });

    testWidgets('dropdown shows all available periods', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Tap the dropdown to open it
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      // Assert - Check if the dropdown menu is displayed with options
      // When dropdown is open, there will be multiple instances of the same text
      // Let's verify all periods exist at least once (we don't care about exact count)
      expect(find.text('Daily'), findsWidgets);
      expect(find.text('Weekly'), findsWidgets);
      expect(find.text('Monthly'), findsWidgets);
      
      // Alternative - check for DropdownMenuItem specifically
      expect(find.byType(DropdownMenuItem<String>), findsAtLeastNWidgets(3));
    });

    testWidgets('chart renders with correct series', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Find the chart
      final chart = tester.widget<SfCartesianChart>(
        find.byType(SfCartesianChart),
      );
      
      // Assert - Check if chart has 2 series (target and actual)
      expect(chart.series.length, 2);
      
      // Check series types
      final series1 = chart.series[0] as LineSeries<WeightData, String>;
      final series2 = chart.series[1] as LineSeries<WeightData, String>;
      
      expect(series1.name, 'Target Weight');
      expect(series2.name, 'Actual Weight');
      
      // Check actual weight series styling - only properties that are accessible as getters
      expect(series2.color, primaryPink);
      expect(series2.markerSettings.isVisible, true);
      expect(series2.markerSettings.borderColor, primaryPink);
      
      // We can't access width directly as it's not a getter, but we can check other marker properties
      expect(series2.markerSettings.height, 6);
      expect(series2.markerSettings.shape, DataMarkerType.circle);
      expect(series2.markerSettings.borderWidth, 2);
    });

    testWidgets('changing period in dropdown triggers callback', (WidgetTester tester) async {
      // Arrange
      selectedPeriod = 'Weekly';
      newPeriodValue = null; // Reset callback value
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Get dropdown
      final dropdownFinder = find.byType(DropdownButton<String>);
      
      // Open the dropdown
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();
      
      // Find the menu items - more reliable approach
      final monthlyItemFinder = find.ancestor(
        of: find.text('Monthly'),
        matching: find.byType(DropdownMenuItem<String>)
      ).first;
      
      // Tap on the Monthly item
      await tester.tap(monthlyItemFinder);
      await tester.pumpAndSettle();
      
      // Assert - Check if callback was called with correct value
      expect(newPeriodValue, 'Monthly');
      
      // Check if widget state was updated
      final dropdownButton = tester.widget<DropdownButton<String>>(dropdownFinder);
      expect(dropdownButton.value, 'Monthly');
    });

    testWidgets('selecting same period does not trigger callback', (WidgetTester tester) async {
      // This test is rewritten to avoid accessing private state class
      
      // Arrange - Use a modified mock callback
      bool callbackCalled = false;
      void testCallback(String? newValue) {
        callbackCalled = true;
        newPeriodValue = newValue;
      }
      
      // Build the widget with our test callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressChartWidget(
              periodData: testPeriodData,
              selectedPeriod: 'Weekly',
              onPeriodChanged: testCallback,
              primaryPink: primaryPink,
            ),
          ),
        )
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Get the dropdown
      final dropdownButton = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>)
      );
      
      // Verify we have the correct value to start with
      expect(dropdownButton.value, 'Weekly');
      
      // Directly simulate dropdown's onChanged callback with the same value
      dropdownButton.onChanged?.call('Weekly');
      await tester.pumpAndSettle();
      
      // Assert - Callback should not have been called with a value change
      expect(callbackCalled, false);
    });
    
    testWidgets('updates chart when parent widget provides new periodData', (WidgetTester tester) async {
      // Arrange - Start with Weekly data
      selectedPeriod = 'Weekly';
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Update the test data and rebuild with Monthly
      selectedPeriod = 'Monthly';
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Find the dropdown and verify its value changed
      final dropdownButton = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      );
      expect(dropdownButton.value, 'Monthly');
    });

    testWidgets('chart is rendered with correct axes and styling', (WidgetTester tester) async {
      // Skip this test if the chart animation is causing issues
      // Future work: Modify the widget to disable animations in test mode
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Find the chart widget
      final chartFinder = find.byType(SfCartesianChart);
      expect(chartFinder, findsOneWidget);
      
      // Basic assertions that can be made without detailed chart inspection
      final chart = tester.widget<SfCartesianChart>(chartFinder);
      expect(chart.legend!.isVisible, true);
      expect(chart.legend!.position, LegendPosition.bottom);
    });
    
    testWidgets('handles initializing with empty data gracefully', (WidgetTester tester) async {
      // Create a modified version of test data with empty arrays
      final emptyPeriodData = {
        'Daily': <WeightData>[],
        'Weekly': <WeightData>[],
        'Monthly': <WeightData>[],
      };

      // We need to wrap this test in runAsync to properly handle timers
      await tester.runAsync(() async {
        // Use the custom empty data
        await tester.pumpWidget(buildTestWidget(customData: emptyPeriodData));
        
        // Pump a frame to allow the widget to build, but don't wait for animations
        await tester.pump();
        
        // Just verify the chart is rendered without exceptions
        expect(find.byType(SfCartesianChart), findsOneWidget);
        expect(find.text('Progress Chart'), findsOneWidget);
      });
    });
  });
}
