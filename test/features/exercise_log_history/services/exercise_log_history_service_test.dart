import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'exercise_log_history_service_test.mocks.dart';

@GenerateMocks([SmartExerciseLogRepository, CardioRepository])
void main() {
  late MockSmartExerciseLogRepository mockSmartExerciseLogRepository;
  late MockCardioRepository mockCardioRepository;
  late ExerciseLogHistoryService service;

  setUp(() {
    mockSmartExerciseLogRepository = MockSmartExerciseLogRepository();
    mockCardioRepository = MockCardioRepository();
    service = ExerciseLogHistoryServiceImpl(
      smartExerciseLogRepository: mockSmartExerciseLogRepository,
      cardioRepository: mockCardioRepository,
    );
  });

  group('ExerciseLogHistoryRepository', () {
    // Test data
    final testDate = DateTime(2025, 3, 6);
    final testMonth = 3;
    final testYear = 2025;

    final smartExerciseLog1 = ExerciseAnalysisResult(
      id: 'smart-1',
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'High',
      estimatedCalories: 300,
      timestamp: DateTime(2025, 3, 6, 10, 0),
      originalInput: 'I ran for 30 minutes',
    );

    final smartExerciseLog2 = ExerciseAnalysisResult(
      id: 'smart-2',
      exerciseType: 'Swimming',
      duration: '45 minutes',
      intensity: 'Medium',
      estimatedCalories: 250,
      timestamp: DateTime(2025, 3, 5, 14, 0),
      originalInput: 'I swam for 45 minutes',
    );

    final smartExerciseLog3 = ExerciseAnalysisResult(
      id: 'smart-3',
      exerciseType: 'Cycling',
      duration: '60 minutes',
      intensity: 'Low',
      estimatedCalories: 400,
      timestamp: DateTime(2025, 2, 15, 16, 0),
      originalInput: 'I cycled for 60 minutes',
    );
    
    // Cardio test data
    final cardioLog1 = _MockRunningActivity(
      id: 'cardio-1',
      date: DateTime(2025, 3, 6, 11, 0),
      startTime: DateTime(2025, 3, 6, 11, 0),
      endTime: DateTime(2025, 3, 6, 11, 30),
      caloriesBurned: 350,
      type: CardioType.running,
    );

    final cardioLog2 = _MockCyclingActivity(
      id: 'cardio-2',
      date: DateTime(2025, 3, 5, 15, 0),
      startTime: DateTime(2025, 3, 5, 15, 0),
      endTime: DateTime(2025, 3, 5, 16, 0),
      caloriesBurned: 450,
      type: CardioType.cycling,
    );

    final cardioLog3 = _MockSwimmingActivity(
      id: 'cardio-3',
      date: DateTime(2025, 2, 14, 9, 0),
      startTime: DateTime(2025, 2, 14, 9, 0),
      endTime: DateTime(2025, 2, 14, 9, 45),
      caloriesBurned: 500,
      type: CardioType.swimming,
    );

    test('getAllExerciseLogs should return all logs sorted by timestamp',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .thenAnswer((_) async =>
              [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);
      when(mockCardioRepository.getAllCardioActivities())
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      // Act
      final result = await service.getAllExerciseLogs();

      // Assert
      expect(result.length, equals(6));
      // Verify logs are sorted by timestamp (newest first)
      expect(result[0].sourceId, equals('cardio-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-1'));
      expect(result[2].sourceId, equals('cardio-2'));
      expect(result[3].sourceId, equals('smart-2'));
      expect(result[4].sourceId, equals('cardio-3'));
      expect(result[5].sourceId, equals('smart-3'));

      verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .called(1);
      verify(mockCardioRepository.getAllCardioActivities()).called(1);
    });

    test('getAllExerciseLogs with limit should return limited number of logs',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: 2))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);
      when(mockCardioRepository.getAllCardioActivities())
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      // Act
      final result = await service.getAllExerciseLogs(limit: 3);

      // Assert
      expect(result.length, equals(3));
      expect(result[0].sourceId, equals('cardio-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-1'));
      expect(result[2].sourceId, equals('cardio-2'));

      verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: 2))
          .called(1);
      verify(mockCardioRepository.getAllCardioActivities()).called(1);
    });

    test('getExerciseLogsByDate should return logs for specific date',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate,
              limit: null))
          .thenAnswer((_) async => [smartExerciseLog1]);
      when(mockCardioRepository.filterByDate(testDate))
          .thenAnswer((_) async => [cardioLog1]);

      // Act
      final result = await service.getExerciseLogsByDate(testDate);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].sourceId, equals('cardio-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-1'));
      expect(result[0].title, equals('Running'));
      expect(result[1].title, equals('Running'));

      verify(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate,
              limit: null))
          .called(1);
      verify(mockCardioRepository.filterByDate(testDate)).called(1);
    });

    test(
        'getExerciseLogsByDate with limit should return limited logs for specific date',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate,
              limit: 1))
          .thenAnswer((_) async => [smartExerciseLog1]);
      when(mockCardioRepository.filterByDate(testDate))
          .thenAnswer((_) async => [cardioLog1]);

      // Act
      final result = await service.getExerciseLogsByDate(testDate, limit: 1);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].sourceId, equals('cardio-1')); // Most recent first

      verify(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate,
              limit: 1))
          .called(1);
      verify(mockCardioRepository.filterByDate(testDate)).called(1);
    });

    test(
        'getExerciseLogsByMonth should return logs for specific month and year',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository
              .getAnalysisResultsByMonth(testMonth, testYear, limit: null))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);
      when(mockCardioRepository.filterByMonth(testMonth, testYear))
          .thenAnswer((_) async => [cardioLog1, cardioLog2]);

      // Act
      final result =
          await service.getExerciseLogsByMonth(testMonth, testYear);

      // Assert
      expect(result.length, equals(4));
      expect(result[0].sourceId, equals('cardio-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-1'));
      expect(result[2].sourceId, equals('cardio-2'));
      expect(result[3].sourceId, equals('smart-2'));

      verify(mockSmartExerciseLogRepository
              .getAnalysisResultsByMonth(testMonth, testYear, limit: null))
          .called(1);
      verify(mockCardioRepository.filterByMonth(testMonth, testYear)).called(1);
    });

    test(
        'getExerciseLogsByMonth with limit should return limited logs for specific month and year',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository
              .getAnalysisResultsByMonth(testMonth, testYear, limit: 1))
          .thenAnswer((_) async => [smartExerciseLog1]);
      when(mockCardioRepository.filterByMonth(testMonth, testYear))
          .thenAnswer((_) async => [cardioLog1, cardioLog2]);

      // Act
      final result = await service
          .getExerciseLogsByMonth(testMonth, testYear, limit: 2);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].sourceId, equals('cardio-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-1'));

      verify(mockSmartExerciseLogRepository
              .getAnalysisResultsByMonth(testMonth, testYear, limit: 1))
          .called(1);
      verify(mockCardioRepository.filterByMonth(testMonth, testYear)).called(1);
    });

    test('getExerciseLogsByYear should return logs for specific year',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear,
              limit: null))
          .thenAnswer((_) async =>
              [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);
      when(mockCardioRepository.filterByYear(testYear))
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      // Act
      final result = await service.getExerciseLogsByYear(testYear);

      // Assert
      expect(result.length, equals(6));
      expect(result[0].sourceId, equals('cardio-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-1'));
      expect(result[2].sourceId, equals('cardio-2'));
      expect(result[3].sourceId, equals('smart-2'));
      expect(result[4].sourceId, equals('cardio-3'));
      expect(result[5].sourceId, equals('smart-3'));

      verify(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear,
              limit: null))
          .called(1);
      verify(mockCardioRepository.filterByYear(testYear)).called(1);
    });

    test(
        'getExerciseLogsByYear with limit should return limited logs for specific year',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear,
              limit: null))
          .thenAnswer((_) async =>
              [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);
      when(mockCardioRepository.filterByYear(testYear))
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      // Act
      final result = await service.getExerciseLogsByYear(testYear, limit: 3);

      // Assert
      expect(result.length, equals(3));
      expect(result[0].sourceId, equals('cardio-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-1'));
      expect(result[2].sourceId, equals('cardio-2'));

      verify(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear,
              limit: null))
          .called(1);
      verify(mockCardioRepository.filterByYear(testYear)).called(1);
    });

    test(
        'getExerciseLogsByActivityCategory should return logs for specific activity category',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .thenAnswer((_) async =>
              [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);
      when(mockCardioRepository.getAllCardioActivities())
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      // Act
      final result = await service.getExerciseLogsByActivityCategory(
          ExerciseLogHistoryItem.TYPE_CARDIO);

      // Assert
      expect(result.length, equals(3));
      expect(result[0].activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(result[1].activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(result[2].activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(result[0].sourceId, equals('cardio-1'));
      expect(result[1].sourceId, equals('cardio-2'));
      expect(result[2].sourceId, equals('cardio-3'));

      verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .called(1);
      verify(mockCardioRepository.getAllCardioActivities()).called(1);
    });

    test(
        'getExerciseLogsByActivityCategory with limit should return limited logs for specific activity category',
        () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .thenAnswer((_) async =>
              [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);
      when(mockCardioRepository.getAllCardioActivities())
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      // Act
      final result = await service.getExerciseLogsByActivityCategory(
          ExerciseLogHistoryItem.TYPE_CARDIO, limit: 2);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(result[1].activityType, equals(ExerciseLogHistoryItem.TYPE_CARDIO));
      expect(result[0].sourceId, equals('cardio-1'));
      expect(result[1].sourceId, equals('cardio-2'));

      verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .called(1);
      verify(mockCardioRepository.getAllCardioActivities()).called(1);
    });
  });
}

