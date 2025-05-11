// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/health_value_proposition_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';

void main() {
  group('HealthValuePropositionPage', () {
    testWidgets('renders without back button in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // AppBar should exist but shouldn't have a back button
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('displays the onboarding progress indicator with correct values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // Find the OnboardingProgressIndicator
      final progressIndicator = find.byType(OnboardingProgressIndicator);
      expect(progressIndicator, findsOneWidget);

      // Verify the progress indicator properties
      final widget = tester.widget(progressIndicator) as OnboardingProgressIndicator;
      expect(widget.totalSteps, equals(16));
      expect(widget.currentStep, equals(0)); // First step (0-indexed)
      expect(widget.showPercentage, isTrue);
    });

    testWidgets('displays the title text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // Check for title text
      expect(find.text('PockEat Creates'), findsOneWidget);
      expect(find.text('Long Term Results'), findsOneWidget);
    });

    testWidgets('renders chart component and legend items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // Allow time for animations to start
      await tester.pump(const Duration(milliseconds: 50));
      
      // Verify chart legend items
      expect(find.text('Traditional diet'), findsOneWidget);
      expect(find.text('With PockEat'), findsOneWidget);
      
      // Verify the section title for the chart
      expect(find.text('Your Weight Transformation'), findsOneWidget);
      
      // We can't verify the exact chart implementation directly since it depends on
      // the fl_chart package, but we can verify its container exists
      expect(find.byWidgetPredicate((widget) => 
        widget is SizedBox && 
        widget.height == 180 // The chart has a height of 180 as specified in the code
      ), findsOneWidget, reason: 'Should find the chart container');
    });

    testWidgets('displays statistic information with correct percentage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // Find and verify the statistic percentage
      expect(find.text('80%'), findsOneWidget);

      // Verify the statistic explanation text
      expect(
        find.textContaining('of PockEat users maintain their results'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Say goodbye to yo-yo dieting!'),
        findsOneWidget,
      );
    });

    testWidgets('shows Continue button with expected properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // Find the Continue button
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Continue');
      expect(buttonFinder, findsOneWidget);

      // Check that the button exists rather than verifying exact styling properties
      // which can be implementation-dependent and fragile in tests
      final elevatedButton = tester.widget(buttonFinder) as ElevatedButton;
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('navigates to height-weight page when Continue button is pressed',
        (WidgetTester tester) async {
      bool navigatedToHeightWeight = false;

      await tester.pumpWidget(
        MaterialApp(
          home: const HealthValuePropositionPage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/height-weight') {
              navigatedToHeightWeight = true;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Height-Weight Page')),
              );
            }
            return null;
          },
        ),
      );

      // Tap the continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(navigatedToHeightWeight, isTrue);
    });

    testWidgets('animation components are properly set up',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // This test only verifies that the animation-related widgets exist
      // We cannot directly access private animation controllers,
      // but we can verify that the animation components are present
      
      // Check for AnimatedBuilder which uses animations
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
      
      // Start the animations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // advance animation
    });

    testWidgets('animation-related widgets are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // Let the widget build and start animations
      await tester.pump(const Duration(milliseconds: 50));
      
      // Verify animation-related widgets are present
      // Note: depending on the exact animation implementation, these might vary
      // We're looking for common animation-related widgets
      final animationWidgets = find.byWidgetPredicate((widget) {
        return widget is AnimatedBuilder || 
               widget is AnimatedContainer || 
               widget is Transform || 
               widget is Opacity;
      });
      
      expect(animationWidgets, findsAtLeastNWidgets(1), 
        reason: 'Should find at least one animation-related widget');
    });

    testWidgets('has scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // Find ScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Check if the content can be scrolled
      final scrollable = find.byType(Scrollable);
      expect(scrollable, findsOneWidget);
      
      // Try scrolling down
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pump();
    });

    testWidgets('applies correct decoration to containers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HealthValuePropositionPage()),
      );

      // Find all containers with decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      
      // Check for containers with white background and rounded corners (card-like elements)
      bool foundCardContainer = false;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.color == Colors.white && 
              decoration.borderRadius != null &&
              decoration.boxShadow != null) {
            foundCardContainer = true;
            break;
          }
        }
      }
      
      expect(foundCardContainer, isTrue, reason: 'Should find at least one card-like container');
    });
  });
}
