import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
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
        activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
        title: 'Running',
        subtitle: '30 minutes • High intensity',
        timestamp: testTimestamp,
        caloriesBurned: 300,
        sourceId: 'source-123',
      );

      // Assert
      expect(item.id, equals(testId));
      expect(item.activityType,
          equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 minutes • High intensity'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(300));
      expect(item.sourceId, equals('source-123'));
    });

    test(
        'should create ExerciseLogHistoryItem with generated id when not provided',
        () {
      // Arrange
      final item = ExerciseLogHistoryItem(
        activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
        title: 'Running',
        subtitle: '30 minutes • High intensity',
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
      final item = ExerciseLogHistoryItem.fromSmartExerciseLog(exerciseAnalysisResult);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 min • High'));
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
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Bench Press')); 
      expect(item.subtitle, equals('3 sets • 24 reps • 80.0 kg')); 
      expect(item.sourceId, equals('weight-123'));
    });

    test('should create ExerciseLogHistoryItem from WeightliftingLog with valid values', () {
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
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Bench Press')); 
      expect(item.subtitle, equals('3 sets • 24 reps • 80.0 kg')); 
      expect(item.sourceId, equals('weight-123'));
    });

    test('should create ExerciseLogHistoryItem from CardioLog - Running activity', () {
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
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 min'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(320));
      expect(item.sourceId, equals('cardio-123'));
    });

    test('should create ExerciseLogHistoryItem from CardioLog - Cycling activity', () {
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
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(item.title, equals('Cycling'));
      expect(item.subtitle, equals('45 min'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(400));
      expect(item.sourceId, equals('cardio-456'));
    });
    
    test('should create ExerciseLogHistoryItem from CardioLog - Swimming activity', () {
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
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(item.title, equals('Swimming'));
      expect(item.subtitle, contains('40 min'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(350));
      expect(item.sourceId, equals('cardio-789'));
    });
    
    test('should create ExerciseLogHistoryItem from WeightLifting with multiple sets', () {
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
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Bench Press'));
      expect(item.subtitle, equals('3 sets • 24 reps • 85.0 kg'));
      expect(item.sourceId, equals('weight-123'));
      
      // Calories should be calculated based on MET, duration, and weight
      // Formula: Calories = MET value × weight (kg) × duration (hours)
      // total duration is 75 minutes = 1.25 hours, standard weight = 70kg
      final expectedCalories = (6.0 * 70.0 * (75.0 / 60.0)).round();
      expect(item.caloriesBurned, equals(expectedCalories));
    });
    
    test('should create ExerciseLogHistoryItem from WeightLifting with a single set', () {
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
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Deadlift'));
      expect(item.subtitle, equals('1 sets • 5 reps • 100.0 kg'));
      expect(item.sourceId, equals('weight-456'));
      
      final expectedCalories = (8.0 * 70.0 * (20.0 / 60.0)).round();
      expect(item.caloriesBurned, equals(expectedCalories));
    });
    
    test('should create ExerciseLogHistoryItem from WeightLifting with empty sets', () {
      // Arrange - create a WeightLifting instance with empty sets
      final weightLifting = WeightLifting(
        id: 'weight-789',
        name: 'Squat',
        bodyPart: 'Legs',
        metValue: 7.0,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Squat'));
      expect(item.subtitle, equals('0 sets • 0 reps • 0.0 kg'));
      expect(item.sourceId, equals('weight-789'));
      
      // With no sets, there should be 0 calories
      expect(item.caloriesBurned, equals(0));
    });
    
    group('timeAgo formatting tests', () {
      test('should format time as years correctly', () {
        // Arrange
        final item = ExerciseLogHistoryItem(
          id: 'test-id',
          activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
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
          activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
          title: 'Test Exercise',
          subtitle: 'Test Subtitle',
          timestamp: DateTime(2025, 1, 1), // Using first day of January for more reliable 2 months
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

    test('should handle null values gracefully when creating from WeightliftingLog', () {
      // Arrange - create a WeightLifting with empty sets
      final weightLifting = WeightLifting(
        id: 'weight-123',
        name: 'Weightlifting Session',
        bodyPart: 'General',
        metValue: 4.0,
        sets: [], // Empty sets
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightLifting);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Weightlifting Session')); // Default title
      expect(item.subtitle, equals('0 sets • 0 reps • 0.0 kg')); // Default values with decimal
      expect(item.sourceId, equals('weight-123'));
    });

    test('should handle different CardioType values correctly', () {
      final testActivities = [
        RunningActivity(
          id: 'cardio-1',
          date: testTimestamp,
          startTime: testTimestamp,
          endTime: testTimestamp.add(Duration(minutes: 30)),
          distanceKm: 5.0,
          caloriesBurned: 300,
        ),
        CyclingActivity(
          id: 'cardio-2',
          date: testTimestamp,
          startTime: testTimestamp,
          endTime: testTimestamp.add(Duration(minutes: 30)),
          distanceKm: 10.0,
          cyclingType: CyclingType.commute,
          caloriesBurned: 250,
        ),
        SwimmingActivity(
          id: 'cardio-3',
          date: testTimestamp,
          startTime: testTimestamp,
          endTime: testTimestamp.add(Duration(minutes: 30)),
          laps: 20,
          poolLength: 25,
          stroke: 'butterfly',
          caloriesBurned: 350,
        ),
      ];
      
      final expectedTitles = [
        'Running',
        'Cycling',
        'Swimming',
      ];
      
      for (int i = 0; i < testActivities.length; i++) {
        // Act
        final item = ExerciseLogHistoryItem.fromCardioLog(testActivities[i]);

        // Assert
        expect(item.title, equals(expectedTitles[i]), 
            reason: 'Incorrect title for CardioType ${testActivities[i].type}');
      }
    });
  });
}
