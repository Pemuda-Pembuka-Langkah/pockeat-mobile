import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:pockeat/features/health_metrics/presentation/screens/diet_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';

import 'diet_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();

    when(mockCubit.state).thenReturn(HealthMetricsFormState()); 
    
    when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([mockCubit.state]));
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/desired-weight': (_) => const Scaffold(body: Text('Desired Weight Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const DietPage(),
      ),
    );
  }

  testWidgets('renders all diet options and disables Next if none selected', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Check that all diet options are rendered
    expect(find.text('Vegetarian'), findsOneWidget);
    expect(find.text('Keto'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('selects a diet and enables Next button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Vegan'));
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('selects a diet, submits it, and navigates to /desired-weight', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Low-carb'));
    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    verify(mockCubit.setDietType('Low-carb')).called(1);

    expect(find.text('Desired Weight Page'), findsOneWidget);
  });
}