// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'weight_lifting_repository_test.mocks.dart';

// Generate a MockExerciseRepository class
@GenerateMocks([WeightLiftingRepository])

void main() {
  late MockWeightLiftingRepository mockRepository;
  late WeightLifting testExercise;

  setUp(() {
    mockRepository = MockWeightLiftingRepository();
    
    testExercise = WeightLifting(
      id: 'test-id',
      name: 'Bench Press',
      bodyPart: 'Chest',
      metValue: 3.5,
      userId: 'test-user-id',
      sets: [
        WeightLiftingSet(weight: 20.0, reps: 12, duration: 60.0),
      ],
    );
  });

  group('ExerciseRepository interface', () {
    test('should save exercise', () async {
      // Setup
      when(mockRepository.saveExercise(testExercise))
          .thenAnswer((_) async => 'test-id');
          
      // Execute
      final result = await mockRepository.saveExercise(testExercise);
      
      // Verify
      verify(mockRepository.saveExercise(testExercise)).called(1);
      expect(result, 'test-id');
    });

    test('should get exercise by id', () async {
      // Setup
      when(mockRepository.getExerciseById('test-id'))
          .thenAnswer((_) async => testExercise);
          
      // Execute
      final result = await mockRepository.getExerciseById('test-id');
      
      // Verify
      verify(mockRepository.getExerciseById('test-id')).called(1);
      expect(result, testExercise);
    });

    test('should return null when exercise not found', () async {
      // Setup
      when(mockRepository.getExerciseById('non-existent'))
          .thenAnswer((_) async => null);
          
      // Execute
      final result = await mockRepository.getExerciseById('non-existent');
      
      // Verify
      verify(mockRepository.getExerciseById('non-existent')).called(1);
      expect(result, isNull);
    });

    test('should get all exercises', () async {
      // Setup
      final exercises = [testExercise];
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => exercises);
          
      // Execute
      final result = await mockRepository.getAllExercises();
      
      // Verify
      verify(mockRepository.getAllExercises()).called(1);
      expect(result, exercises);
    });

    test('should get exercises by body part', () async {
      // Setup
      final exercises = [testExercise];
      when(mockRepository.getExercisesByBodyPart('Chest'))
          .thenAnswer((_) async => exercises);
          
      // Execute
      final result = await mockRepository.getExercisesByBodyPart('Chest');
      
      // Verify
      verify(mockRepository.getExercisesByBodyPart('Chest')).called(1);
      expect(result, exercises);
    });

    test('should delete exercise', () async {
      // Setup
      when(mockRepository.deleteExercise('test-id'))
          .thenAnswer((_) async => true);
          
      // Execute
      final result = await mockRepository.deleteExercise('test-id');
      
      // Verify
      verify(mockRepository.deleteExercise('test-id')).called(1);
      expect(result, true);
    });

    test('should filter by date', () async {
      // Setup
      final date = DateTime(2025, 3, 8);
      final exercises = [testExercise];
      when(mockRepository.filterByDate(date))
          .thenAnswer((_) async => exercises);
          
      // Execute
      final result = await mockRepository.filterByDate(date);
      
      // Verify
      verify(mockRepository.filterByDate(date)).called(1);
      expect(result, exercises);
    });

    test('should filter by month', () async {
      // Setup
      final exercises = [testExercise];
      when(mockRepository.filterByMonth(3, 2025))
          .thenAnswer((_) async => exercises);
          
      // Execute
      final result = await mockRepository.filterByMonth(3, 2025);
      
      // Verify
      verify(mockRepository.filterByMonth(3, 2025)).called(1);
      expect(result, exercises);
    });

    test('should get exercises with limit', () async {
      // Setup
      final exercises = [testExercise];
      when(mockRepository.getExercisesWithLimit(10))
          .thenAnswer((_) async => exercises);
          
      // Execute
      final result = await mockRepository.getExercisesWithLimit(10);
      
      // Verify
      verify(mockRepository.getExercisesWithLimit(10)).called(1);
      expect(result, exercises);
    });

    test('should throw exception when operations fail', () async {
      // Setup
      when(mockRepository.saveExercise(testExercise))
          .thenThrow(Exception('Failed to save'));
          
      // Execute & Verify
      expect(
        () => mockRepository.saveExercise(testExercise),
        throwsException,
      );
    });
  });
}
