import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_summary_card.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

// Mock classes
class MockRunningActivity extends Mock implements RunningActivity {}

class MockCyclingActivity extends Mock implements CyclingActivity {}

class MockSwimmingActivity extends Mock implements SwimmingActivity {}

class MockWeightLifting extends Mock implements WeightLifting {}

class MockExerciseAnalysisResult extends Mock
    implements ExerciseAnalysisResult {}

class MockWeightLiftingSet extends Mock implements WeightLiftingSet {}

void main() {
  late MockRunningActivity runningActivity;
  late MockCyclingActivity cyclingActivity;
  late MockSwimmingActivity swimmingActivity;
  late MockWeightLifting weightLifting;
  late MockExerciseAnalysisResult exerciseAnalysis;
  late List<MockWeightLiftingSet> weightSets;

  setUp(() {
    // Set up running activity mock
    runningActivity = MockRunningActivity();
    when(() => runningActivity.distanceKm).thenReturn(5.0);
    when(() => runningActivity.duration)
        .thenReturn(const Duration(minutes: 30));
    when(() => runningActivity.caloriesBurned).thenReturn(250);
    when(() => runningActivity.date).thenReturn(DateTime(2023, 5, 15, 10, 30));
    when(() => runningActivity.startTime)
        .thenReturn(DateTime(2023, 5, 15, 10, 0));

    // Set up cycling activity mock
    cyclingActivity = MockCyclingActivity();
    when(() => cyclingActivity.distanceKm).thenReturn(10.0);
    when(() => cyclingActivity.duration)
        .thenReturn(const Duration(minutes: 45));
    when(() => cyclingActivity.caloriesBurned).thenReturn(300);
    when(() => cyclingActivity.date).thenReturn(DateTime(2023, 5, 16, 11, 30));
    when(() => cyclingActivity.startTime)
        .thenReturn(DateTime(2023, 5, 16, 11, 0));

    // Set up swimming activity mock
    swimmingActivity = MockSwimmingActivity();
    when(() => swimmingActivity.totalDistance).thenReturn(500.0);
    when(() => swimmingActivity.duration)
        .thenReturn(const Duration(minutes: 20));
    when(() => swimmingActivity.caloriesBurned).thenReturn(200);
    when(() => swimmingActivity.date).thenReturn(DateTime(2023, 5, 17, 12, 30));
    when(() => swimmingActivity.startTime)
        .thenReturn(DateTime(2023, 5, 17, 12, 0));
    when(() => swimmingActivity.laps).thenReturn(20);

    // Set up weight lifting mock
    weightSets = List.generate(3, (index) {
      final set = MockWeightLiftingSet();
      when(() => set.reps).thenReturn(12);
      when(() => set.weight).thenReturn(50.0);
      when(() => set.duration).thenReturn(30);
      return set;
    });

    weightLifting = MockWeightLifting();
    when(() => weightLifting.name).thenReturn('Bench Press');
    when(() => weightLifting.bodyPart).thenReturn('Chest');
    when(() => weightLifting.timestamp)
        .thenReturn(DateTime(2023, 5, 18, 13, 30));
    when(() => weightLifting.sets).thenReturn(weightSets);

    // Set up exercise analysis mock
    exerciseAnalysis = MockExerciseAnalysisResult();
    when(() => exerciseAnalysis.exerciseType).thenReturn('Cardio');
    when(() => exerciseAnalysis.duration).thenReturn('30 minutes');
    when(() => exerciseAnalysis.intensity).thenReturn('Medium');
    when(() => exerciseAnalysis.estimatedCalories).thenReturn(220);
    when(() => exerciseAnalysis.metValue).thenReturn(5.5);
    when(() => exerciseAnalysis.timestamp)
        .thenReturn(DateTime(2023, 5, 19, 14, 30));
  });

  group('ExerciseSummaryCard', () {
    testWidgets('renders correctly with running activity data',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ExerciseSummaryCard(
                cardKey: cardKey,
                exercise: runningActivity,
                activityType: 'cardio',
              ),
            ),
          ),
        ),
      );

      // Verify structural elements
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('Running Session'), findsOneWidget);
      expect(find.text('5.00 km'), findsOneWidget);
      expect(find.text('30m 0s'), findsOneWidget);
      expect(find.text('250 cal'), findsOneWidget);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders correctly with cycling activity data',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ExerciseSummaryCard(
                cardKey: cardKey,
                exercise: cyclingActivity,
                activityType: 'cardio',
              ),
            ),
          ),
        ),
      );

      // Verify structural elements
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('Cycling Session'), findsOneWidget);
      expect(find.text('10.00 km'), findsOneWidget);
      expect(find.text('45m 0s'), findsOneWidget);
      expect(find.text('300 cal'), findsOneWidget);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders correctly with swimming activity data',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ExerciseSummaryCard(
                cardKey: cardKey,
                exercise: swimmingActivity,
                activityType: 'cardio',
              ),
            ),
          ),
        ),
      );

      // Verify structural elements
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('Swimming Session'), findsOneWidget);
      expect(find.text('500.00 m'), findsOneWidget);
      expect(find.text('20m 0s'), findsOneWidget);
      expect(find.text('200 cal'), findsOneWidget);
      expect(find.text('20'), findsOneWidget); // Laps

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders correctly with weight lifting data',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ExerciseSummaryCard(
                cardKey: cardKey,
                exercise: weightLifting,
                activityType: 'weightlifting',
              ),
            ),
          ),
        ),
      );

      // Verify structural elements
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Sets
      expect(find.text('36'), findsOneWidget); // Reps (12 * 3)
      expect(find.text('50.0 kg'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders correctly with exercise analysis data',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ExerciseSummaryCard(
                cardKey: cardKey,
                exercise: exerciseAnalysis,
                activityType: 'smart_exercise',
              ),
            ),
          ),
        ),
      );

      // Verify structural elements
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('AI Analyzed Exercise Session'), findsOneWidget);
      expect(find.text('30 minutes'), findsOneWidget);
      expect(find.text('220 cal'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Cardio'), findsOneWidget);
      expect(find.text('5.5'), findsOneWidget);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('handles unknown exercise type gracefully',
        (WidgetTester tester) async {
      // Use a large viewport to avoid overflow errors during testing
      await tester.binding.setSurfaceSize(const Size(500, 800));

      final cardKey = GlobalKey();
      final unknownExercise = "Unknown Exercise Type";

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ExerciseSummaryCard(
                cardKey: cardKey,
                exercise: unknownExercise,
                activityType: 'unknown',
              ),
            ),
          ),
        ),
      );

      // Verify fallback display
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('Exercise Session'), findsOneWidget);
      expect(find.text('Session'), findsOneWidget);

      // Reset the surface size
      await tester.binding.setSurfaceSize(null);
    });
  });
}
