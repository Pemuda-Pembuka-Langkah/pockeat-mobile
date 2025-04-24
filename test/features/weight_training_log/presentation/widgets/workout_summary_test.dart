// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
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

    // Test text display with the new flexible formatting
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    
    // For values with line breaks, we need to test differently
    expect(find.text('150.0\nkg'), findsOneWidget);
    expect(find.text('45.0\nminutes'), findsOneWidget);
    expect(find.text('500.00\nkcal'), findsOneWidget);
    
    // Check for labels
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Sets'), findsOneWidget);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Estimated\nCalories'), findsOneWidget);
    
    // Check for icons
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    
    // Verify container styling
    expect(find.byType(Container), findsWidgets);
    expect(find.byType(Row), findsOneWidget);
  });
  
  testWidgets('WorkoutSummary handles zero values correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutSummary(
            exerciseCount: 0,
            totalSets: 0,
            totalReps: 0,
            totalVolume: 0.0,
            totalDuration: 0.0,
            estimatedCalories: 0.0,
            primaryGreen: Colors.green,
          ),
        ),
      ),
    );

    expect(find.text('0'), findsNWidgets(2)); // For exercise count and sets
    expect(find.text('0.0\nkg'), findsOneWidget);
    expect(find.text('0.0\nminutes'), findsOneWidget);
    expect(find.text('0.00\nkcal'), findsOneWidget);
  });
  
  testWidgets('WorkoutSummary handles large values correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutSummary(
            exerciseCount: 100,
            totalSets: 500,
            totalReps: 1000,
            totalVolume: 9999.9,
            totalDuration: 1234.5,
            estimatedCalories: 9876.5,
            primaryGreen: Colors.green,
          ),
        ),
      ),
    );

    expect(find.text('100'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('9999.9\nkg'), findsOneWidget);
    expect(find.text('1234.5\nminutes'), findsOneWidget);
    expect(find.text('9876.50\nkcal'), findsOneWidget);
  });
}
