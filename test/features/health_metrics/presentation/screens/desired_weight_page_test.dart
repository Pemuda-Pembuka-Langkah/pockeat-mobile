import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

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

  testWidgets('enters valid weight and navigates to /speed', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextFormField), '70');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    verify(mockCubit.setDesiredWeight(70.0)).called(1);
    expect(find.text('Speed Page'), findsOneWidget);
  });
}