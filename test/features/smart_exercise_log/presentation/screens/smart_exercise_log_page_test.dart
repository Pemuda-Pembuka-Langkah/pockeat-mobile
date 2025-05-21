// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/screens/smart_exercise_log_page.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/analysis_result_widget.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/workout_form_widget.dart';
import 'smart_exercise_log_page_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  ExerciseAnalysisService,
  SmartExerciseLogRepository,
  firebase_auth.FirebaseAuth,
  firebase_auth.User,
  HealthMetricsService
])

void main() {
  group('SmartExerciseLogPage Widget Tests', () {
    late MockExerciseAnalysisService mockExerciseAnalysisService;
    late MockSmartExerciseLogRepository mockRepository;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockHealthMetricsService mockHealthMetricsService;
    final getIt = GetIt.instance;

    // Sample exercise analysis result for testing
    final mockAnalysisResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'High',
      estimatedCalories: 300,
      metValue: 8.0,
      summary:
          'You performed Running for 30 minutes at High intensity, burning approximately 300 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 30 minutes high intensity',
      userId: 'test-user-123',
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
      userId: 'test-user-123',
    );

    setUp(() {
      mockExerciseAnalysisService = MockExerciseAnalysisService();
      mockRepository = MockSmartExerciseLogRepository();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockHealthMetricsService = MockHealthMetricsService();

      // Configure mock auth
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-user-123');
      when(mockHealthMetricsService.getUserHealthMetrics())
        .thenAnswer((_) async => HealthMetricsModel(
          userId: 'test-user-123',
          height: 175.0,
          weight: 70.0,
          age: 30,
          gender: 'Male',
          activityLevel: 'moderate',
          fitnessGoal: 'maintain',
          bmi: 22.9,
          bmiCategory: 'Normal weight',
          desiredWeight: 70.0,
        ));
        
      // Reset GetIt before each test
      if (GetIt.I.isRegistered<ExerciseAnalysisService>()) {
        GetIt.I.unregister<ExerciseAnalysisService>();
      }

      // Register mock services in GetIt
      getIt.registerSingleton<ExerciseAnalysisService>(mockExerciseAnalysisService);
    });

    tearDown(() {
      // Clean up GetIt after each test
      if (GetIt.I.isRegistered<ExerciseAnalysisService>()) {
        GetIt.I.unregister<ExerciseAnalysisService>();
      }
    });

    testWidgets('renders initial UI with workout form',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Assert
      expect(find.text('Smart Exercise Log'), findsOneWidget);
      expect(find.byType(WorkoutFormWidget), findsOneWidget);
      expect(find.byType(AnalysisResultWidget), findsNothing);
    });

    testWidgets('shows loading indicator when analyzing workout',
        (WidgetTester tester) async {
      // Arrange - Setup mock with delay to simulate network request
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return mockAnalysisResult;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Wait for health metrics to load
      await tester.pumpAndSettle();

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

    testWidgets('shows analysis result after successful analysis',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResult);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Wait for health metrics to load
      await tester.pumpAndSettle();

      // Act - Input text and click button
      await tester.enterText(
          find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle(); // Wait for animations/async operations

      // Assert - Verify UI changes correctly
      expect(find.byType(WorkoutFormWidget), findsNothing); // Form is hidden
      expect(find.byType(AnalysisResultWidget),
          findsOneWidget); // Results are displayed

      // Verify specific data is displayed
      expect(find.text('Running'), findsOneWidget); // Exercise type
      expect(find.text('30 minutes'), findsOneWidget); // Duration
      expect(find.text('High'), findsOneWidget); // Intensity
      expect(find.text('300 kcal'), findsOneWidget); // Calories
    });

    testWidgets('shows error message when analysis fails',
        (WidgetTester tester) async {
      // Arrange - Setup mock to throw error
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Wait for health metrics to load
      await tester.pumpAndSettle();

      // Act - Input text and click button
      await tester.enterText(find.byType(TextField), 'Invalid workout');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Assert - Verify error message appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to analyze workout'), findsOneWidget);
      expect(find.byType(WorkoutFormWidget),
          findsOneWidget); // Form is still visible
    });

    testWidgets('saves analysis result and shows success message',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResult);
      when(mockRepository.saveAnalysisResult(any))
          .thenAnswer((_) async => 'mock_id');

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Wait for health metrics to load
      await tester.pumpAndSettle();

      // Act - Complete analysis first
      await tester.enterText(
          find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Now save the result
      await tester.tap(find.text('Save Log'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Workout log saved successfully'),
          findsOneWidget);
    });

    testWidgets('shows incomplete data warning for incomplete analysis result',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResultWithError);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
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

    testWidgets('retry button resets analysis and shows form again',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResult);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Act - Complete analysis first
      await tester.enterText(
          find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Then click retry button
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WorkoutFormWidget), findsOneWidget);
      expect(find.byType(AnalysisResultWidget), findsNothing);
    });

    testWidgets('shows error message when saving fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResult);
      when(mockRepository.saveAnalysisResult(any))
          .thenThrow(Exception('Database error'));

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Act - Complete analysis first
      await tester.enterText(
          find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Then click save button
      await tester.tap(find.text('Save Log'));
      await tester.pumpAndSettle();

      // Assert - Verify error message appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to save log'), findsOneWidget);
    });

    testWidgets('shows correction dialog when correction button is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResult);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Act - Complete analysis first
      await tester.enterText(
          find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Then tap correction button
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Assert - Verify correction dialog appears
      expect(find.text('Correct Analysis'),
          findsNWidgets(2)); // One in button, one in dialog title
      expect(find.text('Please provide details on what needs to be corrected:'),
          findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Submit Correction'), findsOneWidget);
    });

    // testWidgets('applies correction when submitted in dialog',
    //     (WidgetTester tester) async {
    //   // Arrange
    //   when(mockExerciseAnalysisService.analyze(
    //     any,
    //     userId: anyNamed('userId'),
    //     userWeightKg: anyNamed('userWeightKg'),
    //     userHeightCm: anyNamed('userHeightCm'),
    //     userAge: anyNamed('userAge'),
    //     userGender: anyNamed('userGender'),
    //   )).thenAnswer((_) async => mockAnalysisResult);

    //   // Create a corrected result
    //   final correctedResult = ExerciseAnalysisResult(
    //     exerciseType: 'Running',
    //     duration: '45 minutes', // Changed duration
    //     intensity: 'High',
    //     estimatedCalories: 450, // Updated calories
    //     metValue: 8.0,
    //     summary:
    //         'You performed Running for 45 minutes at High intensity, burning approximately 450 calories.',
    //     timestamp: DateTime.now(),
    //     originalInput: 'Running 30 minutes high intensity',
    //     userId: 'test-user-123',
    //   );

    //   // Setup mock for correction
    //   when(mockExerciseAnalysisService.correctAnalysis(
    //     any,
    //     any,
    //     userWeightKg: anyNamed('userWeightKg'),
    //     userHeightCm: anyNamed('userHeightCm'),
    //     userAge: anyNamed('userAge'),
    //     userGender: anyNamed('userGender'),
    //   )).thenAnswer((_) async {
    //     await Future.delayed(const Duration(milliseconds: 300));
    //     return correctedResult;
    //   });

    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: SmartExerciseLogPage(
    //         repository: mockRepository,
    //         auth: mockAuth,
    //         healthMetricsService: mockHealthMetricsService,
    //       ),
    //     ),
    //   );

    //   // Complete initial analysis
    //   await tester.enterText(
    //       find.byType(TextField), 'Running 30 minutes high intensity');
    //   await tester.tap(find.text('Analyze Workout'));
    //   await tester.pumpAndSettle();

    //   // Open correction dialog
    //   await tester.tap(find.text('Correct Analysis'));
    //   await tester.pumpAndSettle();

    //   // Enter correction
    //   await tester.enterText(
    //       find.byType(TextField).last, 'I actually ran for 45 minutes');

    //   // Submit correction
    //   await tester.tap(find.text('Submit Correction'));
      
    //   // Skip looking for loading indicators - just wait for the correction to complete
    //   await tester.pumpAndSettle();

    //   // Verify the updated values appear
    //   expect(find.text('45 minutes'), findsOneWidget); // Exact duration text
    //   expect(find.text('450 kcal'), findsOneWidget); // Exact calories text
    //   expect(find.textContaining('450'), findsOneWidget); // Calories
    //   expect(find.text('Analysis corrected successfully!'), findsOneWidget);
    // });

    testWidgets('shows error message when correction fails',
        (WidgetTester tester) async {
      // Same setup as other test...
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResult);

      // Setup mock to throw error
      when(mockExerciseAnalysisService.correctAnalysis(
        any,
        any,
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenThrow(Exception('Correction failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Complete the setup steps
      await tester.enterText(
          find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextField).last, 'I actually ran for 45 minutes');

      // Submit correction
      await tester.tap(find.text('Submit Correction'));
      await tester.pumpAndSettle();

      // Verify error appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to correct analysis'), findsOneWidget);
    });

    testWidgets('shows error message when correction fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResult);

      // Setup mock to throw error
      when(mockExerciseAnalysisService.correctAnalysis(any, any))
          .thenThrow(Exception('Correction failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Act - Complete analysis first
      await tester.enterText(
          find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Then tap correction button
      expect(find.text('Correct Analysis'), findsOneWidget);
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Enter correction comment
      await tester.enterText(
          find.byType(TextField).last, 'I actually ran for 45 minutes');

      // Submit correction
      await tester.tap(find.text('Submit Correction'));
      await tester.pump(); // trigger dialog close
      await tester.pump(const Duration(milliseconds: 10)); // biar state update
      await tester.pump(const Duration(milliseconds: 100)); // biar loading muncul

      // Assert - Verify error message appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to correct analysis'), findsOneWidget);
    });

    testWidgets('back button navigates away from the page',
        (WidgetTester tester) async {
      // Setup navigation test with a navigator
      bool didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute<dynamic>(
                builder: (BuildContext context) {
                  if (settings.name == '/') {
                    return SmartExerciseLogPage(
                      repository: mockRepository,
                      auth: mockAuth,
                      healthMetricsService: mockHealthMetricsService,
                    );
                  }
                  return Container();
                },
                settings: settings,
              );
            },
            observers: [
              MockNavigatorObserver(
                didPopCallback: () {
                  didPop = true;
                },
              ),
            ],
          ),
        ),
      );

      // Act - Tap back button in app bar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert
      expect(didPop, isTrue, reason: 'Navigator should have popped');
    });

    testWidgets('handles health metrics loading failure gracefully', (WidgetTester tester) async {
      // Arrange - Setup mock to throw error
      when(mockHealthMetricsService.getUserHealthMetrics())
        .thenThrow(Exception('Failed to load health metrics'));
      
      // Act - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );
      
      // Let the error be caught and handled
      await tester.pumpAndSettle();
      
      // Assert - Page should still function with default metrics
      expect(find.text('Smart Exercise Log'), findsOneWidget);
      expect(find.byType(WorkoutFormWidget), findsOneWidget);
      
      // Complete an analysis to verify it works with default metrics
      await tester.enterText(find.byType(TextField), 'Running 30 minutes');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();
      
      // Verify analysis still works with default metrics
      verify(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: 70.0, // Default value
        userHeightCm: 175.0, // Default value
        userAge: 30, // Default value
        userGender: anyNamed('userGender'),
      )).called(1);
    });

    // Test full correction flow with successful response
    testWidgets('applies correction successfully when correction dialog is submitted',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseAnalysisService.analyze(
        any,
        userId: anyNamed('userId'),
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async => mockAnalysisResult);

      // Create a corrected result for testing
      final correctedResult = ExerciseAnalysisResult(
        exerciseType: 'Running',
        duration: '45 minutes', // Changed duration
        intensity: 'High',
        estimatedCalories: 450, // Updated calories
        metValue: 8.0,
        summary: 'You performed Running for 45 minutes at High intensity, burning approximately 450 calories.',
        timestamp: DateTime.now(),
        originalInput: 'Running 30 minutes high intensity',
        userId: 'test-user-123',
      );

      // Setup mock for correction with delayed response
      when(mockExerciseAnalysisService.correctAnalysis(
        any,
        any,
        userWeightKg: anyNamed('userWeightKg'),
        userHeightCm: anyNamed('userHeightCm'),
        userAge: anyNamed('userAge'),
        userGender: anyNamed('userGender'),
      )).thenAnswer((_) async {
        // Add delay to test loading state
        await Future.delayed(const Duration(milliseconds: 100));
        return correctedResult;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );

      // Complete initial analysis
      await tester.enterText(
          find.byType(TextField), 'Running 30 minutes high intensity');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();

      // Open correction dialog
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Enter correction
      await tester.enterText(
          find.byType(TextField).last, 'I actually ran for 45 minutes');

      // Submit correction
      await tester.tap(find.text('Submit Correction'));
      await tester.pump(); // Start correction process
      
      // Verify loading indicator appears
      expect(find.text('Correcting analysis...'), findsOneWidget);
      
      // Complete the correction
      await tester.pumpAndSettle();

      // Verify the updated values appear in the UI
      expect(find.text('45 minutes'), findsOneWidget); // Exact duration text
      expect(find.text('450 kcal'), findsOneWidget); // Exact calories text
      
      // Verify success message
      expect(find.text('Analysis corrected successfully!'), findsOneWidget);
    });

    // Test user ID handling when user is not logged in
    testWidgets('handles missing user ID gracefully when not logged in',
        (WidgetTester tester) async {
      // Arrange - Set up mock auth to return null for current user
      when(mockAuth.currentUser).thenReturn(null);
      
      await tester.pumpWidget(
        MaterialApp(
          home: SmartExerciseLogPage(
            repository: mockRepository,
            auth: mockAuth,
            healthMetricsService: mockHealthMetricsService,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Act - Try to analyze exercise
      await tester.enterText(find.byType(TextField), 'Running 30 minutes');
      await tester.tap(find.text('Analyze Workout'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('User not logged in'), findsOneWidget);
    });

  });


}

// Helper class for monitoring navigation
class MockNavigatorObserver extends NavigatorObserver {
  final Function? didPopCallback;

  MockNavigatorObserver({this.didPopCallback});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (didPopCallback != null) {
      didPopCallback!();
    }
    super.didPop(route, previousRoute);
  }
}
