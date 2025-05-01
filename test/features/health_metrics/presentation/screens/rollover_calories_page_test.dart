// rollover_calories_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/rollover_calories_page.dart';

// Project imports

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/used-other-apps': (_) => const Scaffold(body: Text('Used Other Apps Page')),
      },
      home: const RolloverCaloriesPage(),
    );
  }

  testWidgets('renders rollover options and Continue button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Rollover extra calories to the next day?'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Continue button is disabled when no option is selected', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('selecting No enables the Continue button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('No'));
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('selecting Yes enables the Continue button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Yes'));
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('selecting No saves preference and navigates', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('No'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('rolloverCaloriesEnabled'), isFalse);
    expect(find.text('Used Other Apps Page'), findsOneWidget);
  });

  testWidgets('selecting Yes saves preference and navigates', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Yes'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('rolloverCaloriesEnabled'), isTrue);
    expect(find.text('Used Other Apps Page'), findsOneWidget);
  });
}
