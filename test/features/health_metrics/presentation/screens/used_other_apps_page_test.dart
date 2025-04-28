// used_other_apps_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/used_other_apps_page.dart';

void main() {
  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/heard-about': (_) => const Scaffold(body: Text('Heard About Page')),
      },
      home: const UsedOtherAppsPage(),
    );
  }

  group('UsedOtherAppsPage', () {
    testWidgets('renders title and options', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Have you used other calorie tracking apps before?'), findsOneWidget);
      expect(find.text('Never used any'), findsOneWidget);
      expect(find.text('MyFitnessPal'), findsOneWidget);
      expect(find.text('Lose It!'), findsOneWidget);
      expect(find.text('Lifesum'), findsOneWidget);
      expect(find.text('Other apps'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('tapping an option enables the Next button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially, button should be disabled
      final buttonBefore = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttonBefore.onPressed, isNull);

      // Tap an option
      await tester.tap(find.text('MyFitnessPal'));
      await tester.pump();

      // Button should now be enabled
      final buttonAfter = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttonAfter.onPressed, isNotNull);
    });

    testWidgets('saves selection and navigates on Next', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Lifesum'));
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should navigate to the next page
      expect(find.text('Heard About Page'), findsOneWidget);

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('usedOtherApps'), 'Lifesum');
    });
  });
}