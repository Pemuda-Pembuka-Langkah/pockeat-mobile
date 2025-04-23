// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';

abstract class ExerciseProgressRepository {
  Future<List<ExerciseData>> getExerciseData(bool isWeeklyView);
  Future<List<WorkoutStat>> getWorkoutStats();
  Future<List<ExerciseType>> getExerciseTypes();
  Future<List<PerformanceMetric>> getPerformanceMetrics();
  Future<List<WorkoutItem>> getWorkoutHistory();
  Future<bool> getSelectedViewPeriod();
  Future<void> setSelectedViewPeriod(bool isWeeklyView);
  Future<String> getCompletionPercentage();
}
