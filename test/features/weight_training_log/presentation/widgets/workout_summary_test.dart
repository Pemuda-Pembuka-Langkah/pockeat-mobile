import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/workout_summary.dart';

void main() {
  testWidgets('WorkoutSummary displays correct information', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutSummary(
            exerciseCount: 2,
            totalSets: 3,
            totalReps: 20,
            totalVolume: 150.0,
            totalDuration: 45.0,
            estimatedCalories: 500.0,
            primaryGreen: Colors.green,
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.textContaining('150.0 kg'), findsOneWidget);
    expect(find.textContaining('45.0 minutes'), findsOneWidget);
    expect(find.textContaining('Est. 500.00 kcal'), findsOneWidget);
  });
}