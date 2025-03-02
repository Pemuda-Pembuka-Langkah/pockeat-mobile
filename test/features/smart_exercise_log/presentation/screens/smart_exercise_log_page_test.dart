import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/screens/smart_exercise_log_page.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/analysis_result_widget.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/workout_form_widget.dart';

// Generate mocks
@GenerateMocks([GeminiService, SmartExerciseLogRepository])
import 'smart_exercise_log_page_test.mocks.dart';

void main() {
  group('SmartExerciseLogPage Widget Tests', () {
    late MockGeminiService mockGeminiService;
    late MockSmartExerciseLogRepository mockRepository;

    // Sample exercise analysis result for testing
    final mockAnalysisResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'High',
      estimatedCalories: 300,
      metValue: 8.0,
      summary: 'You performed Running for 30 minutes at High intensity, burning approximately 300 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 30 minutes high intensity',
    );

    // Error sample
    final mockAnalysisResultWithError = ExerciseAnalysisResult(
      exerciseType: 'Unknown',
      duration: 'Not specified',
      intensity: 'Not specified',
      estimatedCalories: 0,
      metValue: 0.0,
      summary: 'Could not analyze exercise properly',
      timestamp: DateTime.now(),
      originalInput: 'Invalid input',
      missingInfo: ['type', 'duration', 'intensity'],
    );

    setUp(() {
      mockGeminiService = MockGeminiService();
      mockRepository = MockSmartExerciseLogRepository();
    });

    testWidgets('renders initial UI with workout form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            geminiService: mockGeminiService,
            repository: mockRepository,
          ),
        ),
      );

      // Assert
      expect(find.text('Smart Workout Log'), findsOneWidget);
      expect(find.byType(WorkoutFormWidget), findsOneWidget);
      expect(find.byType(AnalysisResultWidget), findsNothing);
    });

    testWidgets('shows loading indicator when analyzing workout', (WidgetTester tester) async {
      // Arrange - Setup mock dengan delay untuk simulasi network request
      when(mockGeminiService.analyzeExercise(any))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return mockAnalysisResult;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            geminiService: mockGeminiService,
            repository: mockRepository,
          ),
        ),
      );

      // Act - Input text dan klik tombol
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Running 30 minutes high intensity');
      
      final analyzeButton = find.text('Analisis Olahraga');
      await tester.tap(analyzeButton);
      await tester.pump(); // Rebuild setelah setState

      // Assert - Verifikasi loading indicator muncul
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Tunggu sampai proses selesai
      await tester.pumpAndSettle();
      
      // Verifikasi hasil akhir
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AnalysisResultWidget), findsOneWidget);
    });

    testWidgets('shows analysis result after successful analysis', (WidgetTester tester) async {
      // Arrange
      when(mockGeminiService.analyzeExercise(any))
          .thenAnswer((_) async => mockAnalysisResult);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            geminiService: mockGeminiService,
            repository: mockRepository,
          ),
        ),
      );

      // Act - Input text dan klik tombol
      await tester.enterText(find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pumpAndSettle(); // Tunggu animasi/operasi async

      // Assert - Verifikasi UI berubah dengan benar
      expect(find.byType(WorkoutFormWidget), findsNothing); // Form disembunyikan
      expect(find.byType(AnalysisResultWidget), findsOneWidget); // Hasil ditampilkan
      
      // Verifikasi data spesifik ditampilkan
      expect(find.text('Running'), findsOneWidget); // Exercise type
      expect(find.text('30 minutes'), findsOneWidget); // Duration
      expect(find.text('High'), findsOneWidget); // Intensity
      expect(find.text('300 kkal'), findsOneWidget); // Calories
    });

    testWidgets('shows error message when analysis fails', (WidgetTester tester) async {
      // Arrange - Setup mock untuk melempar error
      when(mockGeminiService.analyzeExercise(any))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            geminiService: mockGeminiService,
            repository: mockRepository,
          ),
        ),
      );

      // Act - Input text dan klik tombol
      await tester.enterText(find.byType(TextField), 'Invalid workout');
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pumpAndSettle();

      // Assert - Verifikasi pesan error muncul
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Gagal menganalisis olahraga'), findsOneWidget);
      expect(find.byType(WorkoutFormWidget), findsOneWidget); // Form masih terlihat
    });

    testWidgets('saves analysis result and shows success message', (WidgetTester tester) async {
      // Arrange
      when(mockGeminiService.analyzeExercise(any))
          .thenAnswer((_) async => mockAnalysisResult);
      when(mockRepository.saveAnalysisResult(any))
          .thenAnswer((_) async => 'mock_id');

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            geminiService: mockGeminiService,
            repository: mockRepository,
          ),
        ),
      );

      // Act - Selesaikan analisis terlebih dahulu
      await tester.enterText(find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pumpAndSettle();

      // Kemudian klik tombol simpan
      await tester.tap(find.text('Simpan Log'));
      await tester.pump(); // Tampilkan SnackBar

      // Assert - Verifikasi repository dipanggil dan pesan sukses muncul
      verify(mockRepository.saveAnalysisResult(any)).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Catatan olahraga berhasil disimpan!'), findsOneWidget);
    });

    testWidgets('shows incomplete data warning for incomplete analysis result', (WidgetTester tester) async {
      // Arrange
      when(mockGeminiService.analyzeExercise(any))
          .thenAnswer((_) async => mockAnalysisResultWithError);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            geminiService: mockGeminiService,
            repository: mockRepository,
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Invalid workout data');
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Informasi Kurang Lengkap'), findsOneWidget);
      expect(find.text('Ulangi Input'), findsOneWidget);
      // Verifikasi tombol Simpan tidak muncul untuk data yang tidak lengkap
      expect(find.text('Simpan Log'), findsNothing);
    });

    testWidgets('retry button resets analysis and shows form again', (WidgetTester tester) async {
      // Arrange
      when(mockGeminiService.analyzeExercise(any))
          .thenAnswer((_) async => mockAnalysisResult);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            geminiService: mockGeminiService,
            repository: mockRepository,
          ),
        ),
      );

      // Act - Selesaikan analisis terlebih dahulu
      await tester.enterText(find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analisis Olahraga'));
      await tester.pumpAndSettle();

      // Kemudian klik tombol ulangi
      await tester.tap(find.text('Ulangi Input'));
      await tester.pump();

      // Assert
      expect(find.byType(WorkoutFormWidget), findsOneWidget);
      expect(find.byType(AnalysisResultWidget), findsNothing);
    });
  });
}