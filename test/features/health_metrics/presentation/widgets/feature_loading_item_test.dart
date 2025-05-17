import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/feature_loading_item.dart';

void main() {
  group('FeatureLoadingItem', () {
    const String title = 'Personalized Profile';
    const IconData icon = Icons.person;
    const Color primaryColor = Colors.green;
    final Color textDarkColor = Colors.black87;

    testWidgets('should render loading state correctly', (WidgetTester tester) async {
      // Act - build widget in loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureLoadingItem(
              title: title,
              icon: icon,
              isLoaded: false,
              primaryColor: primaryColor,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify content is displayed correctly
      expect(find.text(title), findsOneWidget);
      expect(find.text('Processing...'), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
      
      // Check that there's no checkmark in loading state
      expect(find.byIcon(Icons.check), findsNothing);
      
      // Verify icon color is grey when loading
      final iconWidget = tester.widget<Icon>(find.byIcon(icon));
      expect(iconWidget.color, equals(Colors.grey));
    });

    testWidgets('should render completed state correctly', (WidgetTester tester) async {
      // Act - build widget in completed state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureLoadingItem(
              title: title,
              icon: icon,
              isLoaded: true,
              primaryColor: primaryColor,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify content is displayed correctly
      expect(find.text(title), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
      
      // Check that there's a checkmark in completed state
      expect(find.byIcon(Icons.check), findsOneWidget);
      
      // Verify icon color is primaryColor when loaded
      final iconWidget = tester.widget<Icon>(find.byIcon(icon));
      expect(iconWidget.color, equals(primaryColor));
    });

    testWidgets('should apply custom colors correctly', (WidgetTester tester) async {
      // Arrange
      const Color customPrimary = Colors.purple;
      final Color customTextDark = Colors.indigo;

      // Act - build widget with custom colors in loaded state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureLoadingItem(
              title: title,
              icon: icon,
              isLoaded: true,
              primaryColor: customPrimary,
              textDarkColor: customTextDark,
            ),
          ),
        ),
      );

      // Assert - verify custom colors are applied correctly
      // Find the title text
      final titleText = tester.widget<Text>(find.text(title));
      expect(titleText.style?.color, equals(customTextDark));
      
      // Find the status text (should use primary color when loaded)
      final statusText = tester.widget<Text>(find.text('Completed'));
      expect(statusText.style?.color, equals(customPrimary));
      
      // Verify icon color is the custom primary color
      final iconWidget = tester.widget<Icon>(find.byIcon(icon));
      expect(iconWidget.color, equals(customPrimary));
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureLoadingItem(
              title: title,
              icon: icon,
              isLoaded: true,
              primaryColor: primaryColor,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify the widget structure
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsAtLeastNWidgets(2));
      expect(find.byType(AnimatedContainer), findsOneWidget);
      
      // The layout should have title and status in a column
      expect(find.descendant(
        of: find.byType(Column),
        matching: find.text(title),
      ), findsOneWidget);
      
      expect(find.descendant(
        of: find.byType(Column),
        matching: find.text('Completed'),
      ), findsOneWidget);
    });
  });
}
