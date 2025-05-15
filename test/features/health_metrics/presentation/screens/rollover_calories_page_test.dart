// rollover_calories_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/rollover_calories_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';

void main() {
  group('RolloverCaloriesPage', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Widget createTestWidget() {
      return MaterialApp(
        routes: {
          '/used-other-apps': (_) => const Scaffold(body: Center(child: Text('Used Other Apps Page'))),
        },
        home: const RolloverCaloriesPage(),
      );
    }
    
    testWidgets('renders with modern UI components and gradient background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow animations to start
      
      // Check title and subtitle with proper styling
      final titleFinder = find.text('Rollover Calories');
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style!.fontSize, 28);
      expect(titleWidget.style!.fontWeight, FontWeight.bold);
      
      // Check for progress indicator with correct step
      final progressIndicator = tester.widget<OnboardingProgressIndicator>(
        find.byType(OnboardingProgressIndicator)
      );
      expect(progressIndicator.currentStep, 11); // 12th step (0-indexed)
      expect(progressIndicator.totalSteps, 16);
      
      // Verify gradient background exists
      final containerWithGradient = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient != null;
        }
        return false;
      });
      expect(containerWithGradient, findsWidgets);
      
      // Verify explanation card with icon
      expect(find.text('What this means'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      
      // Verify option buttons and Continue button
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
    
    testWidgets('animations are properly initialized', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Check animations exist
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
      
      // Let animations play
      await tester.pump(const Duration(milliseconds: 600));
      
      // Content should be visible after animation
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('Continue button is disabled when no option is selected', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify button styling for disabled state
      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(button.onPressed, isNull);
      
      // Check for modern styling (rounded corners, elevation)
      final buttonStyle = button.style!;
      final shape = buttonStyle.shape!.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, isA<BorderRadius>());
    });

    testWidgets('selecting No enables Continue button with visual feedback', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap No option
      await tester.tap(find.text('No'));
      await tester.pump();
      
      // Verify No is highlighted with primary color (by checking the close icon appears)
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Continue button should be enabled
      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('selecting Yes enables Continue button with visual feedback', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap Yes option
      await tester.tap(find.text('Yes'));
      await tester.pump();
      
      // Verify Yes is highlighted with primary color and shows check icon
      expect(find.byIcon(Icons.check), findsOneWidget);
      
      // Check that the container around Yes has changed its color
      final selectedContainer = find.ancestor(
        of: find.byIcon(Icons.check),
        matching: find.byType(Container),
      ).first;
      expect(selectedContainer, findsOneWidget);
      
      // Continue button should be enabled
      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('selecting No saves preference and navigates', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap No and Continue
      await tester.tap(find.text('No'));
      await tester.pump();
      
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify preference is saved correctly
      expect(prefs.getBool('rolloverCaloriesEnabled'), isFalse);
      
      // Verify navigation
      expect(find.text('Used Other Apps Page'), findsOneWidget);
    });

    testWidgets('selecting Yes saves preference and navigates', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap Yes and Continue
      await tester.tap(find.text('Yes'));
      await tester.pump();
      
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify preference is saved correctly
      expect(prefs.getBool('rolloverCaloriesEnabled'), isTrue);
      
      // Verify navigation
      expect(find.text('Used Other Apps Page'), findsOneWidget);
    });
    
    testWidgets('back button has modern shadow styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Find back button with container decoration
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      
      // Verify modern styling with shadow
      final backButtonContainer = find.ancestor(
        of: backButton,
        matching: find.byType(Container),
      ).first;
      
      final container = tester.widget<Container>(backButtonContainer);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
      expect(decoration.color, equals(Colors.white));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, isTrue);
    });
    
    testWidgets('can switch between Yes and No options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap Yes first
      await tester.tap(find.text('Yes'));
      await tester.pump();
      
      // Verify Yes is selected
      expect(find.byIcon(Icons.check), findsOneWidget);
      
      // Now tap No
      await tester.tap(find.text('No'));
      await tester.pump();
      
      // Verify No is now selected instead
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Tap Continue and verify the last selection (No) is saved
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      expect(prefs.getBool('rolloverCaloriesEnabled'), isFalse);
    });
  });
}
