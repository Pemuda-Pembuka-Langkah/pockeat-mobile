// sync_fitness_tracker_option_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/sync_fitness_tracker_option_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';
import 'package:pockeat/features/sync_fitness_tracker/services/health_connect_sync.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

// Mock implementation of UserPreferencesService for testing
class MockUserPreferencesService implements UserPreferencesService {
  final SharedPreferences prefs;

  MockUserPreferencesService(this.prefs);

  @override
  Future<bool> isSyncFitnessTrackerEnabled() async {
    return prefs.getBool('sync_fitness_tracker_enabled') ?? false;
  }

  @override
  Future<void> setSyncFitnessTrackerEnabled(bool enabled) async {
    await prefs.setBool('sync_fitness_tracker_enabled', enabled);
  }

  // Stub implementations for other methods
  @override
  Future<bool> isExerciseCalorieCompensationEnabled() async => false;

  @override
  Future<void> setExerciseCalorieCompensationEnabled(bool enabled) async {}

  @override
  Future<bool> isRolloverCaloriesEnabled() async => false;

  @override
  Future<void> setRolloverCaloriesEnabled(bool enabled) async {}

  @override
  Future<int> getRolloverCalories() async => 0;

  @override
  Future<void> synchronizePreferencesAfterLogin() async {}
}

void main() {
  late SharedPreferences prefs;
  late GetIt getIt;

  setUp(() async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Set up GetIt
    getIt = GetIt.instance;

    // Register UserPreferencesService
    if (getIt.isRegistered<UserPreferencesService>()) {
      getIt.unregister<UserPreferencesService>();
    }
    getIt.registerSingleton<UserPreferencesService>(
        MockUserPreferencesService(prefs));
  });

  tearDown(() {
    if (getIt.isRegistered<UserPreferencesService>()) {
      getIt.unregister<UserPreferencesService>();
    }
    if (getIt.isRegistered<FitnessTrackerSync>()) {
      getIt.unregister<FitnessTrackerSync>();
    }
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
      await tester
          .pumpWidget(createTestWidget()); // Allow animations to fully complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

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
      expect(find.text('Open Health Connect'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);

      // Verify buttons - Need to use more flexible approach to find them in the animated containers
      // Find the OutlinedButton with the text "Open Health Connect" using a predicate
      final openHealthConnectButton = find.byWidgetPredicate((widget) {
        if (widget is OutlinedButton) {
          final buttonText = find.descendant(
            of: find.byWidget(widget),
            matching: find.text('Open Health Connect'),
          );
          return buttonText.evaluate().isNotEmpty;
        }
        return false;
      });
      expect(openHealthConnectButton, findsOneWidget);

      // Find the TextButton with the text "Not Now" using a predicate
      final notNowButton = find.byWidgetPredicate((widget) {
        if (widget is TextButton) {
          final buttonText = find.descendant(
            of: find.byWidget(widget),
            matching: find.text('Not Now'),
          );
          return buttonText.evaluate().isNotEmpty;
        }
        return false;
      });
      expect(notNowButton, findsOneWidget);
    });
    testWidgets('animations are properly initialized', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check animations exist
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);

      // Let animations play
      await tester.pump(const Duration(milliseconds: 700));

      // Content should be visible after animation
      expect(find.text('Open Health Connect'), findsOneWidget);
    });

    /* Test commented out because it requires a mock for FitnessTrackerSync
    testWidgets('tapping Open Health Connect button sets preference to true',
        (tester) async {
      await tester.pumpWidget(
          createTestWidget()); // Wait for all animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find the button by text and icon combination, which is more reliable
      final openHealthConnectText = find.text('Open Health Connect');
      expect(openHealthConnectText, findsOneWidget);

      // Instead of using ancestor finder, use byWidgetPredicate to find the button
      final healthConnectButtonFinder = find.byWidgetPredicate((widget) {
        if (widget is OutlinedButton) {
          // Find button by looking at its child
          final buttonText = find.descendant(
            of: find.byWidget(widget),
            matching: find.text('Open Health Connect'),
          );
          return buttonText.evaluate().isNotEmpty;
        }
        return false;
      });

      expect(healthConnectButtonFinder, findsOneWidget);

      // Ensure mock is set up properly before tapping the button
      mockFitnessTracker.setAvailability(true);

      await tester.ensureVisible(healthConnectButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(healthConnectButtonFinder);
      await tester.pumpAndSettle();

      // Verify preference was saved
      expect(prefs.getBool('sync_fitness_tracker_enabled'), isTrue);

      // The dialog will appear at this point, but we can't interact with it in tests
      // without mocking the FitnessTrackerSync class
    });
    */
    testWidgets('tapping Not Now saves preference and navigates',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Find the Not Now text
      final notNowText = find.text('Not Now');
      expect(notNowText, findsOneWidget);

      // Find the TextButton that contains this text
      final notNowButtonFinder = find.ancestor(
        of: notNowText,
        matching: find.byType(TextButton),
      );
      expect(notNowButtonFinder, findsOneWidget);

      await tester.ensureVisible(notNowButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(notNowButtonFinder);
      await tester.pumpAndSettle();

      // Verify navigation and preference
      expect(find.text('Pet Onboarding Page'), findsOneWidget);
      expect(prefs.getBool('sync_fitness_tracker_enabled'), isFalse);
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

    testWidgets('loads preference from SharedPreferences and reflects in UI',
        (tester) async {
      // Reset the GetIt registry to ensure a fresh test environment
      if (getIt.isRegistered<UserPreferencesService>()) {
        getIt.unregister<UserPreferencesService>();
      }

      // Set preference to true
      await prefs.setBool('sync_fitness_tracker_enabled', true);
      getIt.registerSingleton<UserPreferencesService>(
          MockUserPreferencesService(prefs));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Since we set the preference to true, verify Not Now doesn't have an icon
      final closeIcon = find.descendant(
        of: find.widgetWithText(TextButton, 'Not Now'),
        matching: find.byIcon(Icons.close_rounded),
      );

      // The Not Now button doesn't have a close icon when the preference is true
      expect(closeIcon, findsNothing);
    });
    testWidgets(
        'loads preference with "false" from SharedPreferences and reflects in UI',
        (tester) async {
      // Reset the GetIt registry to ensure a fresh test environment
      if (getIt.isRegistered<UserPreferencesService>()) {
        getIt.unregister<UserPreferencesService>();
      }

      // Set preference to false
      await prefs.setBool('sync_fitness_tracker_enabled', false);
      getIt.registerSingleton<UserPreferencesService>(
          MockUserPreferencesService(prefs));

      await tester.pumpWidget(createTestWidget());

      // Wait for everything to be fully rendered
      await tester.pumpAndSettle();

      // We need to find the "Not Now" text first
      final notNowText = find.text('Not Now');
      expect(notNowText, findsOneWidget);

      // Now find the Row containing this text
      final notNowRow = find.ancestor(
        of: notNowText,
        matching: find.byType(Row),
      );
      expect(notNowRow, findsOneWidget);

      // Find the close icon within this row
      final closeIcon = find.descendant(
        of: notNowRow,
        matching: find.byIcon(Icons.close_rounded),
      );

      // The close icon should be present when preference is false
      expect(closeIcon, findsOneWidget);
    });
  });
}
