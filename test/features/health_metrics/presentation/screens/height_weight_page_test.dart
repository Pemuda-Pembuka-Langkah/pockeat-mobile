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

  testWidgets('shows range error for too small height', (tester) async {
  await tester.pumpWidget(createTestWidget());

  await tester.enterText(find.byType(TextFormField).at(0), '20'); // too small
  await tester.enterText(find.byType(TextFormField).at(1), '65'); // valid weight

  await tester.tap(find.text('Next'));
  await tester.pump();

  expect(find.text('Height must be between 50 and 300 cm'), findsOneWidget);
});

testWidgets('shows range error for too large height', (tester) async {
  await tester.pumpWidget(createTestWidget());

  await tester.enterText(find.byType(TextFormField).at(0), '400'); // too big
  await tester.enterText(find.byType(TextFormField).at(1), '70'); // valid weight

  await tester.tap(find.text('Next'));
  await tester.pump();

  expect(find.text('Height must be between 50 and 300 cm'), findsOneWidget);
});

testWidgets('shows range error for too small weight', (tester) async {
  await tester.pumpWidget(createTestWidget());

  await tester.enterText(find.byType(TextFormField).at(0), '170'); // valid height
  await tester.enterText(find.byType(TextFormField).at(1), '5'); // too small

  await tester.tap(find.text('Next'));
  await tester.pump();

  expect(find.text('Weight must be between 10 and 500 kg'), findsOneWidget);
});

testWidgets('shows range error for too large weight', (tester) async {
  await tester.pumpWidget(createTestWidget());

  await tester.enterText(find.byType(TextFormField).at(0), '175'); // valid height
  await tester.enterText(find.byType(TextFormField).at(1), '800'); // too big

  await tester.tap(find.text('Next'));
  await tester.pump();

  expect(find.text('Weight must be between 10 and 500 kg'), findsOneWidget);
});

}
