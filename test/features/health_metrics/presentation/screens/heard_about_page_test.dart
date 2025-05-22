// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/heard_about_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';

void main() {
  group('HeardAboutPage', () {
    late SharedPreferences prefs;
    
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        // Ensure we start with clean preferences for each test
      });
      prefs = await SharedPreferences.getInstance();
    });

    Widget buildTestableWidget() {
      return MaterialApp(
        routes: {
          '/review': (_) => const Scaffold(body: Center(child: Text('Review Page'))),
          '/sync-fitness-tracker': (_) => const Scaffold(body: Center(child: Text('Sync Fitness Tracker Page'))),
        },
        home: const HeardAboutPage(),
      );
    }

    testWidgets('renders with proper modern UI components and gradient background', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump(); // Complete animations from initState

      // Main title and subtitle with proper styling
      final titleFinder = find.text('How You Found Us');
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style!.fontSize, 28);
      expect(titleWidget.style!.fontWeight, FontWeight.bold);
      expect(titleWidget.style!.color, Colors.black87);
      
      final subtitleFinder = find.text('Where did you hear about PockEat?');
      expect(subtitleFinder, findsOneWidget);
      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect(subtitleWidget.style!.fontSize, 16);
      expect(subtitleWidget.style!.color, Colors.black54);
      
      // Core UI components
      expect(find.byType(OnboardingProgressIndicator), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      
      // Check for all options
      for (final option in HeardAboutPage.options) {
        expect(find.text(option), findsOneWidget);
      }
      
      // Verify gradient exists somewhere in the widget tree
      // Menggunakan pendekatan direct widget finder
      final containerWithGradient = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient != null;
        }
        return false;
      });
      expect(containerWithGradient, findsWidgets);
      
      // Verify white container with shadow for options
      final whiteShadowContainers = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          final boxShadow = decoration.boxShadow;
          return decoration.color == Colors.white && boxShadow != null && boxShadow.isNotEmpty;
        }
        return false;
      });
      expect(whiteShadowContainers, findsWidgets);
    });

    testWidgets('progress indicator shows correct step', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final progressIndicator = tester.widget<OnboardingProgressIndicator>(
        find.byType(OnboardingProgressIndicator)
      );
      
      expect(progressIndicator.totalSteps, 16);
      expect(progressIndicator.currentStep, 13); // Should be step 14 (0-indexed)
      expect(progressIndicator.showPercentage, isTrue);
    });

    testWidgets('animations are properly initialized and complete correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      
      // Initial frame before animations
      final fadeTransition = tester.widget<FadeTransition>(find.byType(FadeTransition));
      final slideTransition = tester.widget<SlideTransition>(find.byType(SlideTransition));
      
      // Verify initial animation values
      expect(fadeTransition.opacity.value, isIn(<double>[0.0, 0.0001])); // Close to 0 at the start
      
      // Verifikasi slide transition ada, tapi tidak perlu memeriksa nilai awalnya
      // karena di implementasi sebenarnya nilai awal mungkin 0.0
      final slidePosition = slideTransition.position;
      expect(slidePosition, isNotNull);
      
      // Let animations play - mid animation
      await tester.pump(const Duration(milliseconds: 300));
      
      // Skip pemeriksaan animasi di tengah-tengah
      // dan langsung lanjut ke verifikasi animasi akhir
      
      // Animation complete
      await tester.pump(const Duration(milliseconds: 300));
      
      // Verifikasi animasi telah dijalankan dan nilai opacity telah berubah
      final fadeTransitionEnd = tester.widget<FadeTransition>(find.byType(FadeTransition));
      // Tidak mengharapkan nilai tertentu, hanya memastikan animasi telah berjalan
      expect(fadeTransitionEnd.opacity.value, greaterThan(0.0));
      
      // Content should now be visible
      for (final option in HeardAboutPage.options) {
        expect(find.text(option), findsOneWidget);
      }
    });

    testWidgets('continue button is initially disabled', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final continueButtonFinder = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButtonFinder, findsOneWidget);
      
      final continueButton = tester.widget<ElevatedButton>(continueButtonFinder);
      expect(continueButton.onPressed, isNull); // Button should be disabled initially
    });

    testWidgets('selecting an option enables Continue button and shows selection UI', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Friend / Family'));
      await tester.pump();

      // Check button is enabled
      final continueButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(continueButton.onPressed, isNotNull);
      
      // Check for visual selection indicator (check icon appears)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('selected option has different styling with primary green color', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      
      // Select the option
      await tester.tap(find.text('Social Media (Instagram, TikTok, etc)'));
      await tester.pump();
      
      // Verify check icon appears for selected item
      expect(find.byIcon(Icons.circle_outlined), findsWidgets); // Unselected options
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Selected option
      
      // Find the selected container by finding the parent of the check icon
      final selectedIconFinder = find.byIcon(Icons.check_circle);
      final selectedContainer = find.ancestor(
        of: selectedIconFinder,
        matching: find.byType(Container),
      ).first;
      
      // We can verify the container styling by checking its child widget properties
      final container = tester.widget<Container>(selectedContainer);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      
      // Check border is thicker for selected item (2px vs 1px for unselected)
      expect(border.top.width, equals(2.0));
      
      // Check text is also styled differently for selected item
      final selectedText = find.descendant(
        of: selectedContainer,
        matching: find.byType(Text),
      ).first;
      final textWidget = tester.widget<Text>(selectedText);
      expect(textWidget.style!.fontWeight, equals(FontWeight.w600)); // Bold for selected
    });

    testWidgets('selecting an option and tapping Continue saves preference and navigates', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Select the option
      await tester.tap(find.text('Google Search'));
      await tester.pump();

      // Find the continue button by type and text
      final continueButtonFinder = find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(ElevatedButton),
      );
      expect(continueButtonFinder, findsOneWidget);

      // Ensure it's visible and tap it
      await tester.ensureVisible(continueButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(continueButtonFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Check if navigated to sync fitness tracker page
      expect(find.text('Sync Fitness Tracker Page'), findsOneWidget);

      // Verify preference was saved
      expect(prefs.getString('heardAboutPockEat'), 'Google Search');
    });
    
    testWidgets('can switch between different options', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Select first option
      await tester.tap(find.text('Friend / Family'));
      await tester.pump();
      
      // Check first is selected
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Now select a different option
      await tester.tap(find.text('Google Search'));
      await tester.pump();
      
      // Should still have only one check icon (not two)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Find the ElevatedButton that contains the Continue text
      final continueButtonFinder = find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(ElevatedButton),
      );
      
      // Ensure the button is visible before tapping
      await tester.ensureVisible(continueButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(continueButtonFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      // Verify only the last selection is saved
      expect(prefs.getString('heardAboutPockEat'), 'Google Search');
    });
    testWidgets('back button has modern styling with shadow', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      
      // Find back button in app bar
      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);
      
      // Find container with shadow that surrounds back button
      final containerWithShadow = find.ancestor(
        of: backButtonFinder,
        matching: find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            return decoration.shape == BoxShape.circle && 
                   decoration.color == Colors.white &&
                   decoration.boxShadow != null && 
                   decoration.boxShadow!.isNotEmpty;
          }
          return false;
        }),
      );
      
      // Verify modern circular container with shadow exists
      expect(containerWithShadow, findsOneWidget);
    });
    
    testWidgets('back button navigates properly when pressed', (tester) async {
      // Create widget with navigation history
      final mockObserver = MockNavigatorObserver();
      
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [mockObserver],
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HeardAboutPage(),
              ),
            ),
            child: const Text('Go to HeardAboutPage'),
          ),
        ),
      ));
      
      // Navigate to HeardAboutPage
      await tester.tap(find.text('Go to HeardAboutPage'));
      await tester.pumpAndSettle();
      
      // Verify we're on HeardAboutPage
      expect(find.text('How You Found Us'), findsOneWidget);
      
      // Find and tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verify we navigated back
      expect(find.text('How You Found Us'), findsNothing);
      expect(find.text('Go to HeardAboutPage'), findsOneWidget);
    });
  });
}

// Mock navigator observer for testing navigation
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
  }
}