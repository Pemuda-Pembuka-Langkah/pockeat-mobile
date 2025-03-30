import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository_impl.dart';

void main() {
  late ExerciseProgressRepositoryImpl repository;

  setUp(() {
    repository = ExerciseProgressRepositoryImpl();
  });

  group('ExerciseProgressRepositoryImpl', () {
    test('getExerciseData should return weekly data when isWeeklyView is true', () async {
      // Act
      final result = await repository.getExerciseData(true);

      // Assert
      expect(result.length, 7); // 7 days in a week
      expect(result.first.day, 'M');
      expect(result.first.calories, 320);
    });

    test('getExerciseData should return monthly data when isWeeklyView is false', () async {
      // Act
      final result = await repository.getExerciseData(false);

      // Assert
      expect(result.length, 4); // 4 weeks in a month
      expect(result.first.day, 'Week 1');
      expect(result.first.calories, 1850);
    });

    test('getWorkoutStats should return a list of WorkoutStat objects', () async {
      // Act
      final result = await repository.getWorkoutStats();

      // Assert
      expect(result.length, 3);
      expect(result[0].label, 'Duration');
      expect(result[0].value, '45 min');
      expect(result[1].label, 'Calories');
      expect(result[1].value, '320');
      expect(result[2].label, 'Intensity');
      expect(result[2].value, 'High');
    });

    test('getExerciseTypes should return a list of ExerciseType objects', () async {
      // Act
      final result = await repository.getExerciseTypes();

      // Assert
      expect(result.length, 3);
      expect(result[0].name, 'Cardio');
      expect(result[0].percentage, 45);
      expect(result[1].name, 'Weightlifting');
      expect(result[1].percentage, 30);
      expect(result[2].name, 'Smart Exercise');
      expect(result[2].percentage, 25);
    });

    test('getPerformanceMetrics should return a list of PerformanceMetric objects', () async {
      // Act
      final result = await repository.getPerformanceMetrics();

      // Assert
      expect(result.length, 4);
      expect(result[0].label, 'Consistency');
      expect(result[0].value, '92%');
      expect(result[0].subtext, 'Last week: 87%');
      expect(result[0].icon, Icons.trending_up);
      
      expect(result[1].label, 'Intensity');
      expect(result[1].value, '8.5');
      expect(result[1].subtext, 'Above average');
      expect(result[1].icon, Icons.speed);
      
      expect(result[2].label, 'Streak');
      expect(result[2].value, '14');
      expect(result[2].subtext, 'Personal best');
      expect(result[2].icon, Icons.local_fire_department);
      
      expect(result[3].label, 'Recovery');
      expect(result[3].value, '95%');
      expect(result[3].subtext, 'Optimal');
      expect(result[3].icon, Icons.battery_charging_full);
    });

    test('getWorkoutHistory should return a list of WorkoutItem objects', () async {
      // Act
      final result = await repository.getWorkoutHistory();

      // Assert
      expect(result.length, 3);
      expect(result[0].title, 'Morning Run');
      expect(result[0].type, 'Cardio');
      expect(result[0].stats, '5.2 km • 320 cal');
      expect(result[0].time, '2h ago');
      
      expect(result[1].title, 'Upper Body');
      expect(result[1].type, 'Weightlifting');
      expect(result[1].stats, '45 min • 280 cal');
      expect(result[1].time, '1d ago');
      
      expect(result[2].title, 'HIIT Session');
      expect(result[2].type, 'Smart Exercise');
      expect(result[2].stats, '30 min • 350 cal');
      expect(result[2].time, '2d ago');
    });

    test('getSelectedViewPeriod should return the current view period', () async {
      // Act
      final result = await repository.getSelectedViewPeriod();
      
      // Assert - default is true (weekly view)
      expect(result, isTrue);
    });

    test('setSelectedViewPeriod should update the view period', () async {
      // Act
      await repository.setSelectedViewPeriod(false);
      final result = await repository.getSelectedViewPeriod();
      
      // Assert
      expect(result, isFalse);
      
      // Reset to original state
      await repository.setSelectedViewPeriod(true);
    });

    test('getCompletionPercentage should return the completion percentage as a string', () async {
      // Act
      final result = await repository.getCompletionPercentage();
      
      // Assert
      expect(result, '95% completed');
    });

    test('color values should be correctly assigned', () async {
      // Act
      final workoutStats = await repository.getWorkoutStats();
      final exerciseTypes = await repository.getExerciseTypes();
      final performanceMetrics = await repository.getPerformanceMetrics();
      final workoutHistory = await repository.getWorkoutHistory();
      
      // Assert - verify each color value is assigned correctly
      // Primary Green
      expect(workoutStats[0].colorValue, 0xFF4ECDC4);
      expect(exerciseTypes[1].colorValue, 0xFF4ECDC4);
      expect(performanceMetrics[1].colorValue, 0xFF4ECDC4);
      expect(performanceMetrics[3].colorValue, 0xFF4ECDC4);
      expect(workoutHistory[1].colorValue, 0xFF4ECDC4);
      
      // Primary Pink
      expect(workoutStats[1].colorValue, 0xFFFF6B6B);
      expect(exerciseTypes[0].colorValue, 0xFFFF6B6B);
      expect(performanceMetrics[0].colorValue, 0xFFFF6B6B);
      expect(workoutHistory[0].colorValue, 0xFFFF6B6B);
      
      // Primary Yellow
      expect(workoutStats[2].colorValue, 0xFFFFB946);
      expect(exerciseTypes[2].colorValue, 0xFFFFB946);
      expect(performanceMetrics[2].colorValue, 0xFFFFB946);
      expect(workoutHistory[2].colorValue, 0xFFFFB946);
    });
  });
}