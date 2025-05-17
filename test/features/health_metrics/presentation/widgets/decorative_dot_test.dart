import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/decorative_dot.dart';

void main() {
  group('DecorativeDot', () {
    testWidgets('should render with top-left positioning', (WidgetTester tester) async {
      // Arrange
      const double top = 20;
      const double left = 30;
      const double size = 15;
      const Color color = Colors.blue;
      const double opacity = 0.5;

      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                DecorativeDot(
                  top: top,
                  left: left,
                  size: size,
                  color: color,
                  opacity: opacity,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert - verify dot is rendered
      expect(find.byType(DecorativeDot), findsOneWidget);
      
      // Check the Container properties
      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.top, equals(top));
      expect(positioned.left, equals(left));
      expect(positioned.right, isNull);
      expect(positioned.bottom, isNull);
    });

    testWidgets('should render with bottom-right positioning', (WidgetTester tester) async {
      // Arrange
      const double bottom = 40;
      const double right = 50;
      const double size = 25;
      const Color color = Colors.red;
      const double opacity = 0.3;

      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                DecorativeDot(
                  bottom: bottom,
                  right: right,
                  size: size,
                  color: color,
                  opacity: opacity,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert - verify dot is rendered
      expect(find.byType(DecorativeDot), findsOneWidget);
      
      // Check the Positioned properties
      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.bottom, equals(bottom));
      expect(positioned.right, equals(right));
      expect(positioned.top, isNull);
      expect(positioned.left, isNull);
    });

    testWidgets('should use correct size and color', (WidgetTester tester) async {
      // Arrange
      const double size = 30;
      const Color color = Colors.green;
      const double opacity = 0.7;

      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                DecorativeDot(
                  top: 10,
                  left: 10,
                  size: size,
                  color: color,
                  opacity: opacity,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert - find the container and check its decoration properties
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Positioned),
          matching: find.byType(Container),
        ),
      );
      
      // Check the decoration properties
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
      expect((decoration.color as Color).value, equals(color.withOpacity(opacity).value));
      
      // Unfortunately we can't directly test container.width and container.height
      // as these are constructor parameters and not accessible properties
    });

    testWidgets('should handle zero opacity correctly', (WidgetTester tester) async {
      // Arrange
      const double size = 10;
      const Color color = Colors.purple;
      const double opacity = 0.0;

      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                DecorativeDot(
                  top: 5,
                  left: 5,
                  size: size,
                  color: color,
                  opacity: opacity,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert - find the container and check its color opacity
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Positioned),
          matching: find.byType(Container),
        ),
      );
      
      final decoration = container.decoration as BoxDecoration;
      
      // Verify the color has zero opacity
      expect((decoration.color as Color).opacity, equals(0.0));
    });
  });
}
