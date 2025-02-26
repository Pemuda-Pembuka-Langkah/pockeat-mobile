import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalysisResultWidget', () {
    final mockAnalysisComplete = {
      'type': 'HIIT Workout',
      'duration': '30 menit',
      'intensity': 'Tinggi',
      'estimatedCalories': 320,
      'summary': 'Latihan intensitas tinggi dengan interval pendek'
    };

    final mockAnalysisIncomplete = {
      'type': 'Yoga Session',
      'duration': 'Tidak ditentukan',
      'intensity': 'Sedang',
      'estimatedCalories': 150,
    };

    testWidgets('renders all analysis data correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisData: mockAnalysisComplete,
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
      expect(find.text('Latihan intensitas tinggi dengan interval pendek'), findsOneWidget);
    });

    testWidgets('handles missing summary gracefully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisData: mockAnalysisIncomplete,
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

    testWidgets('calls onRetry when retry button is pressed', (WidgetTester tester) async {
      // Arrange
      bool onRetryCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisData: mockAnalysisComplete,
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

    testWidgets('calls onSave when save button is pressed', (WidgetTester tester) async {
      // Arrange
      bool onSaveCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisData: mockAnalysisComplete,
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

    testWidgets('displays indicator for missing information', (WidgetTester tester) async {
      // Arrange
      final mockAnalysisWithMissingInfo = {
        'type': 'Unknown Workout',
        'duration': 'Tidak ditentukan',
        'intensity': 'Tidak ditentukan',
        'estimatedCalories': 0,
        'missingInfo': ['duration', 'intensity'],
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisData: mockAnalysisWithMissingInfo,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Informasi Kurang Lengkap'), findsOneWidget);
      expect(find.text('Silakan berikan informasi lebih detail tentang:'), findsOneWidget);
      expect(find.text('• Durasi olahraga'), findsOneWidget);
      expect(find.text('• Intensitas olahraga'), findsOneWidget);
    });

    testWidgets('handles different duration formats correctly', (WidgetTester tester) async {
      // Test numerik
      final mockNumericDuration = {
        'type': 'Lari',
        'duration': '45 menit',
        'intensity': 'Sedang',
        'estimatedCalories': 400,
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisData: mockNumericDuration,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );
      
      expect(find.text('45 menit'), findsOneWidget);
      
      // Test deskriptif
      final mockDescriptiveDuration = {
        'type': 'Lari',
        'duration': 'setengah jam',
        'intensity': 'Sedang',
        'estimatedCalories': 300,
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisData: mockDescriptiveDuration,
              onRetry: () {},
              onSave: () {},
            ),
          ),
        ),
      );
      
      expect(find.text('setengah jam'), findsOneWidget);
      
      // Test rentang
      final mockRangeDuration = {
        'type': 'Lari',
        'duration': '30-45 menit',
        'intensity': 'Sedang',
        'estimatedCalories': 350,
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisResultWidget(
              analysisData: mockRangeDuration,
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