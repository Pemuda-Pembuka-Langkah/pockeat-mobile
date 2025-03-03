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
      metValue: 9.5, // Menambahkan MET value yang sesuai untuk HIIT
      summary: 'Latihan intensitas tinggi dengan interval pendek',
      timestamp: DateTime.now(),
      originalInput: 'HIIT latihan 30 menit',
    );

    final mockAnalysisIncomplete = ExerciseAnalysisResult(
      exerciseType: 'Yoga Session',
      duration: 'Tidak ditentukan',
      intensity: 'Sedang',
      estimatedCalories: 150,
      metValue: 3.0, // Menambahkan MET value yang sesuai untuk Yoga
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
      // Jika widget menampilkan MET value, tambahkan assertion di sini
      // expect(find.text('MET: 9.5'), findsOneWidget);
      expect(find.text('Latihan intensitas tinggi dengan interval pendek'),
          findsOneWidget);
    });

    testWidgets('handles missing summary gracefully but should show save button if complete',
        (WidgetTester tester) async {
      // Arrange
      // Pastikan mockAnalysisIncomplete tidak memiliki missingInfo
      final completeAnalysisNoSummary = ExerciseAnalysisResult(
        exerciseType: 'Yoga Session',
        duration: '45 menit',  // Berikan nilai yang jelas
        intensity: 'Sedang',
        estimatedCalories: 150,
        metValue: 3.0,
        timestamp: DateTime.now(),
        originalInput: 'Yoga dengan intensitas sedang',
        // Tidak ada missingInfo, jadi isComplete = true
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
      expect(find.text('Hasil Analisis Olahraga'), findsOneWidget);
      expect(find.text('Yoga Session'), findsOneWidget);
      expect(find.text('45 menit'), findsOneWidget);
      expect(find.text('Sedang'), findsOneWidget);
      expect(find.text('150 kkal'), findsOneWidget);
      expect(find.text('3.0'), findsOneWidget); // MET value
      expect(find.byType(Divider), findsWidgets); // Should still have dividers
      
      // Tombol Simpan Log harus ada karena data lengkap meskipun tidak ada summary
      expect(find.text('Simpan Log'), findsOneWidget);
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

    testWidgets('calls onSave when save button is pressed for complete data',
        (WidgetTester tester) async {
      // Arrange
      bool onSaveCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisResult: mockAnalysisComplete, // Data lengkap
              onRetry: () {},
              onSave: () {
                onSaveCalled = true;
              },
            ),
          ),
        ),
      );

      // Verifikasi tombol save ada karena data lengkap
      expect(find.text('Simpan Log'), findsOneWidget);
      
      // Act
      await tester.tap(find.text('Simpan Log'));
      await tester.pump();

      // Assert
      expect(onSaveCalled, true);
    });

    testWidgets('displays indicator for missing information and only retry button',
        (WidgetTester tester) async {
      // Arrange
      final mockAnalysisWithMissingInfo = ExerciseAnalysisResult(
        exerciseType: 'Unknown Workout',
        duration: 'Tidak ditentukan',
        intensity: 'Tidak ditentukan',
        estimatedCalories: 0,
        metValue: 0.0, // MET value kosong untuk workout yang tidak diketahui
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
      
      // Tombol Ulangi Input harus ada
      expect(find.text('Ulangi Input'), findsOneWidget);
      
      // Tombol Simpan Log TIDAK boleh ada
      expect(find.text('Simpan Log'), findsNothing);
    });

    testWidgets('handles different duration formats correctly',
        (WidgetTester tester) async {
      // Test numerik
      final mockNumericDuration = ExerciseAnalysisResult(
        exerciseType: 'Lari',
        duration: '45 menit',
        intensity: 'Sedang',
        estimatedCalories: 400,
        metValue: 7.0, // MET value untuk lari
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
        metValue: 7.0, // MET value untuk lari
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
        metValue: 7.0, // MET value untuk lari
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
    
    testWidgets('displays and handles zero MET value correctly',
        (WidgetTester tester) async {
      // Arrange
      final mockZeroMetValue = ExerciseAnalysisResult(
        exerciseType: 'Aktivitas Ringan',
        duration: '15 menit',
        intensity: 'Rendah',
        estimatedCalories: 50,
        metValue: 0.0, // Sengaja menggunakan MET value 0
        timestamp: DateTime.now(),
        originalInput: 'Aktivitas ringan selama 15 menit',
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

      // Assert - Jika widget menampilkan MET value, verifikasi tampilan nilai 0
      expect(find.text('Aktivitas Ringan'), findsOneWidget);
      expect(find.text('15 menit'), findsOneWidget);
      // expect(find.text('MET: 0.0'), findsOneWidget); // Uncomment jika widget menampilkan MET value
    });
  });
}