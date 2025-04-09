import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:pockeat/features/health_metrics/presentation/screens/height_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';

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

  testWidgets('renders height and weight fields', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Height (cm)'), findsOneWidget);
    expect(find.text('Weight (kg)'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Next'));
    await tester.pump(); 

    expect(find.text('Please enter a valid height'), findsOneWidget);
    expect(find.text('Please enter a valid weight'), findsOneWidget);
  });

  testWidgets('accepts valid height and weight, calls cubit and navigates', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Enter valid height and weight
    await tester.enterText(find.byType(TextFormField).at(0), '175');
    await tester.enterText(find.byType(TextFormField).at(1), '70');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    verify(mockCubit.setHeightWeight(height: 175.0, weight: 70.0)).called(1);
    expect(find.text('Birthdate Page'), findsOneWidget);
  });

  testWidgets('shows only height error when height is invalid', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextFormField).at(0), '-10'); // invalid height
    await tester.enterText(find.byType(TextFormField).at(1), '65');   // valid weight

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Please enter a valid height'), findsOneWidget);
    expect(find.text('Please enter a valid weight'), findsNothing);
  });

  testWidgets('shows only weight error when weight is invalid', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextFormField).at(0), '170');  // valid height
    await tester.enterText(find.byType(TextFormField).at(1), '0');    // invalid weight

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Please enter a valid weight'), findsOneWidget);
    expect(find.text('Please enter a valid height'), findsNothing);
  });
}