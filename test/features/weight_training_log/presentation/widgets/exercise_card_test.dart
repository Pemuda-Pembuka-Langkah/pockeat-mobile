import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/exercise_card.dart';

void main() {
  testWidgets('ExerciseCard displays exercise data and triggers onAddSet', (WidgetTester tester) async {
    bool addSetCalled = false;
    final exercise = WeightLifting(
      name: 'Bench Press',
      bodyPart: 'Upper Body',
      metValue: 5.0,
      sets: [
        WeightLiftingSet(weight: 50, reps: 10, duration: 30),
        WeightLiftingSet(weight: 60, reps: 8, duration: 30),
      ],
    );
    // Volume calculation: (50*10 + 60*8) = 500 + 480 = 980
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseCard(
            exercise: exercise,
            primaryGreen: Colors.green,
            volume: 980,
            onAddSet: () {
              addSetCalled = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.textContaining('980.00 kg'), findsOneWidget);
    await tester.tap(find.text('Add Set'));
    expect(addSetCalled, true);
  });
}
