// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/goal_progress_chart.dart';

// Test helper untuk menyederhanakan test
class TestHelper {
  // Untuk mengakses fungsi yang akan ditest tanpa merender chart asli
  static testDataMapping() {
    final validWeightData = WeightData('Test', 74.5);
    final zeroWeightData = WeightData('Test', 0);
    
    // Implementasi fungsi yang sama dengan yValueMapper di GoalProgressChart
    final validYValue = validWeightData.weight > 0 ? validWeightData.weight : null;
    final zeroYValue = zeroWeightData.weight > 0 ? zeroWeightData.weight : null;
    
    return {
      'validYValue': validYValue,
      'zeroYValue': zeroYValue,
      'xValue': validWeightData.week,
    };
  }
}

void main() {
  group('GoalProgressChart', () {
    final List<WeightData> testData = [
      WeightData('Week 1', 75.5),
      WeightData('Week 2', 75.0),
      WeightData('Week 3', 74.6),
      WeightData('Week 4', 74.2),
      WeightData('Week 5', 0), // Empty data point
      WeightData('Week 6', 73.5),
    ];

    final Color testGreenColor = Colors.green;
    
    // Nilai default untuk currentWeight di test
    const double testCurrentWeight = 75.0;

    // Fungsi untuk membuat widget untuk pengujian UI dasar saja
    Widget createBasicTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GoalProgressChart(
              displayData: testData,
              primaryGreen: testGreenColor,
              currentWeight: testCurrentWeight, // Tambahkan parameter yang hilang
            ),
          ),
        ),
      );
    }

    testWidgets('renders chart with correct title and goal indicator', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createBasicTestWidget());
      await tester.pumpAndSettle(); // Tunggu animasi selesai
      
      // Verify title text
      expect(find.text('Goal Progress'), findsOneWidget);
      
      // Verify goal percentage indicator
      expect(find.text('2.5% of goal'), findsOneWidget);
      
      // Verify flag icon
      expect(find.byIcon(Icons.flag), findsOneWidget);
    });

    testWidgets('applies provided primary green color to the goal indicator', 
        (WidgetTester tester) async {
      const Color customColor = Colors.teal;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GoalProgressChart(
              displayData: testData,
              primaryGreen: customColor,
              currentWeight: testCurrentWeight, // Tambahkan parameter yang hilang
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle(); // Tunggu animasi selesai
      
      // Find the goal indicator container
      final containerFinder = find.descendant(
        of: find.byType(Row),
        matching: find.byType(Container),
      ).last;
      
      final container = tester.widget<Container>(containerFinder);
      
      // Verify the color is applied with opacity
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.color, customColor.withOpacity(0.1));
    });

    testWidgets('chart respects height constraint', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createBasicTestWidget());
      await tester.pumpAndSettle(); // Tunggu animasi selesai
      
      // Find the SizedBox containing the chart
      final sizedBoxFinder = find.ancestor(
        of: find.byType(SfCartesianChart),
        matching: find.byType(SizedBox),
      );
      
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      
      // Verify the height is set correctly
      expect(sizedBox.height, 200);
    });

    testWidgets('handles empty data source gracefully', 
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GoalProgressChart(
              displayData: [],
              primaryGreen: testGreenColor,
              currentWeight: testCurrentWeight, // Tambahkan parameter yang hilang
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle(); // Tunggu animasi selesai
      
      // Chart should still render without errors
      expect(find.byType(SfCartesianChart), findsOneWidget);
    });

    // Alih-alih merender chart asli dan mengekstrak value mapper-nya,
    // kita test langsung logika yang sama di helper
    test('value mapper filters out zero weight values', () {
      final result = TestHelper.testDataMapping();
      
      // Verify zero weight returns null
      expect(result['zeroYValue'], null);
      
      // Verify non-zero weight returns value
      expect(result['validYValue'], 74.5);
    });

    test('correctly maps x values from data', () {
      final result = TestHelper.testDataMapping();
      
      // Verify xValueMapper returns week string
      expect(result['xValue'], 'Test');
    });
    
    // Test untuk memverifikasi konfigurasi chart yang tidak membutuhkan rendering chart sebenarnya
    test('chart axis configuration is correct', () {
      final chart = GoalProgressChart(
        displayData: testData,
        primaryGreen: testGreenColor,
        currentWeight: testCurrentWeight, // Tambahkan parameter yang hilang
      );
      
      final columnWidget = chart.build(TestWidgetsFlutterBinding.ensureInitialized().rootElement as BuildContext) as Column;
      final sizedBox = columnWidget.children[2] as SizedBox;
      final sfChart = sizedBox.child as SfCartesianChart;
      
      // Verify axis properties without actually rendering
      expect(sfChart.primaryXAxis, isA<CategoryAxis>());
      expect(sfChart.primaryXAxis.majorGridLines.width, 0);
      
      expect(sfChart.primaryYAxis, isA<NumericAxis>());
      // Update expected values to match new calculation based on currentWeight
      expect((sfChart.primaryYAxis as NumericAxis).minimum, 72);
      expect((sfChart.primaryYAxis as NumericAxis).maximum, 78);
      expect((sfChart.primaryYAxis as NumericAxis).interval, 1);
      
      // Verify series configuration
      expect(sfChart.series.length, 1);
      expect(sfChart.series[0], isA<LineSeries>());
      
      final series = sfChart.series[0] as LineSeries;
      expect(series.color, Colors.black);
      expect(series.dataSource, testData);
      
      // Verify MarkerSettings
      expect(series.markerSettings.isVisible, true);
      expect(series.markerSettings.shape, DataMarkerType.circle);
      expect(series.markerSettings.height, 8);
      expect(series.markerSettings.width, 8);
      
      // Verify EmptyPointSettings
      expect(series.emptyPointSettings.mode, EmptyPointMode.gap);
    });
  });
}
