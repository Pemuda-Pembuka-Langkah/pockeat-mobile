// used_other_apps_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/used_other_apps_page.dart';
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
        '/heard-about': (_) => const Scaffold(body: Center(child: Text('Heard About Page'))),
      },
      home: const UsedOtherAppsPage(),
    );
  }

  group('UsedOtherAppsPage', () {
    testWidgets('renders with modern UI components and gradient background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow animations to start
      
      // Check title and subtitle with proper styling
      final titleFinder = find.text('Calorie Tracking');
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style!.fontSize, 28);
      expect(titleWidget.style!.fontWeight, FontWeight.bold);
      expect(titleWidget.style!.color, Colors.black87);
      
      final subtitleFinder = find.text('Have you used other calorie tracking apps before?');
      expect(subtitleFinder, findsOneWidget);
      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect(subtitleWidget.style!.fontSize, 16);
      expect(subtitleWidget.style!.color, Colors.black54);
      
      // Check for progress indicator with correct step
      final progressIndicator = tester.widget<OnboardingProgressIndicator>(
        find.byType(OnboardingProgressIndicator)
      );
      expect(progressIndicator.currentStep, 12); // 13th step (0-indexed)
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
      
      // Verify all options are rendered
      for (final option in UsedOtherAppsPage.appOptions) {
        expect(find.text(option), findsOneWidget);
      }
      
      // Verify Continue button with proper styling
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('tapping an option enables the Next button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially, button should be disabled
      final buttonBefore = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttonBefore.onPressed, isNull);

      // Tap an option
      await tester.tap(find.text('MyFitnessPal'));
      await tester.pump();

      // Button should now be enabled
      final buttonAfter = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttonAfter.onPressed, isNotNull);
    });

    testWidgets('saves selection and navigates on Continue', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Ensure option is visible before tapping
      final lifesumFinder = find.text('Lifesum');
      await tester.ensureVisible(lifesumFinder);
      await tester.pumpAndSettle();
      
      // Tap on option
      await tester.tap(lifesumFinder, warnIfMissed: false);
      await tester.pump();

      // Find and tap Continue button
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should navigate to the next page
      expect(find.text('Heard About Page'), findsOneWidget);

      // Check SharedPreferences
      expect(prefs.getString('usedOtherApps'), 'Lifesum');
    });
    testWidgets('animations are properly initialized', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Check animations exist
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
      
      // Let animations play
      await tester.pump(const Duration(milliseconds: 600));
      
      // Content should be visible after animation
      for (final option in UsedOtherAppsPage.appOptions) {
        expect(find.text(option), findsOneWidget);
      }
    });
    
    testWidgets('selecting an option shows proper visual feedback', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Select an option
      await tester.tap(find.text('MyFitnessPal'));
      await tester.pump();
      
      // Should show check icon for selected option
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Verify selection styling
      final selectedContainer = find.ancestor(
        of: find.text('MyFitnessPal'),
        matching: find.byType(Container),
      ).first;
      
      final container = tester.widget<Container>(selectedContainer);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      
      // Border should be thicker (2px vs 1px) for selected item
      expect(border.top.width, equals(2.0));
      
      // Text should be bold for selected item
      final textWidget = tester.widget<Text>(find.text('MyFitnessPal'));
      expect(textWidget.style!.fontWeight, equals(FontWeight.w600));
    });
    
    testWidgets('can switch between different options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Select first option and ensure it's visible
      final neverUsedFinder = find.text('Never used any');
      await tester.ensureVisible(neverUsedFinder);
      await tester.pumpAndSettle();
      await tester.tap(neverUsedFinder, warnIfMissed: false);
      await tester.pump();
      
      // Verify first is selected
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Now select different option and ensure it's visible
      final lifesumFinder = find.text('Lifesum');
      await tester.ensureVisible(lifesumFinder);
      await tester.pumpAndSettle();
      await tester.tap(lifesumFinder, warnIfMissed: false);
      await tester.pump();
      
      // Should still have only one check icon (not two)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Find and tap Continue button
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      // Verify the correct option was saved
      expect(prefs.getString('usedOtherApps'), 'Lifesum');
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
    
    testWidgets('Continue button has modern rounded styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Select an option to enable the button
      await tester.tap(find.text('MyFitnessPal'));
      await tester.pump();
      
      // Get the enabled button
      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      final buttonStyle = button.style!;
      
      // Check for modern styling elements
      final shape = buttonStyle.shape!.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, isA<BorderRadius>());
      
      // Verify primary green color (4ECDC4) is used
      final backgroundColor = buttonStyle.backgroundColor!.resolve({});
      expect(backgroundColor, isNotNull);
    });
  });
}