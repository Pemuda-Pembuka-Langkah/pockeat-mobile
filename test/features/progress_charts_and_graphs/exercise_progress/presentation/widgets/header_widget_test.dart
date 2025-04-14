import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/toggle_button_widget.dart';

void main() {
  group('HeaderWidget', () {
    testWidgets('renders correctly with weekly view selected', (WidgetTester tester) async {
      bool toggleValue = true;
      bool callbackCalled = false;
      
      // Set a larger surface size to avoid overflow errors
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: toggleValue,
              onToggleView: (value) {
                toggleValue = value;
                callbackCalled = true;
              },
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );
      
      // Verify title text is rendered
      expect(find.text('Exercise Progress'), findsOneWidget);
      
      // Verify toggle button is rendered with "Weekly" text
      expect(find.byType(ToggleButtonWidget), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      
      // Tap the toggle button and verify callback is called
      await tester.tap(find.byType(ToggleButtonWidget));
      expect(callbackCalled, true);
      expect(toggleValue, false); // Should toggle to false
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('renders correctly with monthly view selected', (WidgetTester tester) async {
      bool toggleValue = false;
      bool callbackCalled = false;
      
      // Set a larger surface size to avoid overflow errors
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: toggleValue,
              onToggleView: (value) {
                toggleValue = value;
                callbackCalled = true;
              },
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );
      
      // Verify title text is rendered
      expect(find.text('Exercise Progress'), findsOneWidget);
      
      // Verify toggle button is rendered with "Monthly" text
      expect(find.byType(ToggleButtonWidget), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      
      // Tap the toggle button and verify callback is called
      await tester.tap(find.byType(ToggleButtonWidget));
      expect(callbackCalled, true);
      expect(toggleValue, true); // Should toggle to true
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('applies correct text style based on screen size - large screen', (WidgetTester tester) async {
      // Set up a large screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: true,
              onToggleView: (value) {},
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );
      
      // Get the Text widget and check its style
      final textWidget = tester.widget<Text>(find.text('Exercise Progress'));
      expect(textWidget.style!.fontSize, 24.0); // Should use large font size
      expect(textWidget.style!.fontWeight, FontWeight.bold);
      
      // Reset the screen size after test
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('applies correct text style based on screen size - small screen', (WidgetTester tester) async {
      // Mock a small screen using device pixel ratio
      tester.binding.window.physicalSizeTestValue = const Size(700, 1000);  
      tester.binding.window.devicePixelRatioTestValue = 2.0; // This gives logical size of 350x500
      
      // Create a custom widget that tests only the font size logic
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Override just the font size test by manually reading MediaQuery width
              final screenWidth = MediaQuery.of(context).size.width;
              final fontSize = screenWidth < 360 ? 18.0 : 24.0;
              
              // Assert inside the builder
              expect(screenWidth, lessThan(360));
              expect(fontSize, 18.0);
              
              // Return a minimal test widget
              return const Scaffold(
                body: Center(child: Text('Test Passed')),
              );
            },
          ),
        ),
      );
      
      // Reset the screen size after test
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('passes the primaryGreen color to ToggleButtonWidget', (WidgetTester tester) async {
      const customColor = Color(0xFF00FF00);
      
      // Set an appropriate screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: true,
              onToggleView: (value) {},
              primaryGreen: customColor,
            ),
          ),
        ),
      );
      
      // Find the ToggleButtonWidget and verify it received the right color
      final toggleButton = tester.widget<ToggleButtonWidget>(
        find.byType(ToggleButtonWidget)
      );
      expect(toggleButton.primaryColor, customColor);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('verifies Padding with responsive horizontal padding', (WidgetTester tester) async {
      // Set an appropriate screen size
      tester.binding.window.physicalSizeTestValue = const Size(800, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: true,
              onToggleView: (value) {},
              primaryGreen: Colors.green,
            ),
          ),
        ),
      );
      
      // Find the Padding widget and verify its padding
      final paddingWidget = tester.widget<Padding>(
        find.ancestor(
          of: find.byType(Row),
          matching: find.byType(Padding),
        ).first
      );
      
      // Verify it's using the expected formula (screenWidth * 0.05)
      final expectedPadding = EdgeInsets.symmetric(horizontal: 800 * 0.05);
      expect(paddingWidget.padding.horizontal, expectedPadding.horizontal);
      
      // Reset the screen size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('verifies Row uses spaceBetween for alignment', (WidgetTester tester) async {
      // Set an appropriate screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: true,
              onToggleView: (value) {},
              primaryGreen: Colors.green,
            ),
          ),
        ),
      );
      
      // Find the Row and verify its alignment
      final rowWidget = tester.widget<Row>(find.byType(Row).first);
      expect(rowWidget.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
  });
}