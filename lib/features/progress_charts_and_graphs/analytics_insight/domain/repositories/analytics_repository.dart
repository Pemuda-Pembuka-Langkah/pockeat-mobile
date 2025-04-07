import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/recommendation_item.dart';

abstract class AnalyticsRepository {
  Future<List<FocusItem>> getFocusItems();
  Future<List<MetricItem>> getPerformanceMetrics();
  Future<InsightCategory> getNutritionInsights();
  Future<InsightCategory> getExerciseInsights();
  Future<List<AnalysisItem>> getDetailedAnalysis();
  Future<InsightCategory> getWeeklyPatterns();
  Future<List<RecommendationItem>> getSmartRecommendations();
}