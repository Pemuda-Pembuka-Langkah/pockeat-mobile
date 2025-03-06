import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/domain/repositories/exercise_log_history_repository.dart';
import 'package:pockeat/features/exercise_log_history/domain/repositories/exercise_log_history_repository_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';

import 'exercise_log_history_repository_test.mocks.dart';

@GenerateMocks([SmartExerciseLogRepository])
void main() {
  late MockSmartExerciseLogRepository mockSmartExerciseLogRepository;
  late ExerciseLogHistoryRepository repository;

  setUp(() {
    mockSmartExerciseLogRepository = MockSmartExerciseLogRepository();
    repository = ExerciseLogHistoryRepositoryImpl(
      smartExerciseLogRepository: mockSmartExerciseLogRepository,
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

    test('getAllExerciseLogs should return all logs sorted by timestamp', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults())
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      // Act
      final result = await repository.getAllExerciseLogs();

      // Assert
      expect(result.length, equals(3));
      expect(result[0].sourceId, equals('smart-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-2'));
      expect(result[2].sourceId, equals('smart-3'));
      
      verify(mockSmartExerciseLogRepository.getAllAnalysisResults()).called(1);
    });

    test('getExerciseLogsByDate should return logs for specific date', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate))
          .thenAnswer((_) async => [smartExerciseLog1]);

      // Act
      final result = await repository.getExerciseLogsByDate(testDate);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].sourceId, equals('smart-1'));
      expect(result[0].title, equals('Running'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate)).called(1);
    });

    test('getExerciseLogsByMonth should return logs for specific month and year', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);

      // Act
      final result = await repository.getExerciseLogsByMonth(testMonth, testYear);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].sourceId, equals('smart-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-2'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear)).called(1);
    });

    test('getExerciseLogsByYear should return logs for specific year', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      // Act
      final result = await repository.getExerciseLogsByYear(testYear);

      // Assert
      expect(result.length, equals(3));
      expect(result[0].sourceId, equals('smart-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-2'));
      expect(result[2].sourceId, equals('smart-3'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear)).called(1);
    });

    test('getExerciseLogsByActivityCategory should return logs for specific activity type', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults())
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      // Act
      final result = await repository.getExerciseLogsByActivityCategory(
          ExerciseLogHistoryItem.TYPE_SMART_EXERCISE);

      // Assert
      expect(result.length, equals(3));
      expect(result[0].activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      expect(result[1].activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      expect(result[2].activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      
      verify(mockSmartExerciseLogRepository.getAllAnalysisResults()).called(1);
    });

    // Negative test cases
    group('Error handling tests', () {
      test('getAllExerciseLogs should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAllAnalysisResults())
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getAllExerciseLogs(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to retrieve exercise logs')
          ))
        );
        verify(mockSmartExerciseLogRepository.getAllAnalysisResults()).called(1);
      });

      test('getExerciseLogsByDate should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getExerciseLogsByDate(testDate),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to retrieve exercise logs by date')
          ))
        );
        verify(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate)).called(1);
      });

      test('getExerciseLogsByMonth should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear))
            .thenThrow(Exception('Server error'));

        // Act & Assert
        expect(
          () => repository.getExerciseLogsByMonth(testMonth, testYear),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to retrieve exercise logs by month')
          ))
        );
        verify(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear)).called(1);
      });

      test('getExerciseLogsByYear should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear))
            .thenThrow(Exception('Connection timeout'));

        // Act & Assert
        expect(
          () => repository.getExerciseLogsByYear(testYear),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to retrieve exercise logs by year')
          ))
        );
        verify(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear)).called(1);
      });

      test('getExerciseLogsByActivityCategory should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAllAnalysisResults())
            .thenThrow(Exception('Authentication error'));

        // Act & Assert
        expect(
          () => repository.getExerciseLogsByActivityCategory(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to retrieve exercise logs by activity category')
          ))
        );
        verify(mockSmartExerciseLogRepository.getAllAnalysisResults()).called(1);
      });

      test('getExerciseLogsByActivityCategory should propagate exception from getAllExerciseLogs', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAllAnalysisResults())
            .thenThrow(Exception('Permission denied'));

        // Act & Assert
        expect(
          () => repository.getExerciseLogsByActivityCategory(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to retrieve exercise logs by activity category')
          ))
        );
        verify(mockSmartExerciseLogRepository.getAllAnalysisResults()).called(1);
      });
    });
  });
}
