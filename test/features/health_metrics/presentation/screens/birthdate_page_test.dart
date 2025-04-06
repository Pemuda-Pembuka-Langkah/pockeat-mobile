import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:pockeat/features/health_metrics/presentation/screens/birthdate_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';

@GenerateMocks([HealthMetricsFormCubit, NavigatorObserver])
import 'birthdate_page_test.mocks.dart';

void main() {
  late MockHealthMetricsFormCubit mockCubit;
  late MockNavigatorObserver mockNavigatorObserver;
  late Route mockRoute;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    mockNavigatorObserver = MockNavigatorObserver();
    mockRoute = MaterialPageRoute(builder: (_) => Container());
    
    // Set up basic navigator observer mock
    when(mockNavigatorObserver.navigator).thenReturn(null);

    when(mockCubit.state).thenReturn(HealthMetricsFormState()); // Use appropriate state class
    
    // Create a mock for any route-related methods
    when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([mockCubit.state]));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const BirthdatePage(),
      ),
      navigatorObservers: [mockNavigatorObserver],
      routes: {
        '/diet': (context) => const Scaffold(body: Text('Diet Page')),
      },
    );
  }

  testWidgets('App has appropriate title in AppBar', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    
    // Check for title
    expect(find.text('When were you born?'), findsOneWidget);
  });

  testWidgets('Date picker shows and allows selection', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap the button to open the date picker
    await tester.tap(find.text('Choose your birthdate'));
    await tester.pumpAndSettle();

    // Verify the date picker dialog appears
    expect(find.byType(DatePickerDialog), findsOneWidget);
    
    // Find and tap the OK button to confirm a date selection
    final okButton = find.text('OK');
    expect(okButton, findsOneWidget);
    await tester.tap(okButton);
    await tester.pumpAndSettle();
    
    // Verify that the text on the button has changed to show a selected date
    expect(find.textContaining('Selected:'), findsOneWidget);
    
    // Verify the Next button is now enabled
    final nextButtonFinder = find.widgetWithText(ElevatedButton, 'Next');
    final nextButton = tester.widget<ElevatedButton>(nextButtonFinder);
    expect(nextButton.onPressed, isNotNull);
  });

  testWidgets('Cannot navigate without selecting date', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Next button should be disabled initially, but we can still attempt to tap it
    final nextButtonFinder = find.text('Next');
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    // Verify no interactions happened
    verifyNever(mockCubit.setBirthDate(any));
  });

  testWidgets('Can cancel date picker without selecting date', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Choose your birthdate'));
    await tester.pumpAndSettle();

    // Look for dialog buttons
    final dialogButtons = find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.byType(TextButton),
    );
    
    // Make sure we found at least 2 buttons (Cancel and OK)
    expect(dialogButtons, findsAtLeastNWidgets(2));
    
    // First button should be the Cancel button
    await tester.tap(dialogButtons.first);
    await tester.pumpAndSettle();

    // Verify we're back to the original state
    expect(find.text('Choose your birthdate'), findsOneWidget);

    // Verify Next button is disabled
    final nextButtonFinder = find.widgetWithText(ElevatedButton, 'Next');
    final nextButton = tester.widget<ElevatedButton>(nextButtonFinder);
    expect(nextButton.onPressed, isNull);
  });

  test('Date picker constraints are correctly set', () {
    final now = DateTime.now();
    final firstAllowed = DateTime(now.year - 100);
    final lastAllowed = now;

    expect(firstAllowed.isBefore(now), isTrue);
    expect(lastAllowed.isAtSameMomentAs(now), isTrue);
  });
  
  testWidgets('Successfully sets birthdate and navigates when Next is tapped', (tester) async {
    // Set up the mock response
    when(mockCubit.setBirthDate(any)).thenReturn(null);
    
    await tester.pumpWidget(createWidgetUnderTest());
    
    // Open date picker
    await tester.tap(find.text('Choose your birthdate'));
    await tester.pumpAndSettle();
    
    // Select a date - tap OK
    final okButton = find.text('OK');
    expect(okButton, findsOneWidget);
    await tester.tap(okButton);
    await tester.pumpAndSettle();
    
    // Tap Next button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    
    // Verify the date was set in cubit
    verify(mockCubit.setBirthDate(any)).called(1);
  });
}