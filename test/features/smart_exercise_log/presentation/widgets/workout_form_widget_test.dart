import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(find.text('Ceritakan aktivitas olahragamu'), findsOneWidget);
      expect(find.text('Berikan detail seperti jenis, durasi, dan intensitas olahraga'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Analisis Olahraga'), findsOneWidget);
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
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pump();

      // Assert
      expect(find.text('Deskripsi olahraga tidak boleh kosong'), findsOneWidget);
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
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pump();
      expect(find.text('Deskripsi olahraga tidak boleh kosong'), findsOneWidget);

      // Act - type something
      await tester.enterText(find.byType(TextField), 'Lari pagi 30 menit');
      await tester.pump();

      // Assert
      expect(find.text('Deskripsi olahraga tidak boleh kosong'), findsNothing);
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
      await tester.enterText(find.byType(TextField), 'Lari pagi 30 menit');
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pump();

      // Assert
      expect(capturedInput, 'Lari pagi 30 menit');
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
      await tester.enterText(find.byType(TextField), 'Lari pagi 30 menit');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(onAnalyzeWasCalled, false);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analisis Olahraga'), findsNothing);
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
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pump();

      // Clear input
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Act - English
      await tester.enterText(find.byType(TextField), 'Morning run for 30 minutes');
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pump();

      // Assert
      expect(capturedInputs.length, 2);
      expect(capturedInputs[0], 'Lari pagi selama 30 menit');
      expect(capturedInputs[1], 'Morning run for 30 minutes');
    });
  });
}