// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository.dart';

class ExerciseProgressService {
  final ExerciseProgressRepository repository;

  ExerciseProgressService({required this.repository});

  Future<List<ExerciseData>> getExerciseData(bool isWeeklyView) {
    return repository.getExerciseData(isWeeklyView);
  }

  Future<List<WorkoutStat>> getWorkoutStats() {
    return repository.getWorkoutStats();
  }

  Future<List<ExerciseType>> getExerciseTypes() {
    return repository.getExerciseTypes();
  }

  Future<List<PerformanceMetric>> getPerformanceMetrics() {
    return repository.getPerformanceMetrics();
  }

  Future<List<WorkoutItem>> getWorkoutHistory() {
    return repository.getWorkoutHistory();
  }

  Future<bool> getSelectedViewPeriod() {
    return repository.getSelectedViewPeriod();
  }

  Future<void> setSelectedViewPeriod(bool isWeeklyView) {
    return repository.setSelectedViewPeriod(isWeeklyView);
  }

  Future<String> getCompletionPercentage() {
    return repository.getCompletionPercentage();
  }
}
