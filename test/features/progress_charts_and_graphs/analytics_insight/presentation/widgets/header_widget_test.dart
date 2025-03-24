import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/header_widget.dart';

void main() {
  group('HeaderWidget', () {
    testWidgets('should render correctly with all expected elements', 
      (WidgetTester tester) async {
      // Arrange - define the test color
      final Color testGreen = Colors.green;
      
      // Act - render the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(primaryGreen: testGreen),
          ),
        ),
      );
      
      // Assert - verify the widget renders correctly
      expect(find.text('Insights & Analytics'), findsOneWidget);
      expect(find.text('Your health journey insights'), findsOneWidget);
      expect(find.text('On Track'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('should apply correct styling to title and subtitle', 
      (WidgetTester tester) async {
      // Arrange
      final Color testGreen = Colors.green;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(primaryGreen: testGreen),
          ),
        ),
      );
      
      // Assert - verify text styles
      final titleFinder = find.text('Insights & Analytics');
      final Text titleWidget = tester.widget(titleFinder);
      expect(titleWidget.style!.fontSize, 20);
      expect(titleWidget.style!.fontWeight, FontWeight.bold);
      expect(titleWidget.style!.color, Colors.black87);
      
      final subtitleFinder = find.text('Your health journey insights');
      final Text subtitleWidget = tester.widget(subtitleFinder);
      expect(subtitleWidget.style!.fontSize, 14);
      expect(subtitleWidget.style!.color, Colors.black54);
    });

    testWidgets('should apply correct styling to status badge', 
      (WidgetTester tester) async {
      // Arrange
      final Color testGreen = Colors.green;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(primaryGreen: testGreen),
          ),
        ),
      );
      
      // Assert - verify status badge styling
      final badgeTextFinder = find.text('On Track');
      final Text badgeTextWidget = tester.widget(badgeTextFinder);
      expect(badgeTextWidget.style!.color, testGreen);
      expect(badgeTextWidget.style!.fontWeight, FontWeight.w600);
      expect(badgeTextWidget.style!.fontSize, 12);
      
      // Verify icon color
      final iconFinder = find.byIcon(Icons.trending_up);
      final Icon iconWidget = tester.widget(iconFinder);
      expect(iconWidget.color, testGreen);
      expect(iconWidget.size, 16);
    });

    testWidgets('should apply correct styling to container', 
      (WidgetTester tester) async {
      // Arrange
      final Color testGreen = Colors.green;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(primaryGreen: testGreen),
          ),
        ),
      );
      
      // Assert - verify container decoration
      final containerFinder = find.byType(Container);
      final Container containerWidget = tester.widget(containerFinder);
      
      // Check container padding
      expect(containerWidget.padding, const EdgeInsets.symmetric(horizontal: 12, vertical: 6));
      
      // Check decoration properties
      final BoxDecoration decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.color, testGreen.withOpacity(0.1));
      expect(decoration.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('should have correct widget hierarchy', 
      (WidgetTester tester) async {
      // Arrange
      final Color testGreen = Colors.green;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(primaryGreen: testGreen),
          ),
        ),
      );
      
      // Assert - verify widget hierarchy
      expect(find.byType(Row), findsAtLeastNWidgets(2)); // Main row and badge row
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(SizedBox), findsNWidgets(2)); // Fixed: expecting 2 SizedBox widgets
      
      // Verify main Row has MainAxisAlignment.spaceBetween
      final rowFinder = find.byType(Row).first;
      final Row rowWidget = tester.widget(rowFinder);
      expect(rowWidget.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    });
  });
}