import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/insight_card_widget.dart';

void main() {
  group('InsightCardWidget', () {
    testWidgets('should render with category title and icon', (WidgetTester tester) async {
      // Arrange
      final testCategory = InsightCategory(
        title: 'Nutrition Analysis',
        icon: CupertinoIcons.chart_pie_fill,
        color: Colors.pink,
        insights: [
          InsightItem(
            icon: CupertinoIcons.chart_bar_fill,
            title: 'Macro Distribution',
            description: 'Protein: 15% (Target: 20-25%)',
            action: 'Add lean proteins to meals',
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCardWidget(category: testCategory),
          ),
        ),
      );

      // Assert
      expect(find.text('Nutrition Analysis'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chart_pie_fill), findsOneWidget);
    });

    testWidgets('should render insights list correctly', (WidgetTester tester) async {
      // Arrange
      final testCategory = InsightCategory(
        title: 'Nutrition Analysis',
        icon: CupertinoIcons.chart_pie_fill,
        color: Colors.pink,
        insights: [
          InsightItem(
            icon: CupertinoIcons.chart_bar_fill,
            title: 'Macro Distribution',
            description: 'Protein: 15% (Target: 20-25%)',
            action: 'Add lean proteins to meals',
          ),
          InsightItem(
            icon: CupertinoIcons.graph_circle_fill,
            title: 'Calorie Timing',
            description: '60% calories before 4 PM',
            action: 'Better distribute daily calories',
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCardWidget(category: testCategory),
          ),
        ),
      );

      // Assert - verify all insight titles, descriptions and actions
      expect(find.text('Macro Distribution'), findsOneWidget);
      expect(find.text('Protein: 15% (Target: 20-25%)'), findsOneWidget);
      expect(find.text('Add lean proteins to meals'), findsOneWidget);
      
      expect(find.text('Calorie Timing'), findsOneWidget);
      expect(find.text('60% calories before 4 PM'), findsOneWidget);
      expect(find.text('Better distribute daily calories'), findsOneWidget);
      
      // Verify icons
      expect(find.byIcon(CupertinoIcons.chart_bar_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.graph_circle_fill), findsOneWidget);
    });

    testWidgets('should handle empty insights list', (WidgetTester tester) async {
      // Arrange
      final testCategory = InsightCategory(
        title: 'Empty Category',
        icon: CupertinoIcons.chart_pie_fill,
        color: Colors.blue,
        insights: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCardWidget(category: testCategory),
          ),
        ),
      );

      // Assert
      expect(find.text('Empty Category'), findsOneWidget);
      // No insight-specific elements should be found instead of checking for Padding
      expect(find.text('Add lean proteins to meals'), findsNothing);
      expect(find.byWidgetPredicate((widget) => 
        widget is Container && 
        widget.decoration is BoxDecoration && 
        widget.padding == const EdgeInsets.all(8)), findsNothing);
    });

    testWidgets('should apply correct styling to elements', (WidgetTester tester) async {
      // Arrange
      final testColor = Colors.purple;
      final testCategory = InsightCategory(
        title: 'Styling Test',
        icon: CupertinoIcons.star_fill,
        color: testColor,
        insights: [
          InsightItem(
            icon: CupertinoIcons.chart_bar_fill,
            title: 'Test Insight',
            description: 'Test Description',
            action: 'Test Action',
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCardWidget(category: testCategory),
          ),
        ),
      );

      // Assert - check container styling
      final containerFinder = find.byType(Container).first;
      final Container container = tester.widget(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.boxShadow!.length, 1);
      
      // Check category title style
      final titleFinder = find.text('Styling Test');
      final Text titleWidget = tester.widget(titleFinder);
      expect(titleWidget.style!.fontSize, 16);
      expect(titleWidget.style!.fontWeight, FontWeight.w600);
      expect(titleWidget.style!.color, Colors.black87);
      
      // Check insight title style
      final insightTitleFinder = find.text('Test Insight');
      final Text insightTitleWidget = tester.widget(insightTitleFinder);
      expect(insightTitleWidget.style!.fontSize, 14);
      expect(insightTitleWidget.style!.fontWeight, FontWeight.w500);
      expect(insightTitleWidget.style!.color, Colors.black87);
      
      // Check description style
      final descriptionFinder = find.text('Test Description');
      final Text descriptionWidget = tester.widget(descriptionFinder);
      expect(descriptionWidget.style!.fontSize, 12);
      expect(descriptionWidget.style!.color, Colors.black54);
      
      // Check action style with category color
      final actionFinder = find.text('Test Action');
      final Text actionWidget = tester.widget(actionFinder);
      expect(actionWidget.style!.fontSize, 12);
      expect(actionWidget.style!.fontWeight, FontWeight.w500);
      expect(actionWidget.style!.color, testColor);
      
      // Check icon color matches category color
      final iconFinder = find.byIcon(CupertinoIcons.star_fill);
      final Icon iconWidget = tester.widget(iconFinder);
      expect(iconWidget.color, testColor);
    });

    testWidgets('should render multiple insight items with correct padding', (WidgetTester tester) async {
      // Arrange
      final testCategory = InsightCategory(
        title: 'Multiple Insights Test',
        icon: CupertinoIcons.chart_pie_fill,
        color: Colors.orange,
        insights: List.generate(
          3,
          (index) => InsightItem(
            icon: CupertinoIcons.chart_bar_fill,
            title: 'Insight $index',
            description: 'Description $index',
            action: 'Action $index',
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InsightCardWidget(category: testCategory),
            ),
          ),
        ),
      );

      // Assert
      // Verify all three insights are rendered
      expect(find.text('Insight 0'), findsOneWidget);
      expect(find.text('Insight 1'), findsOneWidget);
      expect(find.text('Insight 2'), findsOneWidget);
      
      // Check that we have the right number of insight action texts instead of counting Paddings
      expect(find.text('Action 0'), findsOneWidget);
      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
      
      // Verify each insight has its own row
      expect(find.byWidgetPredicate((widget) => 
        widget is Row && 
        widget.crossAxisAlignment == CrossAxisAlignment.start), 
        findsNWidgets(3));
      
      // Check the small icon containers exist for each insight
      final iconContainerFinders = find.byWidgetPredicate((widget) => 
        widget is Container && 
        widget.decoration is BoxDecoration && 
        widget.padding == const EdgeInsets.all(8));
      expect(iconContainerFinders, findsNWidgets(3));
    });
  });
}