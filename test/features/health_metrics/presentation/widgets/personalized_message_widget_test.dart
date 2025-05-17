import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/personalized_message_widget.dart';

void main() {
  group('PersonalizedMessageWidget', () {
    testWidgets('should display correct content for weight loss goals', (WidgetTester tester) async {
      // Arrange - create list with weight loss goal
      final goals = ['Lose weight', 'Improve fitness'];
      final primaryGreen = Colors.green;
      final textDarkColor = Colors.black;

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalizedMessageWidget(
              goals: goals,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify correct components are displayed
      expect(find.text('Weight Loss Journey'), findsOneWidget);
      expect(
        find.text('You\'re on your way to a healthier, lighter you! Your plan is designed for sustainable results.'),
        findsOneWidget,
      );
      
      // Check for icon presence (can't easily check the exact icon)
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should display correct content for muscle gain goals', (WidgetTester tester) async {
      // Arrange - create list with muscle gain goal
      final goals = ['Gain muscle', 'Build strength'];
      final primaryGreen = Colors.green;
      final textDarkColor = Colors.black;

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalizedMessageWidget(
              goals: goals,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify correct components are displayed
      expect(find.text('Building Strength'), findsOneWidget);
      expect(
        find.text('Get ready to build strength and energy! Your nutrition plan supports your muscle growth goals.'),
        findsOneWidget,
      );
      
      // Check for icon presence (can't easily check the exact icon)
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should display correct content for maintenance goals', (WidgetTester tester) async {
      // Arrange - create list with maintenance goal
      final goals = ['Maintain weight', 'Stay healthy'];
      final primaryGreen = Colors.green;
      final textDarkColor = Colors.black;

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalizedMessageWidget(
              goals: goals,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify correct components are displayed
      expect(find.text('Maintaining Balance'), findsOneWidget);
      expect(
        find.text('Let\'s maintain your awesome progress! Your balanced nutrition plan will help you stay on track.'),
        findsOneWidget,
      );
      
      // Check for icon presence (can't easily check the exact icon)
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should handle empty goals list gracefully', (WidgetTester tester) async {
      // Arrange - create empty goals list
      final goals = <String>[];
      final primaryGreen = Colors.green;
      final textDarkColor = Colors.black;

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalizedMessageWidget(
              goals: goals,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify default message is displayed
      expect(find.text('Maintaining Balance'), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should use correct color scheme and styling', (WidgetTester tester) async {
      // Arrange - setup custom colors
      final goals = ['Lose weight'];
      final primaryGreen = Colors.blue; // Custom color to test
      final textDarkColor = Colors.red; // Custom color to test

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalizedMessageWidget(
              goals: goals,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify icon has the correct color
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(primaryGreen));
      
      // Find the message text and check its style
      final messageText = tester.widget<Text>(
        find.text('You\'re on your way to a healthier, lighter you! Your plan is designed for sustainable results.'),
      );
      
      expect(
        (messageText.style?.color as Color).value,
        equals(textDarkColor.withOpacity(0.7).value),
      );
      
      // Verify the container uses a white background and border in its decoration
      final outerContainer = tester.widget<Container>(find.byType(Container).first);
      final decoration = outerContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.border, isA<Border>());
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Arrange
      final goals = ['Lose weight'];
      final primaryGreen = Colors.green;
      final textDarkColor = Colors.black;

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalizedMessageWidget(
              goals: goals,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify widget hierarchy and structure
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
      
      // Verify the container has a BoxDecoration with white background and border
      final outerContainer = tester.widget<Container>(find.byType(Container).first);
      final decoration = outerContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.border, isA<Border>());
      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.boxShadow, isNotNull);
    });
  });
}
