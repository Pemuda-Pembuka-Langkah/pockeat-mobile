import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';

abstract class WeightRepository {
  Future<Map<String, List<WeightData>>> getWeightData();
  Future<WeightStatus> getWeightStatus();
  Future<WeightGoal> getWeightGoal();
  Future<WeeklyAnalysis> getWeeklyAnalysis();
  Future<String> getSelectedPeriod();
  Future<void> setSelectedPeriod(String period);
}
