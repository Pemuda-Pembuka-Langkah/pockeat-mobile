import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/detailed_analysis_widget.dart';

void main() {
  group('DetailedAnalysisWidget', () {
    testWidgets('should render correctly with empty analysis items list',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetailedAnalysisWidget(
              analysisItems: [],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Detailed Analysis'), findsOneWidget);
      expect(find.byType(Row), findsNothing); // No analysis items should be rendered
    });

    testWidgets('should render correctly with a single analysis item',
        (WidgetTester tester) async {
      // Arrange
      final analysisItem = AnalysisItem(
        title: 'Exercise vs. Diet Impact',
        value: '40% Exercise, 60% Diet',
        trend: 'Balanced approach',
        color: Colors.green,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetailedAnalysisWidget(
              analysisItems: [analysisItem],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Detailed Analysis'), findsOneWidget);
      expect(find.text('Exercise vs. Diet Impact'), findsOneWidget);
      expect(find.text('40% Exercise, 60% Diet'), findsOneWidget);
      expect(find.text('Balanced approach'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget); // One analysis item
    });

    testWidgets('should render correctly with multiple analysis items',
        (WidgetTester tester) async {
      // Arrange
      final analysisItems = [
        AnalysisItem(
          title: 'Exercise vs. Diet Impact',
          value: '40% Exercise, 60% Diet',
          trend: 'Balanced approach',
          color: Colors.green,
        ),
        AnalysisItem(
          title: 'Recovery Quality',
          value: 'Optimal on rest days',
          trend: 'Sleep: 7.5h avg',
          color: Colors.pink,
        ),
        AnalysisItem(
          title: 'Progress Rate',
          value: '0.5kg/week',
          trend: 'Sustainable pace',
          color: Colors.orange,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetailedAnalysisWidget(
              analysisItems: analysisItems,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Detailed Analysis'), findsOneWidget);
      
      // First item
      expect(find.text('Exercise vs. Diet Impact'), findsOneWidget);
      expect(find.text('40% Exercise, 60% Diet'), findsOneWidget);
      expect(find.text('Balanced approach'), findsOneWidget);
      
      // Second item
      expect(find.text('Recovery Quality'), findsOneWidget);
      expect(find.text('Optimal on rest days'), findsOneWidget);
      expect(find.text('Sleep: 7.5h avg'), findsOneWidget);
      
      // Third item
      expect(find.text('Progress Rate'), findsOneWidget);
      expect(find.text('0.5kg/week'), findsOneWidget);
      expect(find.text('Sustainable pace'), findsOneWidget);
      
      // Count rows (one per analysis item)
      expect(find.byType(Row), findsNWidgets(3));
      
      // Count SizedBox spacers (should be number of items - 1)
      expect(find.byType(SizedBox), findsNWidgets(3)); // 2 for the items spacing + 1 after the header
    });

    testWidgets('should apply the correct styling to each component',
        (WidgetTester tester) async {
      // Arrange
      final analysisItem = AnalysisItem(
        title: 'Exercise vs. Diet Impact',
        value: '40% Exercise, 60% Diet',
        trend: 'Balanced approach',
        color: Colors.green,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetailedAnalysisWidget(
              analysisItems: [analysisItem],
            ),
          ),
        ),
      );

      // Assert
      // Check container styling
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final Container container = tester.widget(containerFinder);
      expect(container.padding, equals(const EdgeInsets.all(16)));
      
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
      expect(decoration.boxShadow!.length, equals(1));
      
      // Check text styling for header
      final titleFinder = find.text('Detailed Analysis');
      final Text titleWidget = tester.widget(titleFinder);
      expect(titleWidget.style!.fontSize, equals(16));
      expect(titleWidget.style!.fontWeight, equals(FontWeight.w600));
      expect(titleWidget.style!.color, equals(Colors.black87));
      
      // Check text styling for title
      final itemTitleFinder = find.text('Exercise vs. Diet Impact');
      final Text itemTitleWidget = tester.widget(itemTitleFinder);
      expect(itemTitleWidget.style!.fontSize, equals(14));
      expect(itemTitleWidget.style!.color, equals(Colors.black54));
      
      // Check text styling for value
      final valueFinder = find.text('40% Exercise, 60% Diet');
      final Text valueWidget = tester.widget(valueFinder);
      expect(valueWidget.style!.fontSize, equals(14));
      expect(valueWidget.style!.fontWeight, equals(FontWeight.w500));
      expect(valueWidget.style!.color, equals(Colors.black87));
      
      // Check text styling for trend
      final trendFinder = find.text('Balanced approach');
      final Text trendWidget = tester.widget(trendFinder);
      expect(trendWidget.style!.fontSize, equals(12));
      expect(trendWidget.style!.color, equals(Colors.green));
      expect(trendWidget.style!.fontWeight, equals(FontWeight.w500));
    });

    testWidgets('should have correct layout with flex factors',
        (WidgetTester tester) async {
      // Arrange
      final analysisItem = AnalysisItem(
        title: 'Exercise vs. Diet Impact',
        value: '40% Exercise, 60% Diet',
        trend: 'Balanced approach',
        color: Colors.green,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetailedAnalysisWidget(
              analysisItems: [analysisItem],
            ),
          ),
        ),
      );

      // Find the expanded widgets
      final expandedWidgets = tester.widgetList<Expanded>(find.byType(Expanded));
      
      // Assert
      expect(expandedWidgets.length, equals(2));
      expect(expandedWidgets.elementAt(0).flex, equals(2)); // Title column
      expect(expandedWidgets.elementAt(1).flex, equals(3)); // Value and trend column
    });
  });
}