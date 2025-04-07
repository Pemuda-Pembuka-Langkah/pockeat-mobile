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
    
    // Setup the initial state
    final initialState = HealthMetricsFormState();
    when(mockCubit.state).thenReturn(initialState);
    
    // Create a proper stream controller for the cubit
    final controller = Stream<HealthMetricsFormState>.fromIterable([initialState]);
    when(mockCubit.stream).thenAnswer((_) => controller);
  });

  // Make sure to properly reset the mock after each test
  tearDown(() {
    reset(mockCubit);
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

  testWidgets('renders the diet options page correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Check that the title is rendered
    expect(find.text('Do you follow a specific diet?'), findsOneWidget);
    
    // Check that the Next button exists and is disabled initially
    final button = find.byType(ElevatedButton);
    expect(button, findsOneWidget);
    expect((tester.widget<ElevatedButton>(button)).onPressed, isNull);
  });

  testWidgets('selects a diet and enables Next button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    
    // Make sure the widget has been rendered fully
    await tester.pumpAndSettle();

    // Find the first diet option (should be "No specific diet")
    final firstOptionText = find.text('No specific diet');
    expect(firstOptionText, findsOneWidget);
    
    // Ensure it's visible and find its RadioListTile ancestor
    await tester.ensureVisible(firstOptionText);
    await tester.pumpAndSettle();
    
    // Find the closest RadioListTile ancestor
    final radioTile = find.ancestor(
      of: firstOptionText,
      matching: find.byType(RadioListTile<String>),
    );
    
    // Tap it
    await tester.tap(radioTile, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify the button is now enabled
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('selects a diet, submits it, and navigates to /desired-weight', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    
    // Find and select the first option
    final firstOptionText = find.text('No specific diet');
    await tester.ensureVisible(firstOptionText);
    await tester.pumpAndSettle();
    
    final radioTile = find.ancestor(
      of: firstOptionText,
      matching: find.byType(RadioListTile<String>),
    );
    
    await tester.tap(radioTile, warnIfMissed: false);
    await tester.pumpAndSettle();
    
    // Setup mockCubit expectation
    when(mockCubit.setDietType(any)).thenReturn(null);
    
    // Find and tap Next button
    final nextButton = find.byType(ElevatedButton);
    await tester.ensureVisible(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    
    // Verify the expected method was called
    verify(mockCubit.setDietType('No specific diet')).called(1);
    
    // Verify navigation occurred
    expect(find.text('Desired Weight Page'), findsOneWidget);
  });
}