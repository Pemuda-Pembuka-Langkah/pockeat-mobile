@GenerateMocks([SmartExerciseLogRepository])
import 'smart_exercise_log_repository_test.mocks.dart';

void main() {
  late MockSmartExerciseLogRepository repository;

  setUp(() {
    repository = MockSmartExerciseLogRepository();
  });

  group('SmartExerciseLogRepository', () {
    group('saveAnalysisResult', () {
      test('should save result and return its id', () async {
        // Arrange
        final result = AnalysisResult(
          id: 'test-id-123',
          exerciseType: 'Running',
          duration: '30 menit',
          intensity: 'Sedang',
          estimatedCalories: 300,
          timestamp: DateTime.now(),
          originalInput: 'Lari 30 menit dengan intensitas sedang',
        );
        
        when(repository.saveAnalysisResult(result))
            .thenAnswer((_) async => 'test-id-123');
        
        // Act
        final resultId = await repository.saveAnalysisResult(result);
        
        // Assert
        expect(resultId, 'test-id-123');
        verify(repository.saveAnalysisResult(result)).called(1);
      });

      test('should throw StorageException when saving fails', () async {
        // Arrange
        final result = AnalysisResult(
          exerciseType: 'Running',
          duration: '30 menit',
          intensity: 'Sedang',
          estimatedCalories: 300,
          timestamp: DateTime.now(),
          originalInput: 'Lari 30 menit',
        );
        
        when(repository.saveAnalysisResult(result))
            .thenThrow(StorageException('Failed to save'));
        
        // Act & Assert
        expect(
          () => repository.saveAnalysisResult(result), 
          throwsA(isA<StorageException>())
        );
      });
    });

    group('getAnalysisResultFromId', () {
      test('should return result when found', () async {
        // Arrange
        final mockResult = AnalysisResult(
          id: 'test-id-123',
          exerciseType: 'HIIT Workout',
          duration: '20 menit',
          intensity: 'Tinggi',
          estimatedCalories: 250,
          timestamp: DateTime.now(),
          originalInput: 'HIIT 20 menit',
        );
        
        when(repository.getAnalysisResultFromId('test-id-123'))
            .thenAnswer((_) async => mockResult);
        
        // Act
        final result = await repository.getAnalysisResultFromId('test-id-123');
        
        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'test-id-123');
        expect(result?.exerciseType, 'HIIT Workout');
        verify(repository.getAnalysisResultFromId('test-id-123')).called(1);
      });

      test('should return null when not found', () async {
        // Arrange
        when(repository.getAnalysisResultFromId('non-existent-id'))
            .thenAnswer((_) async => null);
        
        // Act
        final result = await repository.getAnalysisResultFromId('non-existent-id');
        
        // Assert
        expect(result, isNull);
        verify(repository.getAnalysisResultFromId('non-existent-id')).called(1);
      });

      test('should throw StorageException when retrieval fails', () async {
        // Arrange
        when(repository.getAnalysisResultFromId('error-id'))
            .thenThrow(StorageException('Failed to retrieve'));
        
        // Act & Assert
        expect(
          () => repository.getAnalysisResultFromId('error-id'), 
          throwsA(isA<StorageException>())
        );
      });
    });

    group('getAllAnalysisResults', () {
      test('should return empty list when no results saved', () async {
        // Arrange
        when(repository.getAllAnalysisResults())
            .thenAnswer((_) async => []);
        
        // Act
        final results = await repository.getAllAnalysisResults();
        
        // Assert
        expect(results, isEmpty);
        verify(repository.getAllAnalysisResults()).called(1);
      });

      test('should return all saved results', () async {
        // Arrange
        final mockResults = [
          AnalysisResult(
            id: 'id-1',
            exerciseType: 'Running',
            duration: '30 menit',
            intensity: 'Sedang',
            estimatedCalories: 300,
            timestamp: DateTime.now(),
            originalInput: 'Lari 30 menit',
          ),
          AnalysisResult(
            id: 'id-2',
            exerciseType: 'Yoga',
            duration: '45 menit',
            intensity: 'Rendah',
            estimatedCalories: 150,
            timestamp: DateTime.now(),
            originalInput: 'Yoga 45 menit santai',
          ),
        ];
        
        when(repository.getAllAnalysisResults())
            .thenAnswer((_) async => mockResults);
        
        // Act
        final results = await repository.getAllAnalysisResults();
        
        // Assert
        expect(results.length, 2);
        expect(results[0].exerciseType, 'Running');
        expect(results[1].exerciseType, 'Yoga');
        verify(repository.getAllAnalysisResults()).called(1);
      });

      test('should throw StorageException when retrieval fails', () async {
        // Arrange
        when(repository.getAllAnalysisResults())
            .thenThrow(StorageException('Failed to retrieve all results'));
        
        // Act & Assert
        expect(
          () => repository.getAllAnalysisResults(), 
          throwsA(isA<StorageException>())
        );
      });
    });
  });
}