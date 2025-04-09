import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pockeat/features/health_metrics/presentation/screens/gender_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';

@GenerateMocks([HealthMetricsFormCubit, NavigatorObserver])
import 'gender_page_test.mocks.dart';

void main() {
  late MockHealthMetricsFormCubit mockCubit;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    mockNavigatorObserver = MockNavigatorObserver();

    when(mockNavigatorObserver.navigator).thenReturn(null);
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    when(mockCubit.stream)
        .thenAnswer((_) => Stream.value(mockCubit.state));
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const GenderPage(),
      ),
      navigatorObservers: [mockNavigatorObserver],
      routes: {
        '/activity-level': (context) =>
            const Scaffold(body: Text('Activity Level Page')),
      },
    );
  }

  testWidgets('renders gender options correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text("What is your gender?"), findsOneWidget);
    for (final gender in GenderPage.genderOptions) {
      expect(find.text(gender), findsOneWidget);
    }
  });

  testWidgets('tapping on gender option calls cubit.setGender', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    await tester.tap(find.text('Male'));
    await tester.pump();

    verify(mockCubit.setGender('Male')).called(1);
  });

  testWidgets('Next button is disabled when gender is not selected',
      (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'));

    expect(nextButton.onPressed, isNull);
  });

  testWidgets('navigates to next page when gender is selected and Next tapped',
      (tester) async {
    // Set a gender in the cubit's state
    final updatedState = HealthMetricsFormState(gender: 'Female');
    when(mockCubit.state).thenReturn(updatedState);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(updatedState));

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump(); // needed after changing state

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Activity Level Page'), findsOneWidget);
  });
}