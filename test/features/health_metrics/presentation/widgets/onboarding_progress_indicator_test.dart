// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';

void main() {
  // Test constants
  const int defaultTotalSteps = 10;
  const Color defaultActiveColor = Color(0xFF4ECDC4);
  const Color defaultInactiveColor = Color(0xFFE0E0E0);
  const Color customActiveColor = Colors.purple;
  const Color customInactiveColor = Colors.grey;
  const double defaultBarHeight = 6.0;
  const double customBarHeight = 12.0;
  const double defaultBorderRadius = 3.0;
  const double customBorderRadius = 8.0;

  group('OnboardingProgressIndicator', () {
    testWidgets('should render with default parameters', (WidgetTester tester) async {
      // Arrange
      const currentStep = 2;
      const expectedStepText = 'Step 3 of $defaultTotalSteps';
      const expectedPercentage = '30%';
      
      // Act - Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: currentStep,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(expectedStepText), findsOneWidget);
      expect(find.text(expectedPercentage), findsOneWidget);
      
      // Verify progress bar existence
      final progressIndicator = find.byType(AnimatedFractionallySizedBox);
      expect(progressIndicator, findsOneWidget);
      
      // Verify bar visuals - simplified to just check basic structure
      final containers = find.byType(Container);
      expect(containers, findsAtLeastNWidgets(2)); // At least inactive and active bars
      
      // Verify the AnimatedFractionallySizedBox exists
      expect(progressIndicator, findsOneWidget);
    });
    
    testWidgets('should not show percentage when showPercentage is false', (WidgetTester tester) async {
      // Arrange
      const currentStep = 2;
      const expectedStepText = 'Step 3 of $defaultTotalSteps';
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: currentStep,
              showPercentage: false,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(expectedStepText), findsOneWidget);
      expect(find.text('30%'), findsNothing);
    });
    
    testWidgets('should apply custom colors', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: 5,
              activeColor: customActiveColor,
              inactiveColor: customInactiveColor,
            ),
          ),
        ),
      );
      
      // Assert
      // Verify the colors are applied by finding all BoxDecorations
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundActiveColor = false;
      bool foundInactiveColor = false;
      
      for (final container in containers) {
        final decoration = container.decoration as BoxDecoration?;
        if (decoration != null) {
          if (decoration.color == customActiveColor) {
            foundActiveColor = true;
          }
          if (decoration.color == customInactiveColor) {
            foundInactiveColor = true;
          }
        }
      }
      
      expect(foundActiveColor, isTrue, reason: 'Active color not found in any container');
      expect(foundInactiveColor, isTrue, reason: 'Inactive color not found in any container');
    });
    
    testWidgets('should apply custom bar height', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: 5,
              barHeight: customBarHeight,
            ),
          ),
        ),
      );
      
      // Assert - Find containers and check their height property
      final containers = tester.widgetList<Container>(find.byType(Container));
      
      // Check each container to verify the bar height
      for (final container in containers) {
        // Get the container's height property
        if (container.constraints != null) {
          expect(container.constraints?.minHeight, equals(customBarHeight));
        }
      }
    });
    
    testWidgets('should apply custom border radius', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: 3,
              borderRadius: customBorderRadius,
            ),
          ),
        ),
      );
      
      // Assert - Check if containers have the custom border radius
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundCustomBorderRadius = false;
      
      for (final container in containers) {
        final decoration = container.decoration as BoxDecoration?;
        if (decoration?.borderRadius != null) {
          // Check if borderRadius equals our custom value
          if ((decoration?.borderRadius as BorderRadius?)?.topLeft.x == customBorderRadius) {
            foundCustomBorderRadius = true;
            break;
          }
        }
      }
      
      expect(foundCustomBorderRadius, isTrue, reason: 'Custom border radius not found in any container');
    });
    
    testWidgets('should apply custom label style', (WidgetTester tester) async {
      // Arrange
      const customTextStyle = TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      );
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: 2,
              labelStyle: customTextStyle,
            ),
          ),
        ),
      );
      
      // Assert
      final stepTextWidget = find.text('Step 3 of $defaultTotalSteps')
          .evaluate()
          .first
          .widget as Text;
      expect(stepTextWidget.style, equals(customTextStyle));
      
      final percentageTextWidget = find.text('30%')
          .evaluate()
          .first
          .widget as Text;
      expect(percentageTextWidget.style, equals(customTextStyle));
    });
    
    testWidgets('should calculate completion percentage correctly', (WidgetTester tester) async {
      // Test multiple steps to verify percentage calculation
      final testCases = [
        {'step': 0, 'expected': '10%'}, // First step (0-indexed)
        {'step': 4, 'expected': '50%'}, // Middle step
        {'step': 9, 'expected': '100%'}, // Last step
      ];
      
      for (final testCase in testCases) {
        // Arrange
        final currentStep = testCase['step'] as int;
        final expectedPercentage = testCase['expected'] as String;
        
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OnboardingProgressIndicator(
                totalSteps: defaultTotalSteps,
                currentStep: currentStep,
              ),
            ),
          ),
        );
        
        // Assert
        expect(find.text(expectedPercentage), findsOneWidget);
        
        // Verify progress bar width factor
        final progressStack = find.byType(Stack).evaluate().first.widget as Stack;
        final activeSizedBox = progressStack.children[1] as AnimatedFractionallySizedBox;
        expect(activeSizedBox.widthFactor, equals((currentStep + 1) / defaultTotalSteps));
      }
    });
    
    testWidgets('should handle first step correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: 0, // First step (0-indexed)
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Step 1 of $defaultTotalSteps'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
      
      // Verify progress bar width
      final progressIndicator = find.byType(AnimatedFractionallySizedBox);
      final activeSizedBox = tester.widget(progressIndicator) as AnimatedFractionallySizedBox;
      expect(activeSizedBox.widthFactor, equals(0.1)); // 1/10
    });
    
    testWidgets('should handle last step correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: 9, // Last step (0-indexed)
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Step 10 of $defaultTotalSteps'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      
      // Verify progress bar is full width
      final progressIndicator = find.byType(AnimatedFractionallySizedBox);
      final activeSizedBox = tester.widget(progressIndicator) as AnimatedFractionallySizedBox;
      expect(activeSizedBox.widthFactor, equals(1.0)); // Full width
    });
    
    testWidgets('should animate progress bar transitions', (WidgetTester tester) async {
      // Arrange - Start with step 1
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: 1,
              animationDuration: Duration(milliseconds: 300),
            ),
          ),
        ),
      );
      
      // Verify initial state
      expect(find.text('Step 2 of $defaultTotalSteps'), findsOneWidget);
      
      // Extract initial progress width factor
      var progressIndicator = find.byType(AnimatedFractionallySizedBox);
      var activeSizedBox = tester.widget(progressIndicator) as AnimatedFractionallySizedBox;
      final initialWidthFactor = activeSizedBox.widthFactor;
      
      // Act - Rebuild with step 5
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: defaultTotalSteps,
              currentStep: 5,
              animationDuration: Duration(milliseconds: 300),
            ),
          ),
        ),
      );
      
      // Verify that animation starts
      await tester.pump(const Duration(milliseconds: 100));
      
      // Extract in-progress animation width factor
      progressIndicator = find.byType(AnimatedFractionallySizedBox);
      activeSizedBox = tester.widget(progressIndicator) as AnimatedFractionallySizedBox;
      
      // Verify animation completes
      await tester.pumpAndSettle();
      
      // Verify final state
      expect(find.text('Step 6 of $defaultTotalSteps'), findsOneWidget);
      
      // Extract final progress width factor
      progressIndicator = find.byType(AnimatedFractionallySizedBox);
      activeSizedBox = tester.widget(progressIndicator) as AnimatedFractionallySizedBox;
      final finalWidthFactor = activeSizedBox.widthFactor;
      
      // Verify width factor changed
      expect(initialWidthFactor, equals(0.2)); // 2/10
      expect(finalWidthFactor, equals(0.6)); // 6/10
    });
    
    testWidgets('should handle small number of steps', (WidgetTester tester) async {
      // Arrange & Act
      const totalSteps = 3;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: totalSteps,
              currentStep: 1,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Step 2 of $totalSteps'), findsOneWidget);
      
      // Check for percentage text - could be '67%' or '66%' depending on rounding
      final percentageTextFinder = find.byWidgetPredicate((widget) {
        if (widget is Text) {
          return widget.data == '67%' || widget.data == '66%';
        }
        return false;
      });
      expect(percentageTextFinder, findsOneWidget, reason: 'Expected to find either 66% or 67%');
      
      // Verify progress bar width reflects correct percentage
      final progressIndicator = find.byType(AnimatedFractionallySizedBox);
      final activeSizedBox = tester.widget(progressIndicator) as AnimatedFractionallySizedBox;
      expect(activeSizedBox.widthFactor, equals(2/3));
    });
    
    testWidgets('should handle large number of steps', (WidgetTester tester) async {
      // Arrange & Act
      const totalSteps = 100;
      const currentStep = 49; // 50th step (0-indexed)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: totalSteps,
              currentStep: currentStep,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Step 50 of $totalSteps'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      
      // Verify progress bar width reflects correct percentage
      final progressIndicator = find.byType(AnimatedFractionallySizedBox);
      final activeSizedBox = tester.widget(progressIndicator) as AnimatedFractionallySizedBox;
      expect(activeSizedBox.widthFactor, equals(50/100));
    });
    
    testWidgets('should handle zero total steps assertion', (WidgetTester tester) async {
      // Arrange & Act & Assert
      expect(() => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: 0,
              currentStep: 0,
            ),
          ),
        ),
      ), throwsA(isA<AssertionError>()));
    });
    
    testWidgets('should handle current step out of range assertion - less than zero', (WidgetTester tester) async {
      // Arrange & Act & Assert - Less than zero
      expect(() => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: 10,
              currentStep: -1,
            ),
          ),
        ),
      ), throwsA(isA<AssertionError>()));
    });
    
    testWidgets('should handle current step out of range assertion - greater than total', (WidgetTester tester) async {
      // Arrange & Act & Assert - Greater than or equal to total
      expect(() => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              totalSteps: 10,
              currentStep: 10,
            ),
          ),
        ),
      ), throwsA(isA<AssertionError>()));
    });
  });
}
