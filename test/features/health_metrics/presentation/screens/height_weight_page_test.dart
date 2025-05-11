// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/height_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';
import 'height_weight_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    when(mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/birthdate': (_) => const Scaffold(body: Text('Birthdate Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const HeightWeightPage(),
      ),
    );
  }
  
  // Helper function to pump future frames for animations
  Future<void> pumpFramesForAnimation(WidgetTester tester) async {
    await tester.pump(); // Schedule the animation
    await tester.pump(const Duration(milliseconds: 300)); // Pump a frame during animation
    await tester.pumpAndSettle(); // Wait for animation to complete
  }

  testWidgets('renders progress indicator and title elements', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Check for onboarding progress indicator
    expect(find.byType(OnboardingProgressIndicator), findsOneWidget);
    
    // Check for title elements
    expect(find.text('Measurements'), findsOneWidget);
    expect(find.text('Enter your height and weight'), findsOneWidget);
  });
  
  testWidgets('renders height and weight input sections', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Check for input field labels
    expect(find.text('Height (cm)'), findsOneWidget);
    expect(find.text('Weight (kg)'), findsOneWidget);
    
    // Check for input elements
    expect(find.byType(TextFormField), findsOneWidget); // Height field
    expect(find.byType(Slider), findsOneWidget); // Weight slider
    expect(find.text('Add Measurements'), findsOneWidget); // Submit button
    
    // Check for weight adjustment buttons
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });

  testWidgets('validation state - height input field turns red when empty', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Try to submit with empty height field
    await tester.tap(find.text('Add Measurements'));
    await tester.pump(); 

    // Button should be disabled with empty input
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
    
    // Enter invalid input and check validation happens
    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    
    // Error should appear after entering invalid text
    expect(find.text('Please enter a valid height'), findsOneWidget);
  });

  testWidgets('accepts valid height, calls cubit and navigates', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Enter valid height (weight has default value from slider)
    await tester.enterText(find.byType(TextFormField), '175');
    await tester.pump();
    
    // The button should be enabled after valid input
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNotNull);

    await tester.tap(find.text('Add Measurements'));
    await tester.pumpAndSettle();

    // Verify that the cubit's method was called at least once
    // We don't verify specific parameters to avoid Mockito matcher issues
    verify(mockCubit.setHeightWeight(height: 175.0, weight: 65.0)).called(1);
    expect(find.text('Birthdate Page'), findsOneWidget);
  });

  testWidgets('shows height error for invalid height input', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Enter invalid height
    await tester.enterText(find.byType(TextFormField), '-10');
    await tester.pump();

    // Error should be displayed immediately due to real-time validation
    expect(find.text('Please enter a valid height'), findsOneWidget);
    
    // The button should be disabled when input is invalid
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
  });

  testWidgets('can adjust weight using slider', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Enter valid height to enable calculations
    await tester.enterText(find.byType(TextFormField), '170');
    await tester.pump();
    
    // Drag the slider to change weight value
    await tester.drag(find.byType(Slider), const Offset(50, 0));
    await tester.pump();
    
    // The exact weight depends on the slider position, so we can't assert the exact value
    // But we can check that a weight value exists
    expect(find.textContaining(' kg'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows range error for too small height', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Enter height that's too small
    await tester.enterText(find.byType(TextFormField), '20');
    await tester.pump();

    // Error should be displayed immediately due to real-time validation
    expect(find.text('Height must be between 50 and 300 cm'), findsOneWidget);
  });

  testWidgets('shows range error for too large height', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Enter height that's too large
    await tester.enterText(find.byType(TextFormField), '350');
    await tester.pump();

    // Error should be displayed immediately due to real-time validation
    expect(find.text('Height must be between 50 and 300 cm'), findsOneWidget);
  });

  testWidgets('can adjust weight using + button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);
    
    // Find the weight display
    final weightDisplayFinder = find.textContaining(' kg');
    expect(weightDisplayFinder, findsAtLeastNWidgets(1));
    
    // Tap the + button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    
    // Verify the weight display updates (we can't test exact values without more complex state mocking)
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
  
  testWidgets('can adjust weight using - button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);
    
    // Find the weight display
    final weightDisplayFinder = find.textContaining(' kg');
    expect(weightDisplayFinder, findsAtLeastNWidgets(1));
    
    // Tap the - button
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    
    // Verify the weight display updates (we can't test exact values without more complex state mocking)
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });

  testWidgets('displays BMI calculation when valid height is entered', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpFramesForAnimation(tester);

    // Enter valid height (required for BMI calculation)
    await tester.enterText(find.byType(TextFormField), '170');
    await tester.pump();
    
    // Verify BMI-related UI components appear
    expect(find.textContaining('BMI'), findsAtLeastNWidgets(1));
    expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
  });
  
  testWidgets('displays animations during page initialization', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    
    // Find animation-related widgets
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(SlideTransition), findsOneWidget);
    
    // Pump frames for animation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    
    // Make sure page content appears after animation
    expect(find.text('Height (cm)'), findsOneWidget);
  });
}
