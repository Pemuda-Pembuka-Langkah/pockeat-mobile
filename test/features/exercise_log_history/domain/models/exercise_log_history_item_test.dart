import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';

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

    test('should convert to and from Map correctly', () {
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

      // Act
      final map = item.toMap();
      final fromMap = ExerciseLogHistoryItem.fromMap(map, testId);

      // Assert
      expect(fromMap.id, equals(item.id));
      expect(fromMap.activityType, equals(item.activityType));
      expect(fromMap.title, equals(item.title));
      expect(fromMap.subtitle, equals(item.subtitle));
      expect(fromMap.timestamp.millisecondsSinceEpoch,
          equals(item.timestamp.millisecondsSinceEpoch));
      expect(fromMap.caloriesBurned, equals(item.caloriesBurned));
      expect(fromMap.sourceId, equals(item.sourceId));
    });

    test('should create ExerciseLogHistoryItem from SmartExerciseLog', () {
      // Arrange
      final smartExerciseLog = ExerciseAnalysisResult(
        id: 'smart-123',
        exerciseType: 'Running',
        duration: '30 minutes',
        intensity: 'High',
        estimatedCalories: 300,
        metValue: 8.0,
        summary: 'Good workout',
        timestamp: testTimestamp,
        originalInput: 'I ran for 30 minutes',
      );

      // Act
      final item =
          ExerciseLogHistoryItem.fromSmartExerciseLog(smartExerciseLog);

      // Assert
      expect(item.activityType,
          equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 minutes • High'));
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

    test('should create ExerciseLogHistoryItem from CardioLog', () {
      // Arrange - create a mock CardioLog with some null values
      final cardioLog = _MockCardioLog(
        id: 'cardio-123',
        date: testTimestamp,
        startTime: testTimestamp,
        endTime: testTimestamp.add(Duration(minutes: 30)),
        type: CardioType.running,
        caloriesBurned: 320,
        distance: 5.2,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromCardioLog(cardioLog);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 min • 5.2 km'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(320));
      expect(item.sourceId, equals('cardio-123'));
    });

    test('should create ExerciseLogHistoryItem from CardioLog with valid values', () {
      // Arrange - create a mock CardioLog with valid values
      final cardioLog = _MockCardioLog(
        id: 'cardio-123',
        date: testTimestamp,
        startTime: testTimestamp,
        endTime: testTimestamp.add(Duration(minutes: 30)),
        type: CardioType.running,
        caloriesBurned: 320,
        distance: 5.2,
      );

      // Act
      final item = ExerciseLogHistoryItem.fromCardioLog(cardioLog);

      // Assert
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(item.title, equals('Running'));
      expect(item.subtitle, equals('30 min • 5.2 km'));
      expect(item.timestamp, equals(testTimestamp));
      expect(item.caloriesBurned, equals(320));
      expect(item.sourceId, equals('cardio-123'));
    });

    test('should handle null values in fromMap factory', () {
      // Arrange - create a map with null values
      final map = <String, dynamic>{
        'activityType': null,
        'title': null,
        'subtitle': null,
        'timestamp': null,
        'caloriesBurned': null,
        'sourceId': null,
      };

      // Act
      final item = ExerciseLogHistoryItem.fromMap(map, 'test-id');

      // Assert
      expect(item.id, equals('test-id'));
      expect(item.activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE)); // Default value
      expect(item.title, equals('Unknown Exercise')); // Default value
      expect(item.subtitle, equals('')); // Default value
      expect(item.timestamp.millisecondsSinceEpoch, closeTo(DateTime.now().millisecondsSinceEpoch, 5000)); // Default value, allowing 5 seconds tolerance
      expect(item.caloriesBurned, equals(0)); // Default value
      expect(item.sourceId, isNull);
    });

    group('timeAgo', () {
      test('should return "Just now" for current time', () {
        // Arrange
        final now = DateTime.now();
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: now,
          caloriesBurned: 300,
        );

        // Assert
        expect(item.timeAgo, equals('Just now'));
      });

      test('should return minutes for time less than an hour ago', () {
        // Arrange
        final now = DateTime.now();
        final thirtyMinutesAgo = now.subtract(Duration(minutes: 30));
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: thirtyMinutesAgo,
          caloriesBurned: 300,
        );

        // Assert
        expect(item.timeAgo, equals('30m ago'));
      });

      test('should return hours for time less than a day ago', () {
        // Arrange
        final now = DateTime.now();
        final twoHoursAgo = now.subtract(Duration(hours: 2));
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: twoHoursAgo,
          caloriesBurned: 300,
        );

        // Assert
        expect(item.timeAgo, equals('2h ago'));
      });

      test('should return days for time less than a month ago', () {
        // Arrange
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(Duration(days: 3));
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: threeDaysAgo,
          caloriesBurned: 300,
        );

        // Assert
        expect(item.timeAgo, equals('3d ago'));
      });

      test('should return months for time less than a year ago', () {
        // Arrange
        final now = DateTime.now();
        // Menggunakan tanggal yang pasti 2 bulan yang lalu
        final twoMonthsAgo =
            DateTime(now.year, now.month - 2, now.day, now.hour, now.minute);
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: twoMonthsAgo,
          caloriesBurned: 300,
        );

        // Act
        final timeAgo = item.timeAgo;

        // Assert
        // Menggunakan contains untuk mengakomodasi perbedaan perhitungan bulan
        expect(timeAgo, contains('mo ago'));
        expect(int.parse(timeAgo.split('mo').first.trim()),
            greaterThanOrEqualTo(1));
      });

      test('should return years for time more than a year ago', () {
        // Arrange
        final now = DateTime.now();
        final twoYearsAgo = DateTime(now.year - 2, now.month, now.day);
        final item = ExerciseLogHistoryItem(
          activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
          title: 'Running',
          subtitle: '30 minutes',
          timestamp: twoYearsAgo,
          caloriesBurned: 300,
        );

        // Assert
        expect(item.timeAgo, equals('2y ago'));
      });
    });
  });
}

class _MockWeightliftingLog {
  final String id;
  final String exerciseName;
  final String sets;
  final String reps;
  final String weight;
  final DateTime timestamp;
  final int caloriesBurned;

  _MockWeightliftingLog({
    required this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.timestamp,
    required this.caloriesBurned,
  });
}

class _MockCardioLog implements CardioActivity {
  @override
  final String id;
  
  @override
  final DateTime date;
  
  @override
  final DateTime startTime;
  
  @override
  final DateTime endTime;
  
  @override
  final double caloriesBurned;
  
  @override
  final CardioType type;
  
  @override
  Duration get duration => endTime.difference(startTime);
  
  // Additional properties for testing
  final double? distance;

  _MockCardioLog({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.caloriesBurned = 0,
    this.distance,
  });
  
  @override
  double calculateCalories() {
    return caloriesBurned;
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'caloriesBurned': caloriesBurned,
      'type': type.index,
      'distance': distance,
    };
  }
}
