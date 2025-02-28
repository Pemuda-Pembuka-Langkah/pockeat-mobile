import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/analysis_result_widget.dart';
// Ubah dengan path yang benar untuk project Anda

void main() {
  group('AnalysisResultWidget', () {
    final mockAnalysisComplete = ExerciseAnalysisResult(
      exerciseType: 'HIIT Workout',
      duration: '30 menit',
      intensity: 'Tinggi',
      estimatedCalories: 320,
      summary: 'Latihan intensitas tinggi dengan interval pendek',
      timestamp: DateTime.now(),
      originalInput: 'HIIT latihan 30 menit',
    );

    final mockAnalysisIncomplete = ExerciseAnalysisResult(
      exerciseType: 'Yoga Session',
      duration: 'Tidak ditentukan',
      intensity: 'Sedang',
      estimatedCalories: 150,
      timestamp: DateTime.now(),
      originalInput: 'Yoga dengan intensitas sedang',
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
      expect(find.text('Hasil Analisis Olahraga'), findsOneWidget);
      expect(find.text('HIIT Workout'), findsOneWidget);
      expect(find.text('30 menit'), findsOneWidget);
      expect(find.text('Tinggi'), findsOneWidget);
      expect(find.text('320 kkal'), findsOneWidget);
      expect(find.text('Latihan intensitas tinggi dengan interval pendek'),
          findsOneWidget);
    });

    testWidgets('handles missing summary gracefully',
        (WidgetTester tester) async {
      // Arrange
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

      // Assert - should not find summary section
      expect(find.text('Hasil Analisis Olahraga'), findsOneWidget);
      expect(find.text('Yoga Session'), findsOneWidget);
      expect(find.text('Tidak ditentukan'), findsOneWidget);
      expect(find.text('150 kkal'), findsOneWidget);
      expect(find.byType(Divider), findsWidgets); // Should still have dividers
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
      await tester.tap(find.text('Ulangi Input'));
      await tester.pump();

      // Assert
      expect(onRetryCalled, true);
    });

    testWidgets('calls onSave when save button is pressed',
        (WidgetTester tester) async {
      // Arrange
      bool onSaveCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockAnalysisComplete,
              onRetry: () {},
              onSave: () {
                onSaveCalled = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Simpan Log'));
      await tester.pump();

      // Assert
      expect(onSaveCalled, true);
    });

    testWidgets('displays indicator for missing information',
        (WidgetTester tester) async {
      // Arrange
      final mockAnalysisWithMissingInfo = ExerciseAnalysisResult(
        exerciseType: 'Unknown Workout',
        duration: 'Tidak ditentukan',
        intensity: 'Tidak ditentukan',
        estimatedCalories: 0,
        timestamp: DateTime.now(),
        originalInput: 'Olahraga tadi pagi',
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
      expect(find.text('Informasi Kurang Lengkap'), findsOneWidget);
      expect(find.text('Silakan berikan informasi lebih detail tentang:'),
          findsOneWidget);
      expect(find.text('• Jenis olahraga'), findsOneWidget);
      expect(find.text('• Durasi olahraga'), findsOneWidget);
      expect(find.text('• Intensitas olahraga'), findsOneWidget);
    });

    testWidgets('handles different duration formats correctly',
        (WidgetTester tester) async {
      // Test numerik
      final mockNumericDuration = ExerciseAnalysisResult(
        exerciseType: 'Lari',
        duration: '45 menit',
        intensity: 'Sedang',
        estimatedCalories: 400,
        timestamp: DateTime.now(),
        originalInput: 'Lari selama 45 menit',
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

      expect(find.text('45 menit'), findsOneWidget);

      // Test deskriptif
      final mockDescriptiveDuration = ExerciseAnalysisResult(
        exerciseType: 'Lari',
        duration: 'setengah jam',
        intensity: 'Sedang',
        estimatedCalories: 300,
        timestamp: DateTime.now(),
        originalInput: 'Lari selama setengah jam',
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

      expect(find.text('setengah jam'), findsOneWidget);

      // Test rentang
      final mockRangeDuration = ExerciseAnalysisResult(
        exerciseType: 'Lari',
        duration: '30-45 menit',
        intensity: 'Sedang',
        estimatedCalories: 350,
        timestamp: DateTime.now(),
        originalInput: 'Lari selama 30-45 menit',
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

      expect(find.text('30-45 menit'), findsOneWidget);
    });
  });
}
