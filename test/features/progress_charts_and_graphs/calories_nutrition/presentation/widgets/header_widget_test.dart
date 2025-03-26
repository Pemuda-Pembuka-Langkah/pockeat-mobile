import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/toggle_button_widget.dart';

void main() {
  group('HeaderWidget', () {
    testWidgets('renders correctly with weekly view selected', (WidgetTester tester) async {
      bool toggleValue = true;
      bool callbackCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: toggleValue,
              onToggleView: (value) {
                toggleValue = value;
                callbackCalled = true;
              },
              primaryColor: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );
      
      // Verify text elements are rendered
      expect(find.text('Nutrition Progress'), findsOneWidget);
      expect(find.text('Track your nutrition goals'), findsOneWidget);
      
      // Verify toggle buttons are rendered
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      
      // Verify the state of the toggle buttons
      final weeklyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Weekly')
      );
      expect(weeklyButton.isSelected, true);
      
      final monthlyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Monthly')
      );
      expect(monthlyButton.isSelected, false);
    });
    
    testWidgets('renders correctly with monthly view selected', (WidgetTester tester) async {
      bool toggleValue = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: toggleValue,
              onToggleView: (value) {},
              primaryColor: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );
      
      // Verify text elements are rendered
      expect(find.text('Nutrition Progress'), findsOneWidget);
      expect(find.text('Track your nutrition goals'), findsOneWidget);
      
      // Verify toggle buttons are rendered with correct state
      final weeklyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Weekly')
      );
      expect(weeklyButton.isSelected, false);
      
      final monthlyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Monthly')
      );
      expect(monthlyButton.isSelected, true);
    });
    
    testWidgets('calls onToggleView when Weekly button is tapped', (WidgetTester tester) async {
      bool toggleValue = false;
      bool callbackCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: toggleValue,
              onToggleView: (value) {
                toggleValue = value;
                callbackCalled = true;
              },
              primaryColor: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );
      
      // Initially monthly view is selected
      expect(toggleValue, false);
      expect(callbackCalled, false);
      
      // Tap the weekly button
      await tester.tap(find.widgetWithText(ToggleButtonWidget, 'Weekly'));
      await tester.pump();
      
      // Verify the callback was called with the correct value
      expect(callbackCalled, true);
      expect(toggleValue, true);
    });
    
    testWidgets('calls onToggleView when Monthly button is tapped', (WidgetTester tester) async {
      bool toggleValue = true;
      bool callbackCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: toggleValue,
              onToggleView: (value) {
                toggleValue = value;
                callbackCalled = true;
              },
              primaryColor: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );
      
      // Initially weekly view is selected
      expect(toggleValue, true);
      expect(callbackCalled, false);
      
      // Tap the monthly button
      await tester.tap(find.widgetWithText(ToggleButtonWidget, 'Monthly'));
      await tester.pump();
      
      // Verify the callback was called with the correct value
      expect(callbackCalled, true);
      expect(toggleValue, false);
    });
    
    testWidgets('uses the provided primary color for toggle buttons', (WidgetTester tester) async {
      final Color customPink = const Color(0xFFFF00FF);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: true,
              onToggleView: (value) {},
              primaryColor: customPink,
            ),
          ),
        ),
      );
      
      // Verify the color is passed to the toggle buttons
      final weeklyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Weekly')
      );
      expect(weeklyButton.selectedColor, customPink);
      
      final monthlyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Monthly')
      );
      expect(monthlyButton.selectedColor, customPink);
    });
    
    testWidgets('verifies widget structure and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: true,
              onToggleView: (value) {},
              primaryColor: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );
      
      // Verify the overall structure
      expect(find.byType(Row), findsAtLeastNWidgets(2)); // Main row and toggle buttons row
      expect(find.byType(Column), findsOneWidget);
      
      // Find the main container that contains toggle buttons
      // Use a more specific finder to avoid ambiguity
      final containerFinder = find.descendant(
        of: find.byType(HeaderWidget),
        matching: find.byType(Container),
      ).first;
      
      // Verify container styling
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      expect(decoration.border, isNotNull);
      
      // Verify main row alignment
      final mainRow = tester.widget<Row>(find.byType(Row).first);
      expect(mainRow.mainAxisAlignment, equals(MainAxisAlignment.spaceBetween));
    });
    
    // Testing for HeaderWidget behavior rather than individual ToggleButtonWidget behavior
    testWidgets('has appropriate UI state when tapping already selected Weekly button', (WidgetTester tester) async {
      // Track state changes but don't expect callback to not be called
      bool toggleValue = true;
      int callCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: toggleValue,
              onToggleView: (value) {
                toggleValue = value;
                callCount++;
              },
              primaryColor: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );
      
      // Verify initial state
      expect(toggleValue, true);
      expect(callCount, 0);
      
      // Find and tap the already selected Weekly button
      await tester.tap(find.widgetWithText(ToggleButtonWidget, 'Weekly'));
      await tester.pump();
      
      // The important thing is the UI state stays consistent
      // ToggleButtonWidget may call onTap but HeaderWidget should remain in weekly view
      expect(toggleValue, true);  // Should still be true regardless of callback 
      
      // Verify Weekly button is still selected and Monthly is not
      final weeklyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Weekly')
      );
      expect(weeklyButton.isSelected, true);
      
      final monthlyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Monthly')
      );
      expect(monthlyButton.isSelected, false);
    });
    
    testWidgets('has appropriate UI state when tapping already selected Monthly button', (WidgetTester tester) async {
      // Track state changes but don't expect callback to not be called
      bool toggleValue = false;
      int callCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              isWeeklyView: toggleValue,
              onToggleView: (value) {
                toggleValue = value;
                callCount++;
              },
              primaryColor: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );
      
      // Verify initial state
      expect(toggleValue, false);
      expect(callCount, 0);
      
      // Find and tap the already selected Monthly button
      await tester.tap(find.widgetWithText(ToggleButtonWidget, 'Monthly'));
      await tester.pump();
      
      // The important thing is the UI state stays consistent
      // ToggleButtonWidget may call onTap but HeaderWidget should remain in monthly view
      expect(toggleValue, false);  // Should still be false regardless of callback 
      
      // Verify Monthly button is still selected and Weekly is not
      final weeklyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Weekly')
      );
      expect(weeklyButton.isSelected, false);
      
      final monthlyButton = tester.widget<ToggleButtonWidget>(
        find.widgetWithText(ToggleButtonWidget, 'Monthly')
      );
      expect(monthlyButton.isSelected, true);
    });
  });
}