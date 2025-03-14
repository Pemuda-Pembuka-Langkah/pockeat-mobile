import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/presentation/screens/exercise_log_detail_page.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/cycling_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/running_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/smart_exercise_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/swimming_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/weight_lifting_detail_widget.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

// Generate mock classes for repositories
@GenerateMocks(
    [CardioRepository, SmartExerciseLogRepository, WeightLiftingRepository])
import 'exercise_log_detail_page_test.mocks.dart';

// Mock NavigatorObserver for testing navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // Sample data for testing
  final runningActivity = RunningActivity(
    id: 'run-1',
    date: DateTime(2025, 3, 1),
    startTime: DateTime(2025, 3, 1, 8, 0),
    endTime: DateTime(2025, 3, 1, 8, 30),
    distanceKm: 5.0,
    caloriesBurned: 350,
  );

  final cyclingActivity = CyclingActivity(
    id: 'cycle-1',
    date: DateTime(2025, 3, 2),
    startTime: DateTime(2025, 3, 2, 10, 0),
    endTime: DateTime(2025, 3, 2, 11, 0),
    distanceKm: 20.0,
    cyclingType: CyclingType.commute,
    caloriesBurned: 450,
  );

  final swimmingActivity = SwimmingActivity(
    id: 'swim-1',
    date: DateTime(2025, 3, 3),
    startTime: DateTime(2025, 3, 3, 16, 0),
    endTime: DateTime(2025, 3, 3, 16, 45),
    laps: 20,
    poolLength: 50.0,
    stroke: 'freestyle',
    caloriesBurned: 500,
  );

  // Create an ExerciseAnalysisResult instance for smart exercise testing
  final smartExercise = ExerciseAnalysisResult(
    id: 'smart-1',
    exerciseType: 'Push-ups',
    duration: '15 min',
    intensity: 'High',
    estimatedCalories: 120,
    metValue: 8.0,
    timestamp: DateTime(2025, 3, 4),
    originalInput: 'I did push-ups for 15 minutes',
  );

  final weightLiftingExercise = WeightLifting(
    id: 'weight-1',
    name: 'Bench Press',
    bodyPart: 'Chest',
    metValue: 6.0,
    timestamp: DateTime(2025, 3, 5),
    sets: [
      WeightLiftingSet(
        weight: 60.0,
        reps: 12,
        duration: 45.0,
      )
    ],
  );

  group('ExerciseLogDetailPage Widget Tests', () {
    late MockCardioRepository mockCardioRepository;
    late MockSmartExerciseLogRepository mockSmartExerciseRepository;
    late MockWeightLiftingRepository mockWeightLiftingRepository;

    setUp(() {
      mockCardioRepository = MockCardioRepository();
      mockSmartExerciseRepository = MockSmartExerciseLogRepository();
      mockWeightLiftingRepository = MockWeightLiftingRepository();
    });

    testWidgets('should show loading indicator while data is loading',
        (WidgetTester tester) async {
      // Arrange
      // Use a completer to keep the Future in a pending state
      when(mockCardioRepository.getCardioActivityById(any)).thenAnswer((_) =>
          Future.delayed(const Duration(seconds: 1), () => runningActivity));

      // Act - Create widget and pump it
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
          cardioRepository: mockCardioRepository,
          smartExerciseRepository: mockSmartExerciseRepository,
          weightLiftingRepository: mockWeightLiftingRepository,
        ),
      ));

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up - complete the futures so the test can finish
      await tester.pumpAndSettle();
    });

    testWidgets('should display error message when data loading fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockCardioRepository.getCardioActivityById(any))
          .thenAnswer((_) => Future.error('Failed to load data'));

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
          cardioRepository: mockCardioRepository,
          smartExerciseRepository: mockSmartExerciseRepository,
          weightLiftingRepository: mockWeightLiftingRepository,
        ),
      ));

      // Wait for error to appear
      await tester.pumpAndSettle();

      // Assert - should show error message
      expect(find.text('Error loading data'), findsOneWidget);
    });

    testWidgets('should display RunningDetailWidget with modern UI components',
        (WidgetTester tester) async {
      // Arrange
      when(mockCardioRepository.getCardioActivityById(any))
          .thenAnswer((_) async => runningActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
          cardioRepository: mockCardioRepository,
          smartExerciseRepository: mockSmartExerciseRepository,
          weightLiftingRepository: mockWeightLiftingRepository,
        ),
      ));

      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Assert - should render RunningDetailWidget
      expect(find.byType(RunningDetailWidget), findsOneWidget);
      
      // Verify modern UI components
      expect(find.text('Running Session'), findsOneWidget);
      
      // Test for metrics and icons
      expect(find.byIcon(Icons.straighten), findsAtLeastNWidgets(1)); // Distance icon
      expect(find.byIcon(Icons.timer), findsAtLeastNWidgets(1)); // Pace icon
      expect(find.byIcon(Icons.local_fire_department), findsAtLeastNWidgets(1)); // Calories icon
      
      // Verify the container with gradient is present (looking for BoxDecoration)
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should display CyclingDetailWidget with modern UI components',
        (WidgetTester tester) async {
      // Arrange
      when(mockCardioRepository.getCardioActivityById(any))
          .thenAnswer((_) async => cyclingActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'cycle-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
          cardioRepository: mockCardioRepository,
          smartExerciseRepository: mockSmartExerciseRepository,
          weightLiftingRepository: mockWeightLiftingRepository,
        ),
      ));

      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Assert - should render CyclingDetailWidget
      expect(find.byType(CyclingDetailWidget), findsOneWidget);
      
      // Verify modern UI components
      expect(find.text('Cycling Session'), findsOneWidget);
      
      // Test for metrics and icons
      expect(find.byIcon(Icons.straighten), findsAtLeastNWidgets(1)); // Distance icon
      expect(find.byIcon(Icons.speed), findsAtLeastNWidgets(1)); // Speed icon
      expect(find.byIcon(Icons.local_fire_department), findsAtLeastNWidgets(1)); // Calories icon
      
      // Verify activity details
      expect(find.text('Activity Details'), findsOneWidget);
    });

    testWidgets('should display SwimmingDetailWidget with modern UI components',
        (WidgetTester tester) async {
      // Arrange
      when(mockCardioRepository.getCardioActivityById(any))
          .thenAnswer((_) async => swimmingActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'swim-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
          cardioRepository: mockCardioRepository,
          smartExerciseRepository: mockSmartExerciseRepository,
          weightLiftingRepository: mockWeightLiftingRepository,
        ),
      ));

      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Assert - should render SwimmingDetailWidget
      expect(find.byType(SwimmingDetailWidget), findsOneWidget);
      
      // Verify modern UI components
      expect(find.text('Swimming Session'), findsOneWidget);
      
      // Test for metrics display
      expect(find.text('Activity Details'), findsOneWidget);
      expect(find.text('Stroke Style'), findsOneWidget);
      
      // Test for calculating pace per 100m is displayed
      expect(find.text('Pace (100m)'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display SmartExerciseDetailWidget for smart exercise',
        (WidgetTester tester) async {
      // Arrange
      when(mockSmartExerciseRepository.getAnalysisResultFromId(any))
          .thenAnswer((_) async => smartExercise);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'smart-1',
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          cardioRepository: mockCardioRepository,
          smartExerciseRepository: mockSmartExerciseRepository,
          weightLiftingRepository: mockWeightLiftingRepository,
        ),
      ));

      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Assert - should render SmartExerciseDetailWidget
      expect(find.byType(SmartExerciseDetailWidget), findsOneWidget);
    });

    testWidgets('should show error message when exercise data is not found',
        (WidgetTester tester) async {
      // Arrange
      when(mockSmartExerciseRepository.getAnalysisResultFromId(any))
          .thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'non-existent-id',
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          cardioRepository: mockCardioRepository,
          smartExerciseRepository: mockSmartExerciseRepository,
          weightLiftingRepository: mockWeightLiftingRepository,
        ),
      ));

      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Assert - should show the error message that appears when data is null
      expect(find.text('An error occurred while loading exercise data'),
          findsOneWidget);
    });

    testWidgets(
        'should display weight lifting details with modern UI components',
        (WidgetTester tester) async {
      // Arrange
      when(mockWeightLiftingRepository.getExerciseById('weight-1'))
          .thenAnswer((_) async => weightLiftingExercise);

      // Act - Create widget and pump it
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'weight-1',
          activityType: ExerciseLogHistoryItem.typeWeightlifting,
          cardioRepository: mockCardioRepository,
          smartExerciseRepository: mockSmartExerciseRepository,
          weightLiftingRepository: mockWeightLiftingRepository,
        ),
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Assert - basic info (using more flexible expectations)
      expect(find.text('Bench Press'), findsOneWidget);

      // Check that the body part is displayed somewhere (may appear multiple times)
      expect(find.textContaining('Chest'), findsAtLeastNWidgets(1));

      // Check that at least one weight value is displayed
      expect(find.textContaining('60'), findsAtLeastNWidgets(1));
      
      // Verify modern UI components
      // Look for headers that indicate the new design
      expect(find.text('Workout Details'), findsOneWidget);
      
      // Verify gradient container is present
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    group('Delete functionality tests', () {
      testWidgets('should show delete button in AppBar', (WidgetTester tester) async {
        // Arrange
        when(mockSmartExerciseRepository.getAnalysisResultFromId(any))
            .thenAnswer((_) async => smartExercise);

        // Act
        await tester.pumpWidget(MaterialApp(
          home: ExerciseLogDetailPage(
            exerciseId: 'smart-1',
            activityType: ExerciseLogHistoryItem.typeSmartExercise,
            cardioRepository: mockCardioRepository,
            smartExerciseRepository: mockSmartExerciseRepository,
            weightLiftingRepository: mockWeightLiftingRepository,
          ),
        ));

        await tester.pumpAndSettle();

        // Assert - verify delete button is visible in AppBar
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
        expect(find.byTooltip('Delete'), findsOneWidget);
      });

      testWidgets('should show confirmation dialog when delete button is pressed',
          (WidgetTester tester) async {
        // Arrange
        when(mockSmartExerciseRepository.getAnalysisResultFromId(any))
            .thenAnswer((_) async => smartExercise);

        // Act
        await tester.pumpWidget(MaterialApp(
          home: ExerciseLogDetailPage(
            exerciseId: 'smart-1',
            activityType: ExerciseLogHistoryItem.typeSmartExercise,
            cardioRepository: mockCardioRepository,
            smartExerciseRepository: mockSmartExerciseRepository,
            weightLiftingRepository: mockWeightLiftingRepository,
          ),
        ));

        await tester.pumpAndSettle();

        // Tap the delete button
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Assert - verify confirmation dialog appears
        expect(find.text('Delete Exercise'), findsOneWidget);
        expect(
            find.text(
                'Are you sure you want to delete this exercise log? This action cannot be undone.'),
            findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsAtLeastNWidgets(1));
      });

      testWidgets('should close dialog when Cancel is pressed',
          (WidgetTester tester) async {
        // Arrange
        when(mockSmartExerciseRepository.getAnalysisResultFromId(any))
            .thenAnswer((_) async => smartExercise);

        // Act
        await tester.pumpWidget(MaterialApp(
          home: ExerciseLogDetailPage(
            exerciseId: 'smart-1',
            activityType: ExerciseLogHistoryItem.typeSmartExercise,
            cardioRepository: mockCardioRepository,
            smartExerciseRepository: mockSmartExerciseRepository,
            weightLiftingRepository: mockWeightLiftingRepository,
          ),
        ));

        await tester.pumpAndSettle();

        // Tap the delete button to show dialog
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Tap the cancel button
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - dialog should be closed
        expect(find.text('Delete Exercise'), findsNothing);
      });

      // Delete confirmation test would be added here (requires mock navigators)
    });
  });
}
