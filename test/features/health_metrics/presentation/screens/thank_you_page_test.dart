// thank_you_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/thank_you_page.dart';

void main() {
  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/add-calories-back': (_) => const Scaffold(body: Text('Add Calories Back Page')),
      },
      home: const ThankYouPage(),
    );
  }

  group('ThankYouPage', () {
    testWidgets('renders all texts and button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Thank You!'), findsOneWidget);
      expect(find.textContaining('trusting us'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('saves onboardingInProgress and navigates on button tap', (tester) async {
      SharedPreferences.setMockInitialValues({}); // Mock empty prefs

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // complete build

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Check that the navigation happened
      expect(find.text('Add Calories Back Page'), findsOneWidget);

      // Check that onboardingInProgress is saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboardingInProgress'), isTrue);
    });
  });
}