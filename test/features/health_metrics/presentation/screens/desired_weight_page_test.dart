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

import 'desired_weight_page_test.mocks.dart'; 

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();

    when(mockCubit.state).thenReturn(HealthMetricsFormState()); // Use appropriate state class
    
    // Create a mock for any route-related methods
    when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([mockCubit.state]));
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/speed': (_) => const Scaffold(body: Text('Speed Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const DesiredWeightPage(),
      ),
    );
  }

  testWidgets('shows validation error for empty or invalid input', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Next'));
    await tester.pump(); // Trigger form validation

    expect(find.text('Please enter a valid weight'), findsOneWidget);
  });

  testWidgets('enters valid weight, saves it, toggles goal, and navigates to goal-obstacle', (WidgetTester tester) async {
      // Mock cubit with a non-null current weight
      when(mockCubit.state).thenReturn(HealthMetricsFormState(weight: 75.0)); // Assume user currently weighs 75 kg

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HealthMetricsFormCubit>.value(
            value: mockCubit,
            child: const DesiredWeightPage(),
          ),
          routes: {
            '/goal-obstacle': (_) => const Scaffold(body: Text('Goal Obstacle Page')),
          },
        ),
      );

      await tester.enterText(find.byType(TextFormField), '70'); // Enter target weight (70 kg)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Check if setDesiredWeight was called correctly
      verify(mockCubit.setDesiredWeight(70.0)).called(1);

      // Check if toggleGoal was called with "Lose Weight" (since 70 < 75)
      verify(mockCubit.toggleGoal('Lose Weight')).called(1);

      // Should navigate to /goal-obstacle
      expect(find.text('Goal Obstacle Page'), findsOneWidget);
    });

  testWidgets('Back button pops when onboarding is in progress and canPop is true', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingInProgress': true});

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  });

  testWidgets('shows error for weight below 10', (tester) async {
  await tester.pumpWidget(createTestWidget());

  await tester.enterText(find.byType(TextFormField), '5');
  await tester.tap(find.text('Next'));
  await tester.pump();

  expect(find.text('Weight must be between 10 and 500 kg'), findsOneWidget);
});

testWidgets('shows error for weight above 500', (tester) async {
  await tester.pumpWidget(createTestWidget());

  await tester.enterText(find.byType(TextFormField), '600');
  await tester.tap(find.text('Next'));
  await tester.pump();

  expect(find.text('Weight must be between 10 and 500 kg'), findsOneWidget);
});

testWidgets('shows error for non-numeric input', (tester) async {
  await tester.pumpWidget(createTestWidget());

  await tester.enterText(find.byType(TextFormField), 'abc');
  await tester.tap(find.text('Next'));
  await tester.pump();

  expect(find.text('Please enter a valid weight'), findsOneWidget);
});

}
