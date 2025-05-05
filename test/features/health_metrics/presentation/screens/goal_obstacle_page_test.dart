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

  testWidgets('renders page title and all obstacle options', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text("What's been your biggest challenge?"), findsOneWidget);
    
    for (final obstacle in GoalObstaclePage.obstacles) {
      expect(find.text(obstacle), findsOneWidget);
    }
  });

  testWidgets('tapping an obstacle calls cubit.setDietType', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final firstObstacle = GoalObstaclePage.obstacles.first;

    await tester.tap(find.text(firstObstacle));
    await tester.pump();

    verify(mockCubit.setDietType(firstObstacle)).called(1);
  });

  testWidgets('Next button is disabled when no obstacle is selected', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final nextButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('selecting obstacle enables Next button and navigates to diet page', (tester) async {
    // Set state with a selected obstacle (reusing dietType)
    final updatedState = HealthMetricsFormState(dietType: "Lack of Motivation");
    when(mockCubit.state).thenReturn(updatedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(updatedState));

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    await tester.ensureVisible(find.text('Next'));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Diet Page'), findsOneWidget);
  });
}
