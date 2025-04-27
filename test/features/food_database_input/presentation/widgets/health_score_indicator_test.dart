import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/health_score_indicator.dart';

void main() {
  group('HealthScoreIndicator', () {
    testWidgets('should display high score correctly',
        (WidgetTester tester) async {
      // Arrange - high score
      const score = 9.5;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthScoreIndicator(
              score: score,
              primaryGreen: Color(0xFF4ECDC4),
              primaryPink: Color(0xFFFF6B6B),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Health: 9.5'), findsOneWidget);
      expect(find.text('(Good)'), findsOneWidget);

      // The color should be green for high scores
      final Container container = tester.widget<Container>(
        find.descendant(
          of: find.byType(HealthScoreIndicator),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      // Check for green color (high score)
      expect((decoration.border as Border).top.color,
          const Color(0xFF4ECDC4).withOpacity(0.5));
    });

    testWidgets('should display medium score correctly',
        (WidgetTester tester) async {
      // Arrange - medium score
      const score = 6.5;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthScoreIndicator(
              score: score,
              primaryGreen: Color(0xFF4ECDC4),
              primaryPink: Color(0xFFFF6B6B),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Health: 6.5'), findsOneWidget);
      expect(find.text('(Moderate)'), findsOneWidget);
    });

    testWidgets('should display low score correctly',
        (WidgetTester tester) async {
      // Arrange - low score
      const score = 3.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthScoreIndicator(
              score: score,
              primaryGreen: Color(0xFF4ECDC4),
              primaryPink: Color(0xFFFF6B6B),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Health: 3.0'), findsOneWidget);
      expect(find.text('(Poor)'), findsOneWidget);

      // The color should be red for low scores
      final Container container = tester.widget<Container>(
        find.descendant(
          of: find.byType(HealthScoreIndicator),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      // Check for pink border color (low score)
      expect((decoration.border as Border).top.color,
          const Color(0xFFFF6B6B).withOpacity(0.5));
    });

    testWidgets('should handle border values correctly',
        (WidgetTester tester) async {
      // Arrange - border values
      final testCases = [
        {'score': 0.0, 'label': '(Poor)'},
        {'score': 3.9, 'label': '(Poor)'},
        {'score': 4.0, 'label': '(Moderate)'},
        {'score': 6.9, 'label': '(Moderate)'},
        {'score': 7.0, 'label': '(Good)'},
        {'score': 10.0, 'label': '(Good)'},
      ];

      for (final testCase in testCases) {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HealthScoreIndicator(
                score: testCase['score'] as double,
                primaryGreen: const Color(0xFF4ECDC4),
                primaryPink: const Color(0xFFFF6B6B),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(testCase['label'] as String), findsOneWidget);
      }
    });
  });
}
