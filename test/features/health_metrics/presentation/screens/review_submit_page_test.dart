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
import 'package:pockeat/features/health_metrics/presentation/screens/review_submit_page.dart';
import 'review_submit_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    when(mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createTestWidget(HealthMetricsFormState state) {
  when(mockCubit.state).thenReturn(state);

  return MaterialApp(
    home: ScaffoldMessenger(
      child: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const ReviewSubmitPage(),
      ),
    ),
  );
}

  testWidgets('displays all values correctly with "Other" goal', (WidgetTester tester) async {
  final state = HealthMetricsFormState(
    selectedGoals: ["Lose Fat", "Other"],
    otherGoalReason: "Boost confidence",
    height: 180,
    weight: 75,
    birthDate: DateTime(1995, 5, 10),
    gender: "Male",
    activityLevel: "Moderately Active",
    dietType: "Keto",
    desiredWeight: 70,
    weeklyGoal: 0.5,
  );

  await tester.pumpWidget(createTestWidget(state));
  await tester.pump();

  expect(find.text("Goals: "), findsOneWidget);
  expect(find.text("Lose Fat, Other: Boost confidence"), findsOneWidget);
  expect(find.text("Height: "), findsOneWidget);
  expect(find.text("180.0 cm"), findsOneWidget);
  expect(find.text("Weight: "), findsOneWidget);
  expect(find.text("75.0 kg"), findsOneWidget);
  expect(find.text("Birth Date: "), findsOneWidget);
  expect(find.text("1995-05-10"), findsOneWidget);
  expect(find.text("Diet Type: "), findsOneWidget);
  expect(find.text("Keto"), findsOneWidget);
  expect(find.text("Desired Weight: "), findsOneWidget);
  expect(find.text("70.0 kg"), findsOneWidget);
  expect(find.text("Weekly Goal: "), findsOneWidget);
  expect(find.text("0.5 kg/week"), findsOneWidget);
});

testWidgets('calls submit and updates SharedPreferences', (WidgetTester tester) async {
  final state = HealthMetricsFormState(
    selectedGoals: ["Gain Muscle"],
    height: 180,
    weight: 75,
    birthDate: DateTime(2000),
    gender: "Female",
    activityLevel: "Very Active",
    desiredWeight: 80,
    weeklyGoal: 1,
  );

  when(mockCubit.submit()).thenAnswer((_) async {});
  SharedPreferences.setMockInitialValues({});

  await tester.pumpWidget(createTestWidget(state));
  await tester.pump();

  await tester.tap(find.text("Submit"));
  await tester.pumpAndSettle();

  verify(mockCubit.submit()).called(1);

  final prefs = await SharedPreferences.getInstance();
  expect(prefs.getBool('onboardingInProgress'), false);
  expect(prefs.getBool('hasCompletedOnboarding'), true);
});

testWidgets('shows error message on submit failure', (WidgetTester tester) async {
  final state = HealthMetricsFormState(
    selectedGoals: ["Stay healthy"],
    height: 160,
    weight: 60,
    birthDate: DateTime(1998),
    gender: "Female",
    activityLevel: "Lightly Active",
    desiredWeight: 58,
    weeklyGoal: 0.5,
  );

  when(mockCubit.submit()).thenThrow(Exception("Something went wrong"));
  await tester.pumpWidget(createTestWidget(state));
  await tester.pump();

  await tester.tap(find.text("Submit"));
  await tester.pumpAndSettle();

  verify(mockCubit.submit()).called(1);
  expect(find.textContaining("Error: Exception: Something went wrong"), findsOneWidget);
});

}
