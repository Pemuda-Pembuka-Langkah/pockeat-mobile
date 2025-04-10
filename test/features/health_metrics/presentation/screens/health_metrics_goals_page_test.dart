import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'dart:async';

import 'package:pockeat/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/health_metrics_goals_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/height_weight_page.dart';

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

  Widget createTestWidget({NavigatorObserver? observer}) {
    return MaterialApp(
      routes: {
        '/height-weight': (_) => const Scaffold(body: Text('HeightWeight Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const HealthMetricsGoalsPage(),
      ),
      navigatorObservers: observer != null ? [observer] : [],
    );
  }

  testWidgets('renders all goal options', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    for (final option in HealthMetricsGoalsPage.options) {
      expect(find.text(option), findsOneWidget);
    }
  });

  testWidgets('taps a goal option and calls toggleGoal', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final goal = HealthMetricsGoalsPage.options.first;
    await tester.tap(find.text(goal));
    await tester.pump();

    verify(mockCubit.toggleGoal(goal)).called(1);
  });

  testWidgets('shows text field when "Other" is selected', (WidgetTester tester) async {
    when(mockCubit.state).thenReturn(
      HealthMetricsFormState(selectedGoals: ["Other"]),
    );
    when(mockCubit.stream).thenAnswer((_) => Stream.value(
      HealthMetricsFormState(selectedGoals: ["Other"]),
    ));

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Please specify'), findsOneWidget);
  });

  testWidgets('disables non-"Other" goals when "Other" is selected', (WidgetTester tester) async {
    when(mockCubit.state).thenReturn(
      HealthMetricsFormState(selectedGoals: ["Other"]),
    );
    when(mockCubit.stream).thenAnswer((_) => Stream.value(
      HealthMetricsFormState(selectedGoals: ["Other"]),
    ));

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    final disabledOption = HealthMetricsGoalsPage.options.first;
    await tester.tap(find.text(disabledOption));
    await tester.pump();

    verifyNever(mockCubit.toggleGoal(disabledOption));
  });

  testWidgets('enables Next button only when input is valid', (WidgetTester tester) async {
    final controller = StreamController<HealthMetricsFormState>.broadcast();

    // Initial state: invalid
    final invalidState = HealthMetricsFormState(selectedGoals: ["Other"]);
    when(mockCubit.state).thenReturn(invalidState);
    when(mockCubit.stream).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(createTestWidget());
    controller.add(invalidState);
    await tester.pumpAndSettle();

    var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    // Valid state
    final validState = HealthMetricsFormState(
      selectedGoals: ["Other"],
      otherGoalReason: "Gain strength",
    );
    when(mockCubit.state).thenReturn(validState);
    controller.add(validState);
    await tester.pumpAndSettle();

    button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);

    await controller.close();
  });
}