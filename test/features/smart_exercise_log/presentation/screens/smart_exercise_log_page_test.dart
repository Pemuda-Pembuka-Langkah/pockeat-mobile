import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
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
    final getIt = GetIt.instance;

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
      
      // Reset GetIt before each test
      if (GetIt.I.isRegistered<GeminiService>()) {
        GetIt.I.unregister<GeminiService>();
      }
      
      // Register mock services in GetIt
      getIt.registerSingleton<GeminiService>(mockGeminiService);
    });

    tearDown(() {
      // Clean up GetIt after each test
      if (GetIt.I.isRegistered<GeminiService>()) {
        GetIt.I.unregister<GeminiService>();
      }
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
      // Arrange - Setup mock with delay to simulate network request
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

      // Act - Input text and click button
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Running 30 minutes high intensity');
      
      final analyzeButton = find.text('Analyze Workout');
      await tester.tap(analyzeButton);
      await tester.pump(); // Rebuild after setState

      // Assert - Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait until process completes
      await tester.pumpAndSettle();
      
      // Verify final results
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

      // Act - Input text and click button
      await tester.enterText(find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle(); // Wait for animations/async operations

      // Assert - Verify UI changes correctly
      expect(find.byType(WorkoutFormWidget), findsNothing); // Form is hidden
      expect(find.byType(AnalysisResultWidget), findsOneWidget); // Results are displayed
      
      // Verify specific data is displayed
      expect(find.text('Running'), findsOneWidget); // Exercise type
      expect(find.text('30 minutes'), findsOneWidget); // Duration
      expect(find.text('High'), findsOneWidget); // Intensity
      expect(find.text('300 kcal'), findsOneWidget); // Calories
    });

    testWidgets('shows error message when analysis fails', (WidgetTester tester) async {
      // Arrange - Setup mock to throw error
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

      // Act - Input text and click button
      await tester.enterText(find.byType(TextField), 'Invalid workout');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Assert - Verify error message appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to analyze workout'), findsOneWidget);
      expect(find.byType(WorkoutFormWidget), findsOneWidget); // Form is still visible
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

      // Act - Complete analysis first
      await tester.enterText(find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Then click save button
      await tester.tap(find.text('Save Log'));
      await tester.pump(); // Show SnackBar

      // Assert - Verify repository is called and success message appears
      verify(mockRepository.saveAnalysisResult(any)).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Workout log saved successfully!'), findsOneWidget);
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
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Incomplete Information'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      // Verify Save button does not appear for incomplete data
      expect(find.text('Save Log'), findsNothing);
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

      // Act - Complete analysis first
      await tester.enterText(find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Then click retry button
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Assert
      expect(find.byType(WorkoutFormWidget), findsOneWidget);
      expect(find.byType(AnalysisResultWidget), findsNothing);
    });
  });
}