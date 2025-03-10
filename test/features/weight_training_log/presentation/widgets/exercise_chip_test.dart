import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/exercise_chip.dart';

void main() {
  testWidgets('ExerciseChipWidget renders and triggers onTap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseChipWidget(
            exerciseName: 'Bench Press',
            onTap: () {
              tapped = true;
            },
            primaryGreen: Colors.green,
          ),
        ),
      ),
    );

    expect(find.text('Bench Press'), findsOneWidget);
    await tester.tap(find.byType(ExerciseChipWidget));
    expect(tapped, true);
  });
}
