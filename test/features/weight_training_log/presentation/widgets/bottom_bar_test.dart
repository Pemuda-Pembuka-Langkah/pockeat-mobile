import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/bottom_bar.dart';

void main() {
  testWidgets('BottomBar displays total volume and triggers onSaveWorkout', (WidgetTester tester) async {
    bool saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomBar(
            totalVolume: 1330,
            primaryGreen: Colors.green,
            onSaveWorkout: () {
              saved = true;
            },
          ),
        ),
      ),
    );

    expect(find.textContaining('1330.0 kg'), findsOneWidget);
    await tester.tap(find.byType(BottomBar));
    expect(saved, true);
  });

  testWidgets('BottomBar displays correct volume when volume is zero', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomBar(
            totalVolume: 0.0,
            primaryGreen: Colors.green,
            onSaveWorkout: () {},
          ),
        ),
      ),
    );

    expect(find.text('Save Workout (0.0 kg)'), findsOneWidget);
  });
}