import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/performance_metric_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/metric_card_widget.dart';

void main() {
  group('PerformanceMetricsWidget', () {
    late List<PerformanceMetric> mockMetrics;
    
    setUp(() {
      // Create mock metrics for testing
      mockMetrics = [
        PerformanceMetric(
          label: 'Consistency',
          value: '92%',
          subtext: 'Last week: 87%',
          colorValue: 0xFF4ECDC4, // Green
          icon: Icons.trending_up,
        ),
        PerformanceMetric(
          label: 'Recovery',
          value: '95%',
          subtext: 'Optimal',
          colorValue: 0xFFFF6B6B, // Red
          icon: Icons.battery_charging_full,
        ),
        PerformanceMetric(
          label: 'Calories',
          value: '2,450',
          subtext: 'Daily average',
          colorValue: 0xFFFFE893, // Yellow
          icon: Icons.local_fire_department,
        ),
        PerformanceMetric(
          label: 'Progress',
          value: '78%',
          subtext: 'To goal weight',
          colorValue: 0xFF9B6BFF, // Purple
          icon: Icons.fitness_center,
        ),
      ];
    });

    testWidgets('renders correct title and all metrics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceMetricsWidget(metrics: mockMetrics),
          ),
        ),
      );

      // Verify title
      expect(find.text('Performance Metrics'), findsOneWidget);
      
      // Verify all MetricCardWidget instances are rendered
      expect(find.byType(MetricCardWidget), findsNWidgets(4));
      
      // Verify each metric is displayed
      for (final metric in mockMetrics) {
        expect(find.text(metric.label), findsOneWidget);
        expect(find.text(metric.value), findsOneWidget);
        expect(find.text(metric.subtext), findsOneWidget);
      }
    });

    testWidgets('has correct container styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceMetricsWidget(metrics: mockMetrics),
          ),
        ),
      );

      // Find the main container
      final containerFinder = find.ancestor(
        of: find.text('Performance Metrics'),
        matching: find.byType(Container),
      );
      
      final container = tester.widget<Container>(containerFinder);
      
      // Verify container styling
      expect(container.padding, equals(const EdgeInsets.all(20)));
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
      
      // Verify box shadow
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow![0].color, equals(Colors.black.withOpacity(0.05)));
      expect(decoration.boxShadow![0].blurRadius, equals(10));
      expect(decoration.boxShadow![0].offset, equals(const Offset(0, 2)));
    });

    testWidgets('uses correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceMetricsWidget(metrics: mockMetrics),
          ),
        ),
      );

      // Find the main container
      final mainContainerFinder = find.ancestor(
        of: find.text('Performance Metrics'),
        matching: find.byType(Container),
      );
      
      // Find the main column
      final mainColumnFinder = find.descendant(
        of: mainContainerFinder,
        matching: find.byType(Column),
      ).first;
      
      expect(mainColumnFinder, findsOneWidget);
      
      // Find the main Column widget to check its children
      final mainColumn = tester.widget<Column>(mainColumnFinder);
      
      // Verify that the Column has proper children types
      // There should be a Text, SizedBox, Row, SizedBox, Row in that order
      expect(mainColumn.children.length, equals(5));
      expect(mainColumn.children[0], isA<Text>());
      expect(mainColumn.children[1], isA<SizedBox>());
      expect(mainColumn.children[2], isA<Row>());
      expect(mainColumn.children[3], isA<SizedBox>());
      expect(mainColumn.children[4], isA<Row>());
      
      // Verify Expanded widgets are used for equal sizing
      expect(find.byType(Expanded), findsNWidgets(4));
    });

    testWidgets('has correct spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceMetricsWidget(metrics: mockMetrics),
          ),
        ),
      );

      // Find the main container
      final mainContainerFinder = find.ancestor(
        of: find.text('Performance Metrics'),
        matching: find.byType(Container),
      );
      
      // Verify SizedBox for height after title
      final titleSpacerFinder = find.descendant(
        of: mainContainerFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 20 && widget.width == null
        ),
      );
      expect(titleSpacerFinder, findsOneWidget);
      
      // Verify SizedBox for height between rows
      final rowsSpacerFinder = find.descendant(
        of: mainContainerFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 12 && widget.width == null
        ),
      );
      expect(rowsSpacerFinder, findsOneWidget);
      
      // Verify SizedBox for width between cards in a row
      final cardsSpacerFinder = find.descendant(
        of: mainContainerFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 12 && widget.height == null
        ),
      );
      expect(cardsSpacerFinder, findsNWidgets(2)); // One for each row
    });

    testWidgets('applies correct text style to title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceMetricsWidget(metrics: mockMetrics),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Performance Metrics'));
      expect(titleText.style?.fontSize, equals(16));
      expect(titleText.style?.fontWeight, equals(FontWeight.w600));
      expect(titleText.style?.color, equals(Colors.black87));
    });
    
    testWidgets('correctly displays the first row of metrics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceMetricsWidget(metrics: mockMetrics),
          ),
        ),
      );
      
      // Verify first row metrics
      expect(find.text(mockMetrics[0].label), findsOneWidget);
      expect(find.text(mockMetrics[1].label), findsOneWidget);
    });
    
    testWidgets('correctly displays the second row of metrics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceMetricsWidget(metrics: mockMetrics),
          ),
        ),
      );
      
      // Verify second row metrics
      expect(find.text(mockMetrics[2].label), findsOneWidget);
      expect(find.text(mockMetrics[3].label), findsOneWidget);
    });
  });
}