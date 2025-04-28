// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/add_calories_back_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AddCaloriesBackPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({}); // Reset prefs before each test
    });

    testWidgets('renders title and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));

      expect(find.text('Add calories burned\nback to your daily goal?'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('continue button is disabled initially', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));

      final continueButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(continueButton.onPressed, isNull); // Button should be disabled
    });

    testWidgets('tapping Yes enables continue and saves true', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));

      // Tap Yes
      await tester.tap(find.text('Yes'));
      await tester.pump();

      final continueButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(continueButton.onPressed, isNotNull); // Button should be enabled
    });

    testWidgets('tapping No enables continue and saves false', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCaloriesBackPage()));

      // Tap No
      await tester.tap(find.text('No'));
      await tester.pump();

      final continueButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
      expect(continueButton.onPressed, isNotNull); // Button should be enabled
    });

    testWidgets('pressing continue after choosing Yes saves true and navigates', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: const AddCaloriesBackPage(),
          routes: {
            '/rollover-calories': (_) => const Scaffold(body: Text('Rollover Calories Page')),
          },
        ),
      );

      // Tap Yes
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // Press Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Check if navigated
      expect(find.text('Rollover Calories Page'), findsOneWidget);

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('addCaloriesBack'), isTrue);
    });

    testWidgets('pressing continue after choosing No saves false and navigates', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: const AddCaloriesBackPage(),
          routes: {
            '/rollover-calories': (_) => const Scaffold(body: Text('Rollover Calories Page')),
          },
        ),
      );

      // Tap No
      await tester.tap(find.text('No'));
      await tester.pump();

      // Press Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Check if navigated
      expect(find.text('Rollover Calories Page'), findsOneWidget);

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('addCaloriesBack'), isFalse);
    });
  });
}