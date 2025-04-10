import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/smart_exercise_detail_widget.dart';

void main() {
  // Base test data
  final testExercise = ExerciseAnalysisResult(
    id: 'smart-1',
    exerciseType: 'Push-ups',
    duration: '15 min',
    intensity: 'High',
    estimatedCalories: 120,
    metValue: 8.0,
    timestamp: DateTime(2025, 3, 4, 17, 30),
    originalInput: 'I did push-ups for 15 minutes',
    summary: 'Great push-up session with proper form. Keep it up!',
    userId: 'test-user-123',
  );

  // Test data without summary
  final testExerciseNoSummary = ExerciseAnalysisResult(
    id: 'smart-2',
    exerciseType: 'Squats',
    duration: '10 min',
    intensity: 'Medium',
    estimatedCalories: 80,
    metValue: 6.0,
    timestamp: DateTime(2025, 3, 5, 18, 0),
    originalInput: 'Did some squats today',
    summary: null,
    userId: 'test-user-123',
  );

  group('SmartExerciseDetailWidget Tests', () {
    testWidgets('should display exercise type as title', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartExerciseDetailWidget(exercise: testExercise),
        ),
      ));

      // Assert - Check exercise type is displayed as the title
      // The exercise type appears multiple times in the widget
      expect(find.text('Push-ups'), findsAtLeastNWidgets(1));
      expect(find.byIcon(CupertinoIcons.text_badge_checkmark), findsOneWidget);
    });

    testWidgets('should display formatted date', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartExerciseDetailWidget(exercise: testExercise),
        ),
      ));

      // Expected formatted date
      final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(testExercise.timestamp);

      // Assert - Check date is displayed
      expect(find.text(formattedDate), findsOneWidget);
    });

    testWidgets('should display duration, intensity and calories in metrics section', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartExerciseDetailWidget(exercise: testExercise),
        ),
      ));
      
      // Assert - Check metrics are displayed correctly
      expect(find.text('15 min'), findsAtLeastNWidgets(1));
      expect(find.text('High'), findsAtLeastNWidgets(1));
      expect(find.text('120 kcal'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display analysis details section with MET value', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartExerciseDetailWidget(exercise: testExercise),
        ),
      ));

      // Assert - Check analysis details section
      expect(find.text('Analysis Details'), findsOneWidget);
      expect(find.text('MET Value'), findsOneWidget);
      expect(find.text('8.0'), findsOneWidget);
    });

    testWidgets('should display summary when provided', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartExerciseDetailWidget(exercise: testExercise),
        ),
      ));

      // Assert - Check summary section is displayed
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text(testExercise.summary!), findsOneWidget);
    });

    testWidgets('should not display summary when not provided', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartExerciseDetailWidget(exercise: testExerciseNoSummary),
        ),
      ));

      // Assert - Check summary section is not displayed
      expect(find.text('Summary'), findsNothing);
    });

    testWidgets('should display original input in the analysis details', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartExerciseDetailWidget(exercise: testExercise),
        ),
      ));

      // Assert - Check original input is displayed
      expect(find.text('Original Input'), findsOneWidget);
      expect(find.text(testExercise.originalInput), findsOneWidget);
    });
  });
}
