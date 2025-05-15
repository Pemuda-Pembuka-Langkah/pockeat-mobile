// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/goal_obstacle_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';
import 'goal_obstacle_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])

void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    when(mockCubit.stream).thenAnswer((_) => Stream.value(HealthMetricsFormState()));
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      routes: {
        '/diet': (_) => const Scaffold(body: Text('Diet Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const GoalObstaclePage(),
      ),
    );
  }

  testWidgets('renders page title, subtitle and all obstacle options', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle(); // Wait for animations

    // Check title and subtitle
    expect(find.text('Challenges'), findsOneWidget);
    expect(find.text("What's your biggest obstacle?"), findsOneWidget);
    
    // Verify all obstacles are displayed
    for (final obstacle in GoalObstaclePage.obstacles) {
      // Some obstacles might need scrolling to be visible
      await tester.dragUntilVisible(
        find.text(obstacle),
        find.byType(SingleChildScrollView),
        const Offset(0, -100)
      );
      expect(find.text(obstacle), findsOneWidget);
    }
  });

  testWidgets('tapping an obstacle calls cubit.setDietType', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle(); // Wait for animations

    final firstObstacle = GoalObstaclePage.obstacles.first;

    // Find the obstacle option and tap it
    await tester.tap(find.ancestor(
      of: find.text(firstObstacle),
      matching: find.byType(InkWell),
    ));
    await tester.pump();

    // Verify the cubit method was called with the correct parameter
    verify(mockCubit.setDietType(firstObstacle)).called(1);
  });
  
  testWidgets('obstacles have appropriate icons', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Check a few specific icons that should be present
    expect(find.byIcon(Icons.access_time), findsOneWidget); // Lack of Time
    expect(find.byIcon(Icons.battery_alert), findsOneWidget); // Lack of Motivation
    
    // Scroll to see more icons
    await tester.dragUntilVisible(
      find.byIcon(Icons.fitness_center),
      find.byType(SingleChildScrollView),
      const Offset(0, -100)
    );
    expect(find.byIcon(Icons.fitness_center), findsOneWidget); // Inconsistent Exercise
  });

  testWidgets('Continue button is disabled when no obstacle is selected', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find the Continue button (renamed from Next)
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButton, findsOneWidget);
    
    // Check if button is disabled initially
    final button = tester.widget<ElevatedButton>(continueButton);
    expect(button.onPressed, isNull);
  });

  testWidgets('Continue button is enabled when obstacle is selected', (tester) async {
    // Setup state with a selection
    final selectedState = HealthMetricsFormState(dietType: "Lack of Motivation");
    when(mockCubit.state).thenReturn(selectedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(selectedState));
    
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Find Continue button and verify it's enabled
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    final button = tester.widget<ElevatedButton>(continueButton);
    
    // When selection is made, button should be enabled
    expect(button.onPressed, isNotNull, reason: 'Button should be enabled when obstacle is selected');
  });
  
  testWidgets('can navigate to diet page when obstacle is selected and Continue is tapped', (tester) async {
    // Set state with a selected obstacle (reusing dietType)
    final selectedState = HealthMetricsFormState(dietType: "Lack of Motivation");
    when(mockCubit.state).thenReturn(selectedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(selectedState));

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find the Continue button
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButton, findsOneWidget);

    // Tap the Continue button
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify we've navigated to the Diet page
    expect(find.text('Diet Page'), findsOneWidget);
  });
  
  testWidgets('selected obstacle shows visual selection indicator', (tester) async {
    // Create a state with an obstacle already selected
    final selectedState = HealthMetricsFormState(dietType: "Lack of Time");
    when(mockCubit.state).thenReturn(selectedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(selectedState));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find the selected option
    final selectedText = find.text("Lack of Time");
    
    // Since we pre-selected this obstacle in our state, we should see a check icon
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    
    // Find the container of the selected option
    final selectedContainer = find.ancestor(
      of: selectedText,
      matching: find.byType(Container),
    ).first;
    
    // Get the Container widget
    final container = tester.widget<Container>(selectedContainer);
    
    // Check if it has a border (assuming selection changes border)
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
  });
  
  testWidgets('animations are present when page loads', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    // Verify animation widgets exist
    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(SlideTransition), findsWidgets);

    // Let animations play
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Content should be visible after animations
    expect(find.text("Lack of Time"), findsOneWidget);
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
    expect(widget.currentStep, 5); // This is the 6th step (0-indexed)
    expect(widget.showPercentage, true);
  });
  
  testWidgets('back button has proper styling with shadow and circular shape', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingInProgress': true});
    
    await tester.pumpWidget(buildTestableWidget());
    
    // Find the back button and check its styling
    final backButton = find.byIcon(Icons.arrow_back);
    expect(backButton, findsOneWidget);
    
    // Check if it's wrapped in a Container (shadow and circular decoration)
    final buttonContainer = find.ancestor(
      of: backButton,
      matching: find.byType(Container),
    );
    expect(buttonContainer, findsWidgets);
    
    // Check container has proper decoration (white color & circular shape)
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(IconButton),
        matching: find.byType(Container),
      )
    );
    
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.white);
    expect(decoration.shape, BoxShape.circle);
    
    // Verify it has a shadow
    expect(decoration.boxShadow, isNotNull);
    expect(decoration.boxShadow!.length, 1);
  });
}
