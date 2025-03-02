import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/analysis_result_widget.dart';
// Change with the correct path for your project

void main() {
  group('AnalysisResultWidget', () {
    final mockAnalysisComplete = ExerciseAnalysisResult(
      exerciseType: 'HIIT Workout',
      duration: '30 minutes',
      intensity: 'High',
      estimatedCalories: 320,
      metValue: 9.5, // Adding appropriate MET value for HIIT
      summary: 'High-intensity training with short intervals',
      timestamp: DateTime.now(),
      originalInput: 'HIIT workout 30 minutes',
    );

    // This variable will be used in a test to verify handling of incomplete data
    final mockAnalysisIncomplete = ExerciseAnalysisResult(
      exerciseType: 'Yoga Session',
      duration: 'Not specified',
      intensity: 'Medium',
      estimatedCalories: 150,
      metValue: 3.0, // Adding appropriate MET value for Yoga
      timestamp: DateTime.now(),
      originalInput: 'Yoga with medium intensity',
      missingInfo: ['duration'], // Marking the duration as missing info
    );

    testWidgets('renders all analysis data correctly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockAnalysisComplete,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Exercise Analysis Results'), findsOneWidget);
      expect(find.text('HIIT Workout'), findsOneWidget);
      expect(find.text('30 minutes'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('320 kcal'), findsOneWidget);
      // Assert MET value is displayed
      expect(find.text('9.5'), findsOneWidget);
      expect(find.text('High-intensity training with short intervals'),
          findsOneWidget);
    });

    testWidgets('handles incomplete analysis data correctly',
        (WidgetTester tester) async {
      // Use the mockAnalysisIncomplete to test handling of incomplete data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockAnalysisIncomplete,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );
      
      // Assert that duration is shown as "Not specified"
      expect(find.text('Not specified'), findsOneWidget);
      // Missing info section should be displayed
      expect(find.text('Incomplete Information'), findsOneWidget);
      expect(find.text('• Exercise duration'), findsOneWidget);
      // Save button should not be shown for incomplete data
      expect(find.text('Save Log'), findsNothing);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('handles missing summary gracefully but should show save button if complete',
        (WidgetTester tester) async {
      // Arrange
      // Create a complete analysis without a summary
      final completeAnalysisNoSummary = ExerciseAnalysisResult(
        exerciseType: 'Yoga Session',
        duration: '45 minutes',  // Provide clear value
        intensity: 'Medium',
        estimatedCalories: 150,
        metValue: 3.0,
        timestamp: DateTime.now(),
        originalInput: 'Yoga with medium intensity',
        // No missingInfo, so isComplete = true
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: completeAnalysisNoSummary,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      // Assert - should not find summary section
      expect(find.text('Exercise Analysis Results'), findsOneWidget);
      expect(find.text('Yoga Session'), findsOneWidget);
      expect(find.text('45 minutes'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('150 kcal'), findsOneWidget);
      expect(find.text('3.0'), findsOneWidget); // MET value
      expect(find.byType(Divider), findsWidgets); // Should still have dividers
      
      // Save Log button should exist because data is complete even without summary
      expect(find.text('Save Log'), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button is pressed',
        (WidgetTester tester) async {
      // Arrange
      bool onRetryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockAnalysisComplete,
              onRetry: () {
                onRetryCalled = true;
              },
              onSave: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Assert
      expect(onRetryCalled, true);
    });

    testWidgets('calls onSave when save button is pressed for complete data',
        (WidgetTester tester) async {
      // Arrange
      bool onSaveCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockAnalysisComplete, // Complete data
              onRetry: () {},
              onSave: () {
                onSaveCalled = true;
              },
            ),
          ),
        ),
      );

      // Verify save button exists because data is complete
      expect(find.text('Save Log'), findsOneWidget);
      
      // Act
      await tester.tap(find.text('Save Log'));
      await tester.pump();

      // Assert
      expect(onSaveCalled, true);
    });

    testWidgets('displays indicator for missing information and only retry button',
        (WidgetTester tester) async {
      // Arrange
      final mockAnalysisWithMissingInfo = ExerciseAnalysisResult(
        exerciseType: 'Unknown Workout',
        duration: 'Not specified',
        intensity: 'Not specified',
        estimatedCalories: 0,
        metValue: 0.0, // Empty MET value for unknown workout
        timestamp: DateTime.now(),
        originalInput: 'Exercise this morning',
        missingInfo: ['type', 'duration', 'intensity'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockAnalysisWithMissingInfo,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Incomplete Information'), findsOneWidget);
      expect(find.text('Please provide more details about:'),
          findsOneWidget);
      expect(find.text('• Exercise type'), findsOneWidget);
      expect(find.text('• Exercise duration'), findsOneWidget);
      expect(find.text('• Exercise intensity'), findsOneWidget);
      
      // Try Again button should exist
      expect(find.text('Try Again'), findsOneWidget);
      
      // Save Log button should NOT exist
      expect(find.text('Save Log'), findsNothing);
    });

    testWidgets('handles different duration formats correctly',
        (WidgetTester tester) async {
      // Test numeric
      final mockNumericDuration = ExerciseAnalysisResult(
        exerciseType: 'Running',
        duration: '45 minutes',
        intensity: 'Medium',
        estimatedCalories: 400,
        metValue: 7.0, // MET value for running
        timestamp: DateTime.now(),
        originalInput: 'Running for 45 minutes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockNumericDuration,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      expect(find.text('45 minutes'), findsOneWidget);

      // Test descriptive
      final mockDescriptiveDuration = ExerciseAnalysisResult(
        exerciseType: 'Running',
        duration: 'half an hour',
        intensity: 'Medium',
        estimatedCalories: 300,
        metValue: 7.0, // MET value for running
        timestamp: DateTime.now(),
        originalInput: 'Running for half an hour',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockDescriptiveDuration,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      expect(find.text('half an hour'), findsOneWidget);

      // Test range
      final mockRangeDuration = ExerciseAnalysisResult(
        exerciseType: 'Running',
        duration: '30-45 minutes',
        intensity: 'Medium',
        estimatedCalories: 350,
        metValue: 7.0, // MET value for running
        timestamp: DateTime.now(),
        originalInput: 'Running for 30-45 minutes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockRangeDuration,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      expect(find.text('30-45 minutes'), findsOneWidget);
    });
    
    testWidgets('displays and handles zero MET value correctly',
        (WidgetTester tester) async {
      // Arrange
      final mockZeroMetValue = ExerciseAnalysisResult(
        exerciseType: 'Light Activity',
        duration: '15 minutes',
        intensity: 'Low',
        estimatedCalories: 50,
        metValue: 0.0, // Deliberately using MET value 0
        timestamp: DateTime.now(),
        originalInput: 'Light activity for 15 minutes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockZeroMetValue,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      // Assert - MET value should not be displayed if it's zero
      expect(find.text('Light Activity'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
      expect(find.text('0.0'), findsNothing); // MET value 0 should not be displayed
    });
  });
}