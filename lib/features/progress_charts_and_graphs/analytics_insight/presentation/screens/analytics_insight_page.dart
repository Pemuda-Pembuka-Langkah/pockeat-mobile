import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/recommendation_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/services/analytics_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/today_insights_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/performance_metrics_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/insight_card_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/detailed_analysis_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/widgets/smart_recommendations_widget.dart';

class AnalyticsInsightPage extends StatefulWidget {
  final AnalyticsService service;
  
  const AnalyticsInsightPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<AnalyticsInsightPage> createState() => _AnalyticsInsightPageState();
}

class _AnalyticsInsightPageState extends State<AnalyticsInsightPage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  
  late Future<List<FocusItem>> _focusItemsFuture;
  late Future<List<MetricItem>> _metricsFuture;
  late Future<InsightCategory> _nutritionInsightsFuture;
  late Future<InsightCategory> _exerciseInsightsFuture;
  late Future<List<AnalysisItem>> _analysisItemsFuture;
  late Future<InsightCategory> _weeklyPatternsFuture;
  late Future<List<RecommendationItem>> _recommendationsFuture;
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    _focusItemsFuture = widget.service.getFocusItems();
    _metricsFuture = widget.service.getPerformanceMetrics();
    _nutritionInsightsFuture = widget.service.getNutritionInsights();
    _exerciseInsightsFuture = widget.service.getExerciseInsights();
    _analysisItemsFuture = widget.service.getDetailedAnalysis();
    _weeklyPatternsFuture = widget.service.getWeeklyPatterns();
    _recommendationsFuture = widget.service.getSmartRecommendations();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(primaryGreen: primaryGreen),
            const SizedBox(height: 24),
            FutureBuilder<List<FocusItem>>(
              future: _focusItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return TodayInsightsWidget(
                  focusItems: snapshot.data!,
                  primaryPink: primaryPink,
                );
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<MetricItem>>(
              future: _metricsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return PerformanceMetricsWidget(metrics: snapshot.data!);
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<InsightCategory>(
              future: _nutritionInsightsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return InsightCardWidget(category: snapshot.data!);
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<InsightCategory>(
              future: _exerciseInsightsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return InsightCardWidget(category: snapshot.data!);
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<AnalysisItem>>(
              future: _analysisItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return DetailedAnalysisWidget(analysisItems: snapshot.data!);
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<InsightCategory>(
              future: _weeklyPatternsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return InsightCardWidget(category: snapshot.data!);
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<RecommendationItem>>(
              future: _recommendationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return SmartRecommendationsWidget(
                  recommendations: snapshot.data!,
                  primaryGreen: primaryGreen,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}