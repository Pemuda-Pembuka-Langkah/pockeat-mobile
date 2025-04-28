// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
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

  testWidgets('renders the diet options page with titles and descriptions', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Check that the main title is shown
    expect(find.text('Do you follow a specific diet?'), findsOneWidget);

    // Check that a few options and their descriptions are shown
    expect(find.text('No specific diet'), findsOneWidget);
    expect(find.text('You eat a general diet without any specific restrictions.'), findsOneWidget);

    expect(find.text('Vegan'), findsOneWidget);
    expect(find.text('No animal products, including dairy, eggs, and honey.'), findsOneWidget);
  });

  testWidgets('selecting a diet enables the Next button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final firstOptionText = find.text('No specific diet');
    await tester.ensureVisible(firstOptionText);
    await tester.tap(firstOptionText);
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('selects a diet, submits it, and navigates to /onboarding/goal', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      routes: {
        '/onboarding/goal': (_) => const Scaffold(body: Text('Onboarding Goal Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const DietPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Select the first RadioListTile (No specific diet)
  final radioTile = find.byType(RadioListTile<String>).first;
  await tester.tap(radioTile);
  await tester.pumpAndSettle();

  // Make sure cubit.setDietType is stubbed properly (optional here because Next button just calls it)
  when(mockCubit.setDietType(any)).thenReturn(null);

  // Tap the Next button
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  // Check if cubit method is called correctly
  verify(mockCubit.setDietType('No specific diet')).called(1);

  // Check if navigated to onboarding
  expect(find.text('Onboarding Goal Page'), findsOneWidget);
});


  testWidgets('Back button pops when onboarding is in progress and canPop is true', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingInProgress': true});
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Do you follow a specific diet?'), findsOneWidget);
  });
}
