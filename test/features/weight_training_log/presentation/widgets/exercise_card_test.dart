import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/exercise_card.dart';

void main() {
  testWidgets('ExerciseCard displays exercise data and triggers onAddSet', (WidgetTester tester) async {
    bool addSetCalled = false;
    bool deleteExerciseCalled = false;
    int? deletedSetIndex;
    
    final exercise = WeightLifting(
      name: 'Bench Press',
      bodyPart: 'Upper Body',
      metValue: 5.0,
      userId: 'test-user-id',
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
            onDeleteExercise: () {
              deleteExerciseCalled = true;
            },
            onDeleteSet: (index) {
              deletedSetIndex = index;
            },
          ),
        ),
      ),
    );

    // Test basic display elements
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.textContaining('980.00 kg'), findsOneWidget);
    
    // Test set rows are displayed correctly
    expect(find.text('50.0 kg'), findsOneWidget);
    expect(find.text('10 reps'), findsOneWidget);
    expect(find.text('60.0 kg'), findsOneWidget);
    expect(find.text('8 reps'), findsOneWidget);
    
    // Test calories are displayed
    expect(find.textContaining('kcal'), findsOneWidget);
    
    // Test set numbers are displayed
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    
    // Test Add Set button
    expect(find.text('Add Set'), findsOneWidget);
    await tester.tap(find.text('Add Set'));
    expect(addSetCalled, true);
    
    // Test Delete Exercise button
    expect(find.text('Delete Exercise'), findsOneWidget);
    await tester.tap(find.text('Delete Exercise'));
    expect(deleteExerciseCalled, true);
    
    // Test Delete Set button (X icon)
    expect(find.byIcon(Icons.close), findsNWidgets(2)); // One for each set
    await tester.tap(find.byIcon(Icons.close).first);
    expect(deletedSetIndex, 0); // First set deleted
    
    // Reset and test second delete button
    deletedSetIndex = null;
    await tester.tap(find.byIcon(Icons.close).last);
    expect(deletedSetIndex, 1); // Second set deleted
  });
  
  testWidgets('ExerciseCard handles empty sets list', (WidgetTester tester) async {
    final exercise = WeightLifting(
      name: 'Empty Exercise',
      bodyPart: 'Upper Body',
      metValue: 3.0,
      userId: 'test-user-id',
      sets: [], // Empty sets
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseCard(
            exercise: exercise,
            primaryGreen: Colors.blue,
            volume: 0,
            onAddSet: () {},
            onDeleteExercise: () {},
            onDeleteSet: (index) {},
          ),
        ),
      ),
    );
    
    // Test that the card still renders without sets
    expect(find.text('Empty Exercise'), findsOneWidget);
    expect(find.text('0.00 kg'), findsOneWidget);
    expect(find.text('Add Set'), findsOneWidget);
    expect(find.text('Delete Exercise'), findsOneWidget);
    
    // Verify that no set rows are rendered
    expect(find.byIcon(Icons.close), findsNothing);
  });
  
  testWidgets('ExerciseCard displays set durations correctly', (WidgetTester tester) async {
    final exercise = WeightLifting(
      name: 'Duration Test',
      bodyPart: 'Lower Body',
      metValue: 3.5,
      userId: 'test-user-id',
      sets: [WeightLiftingSet(weight: 75, reps: 12, duration: 2.5)],
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseCard(
            exercise: exercise,
            primaryGreen: Colors.green,
            volume: 900,
            onAddSet: () {},
            onDeleteExercise: () {},
            onDeleteSet: (index) {},
          ),
        ),
      ),
    );
    
    // Verify duration is displayed - note the space before the parenthesis
    expect(find.text(' (2.5 minutes)'), findsOneWidget);
  });
}