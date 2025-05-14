// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/diet_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';
import 'diet_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    
    // Setup the initial state
    final initialState = HealthMetricsFormState();
    when(mockCubit.state).thenReturn(initialState);
    
    // Create a proper stream controller for the cubit
    final controller = Stream<HealthMetricsFormState>.fromIterable([initialState]);
    when(mockCubit.stream).thenAnswer((_) => controller);
  });

  tearDown(() {
    reset(mockCubit);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      routes: {
        '/onboarding/goal': (_) => const Scaffold(body: Text('Onboarding Goal Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const DietPage(),
      ),
    );
  }

  testWidgets('renders page title and subtitle correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Diet Preference'), findsOneWidget);
    expect(find.text('Do you follow a specific diet?'), findsOneWidget);
  });

  testWidgets('renders diet options with descriptions', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Check first two diet options are displayed without scrolling
    expect(find.text('No specific diet'), findsOneWidget);
    expect(find.text('You eat a general diet without any specific restrictions.'), findsOneWidget);

    expect(find.text('Vegetarian'), findsOneWidget);
    expect(find.text('No meat or fish, but may include dairy and eggs.'), findsOneWidget);

    // Find the scrollable widget
    final scrollable = find.byType(Scrollable);
    
    // Drag the scrollable to look for more options
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    
    // After scrolling, check for Vegan text
    expect(find.textContaining('Vegan'), findsOneWidget);
    
    // Drag more to find other options
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    
    // Look for 'Other' option which should be at the bottom
    expect(find.textContaining('Other'), findsOneWidget);
  });

  testWidgets('option icons are displayed correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Check that icons are displayed
    expect(find.byIcon(Icons.restaurant), findsOneWidget); // No specific diet
    expect(find.byIcon(Icons.eco), findsOneWidget); // Vegetarian
    expect(find.byIcon(Icons.spa), findsOneWidget); // Vegan
  });

  testWidgets('Continue button is initially disabled', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find Continue button
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButton, findsOneWidget);

    // Check if button is disabled initially
    final button = tester.widget<ElevatedButton>(continueButton);
    expect(button.onPressed, isNull);
  });

  testWidgets('selecting a diet option enables the Continue button', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find and tap the first diet option
    final firstOption = find.text('No specific diet');
    expect(firstOption, findsOneWidget);
    
    // Tap on the option container (parent of the text)
    await tester.tap(find.ancestor(
      of: firstOption,
      matching: find.byType(InkWell),
    ));
    await tester.pumpAndSettle();

    // Check if the Continue button is now enabled
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    final button = tester.widget<ElevatedButton>(continueButton);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('selecting a diet option shows visual selection indication', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find and tap 'Vegetarian' option
    final veganOption = find.text('Vegetarian');
    await tester.ensureVisible(veganOption);
    await tester.tap(find.ancestor(
      of: veganOption,
      matching: find.byType(InkWell),
    ));
    await tester.pumpAndSettle();

    // Check for check icon indicating selection
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('selecting a diet, submits it, and navigates to goal page', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Select the first diet option (No specific diet) which should be visible without scrolling
    final firstOption = find.text('No specific diet');
    expect(firstOption, findsOneWidget);
    
    await tester.tap(find.ancestor(
      of: firstOption,
      matching: find.byType(InkWell),
    ));
    await tester.pumpAndSettle();

    // Set up the mock for the diet type setting
    when(mockCubit.setDietType(any)).thenReturn(null);

    // Tap the Continue button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // Verify the diet type was set correctly
    verify(mockCubit.setDietType('No specific diet')).called(1);

    // Verify navigation to the goal page
    expect(find.text('Onboarding Goal Page'), findsOneWidget);
  });

  testWidgets('ScrollController works with Scrollbar', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify Scrollbar is present
    expect(find.byType(Scrollbar), findsOneWidget);
    
    // Verify ListView is present with ScrollController
    expect(find.byType(ListView), findsOneWidget);

    // Find the scrollable widget and scroll down
    final scrollable = find.byType(Scrollable);
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    
    // After scrolling, we should still be on the same page
    expect(find.text('Diet Preference'), findsOneWidget);
  });

  testWidgets('animations are present when page loads', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    // Verify the animation widgets exist
    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(SlideTransition), findsWidgets);

    // Let animations play
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Content should be visible after animations
    expect(find.text('No specific diet'), findsOneWidget);
  });

  testWidgets('progress indicator shows correct step', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    // Find the OnboardingProgressIndicator
    final progressIndicator = find.byType(OnboardingProgressIndicator);
    expect(progressIndicator, findsOneWidget);
    
    // Extract the widget to check its properties
    final widget = tester.widget<OnboardingProgressIndicator>(progressIndicator);
    
    // Verify the step values
    expect(widget.totalSteps, 16);
    expect(widget.currentStep, 6); // This is the 7th step (0-indexed)
    expect(widget.showPercentage, true);
  });

  testWidgets('back button navigates back', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingInProgress': true});
    
    await tester.pumpWidget(buildTestableWidget());
    
    // Find the back button
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
