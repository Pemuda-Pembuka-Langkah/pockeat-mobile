import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/body_part_chip.dart';

void main() {
  testWidgets('BodyPartChip renders correctly and responds to tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BodyPartChip(
            category: 'Upper Body',
            isSelected: true,
            onTap: () {
              tapped = true;
            },
            primaryGreen: Colors.green,
          ),
        ),
      ),
    );
    expect(find.text('Upper Body'), findsOneWidget);
    await tester.tap(find.byType(BodyPartChip));
    expect(tapped, true);
  });
}
