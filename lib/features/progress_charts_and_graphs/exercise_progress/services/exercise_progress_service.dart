import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository.dart';

class ExerciseProgressService {
  final ExerciseProgressRepository _repository;

  ExerciseProgressService(this._repository);

  Future<List<ExerciseData>> getExerciseData(bool isWeeklyView) async {
    return await _repository.getExerciseData(isWeeklyView);
  }

  Future<List<WorkoutStat>> getWorkoutStats() async {
    return await _repository.getWorkoutStats();
  }

  Future<List<ExerciseType>> getExerciseTypes() async {
    return await _repository.getExerciseTypes();
  }

  Future<List<PerformanceMetric>> getPerformanceMetrics() async {
    return await _repository.getPerformanceMetrics();
  }

  Future<List<WorkoutItem>> getWorkoutHistory() async {
    return await _repository.getWorkoutHistory();
  }

  Future<bool> getSelectedViewPeriod() async {
    return await _repository.getSelectedViewPeriod();
  }

  Future<void> setSelectedViewPeriod(bool isWeeklyView) async {
    await _repository.setSelectedViewPeriod(isWeeklyView);
  }

  Future<String> getCompletionPercentage() async {
    return await _repository.getCompletionPercentage();
  }
}