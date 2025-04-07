import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/toggle_button_widget.dart';

void main() {
  group('ToggleButtonWidget', () {
    testWidgets('renders correctly when selected', (WidgetTester tester) async {
      bool tapped = false;
      const Color customColor = Color(0xFFFF6B6B); // Pink color
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Weekly',
              isSelected: true,
              onTap: () => tapped = true,
              selectedColor: customColor,
            ),
          ),
        ),
      );
      
      // Verify the button text is displayed
      expect(find.text('Weekly'), findsOneWidget);
      
      // Verify the button appearance is correct when selected
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      
      // Verify the text style is correct when selected
      final text = tester.widget<Text>(find.text('Weekly'));
      expect(text.style?.color, equals(Colors.white));
      expect(text.style?.fontSize, equals(14));
      expect(text.style?.fontWeight, equals(FontWeight.w500));
      
      // Verify padding
      expect(container.padding, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
    });

    testWidgets('renders correctly when not selected', (WidgetTester tester) async {
      bool tapped = false;
      const Color customColor = Color(0xFFFF6B6B); // Pink color
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Monthly',
              isSelected: false,
              onTap: () => tapped = true,
              selectedColor: customColor,
            ),
          ),
        ),
      );
      
      // Verify the button text is displayed
      expect(find.text('Monthly'), findsOneWidget);
      
      // Verify the button appearance is correct when not selected
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.transparent));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      
      // Verify the text style is correct when not selected
      final text = tester.widget<Text>(find.text('Monthly'));
      expect(text.style?.color, equals(Colors.black54));
      expect(text.style?.fontSize, equals(14));
      expect(text.style?.fontWeight, equals(FontWeight.w500));
      
      // Verify padding
      expect(container.padding, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      const Color customColor = Color(0xFFFF6B6B); // Pink color
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Weekly',
              isSelected: true,
              onTap: () => tapped = true,
              selectedColor: customColor,
            ),
          ),
        ),
      );
      
      // Initially, the tapped flag should be false
      expect(tapped, isFalse);
      
      // Tap the button
      await tester.tap(find.byType(GestureDetector));
      
      // After tapping, the tapped flag should be true
      expect(tapped, isTrue);
    });

    testWidgets('works with different text values', (WidgetTester tester) async {
      const Color customColor = Color(0xFFFF6B6B); // Pink color
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Custom Text',
              isSelected: true,
              onTap: () {},
              selectedColor: customColor,
            ),
          ),
        ),
      );
      
      // Verify the custom text is displayed
      expect(find.text('Custom Text'), findsOneWidget);
      expect(find.text('Weekly'), findsNothing);
      expect(find.text('Monthly'), findsNothing);
    });

    testWidgets('works with different selected colors', (WidgetTester tester) async {
      const Color customColor = Color(0xFF4ECDC4); // Green color
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Weekly',
              isSelected: true,
              onTap: () {},
              selectedColor: customColor,
            ),
          ),
        ),
      );
      
      // Verify the custom color is applied
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });
  });
}