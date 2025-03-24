import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository.dart';

class ExerciseProgressRepositoryImpl implements ExerciseProgressRepository {
  bool _isWeeklyView = true;
  final int _primaryPink = 0xFFFF6B6B;
  final int _primaryGreen = 0xFF4ECDC4;
  final int _primaryYellow = 0xFFFFB946;

  @override
  Future<List<ExerciseData>> getExerciseData(bool isWeeklyView) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (isWeeklyView) {
      return [
        ExerciseData('M', 320),
        ExerciseData('T', 280),
        ExerciseData('W', 350),
        ExerciseData('T', 290),
        ExerciseData('F', 400),
        ExerciseData('S', 250),
        ExerciseData('S', 300),
      ];
    } else {
      return [
        ExerciseData('Week 1', 1850),
        ExerciseData('Week 2', 2100),
        ExerciseData('Week 3', 1950),
        ExerciseData('Week 4', 2200),
      ];
    }
  }

  @override
  Future<List<WorkoutStat>> getWorkoutStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return [
      WorkoutStat(
        label: 'Duration',
        value: '45 min',
        colorValue: _primaryGreen,
      ),
      WorkoutStat(
        label: 'Calories',
        value: '320',
        colorValue: _primaryPink,
      ),
      WorkoutStat(
        label: 'Intensity',
        value: 'High',
        colorValue: _primaryYellow,
      ),
    ];
  }

  @override
  Future<List<ExerciseType>> getExerciseTypes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return [
      ExerciseType(
        name: 'Cardio',
        percentage: 45,
        colorValue: _primaryPink,
      ),
      ExerciseType(
        name: 'Weightlifting',
        percentage: 30,
        colorValue: _primaryGreen,
      ),
      ExerciseType(
        name: 'Smart Exercise',
        percentage: 25,
        colorValue: _primaryYellow,
      ),
    ];
  }

  @override
  Future<List<PerformanceMetric>> getPerformanceMetrics() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return [
      PerformanceMetric(
        label: 'Consistency',
        value: '92%',
        subtext: 'Last week: 87%',
        colorValue: _primaryPink,
        icon: Icons.trending_up,
      ),
      PerformanceMetric(
        label: 'Intensity',
        value: '8.5',
        subtext: 'Above average',
        colorValue: _primaryGreen,
        icon: Icons.speed,
      ),
      PerformanceMetric(
        label: 'Streak',
        value: '14',
        subtext: 'Personal best',
        colorValue: _primaryYellow,
        icon: Icons.local_fire_department,
      ),
      PerformanceMetric(
        label: 'Recovery',
        value: '95%',
        subtext: 'Optimal',
        colorValue: _primaryGreen,
        icon: Icons.battery_charging_full,
      ),
    ];
  }

  @override
  Future<List<WorkoutItem>> getWorkoutHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return [
      WorkoutItem(
        title: 'Morning Run',
        type: 'Cardio',
        stats: '5.2 km • 320 cal',
        time: '2h ago',
        colorValue: _primaryPink,
      ),
      WorkoutItem(
        title: 'Upper Body',
        type: 'Weightlifting',
        stats: '45 min • 280 cal',
        time: '1d ago',
        colorValue: _primaryGreen,
      ),
      WorkoutItem(
        title: 'HIIT Session',
        type: 'Smart Exercise',
        stats: '30 min • 350 cal',
        time: '2d ago',
        colorValue: _primaryYellow,
      ),
    ];
  }

  @override
  Future<bool> getSelectedViewPeriod() async {
    return _isWeeklyView;
  }

  @override
  Future<void> setSelectedViewPeriod(bool isWeeklyView) async {
    _isWeeklyView = isWeeklyView;
  }

  @override
  Future<String> getCompletionPercentage() async {
    return '95% completed';
  }
}