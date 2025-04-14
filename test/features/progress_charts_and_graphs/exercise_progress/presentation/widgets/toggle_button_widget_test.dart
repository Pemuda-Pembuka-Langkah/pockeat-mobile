import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/toggle_button_widget.dart';

void main() {
  group('ToggleButtonWidget', () {
    testWidgets('renders correctly when selected', (WidgetTester tester) async {
      bool tapped = false;
      
      // Use standard screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Weekly',
              isSelected: true,
              onTap: () => tapped = true,
              primaryColor: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );
      
      // Verify the button text is displayed
      expect(find.text('Weekly'), findsOneWidget);
      
      // Verify the button appearance is correct when selected
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF4ECDC4)));
      
      // Verify the text style is correct when selected
      final text = tester.widget<Text>(find.text('Weekly'));
      expect(text.style?.color, equals(Colors.white));
      expect(text.style?.fontSize, equals(16.0)); // Large screen font size
      expect(text.style?.fontWeight, equals(FontWeight.w500));
      
      // Tap the button and verify callback was called
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('renders correctly when not selected', (WidgetTester tester) async {
      bool tapped = false;
      
      // Use standard screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Monthly',
              isSelected: false,
              onTap: () => tapped = true,
              primaryColor: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );
      
      // Verify the button appearance is correct when not selected
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.transparent));
      
      // Verify the text style is correct when not selected
      final text = tester.widget<Text>(find.text('Monthly'));
      expect(text.style?.color, equals(Colors.black54));
      expect(text.style?.fontSize, equals(16.0)); // Large screen font size
      
      // Tap the button and verify callback was called
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('uses provided primaryColor', (WidgetTester tester) async {
      final customColor = Color(0xFFFF6B6B); // Custom red color
      
      // Use standard screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Test',
              isSelected: true,
              onTap: () {},
              primaryColor: customColor,
            ),
          ),
        ),
      );
      
      // Verify the custom color is used
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('handles tap correctly', (WidgetTester tester) async {
      int tapCount = 0;
      
      // Use standard screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Test',
              isSelected: false,
              onTap: () => tapCount++,
              primaryColor: Colors.blue,
            ),
          ),
        ),
      );
      
      // Initial state
      expect(tapCount, equals(0));
      
      // Tap once
      await tester.tap(find.byType(GestureDetector));
      expect(tapCount, equals(1));
      
      // Tap again
      await tester.tap(find.byType(GestureDetector));
      expect(tapCount, equals(2));
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('has correct border radius', (WidgetTester tester) async {
      // Use standard screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Test',
              isSelected: true,
              onTap: () {},
              primaryColor: Colors.blue,
            ),
          ),
        ),
      );
      
      // Verify the border radius
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('applies correct padding for large screen', (WidgetTester tester) async {
      // Set large screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleButtonWidget(
              text: 'Test',
              isSelected: true,
              onTap: () {},
              primaryColor: Colors.blue,
            ),
          ),
        ),
      );
      
      // Verify the padding (for large screen)
      final container = tester.widget<Container>(find.byType(Container));
      final screenWidth = 1080.0;
      final expectedPadding = EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 8,
      );
      
      expect(container.padding, equals(expectedPadding));
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('applies correct font size for small screen', (WidgetTester tester) async {
      // Set small screen size (below 360 logical pixels)
      tester.binding.window.physicalSizeTestValue = const Size(700, 1400);
      tester.binding.window.devicePixelRatioTestValue = 2.0; // Makes logical width 350
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Verify we're really on a small screen
                final screenWidth = MediaQuery.of(context).size.width;
                expect(screenWidth, lessThan(360));
                
                return ToggleButtonWidget(
                  text: 'Test',
                  isSelected: true,
                  onTap: () {},
                  primaryColor: Colors.blue,
                );
              },
            ),
          ),
        ),
      );
      
      // Find the text and verify font size is the smaller size
      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.fontSize, equals(14.0)); // Small screen font size
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('applies correct padding for small screen', (WidgetTester tester) async {
      // Set small screen size (below 360 logical pixels)
      tester.binding.window.physicalSizeTestValue = const Size(700, 1400);
      tester.binding.window.devicePixelRatioTestValue = 2.0; // Makes logical width 350
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                
                return ToggleButtonWidget(
                  text: 'Test',
                  isSelected: true,
                  onTap: () {},
                  primaryColor: Colors.blue,
                );
              },
            ),
          ),
        ),
      );
      
      // Verify the padding (for small screen)
      final container = tester.widget<Container>(find.byType(Container));
      final screenWidth = 350.0; // 700/2
      final expectedPadding = EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 8,
      );
      
      expect(container.padding, equals(expectedPadding));
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
  });
}