import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/workout_form_widget.dart';

void main() {
  group('WorkoutFormWidget', () {
    testWidgets('renders correctly with all elements', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutFormWidget(
              onAnalyzePressed: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Describe your workout activity'), findsOneWidget);
      expect(find.text('Provide details such as type, duration, and intensity'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Analyze Workout'), findsOneWidget);
    });

    testWidgets('shows error message when submitting empty input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutFormWidget(
              onAnalyzePressed: (_) {},
            ),
          ),
        ),
      );

      // Act - tap the button with empty input
      await tester.tap(find.text('Analyze Workout'));
      await tester.pump();

      // Assert
      expect(find.text('Workout description cannot be empty'), findsOneWidget);
    });

    testWidgets('clears error message when user starts typing', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutFormWidget(
              onAnalyzePressed: (_) {},
            ),
          ),
        ),
      );

      // Act - show error first
      await tester.tap(find.text('Analyze Workout'));
      await tester.pump();
      expect(find.text('Workout description cannot be empty'), findsOneWidget);

      // Act - type something
      await tester.enterText(find.byType(TextField), 'Morning run 30 minutes');
      await tester.pump();

      // Assert
      expect(find.text('Workout description cannot be empty'), findsNothing);
    });

    testWidgets('calls onAnalyzePressed with input text when form is valid', (WidgetTester tester) async {
      // Arrange
      String? capturedInput;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutFormWidget(
              onAnalyzePressed: (input) {
                capturedInput = input;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Morning run 30 minutes');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pump();

      // Assert
      expect(capturedInput, 'Morning run 30 minutes');
    });

    testWidgets('button is disabled when isLoading is true', (WidgetTester tester) async {
      // Arrange
      bool onAnalyzeWasCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutFormWidget(
              isLoading: true,
              onAnalyzePressed: (_) {
                onAnalyzeWasCalled = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Morning run 30 minutes');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(onAnalyzeWasCalled, false);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyze Workout'), findsNothing);
    });

    testWidgets('accepts both Indonesian and English text input', (WidgetTester tester) async {
      // Arrange
      List<String> capturedInputs = [];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutFormWidget(
              onAnalyzePressed: (input) {
                capturedInputs.add(input);
              },
            ),
          ),
        ),
      );

      // Act - Indonesian
      await tester.enterText(find.byType(TextField), 'Lari pagi selama 30 menit');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pump();

      // Clear input
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Act - English
      await tester.enterText(find.byType(TextField), 'Morning run for 30 minutes');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pump();

      // Assert
      expect(capturedInputs.length, 2);
      expect(capturedInputs[0], 'Lari pagi selama 30 menit');
      expect(capturedInputs[1], 'Morning run for 30 minutes');
    });
  });
}