// Mock implementations for testing
class _MockRunningActivity extends CardioActivity {
  _MockRunningActivity({
    required String id,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required double caloriesBurned,
    required CardioType type,
  }) : super(
          id: id,
          date: date,
          startTime: startTime,
          endTime: endTime,
          caloriesBurned: caloriesBurned,
          type: type,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'caloriesBurned': caloriesBurned,
      'type': 'running',
    };
  }

  @override
  double calculateCalories() {
    return caloriesBurned;
  }
}

class _MockCyclingActivity extends CardioActivity {
  _MockCyclingActivity({
    required String id,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required double caloriesBurned,
    required CardioType type,
  }) : super(
          id: id,
          date: date,
          startTime: startTime,
          endTime: endTime,
          caloriesBurned: caloriesBurned,
          type: type,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'caloriesBurned': caloriesBurned,
      'type': 'cycling',
    };
  }

  @override
  double calculateCalories() {
    return caloriesBurned;
  }
}

class _MockSwimmingActivity extends CardioActivity {
  _MockSwimmingActivity({
    required String id,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required double caloriesBurned,
    required CardioType type,
  }) : super(
          id: id,
          date: date,
          startTime: startTime,
          endTime: endTime,
          caloriesBurned: caloriesBurned,
          type: type,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'caloriesBurned': caloriesBurned,
      'type': 'swimming',
    };
  }

  @override
  double calculateCalories() {
    return caloriesBurned;
  }
}
