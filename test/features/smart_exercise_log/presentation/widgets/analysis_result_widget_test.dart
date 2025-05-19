// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
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
      userId: 'test-user-123',
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
      userId: 'test-user-123',
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
              onCorrect: (_) {},
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
              onCorrect: (_) {},
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
        userId: 'test-user-123',
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: completeAnalysisNoSummary,
              onRetry: () {},
              onSave: () {},
              onCorrect: (_) {},
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
              onCorrect: (_) {},
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
              onCorrect: (_) {},
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
        missingInfo: ['exercise_type', 'duration', 'intensity'],
        userId: 'test-user-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockAnalysisWithMissingInfo,
              onRetry: () {},
              onSave: () {},
              onCorrect: (_) {},
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
        userId: 'test-user-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockNumericDuration,
              onRetry: () {},
              onSave: () {},
              onCorrect: (_) {},
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
        userId: 'test-user-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockDescriptiveDuration,
              onRetry: () {},
              onSave: () {},
              onCorrect: (_) {},
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
        userId: 'test-user-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockRangeDuration,
              onRetry: () {},
              onSave: () {},
              onCorrect: (_) {},
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
        userId: 'test-user-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockZeroMetValue,
              onRetry: () {},
              onSave: () {},
              onCorrect: (_) {},
            ),
          ),
        ),
      );

      // Assert - MET value should not be displayed if it's zero
      expect(find.text('Light Activity'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
      expect(find.text('0.0'), findsNothing); // MET value 0 should not be displayed
    });

    testWidgets('positive case: shows complete data with summary and valid MET', (WidgetTester tester) async {
      final complete = ExerciseAnalysisResult(
        exerciseType: 'Cycling',
        duration: '60 minutes',
        intensity: 'Medium',
        estimatedCalories: 500,
        metValue: 8.5,
        summary: 'Moderate cycling session for endurance',
        timestamp: DateTime.now(),
        originalInput: 'Cycling 60 mins',
        userId: 'positive-case-user',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: complete,
              onRetry: () {},
              onSave: () {},
              onCorrect: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Cycling'), findsOneWidget);
      expect(find.text('60 minutes'), findsOneWidget);
      expect(find.text('500 kcal'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);
      expect(find.text('Moderate cycling session for endurance'), findsOneWidget);
      expect(find.text('Save Log'), findsOneWidget);
    });

      testWidgets('corner case: empty fields but considered complete', (WidgetTester tester) async {
      final emptyComplete = ExerciseAnalysisResult(
        exerciseType: '',
        duration: '',
        intensity: '',
        estimatedCalories: 0,
        metValue: 0.0,
        summary: '',
        timestamp: DateTime.now(),
        originalInput: '',
        userId: 'corner-case-user',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: emptyComplete,
              onRetry: () {},
              onSave: () {},
              onCorrect: (_) {},
            ),
          ),
        ),
      );

      // Still should render the stat rows with empty strings
      expect(find.text(''), findsNWidgets(4)); // exerciseType, duration, intensity, summary
      expect(find.text('Save Log'), findsOneWidget); // considered complete
      expect(find.text('Try Again'), findsOneWidget); // still allowed
    });

    // Tests for Correction Functionality
    group('Correction Functionality', () {
      testWidgets('displays correction button for complete analysis results',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalysisResultWidget(
                analysisResult: mockAnalysisComplete,
                onRetry: () {},
                onSave: () {},
                onCorrect: (_) {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Correct Analysis'), findsOneWidget);
        expect(find.byIcon(Icons.edit_note), findsOneWidget);
      });

      testWidgets('opens correction dialog when correction button is tapped',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalysisResultWidget(
                analysisResult: mockAnalysisComplete,
                onRetry: () {},
                onSave: () {},
                onCorrect: (_) {},
              ),
            ),
          ),
        );

        // Act - Tap the correction button
        await tester.tap(find.text('Correct Analysis'));
        await tester.pumpAndSettle();

        // Assert - Dialog should be visible
        expect(find.text('Correct Analysis'), findsNWidgets(2)); // One in button, one in dialog title
        expect(find.text('Please provide details on what needs to be corrected:'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Submit Correction'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('calls onCorrect callback with user comment when submitted',
          (WidgetTester tester) async {
        // Arrange
        String? capturedComment;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalysisResultWidget(
                analysisResult: mockAnalysisComplete,
                onRetry: () {},
                onSave: () {},
                onCorrect: (comment) {
                  capturedComment = comment;
                },
              ),
            ),
          ),
        );

        // Act - Open dialog
        await tester.tap(find.text('Correct Analysis'));
        await tester.pumpAndSettle();
        
        // Enter correction text
        await tester.enterText(find.byType(TextField), 'The workout was actually 45 minutes');
        
        // Submit correction
        await tester.tap(find.text('Submit Correction'));
        await tester.pumpAndSettle();

        // Assert
        expect(capturedComment, 'The workout was actually 45 minutes');
      });

      testWidgets('does nothing when correction dialog is canceled',
          (WidgetTester tester) async {
        // Arrange
        bool onCorrectCalled = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalysisResultWidget(
                analysisResult: mockAnalysisComplete,
                onRetry: () {},
                onSave: () {},
                onCorrect: (_) {
                  onCorrectCalled = true;
                },
              ),
            ),
          ),
        );

        // Act - Open dialog
        await tester.tap(find.text('Correct Analysis'));
        await tester.pumpAndSettle();
        
        // Enter text but then cancel
        await tester.enterText(find.byType(TextField), 'Cancel this correction');
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert
        expect(onCorrectCalled, false);
        expect(find.byType(AlertDialog), findsNothing); // Dialog should be closed
      });

      testWidgets('does not call onCorrect when empty comment is submitted',
          (WidgetTester tester) async {
        // Arrange
        bool onCorrectCalled = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalysisResultWidget(
                analysisResult: mockAnalysisComplete,
                onRetry: () {},
                onSave: () {},
                onCorrect: (_) {
                  onCorrectCalled = true;
                },
              ),
            ),
          ),
        );

        // Act - Open dialog
        await tester.tap(find.text('Correct Analysis'));
        await tester.pumpAndSettle();
        
        // Leave text field empty and try to submit
        await tester.tap(find.text('Submit Correction'));
        await tester.pumpAndSettle();

        // Assert
        expect(onCorrectCalled, false);
        expect(find.byType(AlertDialog), findsOneWidget); // Dialog should still be open
      });
    });
  });
}
