// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/widgets/circular_loading_indicator.dart';

void main() {
  group('CircularLoadingIndicator', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      // Act - build widget with only required parameters
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularLoadingIndicator(
              percentage: 50,
              progressColor: Colors.green,
            ),
          ),
        ),
      );

      // Assert - verify content is displayed correctly
      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Check CircularProgressIndicator has correct value
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator)
      );
      expect(progressIndicator.value, equals(0.5)); // 50/100
    });

    testWidgets('should render with custom size and style', (WidgetTester tester) async {
      // Arrange - custom properties
      const double customSize = 200;
      const double customStrokeWidth = 15;
      const TextStyle customTextStyle = TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      // Act - build widget with custom parameters
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularLoadingIndicator(
              percentage: 75,
              size: customSize,
              progressColor: Colors.blue,
              strokeWidth: customStrokeWidth,
              percentageTextStyle: customTextStyle,
            ),
          ),
        ),
      );

      // Assert - verify customizations are applied
      expect(find.text('75%'), findsOneWidget);
      
      // Get the SizedBox that controls the overall size
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );
      
      // Verify custom size is applied
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
      
      // Verify custom text style is applied
      final text = tester.widget<Text>(find.text('75%'));
      expect(text.style, equals(customTextStyle));
      
      // Verify custom stroke width is applied
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator)
      );
      expect(progressIndicator.strokeWidth, equals(customStrokeWidth));
    });

    testWidgets('should handle 0% progress correctly', (WidgetTester tester) async {
      // Act - build widget with 0% progress
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularLoadingIndicator(
              percentage: 0,
              progressColor: Colors.green,
            ),
          ),
        ),
      );

      // Assert - verify content is displayed correctly
      expect(find.text('0%'), findsOneWidget);
      
      // Check CircularProgressIndicator has correct value
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator)
      );
      expect(progressIndicator.value, equals(0));
    });

    testWidgets('should handle 100% progress correctly', (WidgetTester tester) async {
      // Act - build widget with 100% progress
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularLoadingIndicator(
              percentage: 100,
              progressColor: Colors.green,
            ),
          ),
        ),
      );

      // Assert - verify content is displayed correctly
      expect(find.text('100%'), findsOneWidget);
      
      // Check CircularProgressIndicator has correct value
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator)
      );
      expect(progressIndicator.value, equals(1.0));
    });

    testWidgets('should apply custom colors correctly', (WidgetTester tester) async {
      // Arrange - custom colors
      const Color customProgressColor = Colors.purple;
      const Color customBackgroundColor = Colors.orange;

      // Act - build widget with custom colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularLoadingIndicator(
              percentage: 50,
              progressColor: customProgressColor,
              backgroundColor: customBackgroundColor,
            ),
          ),
        ),
      );

      // Assert - verify custom colors are applied
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator)
      );
      
      // Check progress color
      expect(
        (progressIndicator.valueColor as AlwaysStoppedAnimation<Color>).value,
        equals(customProgressColor),
      );
      
      // Check background color (with opacity)
      expect(
        progressIndicator.backgroundColor?.value,
        equals(customBackgroundColor.withOpacity(0.2).value),
      );
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularLoadingIndicator(
              percentage: 50,
              progressColor: Colors.green,
            ),
          ),
        ),
      );

      // Assert - verify widget hierarchy
      // There may be multiple Stack widgets in the widget tree, so we use findsAtLeastNWidgets instead
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Text), findsOneWidget);
      
      // Find the CircularProgressIndicator and verify it exists
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Find the percentage text
      expect(find.text('50%'), findsOneWidget);
    });
  });
}
