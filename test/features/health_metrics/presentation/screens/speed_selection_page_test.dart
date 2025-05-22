// speed_selection_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/speed_selection_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';
import 'speed_selection_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    when(mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
  });

  // Helper method removed as it's no longer needed

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/add-calories-back': (_) => const Scaffold(body: Text('Add Calories Back Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const SpeedSelectionPage(),
      ),
    );
  }

  group('SpeedSelectionPage UI Tests - Normal Mode', () {
    testWidgets('renders with proper modern UI components', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Complete animations from initState

      // Main title and subtitle
      expect(find.text("Goal Speed"), findsOneWidget);
      expect(find.text("How fast do you want to reach your goal?"), findsOneWidget);
      
      // Core UI components
      expect(find.byType(OnboardingProgressIndicator), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text("Continue"), findsOneWidget); // Button text is now "Continue"
      
      // Info container elements
      expect(find.text("Weekly weight change"), findsOneWidget);
      expect(find.textContaining("kg/week"), findsOneWidget); // Value display
      
      // Speed range indicators
      expect(find.text("Slow"), findsOneWidget);
      expect(find.text("Fast"), findsOneWidget);
    });

    testWidgets('displays different progress descriptions based on slider value', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Wait for all animations

      // Initially at 0.5 => "Balanced & Consistent"
      expect(find.text('Balanced & Consistent 🧘'), findsOneWidget);
      expect(find.text('Moderate pace balancing results and sustainability'), findsOneWidget);

      // Drag slider right to >1.2 (Ambitious)
      final sliderFinder = find.byType(Slider);
      await tester.drag(sliderFinder, const Offset(300, 0)); // Big drag to the right
      await tester.pumpAndSettle();

      // Now expect the ambitious text
      expect(find.text('Ambitious & Fast ⚡️'), findsOneWidget);
      expect(find.text('Rapid results but may be more challenging to maintain'), findsOneWidget);

      // Drag slider back to very left (<0.5) (Slow)
      await tester.drag(sliderFinder, const Offset(-600, 0)); // Big drag to the left
      await tester.pumpAndSettle();

      // Now expect slow text
      expect(find.text('Slow & Steady 🐢'), findsOneWidget);
      expect(find.text('Gentle, sustainable pace for long-term results'), findsOneWidget);
    });

    testWidgets('updates displayed kg/week value when slider changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should start around 0.5 kg/week
      expect(find.textContaining('0.5 kg/week'), findsOneWidget);
      
      // Drag to a different value
      final sliderFinder = find.byType(Slider);
      await tester.drag(sliderFinder, const Offset(150, 0)); // Drag right a bit
      await tester.pumpAndSettle();

      // Value should have changed (could be various values like 1.0 or 1.1)
      expect(find.textContaining('0.5 kg/week'), findsNothing);
      expect(find.textContaining('kg/week'), findsAtLeastNWidgets(1)); // Still showing some kg/week value
    });

    testWidgets('calls cubit and navigates to add-calories-back page on Continue tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify cubit was called with any value (since default is 0.5)
      verify(mockCubit.setWeeklyGoal(any)).called(1);
      
      // Verify navigation to new route
      expect(find.text('Add Calories Back Page'), findsOneWidget);
    });

    testWidgets('progress indicator shows correct step', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final progressIndicator = tester.widget<OnboardingProgressIndicator>(
        find.byType(OnboardingProgressIndicator)
      );
      
      expect(progressIndicator.totalSteps, 16);
      expect(progressIndicator.currentStep, 9); // Should be step 10 (0-indexed)
    });
  });

  group('SpeedSelectionPage UI Tests - Maintenance Mode', () {
    setUp(() {
      // Set up the state for maintenance mode (current weight = desired weight)
      final testState = HealthMetricsFormState(
        weight: 70.0,
        desiredWeight: 70.0,
        // Explicitly set weeklyGoal to 0.0 to test maintenance mode
        weeklyGoal: 0.0,
      );
      when(mockCubit.state).thenReturn(testState);
    });
    
    testWidgets('shows maintenance notice when current weight equals desired weight',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify maintenance notice is shown
      expect(find.text("Weight Maintenance"), findsOneWidget);
      expect(
        find.text("Your current weight equals your desired weight. Goal speed will be set to 0 kg/week for weight maintenance."),
        findsOneWidget,
      );
    });

    testWidgets('hides weekly weight change container in maintenance mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // These elements should not be present in maintenance mode
      expect(find.text("Weekly weight change"), findsNothing);
      expect(find.text("Slow"), findsNothing);
      expect(find.text("Fast"), findsNothing);
    });

    testWidgets('hides slider in maintenance mode', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Slider should not be visible
      expect(find.byType(Slider), findsNothing);
    });
    
    testWidgets('calls cubit with 0.0 weekly goal when in maintenance mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify cubit was called with 0.0 (maintenance mode value)
      verify(mockCubit.setWeeklyGoal(0.0)).called(1);
      
      // Verify navigation to new route
      expect(find.text('Add Calories Back Page'), findsOneWidget);
    });
  });

  group('SpeedSelectionPage - Weight Loss Mode with Previous Maintenance Value', () {
    testWidgets('uses reasonable default when previous weekly goal was 0.0',
        (WidgetTester tester) async {
      // Setup state directly for a user who is NOT in maintenance mode
      // but still has a 0.0 weeklyGoal from previous maintenance mode
      when(mockCubit.state).thenReturn(HealthMetricsFormState(
        weight: 80.0,      // Current weight
        desiredWeight: 70.0, // Different desired weight (not maintenance)
        weeklyGoal: 0.0,    // Previous value from maintenance mode
      ));
      
      // Build the widget and let it settle
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Verify we're NOT in maintenance mode
      expect(find.text("Weight Maintenance"), findsNothing);
      
      // Verify a reasonable default is shown (0.5 kg/week)
      // This confirms our initialization logic fixed the 0.0 value
      expect(find.textContaining("0.5 kg/week"), findsOneWidget);
      
      // Set up for the button press
      when(mockCubit.setWeeklyGoal(any)).thenAnswer((_) async {});
      
      // Press the Continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // Verify that 0.5 was passed to the cubit, not the original 0.0
      verify(mockCubit.setWeeklyGoal(0.5)).called(1);
    });
  });
}
