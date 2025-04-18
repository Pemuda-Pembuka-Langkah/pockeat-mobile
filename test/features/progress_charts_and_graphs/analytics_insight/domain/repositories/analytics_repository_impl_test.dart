import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/recommendation_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/repositories/analytics_repository_impl.dart';

void main() {
  late AnalyticsRepositoryImpl repository;

  setUp(() {
    repository = AnalyticsRepositoryImpl();
  });

  group('AnalyticsRepositoryImpl', () {
    test('should initialize with correct color constants', () {
      expect(repository.primaryYellow, equals(const Color(0xFFFFE893)));
      expect(repository.primaryPink, equals(const Color(0xFFFF6B6B)));
      expect(repository.primaryGreen, equals(const Color(0xFF4ECDC4)));
    });

    group('getFocusItems', () {
      test('should return the correct list of focus items', () async {
        // Act
        final result = await repository.getFocusItems();

        // Assert
        expect(result, isA<List<FocusItem>>());
        expect(result.length, 2);
        
        expect(result[0].icon, CupertinoIcons.heart_fill);
        expect(result[0].title, 'Complete your protein target');
        expect(result[0].subtitle, '15g remaining to reach 120g daily goal');
        expect(result[0].color, repository.primaryPink);

        expect(result[1].icon, CupertinoIcons.flame_fill);
        expect(result[1].title, 'Hit your exercise goal');
        expect(result[1].subtitle, '20 minutes left for today\'s target');
        expect(result[1].color, repository.primaryGreen);
      });
    });

    group('getPerformanceMetrics', () {
      test('should return the correct list of performance metrics', () async {
        // Act
        final result = await repository.getPerformanceMetrics();

        // Assert
        expect(result, isA<List<MetricItem>>());
        expect(result.length, 3);
        
        expect(result[0].label, 'Health Score');
        expect(result[0].value, '92');
        expect(result[0].subtext, '↑ 5 points');
        expect(result[0].color, repository.primaryPink);

        expect(result[1].label, 'Consistency');
        expect(result[1].value, '8.5');
        expect(result[1].subtext, 'Top 15%');
        expect(result[1].color, repository.primaryGreen);

        expect(result[2].label, 'Streak');
        expect(result[2].value, '5');
        expect(result[2].subtext, 'days');
        expect(result[2].color, const Color(0xFFFFB946));
      });
    });

    group('getNutritionInsights', () {
      test('should return the correct nutrition insights category', () async {
        // Act
        final result = await repository.getNutritionInsights();

        // Assert
        expect(result, isA<InsightCategory>());
        expect(result.title, 'Nutrition Analysis');
        expect(result.icon, CupertinoIcons.chart_pie_fill);
        expect(result.color, repository.primaryPink);
        expect(result.insights.length, 2);
        
        expect(result.insights[0].icon, CupertinoIcons.chart_bar_fill);
        expect(result.insights[0].title, 'Macro Distribution');
        expect(result.insights[0].description, 'Protein: 15% (Target: 20-25%)');
        expect(result.insights[0].action, 'Add lean proteins to meals');

        expect(result.insights[1].icon, CupertinoIcons.graph_circle_fill);
        expect(result.insights[1].title, 'Calorie Timing');
        expect(result.insights[1].description, '60% calories before 4 PM');
        expect(result.insights[1].action, 'Better distribute daily calories');
      });
    });

    group('getExerciseInsights', () {
      test('should return the correct exercise insights category', () async {
        // Act
        final result = await repository.getExerciseInsights();

        // Assert
        expect(result, isA<InsightCategory>());
        expect(result.title, 'Exercise Impact');
        expect(result.icon, CupertinoIcons.flame_fill);
        expect(result.color, repository.primaryGreen);
        expect(result.insights.length, 2);
        
        expect(result.insights[0].icon, CupertinoIcons.arrow_up_right_circle_fill);
        expect(result.insights[0].title, 'Workout Efficiency');
        expect(result.insights[0].description, 'HIIT burns 30% more calories');
        expect(result.insights[0].action, 'Increase HIIT frequency to 3x/week');

        expect(result.insights[1].icon, CupertinoIcons.clock_fill);
        expect(result.insights[1].title, 'Optimal Timing');
        expect(result.insights[1].description, '45-min sessions most effective');
        expect(result.insights[1].action, 'Maintain 45-min workout blocks');
      });
    });

    group('getDetailedAnalysis', () {
      test('should return the correct list of detailed analysis items', () async {
        // Act
        final result = await repository.getDetailedAnalysis();

        // Assert
        expect(result, isA<List<AnalysisItem>>());
        expect(result.length, 3);
        
        expect(result[0].title, 'Exercise vs. Diet Impact');
        expect(result[0].value, '40% Exercise, 60% Diet');
        expect(result[0].trend, 'Balanced approach');
        expect(result[0].color, repository.primaryGreen);

        expect(result[1].title, 'Recovery Quality');
        expect(result[1].value, 'Optimal on rest days');
        expect(result[1].trend, 'Sleep: 7.5h avg');
        expect(result[1].color, repository.primaryPink);

        expect(result[2].title, 'Progress Rate');
        expect(result[2].value, '0.5kg/week');
        expect(result[2].trend, 'Sustainable pace');
        expect(result[2].color, const Color(0xFFFFB946));
      });
    });

    group('getWeeklyPatterns', () {
      test('should return the correct weekly patterns category', () async {
        // Act
        final result = await repository.getWeeklyPatterns();

        // Assert
        expect(result, isA<InsightCategory>());
        expect(result.title, 'Weekly Patterns');
        expect(result.icon, CupertinoIcons.calendar);
        expect(result.color, const Color(0xFFFFB946));
        expect(result.insights.length, 2);
        
        expect(result.insights[0].icon, CupertinoIcons.chart_bar_alt_fill);
        expect(result.insights[0].title, 'Weekend Effect');
        expect(result.insights[0].description, '35% higher calorie intake on weekends');
        expect(result.insights[0].action, 'Plan weekend meals in advance');

        expect(result.insights[1].icon, CupertinoIcons.arrow_right_circle_fill);
        expect(result.insights[1].title, 'Strong Days');
        expect(result.insights[1].description, 'Best performance on Tuesday & Thursday');
        expect(result.insights[1].action, 'Schedule key workouts on strong days');
      });
    });

    group('getSmartRecommendations', () {
      test('should return the correct list of recommendation items', () async {
        // Act
        final result = await repository.getSmartRecommendations();

        // Assert
        expect(result, isA<List<RecommendationItem>>());
        expect(result.length, 3);
        
        expect(result[0].icon, CupertinoIcons.arrow_up_circle_fill);
        expect(result[0].text, 'Increase protein at breakfast (target: 25-30g)');
        expect(result[0].detail, 'Try eggs, Greek yogurt, or protein shake');
        expect(result[0].color, repository.primaryPink);

        expect(result[1].icon, CupertinoIcons.timer);
        expect(result[1].text, 'Schedule workouts before 10 AM');
        expect(result[1].detail, '28% better performance in morning sessions');
        expect(result[1].color, repository.primaryGreen);

        expect(result[2].icon, CupertinoIcons.arrow_down_circle_fill);
        expect(result[2].text, 'Reduce evening snacking');
        expect(result[2].detail, 'High correlation with daily calorie excess');
        expect(result[2].color, const Color(0xFFFFB946));
      });
    });
  });
}