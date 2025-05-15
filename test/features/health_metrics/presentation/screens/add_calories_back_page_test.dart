// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/add_calories_back_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AddCaloriesBackPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({}); // Reset prefs before each test
    });

    testWidgets('renders with proper modern UI components', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));
      await tester.pump(); // Complete animations from initState

      // Main title and subtitle
      expect(find.text('Exercise Calories'), findsOneWidget);
      expect(find.text('Would you like to add calories burned from exercise back to your daily calorie goal?'), findsOneWidget);
      
      // Core UI components
      expect(find.byType(OnboardingProgressIndicator), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      
      // Info container elements
      expect(find.text('What this means'), findsOneWidget);
      
      // Button options
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('progress indicator shows correct step', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));
      await tester.pump();

      final progressIndicator = tester.widget<OnboardingProgressIndicator>(
        find.byType(OnboardingProgressIndicator)
      );
      
      expect(progressIndicator.totalSteps, 16);
      expect(progressIndicator.currentStep, 10); // Should be step 11 (0-indexed)
      expect(progressIndicator.showPercentage, isTrue);
    });

    testWidgets('info card displays explanation about exercise calories', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));
      await tester.pump();

      expect(find.text('If you choose \'Yes\', calories burned during exercise will be added to your daily target, allowing you to eat more on active days.'), findsOneWidget);
    });

    testWidgets('continue button is disabled initially', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));

      final continueButtonFinder = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButtonFinder, findsOneWidget);
      
      final continueButton = tester.widget<ElevatedButton>(continueButtonFinder);
      expect(continueButton.onPressed, isNull); // Button should be disabled initially
      
      // Check button styling for disabled state
      final buttonStyle = continueButton.style;
      expect(buttonStyle, isNotNull);
    });

    testWidgets('tapping Yes enables continue button and shows selection UI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));

      // Tap Yes
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // Check button is enabled
      final continueButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(continueButton.onPressed, isNotNull);
      
      // Check for visual selection indicators (check icon appears)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping No enables continue button and shows selection UI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));

      // Tap No
      await tester.tap(find.text('No'));
      await tester.pump();

      // Check button is enabled
      final continueButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(continueButton.onPressed, isNotNull);
      
      // Check for visual selection indicators (close icon appears)
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('pressing continue after choosing Yes saves true and navigates', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: const AddCaloriesBackPage(),
          routes: {
            '/rollover-calories': (_) => const Scaffold(body: Text('Rollover Calories Page')),
          },
        ),
      );

      // Tap Yes
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // Press Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Check if navigated
      expect(find.text('Rollover Calories Page'), findsOneWidget);

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('addCaloriesBack'), isTrue);
    });

    testWidgets('pressing continue after choosing No saves false and navigates', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: const AddCaloriesBackPage(),
          routes: {
            '/rollover-calories': (_) => const Scaffold(body: Text('Rollover Calories Page')),
          },
        ),
      );

      // Tap No
      await tester.tap(find.text('No'));
      await tester.pump();

      // Press Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Check if navigated
      expect(find.text('Rollover Calories Page'), findsOneWidget);

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('addCaloriesBack'), isFalse);
    });
    
    testWidgets('animations are properly initialized', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));
      
      // Initial frame before animations
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
      
      // Let animations play
      await tester.pump(const Duration(milliseconds: 300)); // Mid-animation
      await tester.pump(const Duration(milliseconds: 400)); // Animation complete
      
      // Content should now be visible
      expect(find.text('What this means'), findsOneWidget);
    });
  });
}
