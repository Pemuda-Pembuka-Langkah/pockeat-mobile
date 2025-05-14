// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/activity_level_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';
import 'activity_level_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])

void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([mockCubit.state]));
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const ActivityLevelPage(),
      ),
      routes: {
        '/speed': (context) => const Scaffold(body: Text('Speed Page')),
      },
    );
  }

  testWidgets('renders page title and subtitle correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Activity Level'), findsOneWidget);
    expect(find.text('What best describes your weekly activity level?'), findsOneWidget);
  });

  testWidgets('renders all activity level options with descriptions', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Check that activity options are displayed with proper text
    for (final level in ActivityLevelPage.activityLevels) {
      // We may need to scroll to find all options
      final scrollable = find.byType(Scrollable);
      
      // Try to find the label and ensure it's visible
      await tester.dragUntilVisible(
        find.text(level['label']!),
        scrollable,
        const Offset(0, -100),
      );
      
      expect(find.text(level['label']!), findsOneWidget);
      expect(find.text(level['description']!), findsOneWidget);
    }
  });

  testWidgets('activity options have icons displayed correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Check that the first two options' icons are visible without scrolling
    expect(find.byIcon(Icons.weekend), findsOneWidget); // Sedentary
    expect(find.byIcon(Icons.directions_walk), findsOneWidget); // Light
  });

  testWidgets('Continue button is initially disabled', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find Continue button (renamed from Next)
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButton, findsOneWidget);

    // Check if button is disabled initially
    final button = tester.widget<ElevatedButton>(continueButton);
    expect(button.onPressed, isNull);
  });

  testWidgets('shows enabled Continue button when activity level is pre-selected', (tester) async {
    // Start with a state that has a level already selected
    final selectedState = HealthMetricsFormState(activityLevel: 'moderate');
    when(mockCubit.state).thenReturn(selectedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(selectedState));
    
    // Build the widget with the selected state
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Find the Continue button and verify it's enabled
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    final button = tester.widget<ElevatedButton>(continueButton);
    
    // Since we have a pre-selected activity level, the button should be enabled
    expect(button.onPressed, isNotNull, reason: 'Button should be enabled when activity level is selected');
  });

  testWidgets('selected activity option displays check icon', (tester) async {
    // Create a state with a selection already made
    final selectedState = HealthMetricsFormState(activityLevel: 'moderate');
    when(mockCubit.state).thenReturn(selectedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(selectedState));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find the 'Moderate' activity option
    final moderateOption = find.text('Moderate');
    await tester.dragUntilVisible(
      moderateOption,
      find.byType(Scrollable),
      const Offset(0, -100),
    );

    // Since we pre-selected 'moderate' in our state, we should now see a check icon
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    
    // We should also see the green color for selection
    // Find the container wrapper of the selected option
    final selectedContainer = find.ancestor(
      of: moderateOption,
      matching: find.byType(Container),
    ).first;
    
    // Get the Container widget
    final container = tester.widget<Container>(selectedContainer);
    
    // Check if it has a border with the primary green color
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
  });
  
  testWidgets('tapping an activity option calls setActivityLevel on cubit', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find and tap the 'Moderate' activity option
    final moderateOption = find.text('Moderate');
    await tester.dragUntilVisible(
      moderateOption,
      find.byType(Scrollable),
      const Offset(0, -100),
    );
    
    // Tap on the option
    await tester.tap(find.ancestor(
      of: moderateOption,
      matching: find.byType(InkWell),
    ));
    await tester.pumpAndSettle();

    // Verify the cubit method was called with the correct parameter
    verify(mockCubit.setActivityLevel('moderate')).called(1);
  });

  testWidgets('can select activity level and updates the cubit', (tester) async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find and tap an activity option
    final activeOption = find.text('Active');
    await tester.dragUntilVisible(
      activeOption,
      find.byType(Scrollable),
      const Offset(0, -100),
    );
    
    await tester.tap(find.ancestor(
      of: activeOption,
      matching: find.byType(InkWell),
    ));
    await tester.pumpAndSettle();
    
    // Verify the cubit method was called with the correct parameter
    verify(mockCubit.setActivityLevel('active')).called(1);
  });

  testWidgets('Continue button is disabled when no selection is made', (tester) async {
    // Setup state with no selection
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    when(mockCubit.stream).thenAnswer((_) => Stream.value(HealthMetricsFormState()));
    
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Find Continue button and verify it's disabled
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    final button = tester.widget<ElevatedButton>(continueButton);
    
    // When no selection is made, button should be disabled
    expect(button.onPressed, isNull);
  });
  
  testWidgets('Continue button is enabled when activity level is selected', (tester) async {
    // Setup state with a selection
    final selectedState = HealthMetricsFormState(activityLevel: 'light');
    when(mockCubit.state).thenReturn(selectedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(selectedState));
    
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Find Continue button and verify it's enabled
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    final button = tester.widget<ElevatedButton>(continueButton);
    
    // When selection is made, button should be enabled
    expect(button.onPressed, isNotNull);
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
    expect(find.text('Sedentary'), findsOneWidget);
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
    expect(widget.currentStep, 8); // This is the 9th step (0-indexed)
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
