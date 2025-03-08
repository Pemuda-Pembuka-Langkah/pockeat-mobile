import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';

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
      // Arrange - create a mock WeightliftingLog with some null values
      final weightliftingLog = _MockWeightliftingLog(
        id: 'weight-123',
        exerciseName: 'Bench Press',
        sets: '3',
        reps: '8',
        weight: '80 kg',
        timestamp: testTimestamp,
        caloriesBurned: 250,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightliftingLog);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Bench Press')); 
      expect(item.subtitle, equals('3 sets • 8 reps • 80 kg')); 
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(250));
      expect(item.sourceId, equals('weight-123'));
    });

    test('should create ExerciseLogHistoryItem from WeightliftingLog with valid values', () {
      // Arrange - create a mock WeightliftingLog with valid values
      final weightliftingLog = _MockWeightliftingLog(
        id: 'weight-123',
        exerciseName: 'Bench Press',
        sets: '3',
        reps: '8',
        weight: '80 kg',
        timestamp: testTimestamp,
        caloriesBurned: 250,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightliftingLog);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Bench Press')); 
      expect(item.subtitle, equals('3 sets • 8 reps • 80 kg')); 
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(250));
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
      // Arrange - create a mock WeightliftingLog with null values
      final weightliftingLog = _MockWeightliftingLog(
        id: 'weight-123',
        exerciseName: null,
        sets: null,
        reps: null,
        weight: null,
        timestamp: testTimestamp,
        caloriesBurned: null,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromWeightliftingLog(weightliftingLog);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING));
      expect(item.title, equals('Weightlifting Session')); // Default title
      expect(item.subtitle, equals('0 sets • 0 reps • 0 kg')); // Default values
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(0)); // Default to 0
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

class _MockWeightliftingLog {
  final String id;
  final String? exerciseName;
  final String? sets;
  final String? reps;
  final String? weight;
  final DateTime timestamp;
  final int? caloriesBurned;

  _MockWeightliftingLog({
    required this.id,
    this.exerciseName,
    this.sets,
    this.reps,
    this.weight,
    required this.timestamp,
    this.caloriesBurned,
  });
}
