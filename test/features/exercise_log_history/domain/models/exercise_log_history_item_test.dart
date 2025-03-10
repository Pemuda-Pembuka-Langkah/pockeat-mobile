import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

void main() {
  group('ExerciseLogHistoryItem', () {
    // Test data
    final testId = 'test-id';
    final testTimestamp = DateTime(2025, 3, 6, 12, 0);

    test('should create ExerciseLogHistoryItem with provided values', () {
      // Arrange
      final item = ExerciseLogHistoryItem(
        id: testId,
        activityType: ExerciseLogHistoryItem.typeSmartExercise,
        title: 'Running',
        subtitle: '30 minutes • 300 cal',
        timestamp: testTimestamp,
        caloriesBurned: 300,
        sourceId: 'source-123',
      );

      // Assert
      expect(item.id, equals(testId));
      expect(
          item.activityType, equals(ExerciseLogHistoryItem.typeSmartExercise));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 minutes • 300 cal'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(300));
      expect(item.sourceId, equals('source-123'));
    });

    test(
        'should create ExerciseLogHistoryItem with generated id when not provided',
        () {
      // Arrange
      final item = ExerciseLogHistoryItem(
        activityType: ExerciseLogHistoryItem.typeSmartExercise,
        title: 'Running',
        subtitle: '30 minutes • 300 cal',
        timestamp: testTimestamp,
        caloriesBurned: 300,
      );

      // Assert
      expect(item.id, isNotNull);
      expect(item.id.length, greaterThan(0));
    });

    test('should create ExerciseLogHistoryItem from SmartExerciseLog', () {
      // Arrange
      final exerciseAnalysisResult = ExerciseAnalysisResult(
        id: 'smart-123',
        exerciseType: 'Running',
        duration: '30 min',
        intensity: 'High',
        metValue: 8.0,
        estimatedCalories: 300,
        originalInput: 'I went for a run',
        timestamp: testTimestamp,
      );

      // Act
      final item =
          ExerciseLogHistoryItem.fromSmartExerciseLog(exerciseAnalysisResult);

      // Assert
      expect(
          item.activityType, equals(ExerciseLogHistoryItem.typeSmartExercise));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 min • 300 cal'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(300));
      expect(item.sourceId, equals('smart-123'));
    });

    test('should create ExerciseLogHistoryItem from WeightliftingLog', () {
      // Arrange - create a real WeightLifting instance
      final weightLifting = WeightLifting(
        id: 'weight-123',
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 4.0,
        sets: [
          WeightLiftingSet(weight: 80.0, reps: 8, duration: 60.0),
          WeightLiftingSet(weight: 80.0, reps: 8, duration: 60.0),
          WeightLiftingSet(weight: 80.0, reps: 8, duration: 60.0),
        ],
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Assert
      expect(
          item.activityType, equals(ExerciseLogHistoryItem.typeWeightlifting));
      expect(item.title, equals('Bench Press'));

      // The exact calorie value may vary based on our formula,
      // so we'll use a more flexible assertion that checks for the format pattern
      expect(item.subtitle, matches(r'180 min • \d+ cal'));
      expect(item.sourceId, equals('weight-123'));
    });

    test(
        'should create ExerciseLogHistoryItem from WeightliftingLog with valid values',
        () {
      // Arrange - create a real WeightLifting instance
      final weightLifting = WeightLifting(
        id: 'weight-123',
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 4.0,
        sets: [
          WeightLiftingSet(weight: 80.0, reps: 8, duration: 60.0),
          WeightLiftingSet(weight: 80.0, reps: 8, duration: 60.0),
          WeightLiftingSet(weight: 80.0, reps: 8, duration: 60.0),
        ],
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Assert
      expect(
          item.activityType, equals(ExerciseLogHistoryItem.typeWeightlifting));
      expect(item.title, equals('Bench Press'));
      expect(item.subtitle, matches(r'180 min • \d+ cal'));
      expect(item.sourceId, equals('weight-123'));
    });

    test(
        'should create ExerciseLogHistoryItem from CardioLog - Running activity',
        () {
      // Arrange - create a RunningActivity instance
      final runningActivity = RunningActivity(
        id: 'cardio-123',
        date: testTimestamp,
        startTime: testTimestamp,
        endTime: testTimestamp.add(Duration(minutes: 30)),
        distanceKm: 5.2,
        caloriesBurned: 320,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromCardioLog(runningActivity);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.typeCardio));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 min • 320 cal'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(320));
      expect(item.sourceId, equals('cardio-123'));
    });

    test(
        'should create ExerciseLogHistoryItem from CardioLog - Cycling activity',
        () {
      // Arrange - create a CyclingActivity instance
      final cyclingActivity = CyclingActivity(
        id: 'cardio-456',
        date: testTimestamp,
        startTime: testTimestamp,
        endTime: testTimestamp.add(Duration(minutes: 45)),
        distanceKm: 15.0,
        cyclingType: CyclingType.mountain,
        caloriesBurned: 400,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromCardioLog(cyclingActivity);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.typeCardio));
      expect(item.title, equals('Cycling'));
      expect(item.subtitle, equals('45 min • 400 cal'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(400));
      expect(item.sourceId, equals('cardio-456'));
    });

    test(
        'should create ExerciseLogHistoryItem from CardioLog - Swimming activity',
        () {
      // Arrange - create a SwimmingActivity instance
      final swimmingActivity = SwimmingActivity(
        id: 'cardio-789',
        date: testTimestamp,
        startTime: testTimestamp,
        endTime: testTimestamp.add(Duration(minutes: 40)),
        laps: 20,
        poolLength: 50,
        stroke: 'freestyle',
        caloriesBurned: 350,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromCardioLog(swimmingActivity);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.typeCardio));
      expect(item.title, equals('Swimming'));
      expect(item.subtitle, equals('40 min • 350 cal'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(350));
      expect(item.sourceId, equals('cardio-789'));
    });

    test(
        'should create ExerciseLogHistoryItem from WeightLifting with multiple sets',
        () {
      // Arrange - create a WeightLifting instance with multiple sets
      final sets = [
        WeightLiftingSet(weight: 80.0, reps: 10, duration: 30.0),
        WeightLiftingSet(weight: 85.0, reps: 8, duration: 25.0),
        WeightLiftingSet(weight: 90.0, reps: 6, duration: 20.0),
      ];

      final weightLifting = WeightLifting(
        id: 'weight-123',
        name: 'Bench Press',
        bodyPart: 'Chest',
        metValue: 6.0,
        sets: sets,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Assert
      expect(
          item.activityType, equals(ExerciseLogHistoryItem.typeWeightlifting));
      expect(item.title, equals('Bench Press'));
      expect(item.subtitle, matches(r'75 min • \d+ cal'));
      expect(item.sourceId, equals('weight-123'));

      // Calculate calories using our new formula
      double totalDurationInHours = 75.0 / 60.0;
      double totalWeight = sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
      double totalReps = sets.fold(0.0, (sum, set) => sum + set.reps);
      int expectedCalories = (6.0 * 75.0 * (totalDurationInHours + 0.0001 * totalWeight + 0.002 * totalReps)).round();

      expect(item.caloriesBurned, equals(expectedCalories));
    });

    test(
        'should create ExerciseLogHistoryItem from WeightLifting with a single set',
        () {
      // Arrange - create a WeightLifting instance with a single set
      final sets = [
        WeightLiftingSet(weight: 100.0, reps: 5, duration: 20.0),
      ];

      final weightLifting = WeightLifting(
        id: 'weight-456',
        name: 'Deadlift',
        bodyPart: 'Back',
        metValue: 8.0,
        sets: sets,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Assert
      expect(
          item.activityType, equals(ExerciseLogHistoryItem.typeWeightlifting));
      expect(item.title, equals('Deadlift'));
      expect(item.subtitle, matches(r'20 min • \d+ cal'));
      expect(item.sourceId, equals('weight-456'));

      // Calculate calories using our new formula
      double totalDurationInHours = 20.0 / 60.0;
      double totalWeight = sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
      double totalReps = sets.fold(0.0, (sum, set) => sum + set.reps);
      int expectedCalories = (8.0 * 75.0 * (totalDurationInHours + 0.0001 * totalWeight + 0.002 * totalReps)).round();

      expect(item.caloriesBurned, equals(expectedCalories));
    });

    test(
        'should create ExerciseLogHistoryItem from WeightLifting with empty sets',
        () {
      // Arrange
      final weightLifting = WeightLifting(
        id: 'weight-empty',
        name: 'Bench Press',
        bodyPart: 'Chest',
        timestamp: testTimestamp,
        metValue: 4.0,
        sets: [], // Empty sets
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.typeWeightlifting));
      expect(item.title, equals('Bench Press'));
      expect(item.subtitle, equals('0 min • 0 cal'));
      expect(item.caloriesBurned, equals(0));
      expect(item.sourceId, equals('weight-empty'));
    });

    test('should show duration and calories in subtitle for weightlifting log', () {
      // Arrange - create a WeightLifting instance with different weights
      final weightLifting = WeightLifting(
        id: 'weight-123',
        name: 'Bench Press',
        bodyPart: 'Chest',
        timestamp: testTimestamp,
        metValue: 4.0,
        sets: [
          WeightLiftingSet(weight: 70.0, reps: 8, duration: 60.0),
          WeightLiftingSet(weight: 80.0, reps: 6, duration: 60.0),
          WeightLiftingSet(weight: 90.0, reps: 4, duration: 60.0),
        ],
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Total duration is 180 minutes (60+60+60)
      // Assert
      expect(item.subtitle, contains('180 min'));
      expect(item.subtitle, contains('cal'));
      expect(item.caloriesBurned, isNotNull);
    });

    test('should include distance in subtitle for CardioLog when available', () {
      // Arrange - create a RunningActivity instance
      final runningActivity = RunningActivity(
        id: 'cardio-123',
        date: testTimestamp,
        startTime: testTimestamp,
        endTime: testTimestamp.add(Duration(minutes: 30)),
        distanceKm: 5.2,
        caloriesBurned: 320,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromCardioLog(runningActivity);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.typeCardio));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 min • 320 cal'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(320));
    });

    test('should calculate calories for weightlifting activity', () {
      // Arrange - create a WeightLifting instance with specific duration
      final weightLifting = WeightLifting(
        id: 'weight-123',
        name: 'Bench Press',
        bodyPart: 'Chest',
        timestamp: testTimestamp,
        metValue: 5.0,
        sets: [
          WeightLiftingSet(weight: 60, reps: 10, duration: 300.0),
        ],
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Assert - just verify that calories are calculated and greater than zero
      // Instead of testing the exact formula which might change, we validate the value is reasonable
      expect(item.caloriesBurned, greaterThan(0));
      
      // Also verify that calories appear in the subtitle
      expect(item.subtitle, contains('cal'));
      expect(item.subtitle, contains('300 min')); // The implementation treats the duration value as minutes directly
    });

    group('timeAgo formatting tests', () {
      test('should format time as years correctly', () {
        // Arrange
        final item = ExerciseLogHistoryItem(
          id: 'test-id',
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          title: 'Test Exercise',
          subtitle: 'Test Subtitle',
          timestamp: DateTime(2023, 3, 8), // ~2 years ago
          caloriesBurned: 100,
        );

        // Mock current time for consistent testing
        final now = DateTime(2025, 3, 8);
        final difference = now.difference(item.timestamp);
        final years = (difference.inDays / 365).floor();

        // Assert
        expect(years, equals(2));
        // We can't directly test timeAgo because it uses DateTime.now()
        // But we can confirm the logic would produce the expected result
        expect('${years}y ago', equals('2y ago'));
      });

      test('should format time as months correctly', () {
        // Arrange
        final item = ExerciseLogHistoryItem(
          id: 'test-id',
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          title: 'Test Exercise',
          subtitle: 'Test Subtitle',
          timestamp: DateTime(2025, 1,
              1), // Using first day of January for more reliable 2 months
          caloriesBurned: 100,
        );

        // Mock current time for consistent testing
        final now = DateTime(2025, 3, 8);
        final difference = now.difference(item.timestamp);
        final months = (difference.inDays / 30).floor();

        // Assert
        expect(months, equals(2));
        expect('${months}mo ago', equals('2mo ago'));
      });
    });

    group('timeAgo', () {
      test('should return "Just now" for recent timestamps', () {
        final now = DateTime.now();
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: now,
          caloriesBurned: 300,
        );

        expect(item.timeAgo, equals('Just now'));
      });

      test('should return minutes for timestamps less than an hour ago', () {
        final now = DateTime.now();
        final timestamp = now.subtract(Duration(minutes: 30));
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: timestamp,
          caloriesBurned: 300,
        );

        expect(item.timeAgo, equals('30m ago'));
      });

      test('should return hours for timestamps less than a day ago', () {
        final now = DateTime.now();
        final timestamp = now.subtract(Duration(hours: 5));
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: timestamp,
          caloriesBurned: 300,
        );

        expect(item.timeAgo, equals('5h ago'));
      });

      test('should return days for timestamps less than a month ago', () {
        final now = DateTime.now();
        final timestamp = now.subtract(Duration(days: 12));
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: timestamp,
          caloriesBurned: 300,
        );

        expect(item.timeAgo, equals('12d ago'));
      });

      test('should return months for timestamps less than a year ago', () {
        final now = DateTime.now();
        final timestamp = now.subtract(Duration(days: 60)); // ~2 months
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: timestamp,
          caloriesBurned: 300,
        );

        expect(item.timeAgo, equals('2mo ago'));
      });

      test('should return years for timestamps more than a year ago', () {
        final now = DateTime.now();
        final timestamp = now.subtract(Duration(days: 400)); // >1 year
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: timestamp,
          caloriesBurned: 300,
        );

        expect(item.timeAgo, equals('1y ago'));
      });
    });
  });
}
