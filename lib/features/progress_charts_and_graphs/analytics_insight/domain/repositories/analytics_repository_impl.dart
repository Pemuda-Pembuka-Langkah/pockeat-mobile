import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/recommendation_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  
  @override
  Future<List<FocusItem>> getFocusItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      FocusItem(
        icon: CupertinoIcons.heart_fill,
        title: 'Complete your protein target',
        subtitle: '15g remaining to reach 120g daily goal',
        color: primaryPink,
      ),
      FocusItem(
        icon: CupertinoIcons.flame_fill,
        title: 'Hit your exercise goal',
        subtitle: '20 minutes left for today\'s target',
        color: primaryGreen,
      ),
    ];
  }

  @override
  Future<List<MetricItem>> getPerformanceMetrics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      MetricItem(
        label: 'Health Score',
        value: '92',
        subtext: '↑ 5 points',
        color: primaryPink,
      ),
      MetricItem(
        label: 'Consistency',
        value: '8.5',
        subtext: 'Top 15%',
        color: primaryGreen,
      ),
      MetricItem(
        label: 'Streak',
        value: '5',
        subtext: 'days',
        color: const Color(0xFFFFB946),
      ),
    ];
  }

  @override
  Future<InsightCategory> getNutritionInsights() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return InsightCategory(
      title: 'Nutrition Analysis',
      icon: CupertinoIcons.chart_pie_fill,
      color: primaryPink,
      insights: [
        InsightItem(
          icon: CupertinoIcons.chart_bar_fill,
          title: 'Macro Distribution',
          description: 'Protein: 15% (Target: 20-25%)',
          action: 'Add lean proteins to meals',
        ),
        InsightItem(
          icon: CupertinoIcons.graph_circle_fill,
          title: 'Calorie Timing',
          description: '60% calories before 4 PM',
          action: 'Better distribute daily calories',
        ),
      ],
    );
  }

  @override
  Future<InsightCategory> getExerciseInsights() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return InsightCategory(
      title: 'Exercise Impact',
      icon: CupertinoIcons.flame_fill,
      color: primaryGreen,
      insights: [
        InsightItem(
          icon: CupertinoIcons.arrow_up_right_circle_fill,
          title: 'Workout Efficiency',
          description: 'HIIT burns 30% more calories',
          action: 'Increase HIIT frequency to 3x/week',
        ),
        InsightItem(
          icon: CupertinoIcons.clock_fill,
          title: 'Optimal Timing',
          description: '45-min sessions most effective',
          action: 'Maintain 45-min workout blocks',
        ),
      ],
    );
  }

  @override
  Future<List<AnalysisItem>> getDetailedAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      AnalysisItem(
        title: 'Exercise vs. Diet Impact',
        value: '40% Exercise, 60% Diet',
        trend: 'Balanced approach',
        color: primaryGreen,
      ),
      AnalysisItem(
        title: 'Recovery Quality',
        value: 'Optimal on rest days',
        trend: 'Sleep: 7.5h avg',
        color: primaryPink,
      ),
      AnalysisItem(
        title: 'Progress Rate',
        value: '0.5kg/week',
        trend: 'Sustainable pace',
        color: const Color(0xFFFFB946),
      ),
    ];
  }

  @override
  Future<InsightCategory> getWeeklyPatterns() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return InsightCategory(
      title: 'Weekly Patterns',
      icon: CupertinoIcons.calendar,
      color: const Color(0xFFFFB946),
      insights: [
        InsightItem(
          icon: CupertinoIcons.chart_bar_alt_fill,
          title: 'Weekend Effect',
          description: '35% higher calorie intake on weekends',
          action: 'Plan weekend meals in advance',
        ),
        InsightItem(
          icon: CupertinoIcons.arrow_right_circle_fill,
          title: 'Strong Days',
          description: 'Best performance on Tuesday & Thursday',
          action: 'Schedule key workouts on strong days',
        ),
      ],
    );
  }

  @override
  Future<List<RecommendationItem>> getSmartRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      RecommendationItem(
        icon: CupertinoIcons.arrow_up_circle_fill,
        text: 'Increase protein at breakfast (target: 25-30g)',
        detail: 'Try eggs, Greek yogurt, or protein shake',
        color: primaryPink,
      ),
      RecommendationItem(
        icon: CupertinoIcons.timer,
        text: 'Schedule workouts before 10 AM',
        detail: '28% better performance in morning sessions',
        color: primaryGreen,
      ),
      RecommendationItem(
        icon: CupertinoIcons.arrow_down_circle_fill,
        text: 'Reduce evening snacking',
        detail: 'High correlation with daily calorie excess',
        color: const Color(0xFFFFB946),
      ),
    ];
  }
}