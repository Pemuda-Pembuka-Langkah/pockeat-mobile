// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/desired_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';

import 'desired_weight_page_test.mocks.dart'; 

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();

    // Default state with no weight
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([mockCubit.state]));
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      routes: {
        '/goal-obstacle': (_) => const Scaffold(body: Text('Goal Obstacle Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const DesiredWeightPage(),
      ),
    );
  }

  testWidgets('renders title and subtitle correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    expect(find.text('Your Target Weight'), findsOneWidget);
    expect(find.text('What weight would you like to achieve?'), findsOneWidget);
  });
  
  testWidgets('renders slider with correct range', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle(); // Wait for animations
    
    // Test slider exists
    expect(find.byType(Slider), findsOneWidget);
    
    // Test min-max labels
    expect(find.text('30 kg'), findsOneWidget);
    expect(find.text('150 kg'), findsOneWidget);
  });
  
  testWidgets('displays weight value on the slider', (tester) async {
    // Mock state with weight = null
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Any numerical value should be displayed (we don't care about the exact value)
    // just verify that a weight value exists on screen
    expect(find.textContaining(RegExp(r'\d+')), findsWidgets);
    
    // 'kg' should be visible somewhere
    expect(find.textContaining('kg'), findsWidgets);
  });
  
  testWidgets('slider exists and buttons for adjustment are present', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Find the Slider widget
    final Finder sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);
    
    // Verify plus and minus buttons exist
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });
  
  testWidgets('Continue button navigates and properly sets state', (tester) async {
    // Set up a state with current weight for comparison
    when(mockCubit.state).thenReturn(HealthMetricsFormState(weight: 70.0));
    
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Save the displayed weight to a variable before tapping continue
    // This is more reliable than assuming a hardcoded value
    final weightTextFinder = find.descendant(
      of: find.byType(Row),
      matching: find.byWidgetPredicate((widget) => 
        widget is Text && 
        RegExp(r'^\d+$').hasMatch(widget.data ?? ''),
      ),
    ).first;
    
    expect(weightTextFinder, findsOneWidget, reason: 'Could not find weight text widget');
    
    // Get the actual weight value from the widget
    final Text weightTextWidget = tester.widget(weightTextFinder);
    final int displayedWeight = int.parse(weightTextWidget.data!);
    
    // Find and tap the Continue button
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    
    // Verify the cubit methods were called correctly
    // Using the actual displayed weight rather than a hardcoded value
    verify(mockCubit.setDesiredWeight(displayedWeight.toDouble())).called(1);
    
    // Since weight is 70.0 and desired weight is less, the goal should be 'Lose Weight'
    verify(mockCubit.toggleGoal('Lose Weight')).called(1);
    
    // Verify navigation occurred
    expect(find.text('Goal Obstacle Page'), findsOneWidget);
  });
  
  testWidgets('shows current weight info when available', (tester) async {
    // Set up a state with current weight
    when(mockCubit.state).thenReturn(HealthMetricsFormState(weight: 70.0));
    
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Check for the current weight display
    expect(find.text('Your current weight'), findsOneWidget);
    expect(find.text('70.0 kg'), findsOneWidget);
  });
  
  testWidgets('does not show current weight info when unavailable', (tester) async {
    // State without weight
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
    
    // Current weight info should not be present
    expect(find.text('Your current weight'), findsNothing);
  });
  
  testWidgets('back button is present', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingInProgress': true});
    
    await tester.pumpWidget(buildTestableWidget());
    
    // Find the back button
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
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
    expect(widget.currentStep, 4); // This is the fifth step (0-indexed)
    expect(widget.showPercentage, true);
  });
  
  testWidgets('animations are present when page loads', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    // Check for animation widgets
    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(SlideTransition), findsWidgets);
    
    // Let animations play
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    
    // Content should be visible after animations
    expect(find.text('Target Weight (kg)'), findsOneWidget);
  });

}
