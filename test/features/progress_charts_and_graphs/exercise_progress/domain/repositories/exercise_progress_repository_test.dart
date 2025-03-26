import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository.dart';

import 'exercise_progress_repository_test.mocks.dart';

// Generate mock class
@GenerateMocks([ExerciseProgressRepository])
void main() {
  late MockExerciseProgressRepository mockRepository;

  setUp(() {
    mockRepository = MockExerciseProgressRepository();
  });

  group('ExerciseProgressRepository', () {
    test('getExerciseData should retrieve exercise data based on view period', () async {
      // Arrange
      final weeklyData = [
        ExerciseData('M', 320),
        ExerciseData('T', 280),
      ];
      final monthlyData = [
        ExerciseData('Week 1', 1850),
        ExerciseData('Week 2', 2100),
      ];
      
      when(mockRepository.getExerciseData(true)).thenAnswer((_) async => weeklyData);
      when(mockRepository.getExerciseData(false)).thenAnswer((_) async => monthlyData);

      // Act
      final resultWeekly = await mockRepository.getExerciseData(true);
      final resultMonthly = await mockRepository.getExerciseData(false);

      // Assert
      expect(resultWeekly, equals(weeklyData));
      expect(resultMonthly, equals(monthlyData));
      verify(mockRepository.getExerciseData(true)).called(1);
      verify(mockRepository.getExerciseData(false)).called(1);
    });

    test('getWorkoutStats should retrieve workout statistics', () async {
      // Arrange
      final workoutStats = [
        WorkoutStat(label: 'Duration', value: '45 min', colorValue: 0xFF4ECDC4),
        WorkoutStat(label: 'Calories', value: '320', colorValue: 0xFFFF6B6B),
      ];
      
      when(mockRepository.getWorkoutStats()).thenAnswer((_) async => workoutStats);

      // Act
      final result = await mockRepository.getWorkoutStats();

      // Assert
      expect(result, equals(workoutStats));
      verify(mockRepository.getWorkoutStats()).called(1);
    });

    test('getExerciseTypes should retrieve exercise type distribution', () async {
      // Arrange
      final exerciseTypes = [
        ExerciseType(name: 'Cardio', percentage: 45, colorValue: 0xFFFF6B6B),
        ExerciseType(name: 'Strength', percentage: 35, colorValue: 0xFF4ECDC4),
      ];
      
      when(mockRepository.getExerciseTypes()).thenAnswer((_) async => exerciseTypes);

      // Act
      final result = await mockRepository.getExerciseTypes();

      // Assert
      expect(result, equals(exerciseTypes));
      verify(mockRepository.getExerciseTypes()).called(1);
    });

    test('getPerformanceMetrics should retrieve performance metrics', () async {
      // Arrange
      final performanceMetrics = [
        PerformanceMetric(
          label: 'Consistency', 
          value: '92%', 
          subtext: 'Last week: 87%', 
          colorValue: 0xFFFF6B6B, 
          icon: Icons.trending_up, // Fixed null value to use an actual IconData
        ),
      ];
      
      when(mockRepository.getPerformanceMetrics()).thenAnswer((_) async => performanceMetrics);

      // Act
      final result = await mockRepository.getPerformanceMetrics();

      // Assert
      expect(result, equals(performanceMetrics));
      verify(mockRepository.getPerformanceMetrics()).called(1);
    });
    
    test('getWorkoutHistory should retrieve workout history items', () async {
      // Arrange
      final workoutHistory = [
        WorkoutItem(
          title: 'Morning Workout', 
          type: 'Cardio', 
          stats: '350 calories', 
          time: '45 min', 
          colorValue: 0xFF4ECDC4,
        ),
      ];
      
      when(mockRepository.getWorkoutHistory()).thenAnswer((_) async => workoutHistory);

      // Act
      final result = await mockRepository.getWorkoutHistory();

      // Assert
      expect(result, equals(workoutHistory));
      verify(mockRepository.getWorkoutHistory()).called(1);
    });

    test('getSelectedViewPeriod should retrieve current view period setting', () async {
      // Arrange
      when(mockRepository.getSelectedViewPeriod()).thenAnswer((_) async => true);

      // Act
      final result = await mockRepository.getSelectedViewPeriod();

      // Assert
      expect(result, isTrue);
      verify(mockRepository.getSelectedViewPeriod()).called(1);
    });

    test('setSelectedViewPeriod should update the view period setting', () async {
      // Arrange
      when(mockRepository.setSelectedViewPeriod(any)).thenAnswer((_) async {});

      // Act
      await mockRepository.setSelectedViewPeriod(false);

      // Assert
      verify(mockRepository.setSelectedViewPeriod(false)).called(1);
    });

    test('getCompletionPercentage should retrieve goal completion percentage', () async {
      // Arrange
      when(mockRepository.getCompletionPercentage()).thenAnswer((_) async => '75%');

      // Act
      final result = await mockRepository.getCompletionPercentage();

      // Assert
      expect(result, equals('75%'));
      verify(mockRepository.getCompletionPercentage()).called(1);
    });
  });
}