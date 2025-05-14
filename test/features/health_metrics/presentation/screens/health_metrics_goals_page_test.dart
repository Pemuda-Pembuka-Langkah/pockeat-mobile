// Dart imports:
import 'dart:async';

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
import 'package:pockeat/features/health_metrics/presentation/screens/health_metrics_goals_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';
import 'health_metrics_goals_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([
          HealthMetricsFormState(),
        ]));
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      routes: {
        '/activity-level': (_) => const Scaffold(body: Text('Activity Level Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const HealthMetricsGoalsPage(),
      ),
    );
  }

  testWidgets('renders page title, subtitle and prompt text', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle(); // Wait for animations

    // Check title and subtitle
    expect(find.text('Your Goals'), findsOneWidget);
    expect(find.text('What would you like to accomplish?'), findsOneWidget);
    expect(find.text('Select all that apply'), findsOneWidget);
  });
  
  testWidgets('renders all goal options with icons', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle(); // Wait for animations

    // Verify all goal options are displayed with their icons
    for (final option in HealthMetricsGoalsPage.options) {
      expect(find.text(option["title"]), findsOneWidget);
      expect(find.byIcon(option["icon"]), findsOneWidget);
    }
  });

  testWidgets('tapping a goal option calls toggleGoal on cubit', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final goalMap = HealthMetricsGoalsPage.options.first;
    final goalTitle = goalMap["title"] as String;
    
    // Tap on goal option via its InkWell ancestor
    await tester.tap(find.ancestor(
      of: find.text(goalTitle),
      matching: find.byType(InkWell),
    ));
    await tester.pump();

    // Verify the cubit's toggleGoal method was called with correct parameter
    verify(mockCubit.toggleGoal(goalTitle)).called(1);
  });
  
  testWidgets('selected goal shows visual indication', (WidgetTester tester) async {
    // Create a state with a selected goal
    final selectedState = HealthMetricsFormState(selectedGoals: ['Feel better about my body']);
    when(mockCubit.state).thenReturn(selectedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(selectedState));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find the selected goal container
    final selectedText = find.text('Feel better about my body');
    final selectedContainer = find.ancestor(
      of: selectedText,
      matching: find.byType(Container),
    ).first;
    
    // Get the Container widget and its decoration
    final container = tester.widget<Container>(selectedContainer);
    final decoration = container.decoration as BoxDecoration;
    
    // Check for the check icon
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    
    // Check border color (should be green for selected item)
    expect(decoration.border, isNotNull);
  });

  testWidgets('displays text field when "Other" is selected', (WidgetTester tester) async {
    // Set up state with 'Other' selected
    when(mockCubit.state).thenReturn(
      HealthMetricsFormState(selectedGoals: ["Other"]),
    );
    when(mockCubit.stream).thenAnswer((_) => Stream.value(
      HealthMetricsFormState(selectedGoals: ["Other"]),
    ));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Check for text field and its label
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Please specify'), findsOneWidget);
    
    // Test entering text in the field
    await tester.enterText(find.byType(TextField), 'Build muscle');
    await tester.pump();
    
    // Verify the cubit method was called with input text
    verify(mockCubit.setOtherGoalReason('Build muscle')).called(1);
  });

  testWidgets('disables non-"Other" goals when "Other" is selected', (WidgetTester tester) async {
    // Set up state with 'Other' selected
    when(mockCubit.state).thenReturn(
      HealthMetricsFormState(selectedGoals: ["Other"]),
    );
    when(mockCubit.stream).thenAnswer((_) => Stream.value(
      HealthMetricsFormState(selectedGoals: ["Other"]),
    ));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Try to tap a non-Other option
    final disabledOptionMap = HealthMetricsGoalsPage.options.first;
    final disabledOptionTitle = disabledOptionMap["title"] as String;
    await tester.tap(find.ancestor(
      of: find.text(disabledOptionTitle),
      matching: find.byType(InkWell),
    ));
    await tester.pump();

    // Verify the toggleGoal method was never called
    verifyNever(mockCubit.toggleGoal(disabledOptionTitle));
    
    // Verify the option appears visually disabled (has grey color)
    final disabledText = tester.widget<Text>(
      find.text(disabledOptionTitle)
    );
    final style = disabledText.style as TextStyle;
    expect(style.color, isNot(Colors.black87)); // Should be a greyed color
  });

  testWidgets('Continue button is disabled initially and enabled when valid selection', (WidgetTester tester) async {
    final controller = StreamController<HealthMetricsFormState>.broadcast();

    // Initial state: no selection (invalid)
    final emptyState = HealthMetricsFormState();
    when(mockCubit.state).thenReturn(emptyState);
    when(mockCubit.stream).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(buildTestableWidget());
    controller.add(emptyState);
    await tester.pumpAndSettle();

    // Find Continue button and verify it's disabled initially
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    var button = tester.widget<ElevatedButton>(continueButton);
    expect(button.onPressed, isNull, reason: 'Button should be disabled with no selection');

    // Switch to valid state with a regular goal selected
    final validState = HealthMetricsFormState(
      selectedGoals: ["Feel better about my body"],
    );
    when(mockCubit.state).thenReturn(validState);
    controller.add(validState);
    await tester.pumpAndSettle();

    // Button should now be enabled
    button = tester.widget<ElevatedButton>(continueButton);
    expect(button.onPressed, isNotNull, reason: 'Button should be enabled with valid selection');

    await controller.close();
  });
  
  testWidgets('Continue button is disabled with Other selected but no reason', (WidgetTester tester) async {
    final controller = StreamController<HealthMetricsFormState>.broadcast();

    // Invalid state: Other selected but no reason provided
    final invalidState = HealthMetricsFormState(selectedGoals: ["Other"]);
    when(mockCubit.state).thenReturn(invalidState);
    when(mockCubit.stream).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(buildTestableWidget());
    controller.add(invalidState);
    await tester.pumpAndSettle();

    // Button should be disabled
    var button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
    expect(button.onPressed, isNull, reason: 'Button should be disabled without Other reason');

    // Valid state with Other selected and reason provided
    final validState = HealthMetricsFormState(
      selectedGoals: ["Other"],
      otherGoalReason: "Gain strength",
    );
    when(mockCubit.state).thenReturn(validState);
    controller.add(validState);
    await tester.pumpAndSettle();

    // Button should now be enabled
    button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
    expect(button.onPressed, isNotNull, reason: 'Button should be enabled with Other reason');

    await controller.close();
  });

  testWidgets('navigates to activity level page when Continue is tapped', (WidgetTester tester) async {
    // Set up valid state
    final validState = HealthMetricsFormState(
      selectedGoals: ["Feel better about my body"],
    );
    when(mockCubit.state).thenReturn(validState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(validState));
    
    // Set up mock shared preferences
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find and tap the Continue button
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify navigation to the Activity Level page
    expect(find.text('Activity Level Page'), findsOneWidget);
  });
  
  testWidgets('animations are present when page loads', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    // Verify animation widgets exist
    expect(find.byType(FadeTransition), findsWidgets);

    // Let animations play
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Content should be visible after animations
    for (final option in HealthMetricsGoalsPage.options) {
      expect(find.text(option["title"]), findsOneWidget);
    }
  });
  
  testWidgets('progress indicator shows correct step', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Find the OnboardingProgressIndicator
    final progressIndicator = find.byType(OnboardingProgressIndicator);
    expect(progressIndicator, findsOneWidget);
    
    // Extract the widget to check its properties
    final widget = tester.widget<OnboardingProgressIndicator>(progressIndicator);
    
    // Verify the step values
    expect(widget.totalSteps, 16);
    expect(widget.currentStep, 7); // This is the 8th step (0-indexed)
    expect(widget.showPercentage, true);
  });
  
  testWidgets('back button has proper styling', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
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
  });
}
