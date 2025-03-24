import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/analysis_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/focus_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_category.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/recommendation_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/repositories/analytics_repository.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/services/analytics_service.dart';

@GenerateMocks([AnalyticsRepository])
void main() {
  late MockAnalyticsRepository mockRepository;
  late AnalyticsService service;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    service = AnalyticsService(mockRepository);
  });

  group('AnalyticsService', () {
    test('should be created with a repository', () {
      // Assert
      expect(service, isA<AnalyticsService>());
    });

    group('getFocusItems', () {
      test('should return focus items from repository', () async {
        // Arrange
        final expectedFocusItems = [
          FocusItem(
            icon: CupertinoIcons.heart_fill,
            title: 'Complete your protein target',
            subtitle: '15g remaining to reach 120g daily goal',
            color: Colors.red,
          ),
          FocusItem(
            icon: CupertinoIcons.flame_fill,
            title: 'Hit your exercise goal',
            subtitle: '20 minutes left for today\'s target',
            color: Colors.green,
          ),
        ];
        
        when(mockRepository.getFocusItems())
            .thenAnswer((_) async => expectedFocusItems);

        // Act
        final result = await service.getFocusItems();

        // Assert
        verify(mockRepository.getFocusItems()).called(1);
        expect(result, equals(expectedFocusItems));
      });
    });

    group('getPerformanceMetrics', () {
      test('should return performance metrics from repository', () async {
        // Arrange
        final expectedMetrics = [
          MetricItem(
            label: 'Health Score',
            value: '92',
            subtext: '↑ 5 points',
            color: Colors.green,
          ),
          MetricItem(
            label: 'Consistency',
            value: '8.5',
            subtext: 'Top 15%',
            color: Colors.blue,
          ),
        ];
        
        when(mockRepository.getPerformanceMetrics())
            .thenAnswer((_) async => expectedMetrics);

        // Act
        final result = await service.getPerformanceMetrics();

        // Assert
        verify(mockRepository.getPerformanceMetrics()).called(1);
        expect(result, equals(expectedMetrics));
      });
    });

    group('getNutritionInsights', () {
      test('should return nutrition insights from repository', () async {
        // Arrange
        final expectedInsights = InsightCategory(
          title: 'Nutrition Analysis',
          icon: CupertinoIcons.chart_pie_fill,
          color: Colors.pink,
          insights: [
            InsightItem(
              icon: CupertinoIcons.chart_bar_fill,
              title: 'Macro Distribution',
              description: 'Protein: 15% (Target: 20-25%)',
              action: 'Add lean proteins to meals',
            ),
          ],
        );
        
        when(mockRepository.getNutritionInsights())
            .thenAnswer((_) async => expectedInsights);

        // Act
        final result = await service.getNutritionInsights();

        // Assert
        verify(mockRepository.getNutritionInsights()).called(1);
        expect(result, equals(expectedInsights));
      });
    });

    group('getExerciseInsights', () {
      test('should return exercise insights from repository', () async {
        // Arrange
        final expectedInsights = InsightCategory(
          title: 'Exercise Impact',
          icon: CupertinoIcons.flame_fill,
          color: Colors.green,
          insights: [
            InsightItem(
              icon: CupertinoIcons.arrow_up_right_circle_fill,
              title: 'Workout Efficiency',
              description: 'HIIT burns 30% more calories',
              action: 'Increase HIIT frequency to 3x/week',
            ),
          ],
        );
        
        when(mockRepository.getExerciseInsights())
            .thenAnswer((_) async => expectedInsights);

        // Act
        final result = await service.getExerciseInsights();

        // Assert
        verify(mockRepository.getExerciseInsights()).called(1);
        expect(result, equals(expectedInsights));
      });
    });

    group('getDetailedAnalysis', () {
      test('should return detailed analysis from repository', () async {
        // Arrange
        final expectedAnalysis = [
          AnalysisItem(
            title: 'Exercise vs. Diet Impact',
            value: '40% Exercise, 60% Diet',
            trend: 'Balanced approach',
            color: Colors.green,
          ),
          AnalysisItem(
            title: 'Recovery Quality',
            value: 'Optimal on rest days',
            trend: 'Sleep: 7.5h avg',
            color: Colors.pink,
          ),
        ];
        
        when(mockRepository.getDetailedAnalysis())
            .thenAnswer((_) async => expectedAnalysis);

        // Act
        final result = await service.getDetailedAnalysis();

        // Assert
        verify(mockRepository.getDetailedAnalysis()).called(1);
        expect(result, equals(expectedAnalysis));
      });
    });

    group('getWeeklyPatterns', () {
      test('should return weekly patterns from repository', () async {
        // Arrange
        final expectedPatterns = InsightCategory(
          title: 'Weekly Patterns',
          icon: CupertinoIcons.calendar,
          color: Colors.orange,
          insights: [
            InsightItem(
              icon: CupertinoIcons.chart_bar_alt_fill,
              title: 'Weekend Effect',
              description: '35% higher calorie intake on weekends',
              action: 'Plan weekend meals in advance',
            ),
          ],
        );
        
        when(mockRepository.getWeeklyPatterns())
            .thenAnswer((_) async => expectedPatterns);

        // Act
        final result = await service.getWeeklyPatterns();

        // Assert
        verify(mockRepository.getWeeklyPatterns()).called(1);
        expect(result, equals(expectedPatterns));
      });
    });

    group('getSmartRecommendations', () {
      test('should return smart recommendations from repository', () async {
        // Arrange
        final expectedRecommendations = [
          RecommendationItem(
            icon: CupertinoIcons.arrow_up_circle_fill,
            text: 'Increase protein at breakfast (target: 25-30g)',
            detail: 'Try eggs, Greek yogurt, or protein shake',
            color: Colors.pink,
          ),
          RecommendationItem(
            icon: CupertinoIcons.timer,
            text: 'Schedule workouts before 10 AM',
            detail: '28% better performance in morning sessions',
            color: Colors.green,
          ),
        ];
        
        when(mockRepository.getSmartRecommendations())
            .thenAnswer((_) async => expectedRecommendations);

        // Act
        final result = await service.getSmartRecommendations();

        // Assert
        verify(mockRepository.getSmartRecommendations()).called(1);
        expect(result, equals(expectedRecommendations));
      });
    });
  });
}

