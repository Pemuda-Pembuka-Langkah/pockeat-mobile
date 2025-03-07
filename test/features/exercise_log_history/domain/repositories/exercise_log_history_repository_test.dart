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
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      // Act
      final result = await repository.getAllExerciseLogs();

      // Assert
      expect(result.length, equals(3));
      expect(result[0].sourceId, equals('smart-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-2'));
      expect(result[2].sourceId, equals('smart-3'));
      
      verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null)).called(1);
    });

    test('getAllExerciseLogs with limit should return limited number of logs', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: 2))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);

      // Act
      final result = await repository.getAllExerciseLogs(limit: 2);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].sourceId, equals('smart-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-2'));
      
      verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: 2)).called(1);
    });

    test('getExerciseLogsByDate should return logs for specific date', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate, limit: null))
          .thenAnswer((_) async => [smartExerciseLog1]);

      // Act
      final result = await repository.getExerciseLogsByDate(testDate);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].sourceId, equals('smart-1'));
      expect(result[0].title, equals('Running'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate, limit: null)).called(1);
    });

    test('getExerciseLogsByDate with limit should return limited logs for specific date', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate, limit: 1))
          .thenAnswer((_) async => [smartExerciseLog1]);

      // Act
      final result = await repository.getExerciseLogsByDate(testDate, limit: 1);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].sourceId, equals('smart-1'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate, limit: 1)).called(1);
    });

    test('getExerciseLogsByMonth should return logs for specific month and year', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear, limit: null))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);

      // Act
      final result = await repository.getExerciseLogsByMonth(testMonth, testYear);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].sourceId, equals('smart-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-2'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear, limit: null)).called(1);
    });

    test('getExerciseLogsByMonth with limit should return limited logs for specific month and year', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear, limit: 1))
          .thenAnswer((_) async => [smartExerciseLog1]);

      // Act
      final result = await repository.getExerciseLogsByMonth(testMonth, testYear, limit: 1);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].sourceId, equals('smart-1'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear, limit: 1)).called(1);
    });

    test('getExerciseLogsByYear should return logs for specific year', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear, limit: null))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      // Act
      final result = await repository.getExerciseLogsByYear(testYear);

      // Assert
      expect(result.length, equals(3));
      expect(result[0].sourceId, equals('smart-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-2'));
      expect(result[2].sourceId, equals('smart-3'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear, limit: null)).called(1);
    });

    test('getExerciseLogsByYear with limit should return limited logs for specific year', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear, limit: 2))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);

      // Act
      final result = await repository.getExerciseLogsByYear(testYear, limit: 2);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].sourceId, equals('smart-1')); // Most recent first
      expect(result[1].sourceId, equals('smart-2'));
      
      verify(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear, limit: 2)).called(1);
    });

    test('getExerciseLogsByActivityCategory should return logs for specific activity type', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      // Act
      final result = await repository.getExerciseLogsByActivityCategory(
          ExerciseLogHistoryItem.TYPE_SMART_EXERCISE);

      // Assert
      expect(result.length, equals(3));
      expect(result[0].activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      expect(result[1].activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      expect(result[2].activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      
      verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null)).called(1);
    });

    test('getExerciseLogsByActivityCategory with limit should return limited logs for specific activity type', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      // Act
      final result = await repository.getExerciseLogsByActivityCategory(
          ExerciseLogHistoryItem.TYPE_SMART_EXERCISE, limit: 2);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      expect(result[1].activityType, equals(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE));
      
      verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null)).called(1);
    });

    group('Limit handling tests', () {
      test('getAllExerciseLogs should apply limit correctly when there are more items than the limit', () async {
        // Arrange - Create a large list of logs
        final manyLogs = List.generate(10, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 3, 6).subtract(Duration(days: index)),
            originalInput: 'Exercise input $index',
          )
        );
        
        // Important: Add the correct stub with limit parameter
        when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: 5))
            .thenAnswer((_) async => manyLogs.take(5).toList());
        
        // Act
        final result = await repository.getAllExerciseLogs(limit: 5);
        
        // Assert
        expect(result.length, equals(5));
        // Verify the logs are sorted by timestamp (newest first)
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].timestamp.isAfter(result[i + 1].timestamp), isTrue);
        }
      });
      
      test('getExerciseLogsByDate should apply limit correctly when there are more items than the limit', () async {
        // Arrange - Create a large list of logs for the same date
        final manyLogs = List.generate(10, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 3, 6, 8 + index), // Same date, different hours
            originalInput: 'Exercise input $index',
          )
        );
        
        // Important: Add the correct stub with limit parameter
        when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate, limit: 5))
            .thenAnswer((_) async => manyLogs.take(5).toList());
        
        // Act
        final result = await repository.getExerciseLogsByDate(testDate, limit: 5);
        
        // Assert
        expect(result.length, equals(5));
        // Verify the logs are sorted by timestamp (newest first)
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].timestamp.isAfter(result[i + 1].timestamp), isTrue);
        }
      });
      
      test('getExerciseLogsByMonth should apply limit correctly when there are more items than the limit', () async {
        // Arrange - Create a large list of logs for the same month
        final manyLogs = List.generate(10, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 3, 1 + index), // Same month, different days
            originalInput: 'Exercise input $index',
          )
        );
        
        // Important: Add the correct stub with limit parameter
        when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear, limit: 5))
            .thenAnswer((_) async => manyLogs.take(5).toList());
        
        // Act
        final result = await repository.getExerciseLogsByMonth(testMonth, testYear, limit: 5);
        
        // Assert
        expect(result.length, equals(5));
        // Verify the logs are sorted by timestamp (newest first)
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].timestamp.isAfter(result[i + 1].timestamp), isTrue);
        }
      });
      
      test('getExerciseLogsByYear should apply limit correctly when there are more items than the limit', () async {
        // Arrange - Create a large list of logs for the same year
        final manyLogs = List.generate(10, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 1 + index, 1), // Same year, different months
            originalInput: 'Exercise input $index',
          )
        );
        
        // Important: Add the correct stub with limit parameter
        when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear, limit: 5))
            .thenAnswer((_) async => manyLogs.take(5).toList());
        
        // Act
        final result = await repository.getExerciseLogsByYear(testYear, limit: 5);
        
        // Assert
        expect(result.length, equals(5));
        // Verify the logs are sorted by timestamp (newest first)
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].timestamp.isAfter(result[i + 1].timestamp), isTrue);
        }
      });
      
      test('getExerciseLogsByActivityCategory should apply limit correctly when there are more items than the limit', () async {
        // Arrange - Create a large list of logs
        final manyLogs = List.generate(10, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 3, 6).subtract(Duration(days: index)),
            originalInput: 'Exercise input $index',
          )
        );
        
        when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
            .thenAnswer((_) async => manyLogs);
        
        // Act
        final result = await repository.getExerciseLogsByActivityCategory(
            ExerciseLogHistoryItem.TYPE_SMART_EXERCISE, limit: 5);
        
        // Assert
        expect(result.length, equals(5));
        // Verify the logs are sorted by timestamp (newest first)
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].timestamp.isAfter(result[i + 1].timestamp), isTrue);
        }
      });
    });

    group('Limit handling edge cases', () {
      test('getAllExerciseLogs should not apply limit when limit is negative', () async {
        // Arrange - Create a list of logs
        final logs = List.generate(5, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 3, 6).subtract(Duration(days: index)),
            originalInput: 'Exercise input $index',
          )
        );
        
        // We need to set up the mock for the specific limit value we're using
        when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: -1))
            .thenAnswer((_) async => logs);
        
        // Act - Test with negative limit
        final result = await repository.getAllExerciseLogs(limit: -1);
        
        // Assert
        expect(result.length, equals(5)); // Should return all items
      });
      
      test('getExerciseLogsByDate should not apply limit when limit is negative', () async {
        // Arrange - Create a list of logs
        final logs = List.generate(5, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 3, 6, 8 + index), // Same date, different hours
            originalInput: 'Exercise input $index',
          )
        );
        
        // We need to set up the mock for the specific limit value we're using
        when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate, limit: -1))
            .thenAnswer((_) async => logs);
        
        // Act - Test with negative limit
        final result = await repository.getExerciseLogsByDate(testDate, limit: -1);
        
        // Assert
        expect(result.length, equals(5)); // Should return all items
      });
      
      test('getExerciseLogsByMonth should not apply limit when limit is negative', () async {
        // Arrange - Create a list of logs
        final logs = List.generate(5, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 3, 1 + index), // Same month, different days
            originalInput: 'Exercise input $index',
          )
        );
        
        // We need to set up the mock for the specific limit value we're using
        when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear, limit: -1))
            .thenAnswer((_) async => logs);
        
        // Act - Test with negative limit
        final result = await repository.getExerciseLogsByMonth(testMonth, testYear, limit: -1);
        
        // Assert
        expect(result.length, equals(5)); // Should return all items
      });
      
      test('getExerciseLogsByYear should not apply limit when limit is negative', () async {
        // Arrange - Create a list of logs
        final logs = List.generate(5, (index) => 
          ExerciseAnalysisResult(
            id: 'smart-$index',
            exerciseType: 'Exercise $index',
            duration: '$index minutes',
            intensity: 'Medium',
            estimatedCalories: 100 + index,
            timestamp: DateTime(2025, 1 + index, 1), // Same year, different months
            originalInput: 'Exercise input $index',
          )
        );
        
        // We need to set up the mock for the specific limit value we're using
        when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear, limit: -1))
            .thenAnswer((_) async => logs);
        
        // Act - Test with negative limit
        final result = await repository.getExerciseLogsByYear(testYear, limit: -1);
        
        // Assert
        expect(result.length, equals(5)); // Should return all items
      });
    });

    // Negative test cases
    group('Error handling tests', () {
      test('getAllExerciseLogs should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
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
        verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null)).called(1);
      });

      test('getExerciseLogsByDate should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate, limit: null))
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
        verify(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate, limit: null)).called(1);
      });

      test('getExerciseLogsByMonth should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear, limit: null))
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
        verify(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(testMonth, testYear, limit: null)).called(1);
      });

      test('getExerciseLogsByYear should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear, limit: null))
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
        verify(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear, limit: null)).called(1);
      });

      test('getExerciseLogsByActivityCategory should throw exception with proper message when SmartExerciseLogRepository fails', () async {
        // Arrange
        when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => repository.getExerciseLogsByActivityCategory(ExerciseLogHistoryItem.TYPE_SMART_EXERCISE),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to retrieve exercise logs by activity category')
          ))
        );
        verify(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null)).called(1);
      });
    });
  });
}
