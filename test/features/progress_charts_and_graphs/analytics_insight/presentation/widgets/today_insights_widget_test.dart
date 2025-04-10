import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/today_insights_widget.dart';

void main() {
  group('TodayInsightsWidget', () {
    // Helper function to create test widget
    Widget createTestWidget({
      required List<FocusItem> focusItems,
      Color primaryPink = Colors.pink,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TodayInsightsWidget(
            focusItems: focusItems,
            primaryPink: primaryPink,
          ),
        ),
      );
    }
    
    testWidgets('should render with title and header icon', (WidgetTester tester) async {
      // Arrange
      final focusItems = [
        FocusItem(
          icon: CupertinoIcons.heart_fill,
          title: 'Test Focus Item',
          subtitle: 'Test Subtitle',
          color: Colors.blue,
        ),
      ];
      
      // Act
      await tester.pumpWidget(createTestWidget(
        focusItems: focusItems,
        primaryPink: Colors.pink,
      ));
      
      // Assert
      expect(find.text('Today\'s Focus'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.star_fill), findsOneWidget);
      
      final headerIconFinder = find.byIcon(CupertinoIcons.star_fill);
      final Icon headerIcon = tester.widget(headerIconFinder);
      expect(headerIcon.color, Colors.pink);
      expect(headerIcon.size, 20);
    });
    
    testWidgets('should render a single focus item correctly', (WidgetTester tester) async {
      // Arrange
      final testColor = Colors.purple;
      final focusItems = [
        FocusItem(
          icon: CupertinoIcons.heart_fill,
          title: 'Complete protein intake',
          subtitle: '20g remaining today',
          color: testColor,
        ),
      ];
      
      // Act
      await tester.pumpWidget(createTestWidget(
        focusItems: focusItems,
      ));
      
      // Assert
      expect(find.text('Complete protein intake'), findsOneWidget);
      expect(find.text('20g remaining today'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
      
      // Check icon color and styling
      final iconFinder = find.byIcon(CupertinoIcons.heart_fill);
      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, testColor);
      expect(icon.size, 20);
      
      // FIXED: Use a more specific predicate to find only the container we want
      final containerFinder = find.byWidgetPredicate((widget) => 
        widget is Container && 
        widget.padding == const EdgeInsets.all(8) &&
        widget.decoration is BoxDecoration);
      
      // Make sure we found exactly one container with our criteria
      expect(containerFinder, findsOneWidget);
      
      final Container container = tester.widget(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, testColor.withOpacity(0.1));
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });
    
    testWidgets('should handle multiple focus items with spacing', (WidgetTester tester) async {
      // Arrange
      final focusItems = [
        FocusItem(
          icon: CupertinoIcons.heart_fill,
          title: 'First Focus Item',
          subtitle: 'First subtitle',
          color: Colors.red,
        ),
        FocusItem(
          icon: CupertinoIcons.flame_fill,
          title: 'Second Focus Item',
          subtitle: 'Second subtitle',
          color: Colors.blue,
        ),
        FocusItem(
          icon: CupertinoIcons.clock_fill,
          title: 'Third Focus Item',
          subtitle: 'Third subtitle',
          color: Colors.green,
        ),
      ];
      
      // Act
      await tester.pumpWidget(createTestWidget(
        focusItems: focusItems,
      ));
      
      // Assert - verify all items are rendered
      expect(find.text('First Focus Item'), findsOneWidget);
      expect(find.text('First subtitle'), findsOneWidget);
      expect(find.text('Second Focus Item'), findsOneWidget);
      expect(find.text('Second subtitle'), findsOneWidget);
      expect(find.text('Third Focus Item'), findsOneWidget);
      expect(find.text('Third subtitle'), findsOneWidget);
      
      expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.flame_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.clock_fill), findsOneWidget);
      
      // Check for SizedBox height: 12 between items (should be 2 for 3 items)
      expect(find.byWidgetPredicate((widget) => 
        widget is SizedBox && widget.height == 12), findsNWidgets(2));
    });
    
    testWidgets('should handle empty focus items list', (WidgetTester tester) async {
      // Arrange
      final focusItems = <FocusItem>[];
      
      // Act
      await tester.pumpWidget(createTestWidget(
        focusItems: focusItems,
      ));
      
      // Assert
      expect(find.text('Today\'s Focus'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.star_fill), findsOneWidget);
      
      // No focus items should be rendered
      expect(find.byWidgetPredicate((widget) => 
        widget is Container && 
        widget.padding == const EdgeInsets.all(8) &&
        widget.decoration is BoxDecoration), findsNothing);
      
      // Only the header container and title should exist
      expect(find.text('First Focus Item'), findsNothing);
      expect(find.text('Second Focus Item'), findsNothing);
    });
    
    testWidgets('should apply correct container styling', (WidgetTester tester) async {
      // Arrange
      final focusItems = [
        FocusItem(
          icon: CupertinoIcons.heart_fill,
          title: 'Test Focus Item',
          subtitle: 'Test subtitle',
          color: Colors.purple,
        ),
      ];
      
      // Act
      await tester.pumpWidget(createTestWidget(
        focusItems: focusItems,
      ));
      
      // Assert - check main container styling
      final containerFinder = find.byType(Container).first;
      final Container container = tester.widget(containerFinder);
      
      // Check container properties
      expect(container.padding, const EdgeInsets.all(16));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow![0].color, Colors.black.withOpacity(0.05));
      expect(decoration.boxShadow![0].blurRadius, 10);
      expect(decoration.boxShadow![0].offset, const Offset(0, 2));
    });
    
    testWidgets('should apply correct text styling to focus items', (WidgetTester tester) async {
      // Arrange
      final focusItems = [
        FocusItem(
          icon: CupertinoIcons.heart_fill,
          title: 'Styling Test',
          subtitle: 'Subtitle styling test',
          color: Colors.purple,
        ),
      ];
      
      // Act
      await tester.pumpWidget(createTestWidget(
        focusItems: focusItems,
      ));
      
      // Assert - check title and subtitle text styling
      final titleFinder = find.text('Styling Test');
      final Text titleWidget = tester.widget(titleFinder);
      expect(titleWidget.style!.fontSize, 14);
      expect(titleWidget.style!.fontWeight, FontWeight.w500);
      expect(titleWidget.style!.color, Colors.black87);
      
      final subtitleFinder = find.text('Subtitle styling test');
      final Text subtitleWidget = tester.widget(subtitleFinder);
      expect(subtitleWidget.style!.fontSize, 12);
      expect(subtitleWidget.style!.color, Colors.black54);
    });
    
    testWidgets('should layout the items with correct structure', (WidgetTester tester) async {
      // Arrange
      final focusItems = [
        FocusItem(
          icon: CupertinoIcons.heart_fill,
          title: 'Layout Test',
          subtitle: 'Testing layout structure',
          color: Colors.purple,
        ),
      ];
      
      // Act
      await tester.pumpWidget(createTestWidget(
        focusItems: focusItems,
      ));
      
      // Assert - check that we have a Column containing a Row for the header and Rows for items
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsAtLeastNWidgets(2)); // Header row + at least one item row
      
      // Verify Expanded widget is used for text column
      expect(find.byType(Expanded), findsOneWidget);
      
      // Check that the text column has the correct cross axis alignment
      final columnFinder = find.descendant(
        of: find.byType(Expanded),
        matching: find.byType(Column),
      );
      final Column column = tester.widget(columnFinder);
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });
    
    testWidgets('should apply different colors for different focus items', (WidgetTester tester) async {
      // Arrange
      final focusItems = [
        FocusItem(
          icon: CupertinoIcons.heart_fill,
          title: 'Red Item',
          subtitle: 'Red subtitle',
          color: Colors.red,
        ),
        FocusItem(
          icon: CupertinoIcons.flame_fill,
          title: 'Blue Item',
          subtitle: 'Blue subtitle',
          color: Colors.blue,
        ),
      ];
      
      // Act
      await tester.pumpWidget(createTestWidget(
        focusItems: focusItems,
      ));
      
      // Assert - check that the icons have the correct colors
      final heartIconFinder = find.byIcon(CupertinoIcons.heart_fill);
      final Icon heartIcon = tester.widget(heartIconFinder);
      expect(heartIcon.color, Colors.red);
      
      final flameIconFinder = find.byIcon(CupertinoIcons.flame_fill);
      final Icon flameIcon = tester.widget(flameIconFinder);
      expect(flameIcon.color, Colors.blue);
      
      // Verify the item containers have the correct background colors with opacity
      final containers = tester.widgetList<Container>(find.byWidgetPredicate(
        (widget) => widget is Container && widget.padding == const EdgeInsets.all(8),
      )).toList();
      
      expect(containers.length, 2);
      
      // First container (for heart icon) should have red with opacity
      final redDecoration = containers[0].decoration as BoxDecoration;
      expect(redDecoration.color, Colors.red.withOpacity(0.1));
      
      // Second container (for flame icon) should have blue with opacity
      final blueDecoration = containers[1].decoration as BoxDecoration;
      expect(blueDecoration.color, Colors.blue.withOpacity(0.1));
    });
  });
}