// Mock class implementation to handle mockito calls
class MockAnalyticsRepository extends Mock implements AnalyticsRepository {
  @override
  Future<List<FocusItem>> getFocusItems() => super.noSuchMethod(
        Invocation.method(#getFocusItems, []),
        returnValue: Future.value(<FocusItem>[]),
      ) as Future<List<FocusItem>>;

  @override
  Future<List<MetricItem>> getPerformanceMetrics() => super.noSuchMethod(
        Invocation.method(#getPerformanceMetrics, []),
        returnValue: Future.value(<MetricItem>[]),
      ) as Future<List<MetricItem>>;

  @override
  Future<InsightCategory> getNutritionInsights() => super.noSuchMethod(
        Invocation.method(#getNutritionInsights, []),
        returnValue: Future.value(InsightCategory(
          title: '',
          icon: CupertinoIcons.circle,
          color: Colors.black,
          insights: [],
        )),
      ) as Future<InsightCategory>;

  @override
  Future<InsightCategory> getExerciseInsights() => super.noSuchMethod(
        Invocation.method(#getExerciseInsights, []),
        returnValue: Future.value(InsightCategory(
          title: '',
          icon: CupertinoIcons.circle,
          color: Colors.black,
          insights: [],
        )),
      ) as Future<InsightCategory>;

  @override
  Future<List<AnalysisItem>> getDetailedAnalysis() => super.noSuchMethod(
        Invocation.method(#getDetailedAnalysis, []),
        returnValue: Future.value(<AnalysisItem>[]),
      ) as Future<List<AnalysisItem>>;

  @override
  Future<InsightCategory> getWeeklyPatterns() => super.noSuchMethod(
        Invocation.method(#getWeeklyPatterns, []),
        returnValue: Future.value(InsightCategory(
          title: '',
          icon: CupertinoIcons.circle,
          color: Colors.black,
          insights: [],
        )),
      ) as Future<InsightCategory>;

  @override
  Future<List<RecommendationItem>> getSmartRecommendations() => super.noSuchMethod(
        Invocation.method(#getSmartRecommendations, []),
        returnValue: Future.value(<RecommendationItem>[]),
      ) as Future<List<RecommendationItem>>;
}