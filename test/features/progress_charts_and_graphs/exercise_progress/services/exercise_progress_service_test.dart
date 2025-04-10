import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/services/exercise_progress_service.dart';

import 'exercise_progress_service_test.mocks.dart';

@GenerateMocks([ExerciseProgressRepository])
void main() {
  late ExerciseProgressService service;
  late MockExerciseProgressRepository mockRepository;

  setUp(() {
    mockRepository = MockExerciseProgressRepository();
    service = ExerciseProgressService(repository: mockRepository);
  });

  group('ExerciseProgressService', () {
    test('getExerciseData should call repository.getExerciseData with the same parameter', () async {
      // Arrange - test weekly view
      final mockExerciseData = [
        ExerciseData('Mon', 320),
        ExerciseData('Tue', 280),
      ];
      when(mockRepository.getExerciseData(true)).thenAnswer((_) async => mockExerciseData);

      // Act
      final result = await service.getExerciseData(true);

      // Assert
      expect(result, equals(mockExerciseData));
      verify(mockRepository.getExerciseData(true)).called(1);
      
      // Test with isWeeklyView = false (monthly view)
      final mockMonthlyData = [
        ExerciseData('Week 1', 1850),
        ExerciseData('Week 2', 2100),
      ];
      when(mockRepository.getExerciseData(false)).thenAnswer((_) async => mockMonthlyData);
      
      final monthlyResult = await service.getExerciseData(false);
      
      expect(monthlyResult, equals(mockMonthlyData));
      verify(mockRepository.getExerciseData(false)).called(1);
    });

    test('getWorkoutStats should call repository.getWorkoutStats', () async {
      // Arrange
      final mockWorkoutStats = [
        WorkoutStat(label: 'Duration', value: '45 min', colorValue: 0xFF4ECDC4),
        WorkoutStat(label: 'Calories', value: '320 kcal', colorValue: 0xFFFF6B6B),
      ];
      when(mockRepository.getWorkoutStats()).thenAnswer((_) async => mockWorkoutStats);

      // Act
      final result = await service.getWorkoutStats();

      // Assert
      expect(result, equals(mockWorkoutStats));
      verify(mockRepository.getWorkoutStats()).called(1);
    });

    test('getExerciseTypes should call repository.getExerciseTypes', () async {
      // Arrange
      final mockExerciseTypes = [
        ExerciseType(name: 'Cardio', percentage: 45, colorValue: 0xFFFF6B6B),
        ExerciseType(name: 'Strength', percentage: 35, colorValue: 0xFF4ECDC4),
      ];
      when(mockRepository.getExerciseTypes()).thenAnswer((_) async => mockExerciseTypes);

      // Act
      final result = await service.getExerciseTypes();

      // Assert
      expect(result, equals(mockExerciseTypes));
      verify(mockRepository.getExerciseTypes()).called(1);
    });

    test('getPerformanceMetrics should call repository.getPerformanceMetrics', () async {
      // Arrange
      final mockPerformanceMetrics = [
        PerformanceMetric(
          label: 'Consistency',
          value: '92%',
          subtext: 'Last week: 87%',
          colorValue: 0xFFFF6B6B,
          icon: Icons.trending_up,
        ),
      ];
      when(mockRepository.getPerformanceMetrics()).thenAnswer((_) async => mockPerformanceMetrics);

      // Act
      final result = await service.getPerformanceMetrics();

      // Assert
      expect(result, equals(mockPerformanceMetrics));
      verify(mockRepository.getPerformanceMetrics()).called(1);
    });

    test('getWorkoutHistory should call repository.getWorkoutHistory', () async {
      // Arrange
      final mockWorkoutHistory = [
        WorkoutItem(
          title: 'Morning Workout',
          type: 'Cardio',
          stats: '350 calories',
          time: '45 min',
          colorValue: 0xFF4ECDC4,
        ),
      ];
      when(mockRepository.getWorkoutHistory()).thenAnswer((_) async => mockWorkoutHistory);

      // Act
      final result = await service.getWorkoutHistory();

      // Assert
      expect(result, equals(mockWorkoutHistory));
      verify(mockRepository.getWorkoutHistory()).called(1);
    });

    test('getSelectedViewPeriod should call repository.getSelectedViewPeriod', () async {
      // Arrange
      when(mockRepository.getSelectedViewPeriod()).thenAnswer((_) async => true);

      // Act
      final result = await service.getSelectedViewPeriod();

      // Assert
      expect(result, isTrue);
      verify(mockRepository.getSelectedViewPeriod()).called(1);
    });

    test('setSelectedViewPeriod should call repository.setSelectedViewPeriod with the same parameter', () async {
      // Arrange
      when(mockRepository.setSelectedViewPeriod(any)).thenAnswer((_) async {});

      // Act
      await service.setSelectedViewPeriod(false);

      // Assert
      verify(mockRepository.setSelectedViewPeriod(false)).called(1);
    });
    
    test('getCompletionPercentage should call repository.getCompletionPercentage', () async {
      // Arrange
      when(mockRepository.getCompletionPercentage()).thenAnswer((_) async => '75% completed');

      // Act
      final result = await service.getCompletionPercentage();

      // Assert
      expect(result, equals('75% completed'));
      verify(mockRepository.getCompletionPercentage()).called(1);
    });
  });
}