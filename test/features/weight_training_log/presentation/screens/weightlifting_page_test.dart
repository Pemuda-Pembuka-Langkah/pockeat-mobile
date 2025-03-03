import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/presentation/screens/weightlifting_page.dart';

void main() {
  group('WeightliftingPage Screen Tests', () {
    testWidgets('renders WeightliftingPage correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WeightliftingPage(),
        ),
      );
      expect(find.text('Weightlifting'), findsOneWidget);
      expect(find.text('Select Body Part'), findsOneWidget);
    });
  });
}
