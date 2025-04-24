// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/repositories/weight_repository.dart';

class WeightService {
  final WeightRepository _repository;

  WeightService(this._repository);

  Future<Map<String, List<WeightData>>> getWeightData() async {
    return await _repository.getWeightData();
  }

  Future<WeightStatus> getWeightStatus() async {
    return await _repository.getWeightStatus();
  }

  Future<WeightGoal> getWeightGoal() async {
    return await _repository.getWeightGoal();
  }

  Future<WeeklyAnalysis> getWeeklyAnalysis() async {
    return await _repository.getWeeklyAnalysis();
  }

  Future<String> getSelectedPeriod() async {
    return await _repository.getSelectedPeriod();
  }

  Future<void> setSelectedPeriod(String period) async {
    await _repository.setSelectedPeriod(period);
  }
}
