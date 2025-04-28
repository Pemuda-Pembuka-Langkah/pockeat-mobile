// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/activity_level_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'activity_level_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit, NavigatorObserver])

void main() {
  late MockHealthMetricsFormCubit mockCubit;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    mockNavigatorObserver = MockNavigatorObserver();
    when(mockNavigatorObserver.navigator).thenReturn(null);
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([mockCubit.state]));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const ActivityLevelPage(),
      ),
      navigatorObservers: [mockNavigatorObserver],
      routes: {
        '/diet': (context) => const Scaffold(body: Text('Diet Page')),
      },
    );
  }

  testWidgets('Page renders with correct AppBar title and options', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text("What best describes your weekly activity level?"), findsOneWidget);

    for (final level in ActivityLevelPage.activityLevels) {
      expect(find.text(level['label']!), findsOneWidget);
      expect(find.text(level['description']!), findsOneWidget);
    }
  });

  testWidgets('Selecting an activity level updates state via cubit', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final firstOption = ActivityLevelPage.activityLevels.first;
    await tester.tap(find.text(firstOption['label']!));
    await tester.pumpAndSettle();

    verify(mockCubit.setActivityLevel(firstOption['value']!)).called(1);
  });

  testWidgets('Next button is disabled when no selection is made', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final nextButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Next'),
    );
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('Successfully sets activity level and navigates when Next is tapped', (tester) async {
    when(mockCubit.setActivityLevel(any)).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Moderate'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    verify(mockCubit.setActivityLevel('moderate')).called(1);
  });

  testWidgets('Back button pops when onboarding is in progress and canPop is true', (tester) async {
    // Set mock values before any async UI code runs
    SharedPreferences.setMockInitialValues({'onboardingInProgress': true});

    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    when(mockCubit.stream).thenAnswer((_) => Stream.value(mockCubit.state));

    final testKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: testKey,
        home: BlocProvider<HealthMetricsFormCubit>.value(
          value: mockCubit,
          child: const ActivityLevelPage(),
        ),
      ),
    );

    expect(find.byType(IconButton), findsOneWidget);

    // Ensure UI has built and we're ready to interact
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  });
}
