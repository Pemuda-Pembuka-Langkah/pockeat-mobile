import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/recommendation_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/repositories/analytics_repository.dart';

class AnalyticsService {
  final AnalyticsRepository _repository;

  AnalyticsService(this._repository);

  Future<List<FocusItem>> getFocusItems() async {
    return await _repository.getFocusItems();
  }

  Future<List<MetricItem>> getPerformanceMetrics() async {
    return await _repository.getPerformanceMetrics();
  }

  Future<InsightCategory> getNutritionInsights() async {
    return await _repository.getNutritionInsights();
  }

  Future<InsightCategory> getExerciseInsights() async {
    return await _repository.getExerciseInsights();
  }

  Future<List<AnalysisItem>> getDetailedAnalysis() async {
    return await _repository.getDetailedAnalysis();
  }

  Future<InsightCategory> getWeeklyPatterns() async {
    return await _repository.getWeeklyPatterns();
  }

  Future<List<RecommendationItem>> getSmartRecommendations() async {
    return await _repository.getSmartRecommendations();
  }
}