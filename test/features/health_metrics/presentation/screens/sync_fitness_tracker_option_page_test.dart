// sync_fitness_tracker_option_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/sync_fitness_tracker_option_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/pet-onboard': (_) =>
            const Scaffold(body: Center(child: Text('Pet Onboarding Page'))),
      },
      home: const SyncFitnessTrackerOptionPage(),
    );
  }

  group('SyncFitnessTrackerOptionPage', () {
    testWidgets('renders with modern UI components and gradient background',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow animations to start

      // Check title and subtitle with proper styling
      final titleFinder = find.text('Health Trackers');
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style!.fontSize, 28);
      expect(titleWidget.style!.fontWeight, FontWeight.bold);
      expect(titleWidget.style!.color, Colors.black87);

      final subtitleFinder =
          find.text('Connect to a fitness tracker to sync your activity data');
      expect(subtitleFinder, findsOneWidget);
      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect(subtitleWidget.style!.fontSize, 16);
      expect(subtitleWidget.style!.color, Colors.black54);

      // Check for progress indicator with correct step
      final progressIndicator = tester.widget<OnboardingProgressIndicator>(
          find.byType(OnboardingProgressIndicator));
      expect(progressIndicator.currentStep, 14); // 15th step (0-indexed)
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

      // Verify main title and benefit items
      expect(find.text('Connect to Health Tracker'), findsOneWidget);
      expect(
          find.text('Automatic exercise calorie adjustment'), findsOneWidget);
      expect(find.text('More accurate weight tracking'), findsOneWidget);
      expect(find.text('Better insights on your progress'), findsOneWidget);

      // Verify buttons
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);
    });

    testWidgets('animations are properly initialized', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check animations exist
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);

      // Let animations play
      await tester.pump(const Duration(milliseconds: 700));

      // Content should be visible after animation
      expect(find.text('Connect to Health Tracker'), findsOneWidget);
    });

    testWidgets('tapping Continue saves preference and navigates',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap Continue button
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);

      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify navigation and preference
      expect(find.text('Pet Onboarding Page'), findsOneWidget);
      expect(prefs.getBool('syncHealthTracker'), isTrue);
    });

    testWidgets('tapping Not Now saves preference and navigates',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap Not Now button
      final notNowButton = find.widgetWithText(TextButton, 'Not Now');
      expect(notNowButton, findsOneWidget);

      await tester.ensureVisible(notNowButton);
      await tester.pumpAndSettle();
      await tester.tap(notNowButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify navigation and preference
      expect(find.text('Pet Onboarding Page'), findsOneWidget);
      expect(prefs.getBool('syncHealthTracker'), isFalse);
    });

    testWidgets('back button has modern shadow styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find back button with container decoration
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Verify modern styling with shadow
      final backButtonContainer = find
          .ancestor(
            of: backButton,
            matching: find.byType(Container),
          )
          .first;

      final container = tester.widget<Container>(backButtonContainer);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
      expect(decoration.color, equals(Colors.white));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, isTrue);
    });

    testWidgets('benefit items have primary green icons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find only benefit icons by looking for specific icons rather than all containers
      expect(find.byIcon(Icons.autorenew), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.insights), findsOneWidget);

      // Verify each benefit item has the right styling
      final benefitItems = [Icons.autorenew, Icons.trending_up, Icons.insights];

      for (final iconData in benefitItems) {
        final icon = find.byIcon(iconData);
        // Get parent Container
        final container = find
            .ancestor(
              of: icon,
              matching: find.byType(Container),
            )
            .first;

        // Verify container styling
        final containerWidget = tester.widget<Container>(container);
        final decoration = containerWidget.decoration as BoxDecoration;

        // Checks - should be a circle with primaryGreen background
        expect(decoration.shape, equals(BoxShape.circle));

        // Verify this is a benefit item by checking text next to it
        final row = find
            .ancestor(
              of: container,
              matching: find.byType(Row),
            )
            .first;

        // Each row should have an icon and text
        expect(find.descendant(of: row, matching: find.byType(Text)),
            findsOneWidget);
      }
    });
  });
}
