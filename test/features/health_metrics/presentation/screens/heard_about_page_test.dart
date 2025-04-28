// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/heard_about_page.dart';

// --- Add this manually ---
const List<String> heardAboutOptions = [
  'Friend / Family',
  'Social Media (Instagram, TikTok, etc)',
  'Google Search',
  'Ad / Promotion',
  'Other',
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      routes: {
        '/review': (_) => const Scaffold(body: Text('Review Page')),
      },
      home: const HeardAboutPage(),
    );
  }

  testWidgets('renders title and all options', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Where did you hear about PockEat?'), findsOneWidget);

    for (final option in heardAboutOptions) {
      expect(find.text(option), findsOneWidget);
    }
  });

  testWidgets('Next button is initially disabled', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final nextButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Next'));
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('selecting an option enables Next button', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    await tester.tap(find.text('Friend / Family'));
    await tester.pump();

    final nextButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Next'));
    expect(nextButton.onPressed, isNotNull);
  });

  testWidgets('selecting an option and tapping Next saves preference and navigates', (tester) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(buildTestableWidget());

    await tester.tap(find.text('Google Search'));
    await tester.pump();

    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Review Page'), findsOneWidget);

    expect(prefs.getString('heardAboutPockEat'), 'Google Search');
  });
}