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

// Generate mock class
@GenerateMocks([], customMocks: [MockSpec<AnalyticsRepository>(as: #GeneratedMockAnalyticsRepository)])
void main() {
  late MockAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
  });

  group('AnalyticsRepository', () {
    group('getFocusItems', () {
      test('should return a list of FocusItem', () async {
        // Arrange
        final List<FocusItem> mockFocusItems = [
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
            .thenAnswer((_) async => mockFocusItems);

        // Act
        final result = await mockRepository.getFocusItems();

        // Assert
        verify(mockRepository.getFocusItems()).called(1);
        expect(result, equals(mockFocusItems));
        expect(result.length, equals(2));
        expect(result[0].title, equals('Complete your protein target'));
        expect(result[1].title, equals('Hit your exercise goal'));
      });
    });

    group('getPerformanceMetrics', () {
      test('should return a list of MetricItem', () async {
        // Arrange
        final List<MetricItem> mockMetrics = [
          MetricItem(
            label: 'Health Score',
            value: '92',
            subtext: '↑ 5 points',
            color: Colors.pink,
          ),
          MetricItem(
            label: 'Consistency',
            value: '8.5',
            subtext: 'Top 15%',
            color: Colors.green,
          ),
        ];
        
        when(mockRepository.getPerformanceMetrics())
            .thenAnswer((_) async => mockMetrics);

        // Act
        final result = await mockRepository.getPerformanceMetrics();

        // Assert
        verify(mockRepository.getPerformanceMetrics()).called(1);
        expect(result, equals(mockMetrics));
        expect(result.length, equals(2));
        expect(result[0].label, equals('Health Score'));
        expect(result[1].label, equals('Consistency'));
      });
    });

    group('getNutritionInsights', () {
      test('should return an InsightCategory for nutrition', () async {
        // Arrange
        final InsightCategory mockNutritionInsights = InsightCategory(
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
            .thenAnswer((_) async => mockNutritionInsights);

        // Act
        final result = await mockRepository.getNutritionInsights();

        // Assert
        verify(mockRepository.getNutritionInsights()).called(1);
        expect(result, equals(mockNutritionInsights));
        expect(result.title, equals('Nutrition Analysis'));
        expect(result.insights.length, equals(1));
      });
    });

    group('getExerciseInsights', () {
      test('should return an InsightCategory for exercise', () async {
        // Arrange
        final InsightCategory mockExerciseInsights = InsightCategory(
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
            .thenAnswer((_) async => mockExerciseInsights);

        // Act
        final result = await mockRepository.getExerciseInsights();

        // Assert
        verify(mockRepository.getExerciseInsights()).called(1);
        expect(result, equals(mockExerciseInsights));
        expect(result.title, equals('Exercise Impact'));
        expect(result.insights.length, equals(1));
      });
    });

    group('getDetailedAnalysis', () {
      test('should return a list of AnalysisItem', () async {
        // Arrange
        final List<AnalysisItem> mockAnalysisItems = [
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
            .thenAnswer((_) async => mockAnalysisItems);

        // Act
        final result = await mockRepository.getDetailedAnalysis();

        // Assert
        verify(mockRepository.getDetailedAnalysis()).called(1);
        expect(result, equals(mockAnalysisItems));
        expect(result.length, equals(2));
        expect(result[0].title, equals('Exercise vs. Diet Impact'));
        expect(result[1].title, equals('Recovery Quality'));
      });
    });

    group('getWeeklyPatterns', () {
      test('should return an InsightCategory for weekly patterns', () async {
        // Arrange
        final InsightCategory mockWeeklyPatterns = InsightCategory(
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
            .thenAnswer((_) async => mockWeeklyPatterns);

        // Act
        final result = await mockRepository.getWeeklyPatterns();

        // Assert
        verify(mockRepository.getWeeklyPatterns()).called(1);
        expect(result, equals(mockWeeklyPatterns));
        expect(result.title, equals('Weekly Patterns'));
        expect(result.insights.length, equals(1));
      });
    });

    group('getSmartRecommendations', () {
      test('should return a list of RecommendationItem', () async {
        // Arrange
        final List<RecommendationItem> mockRecommendations = [
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
            .thenAnswer((_) async => mockRecommendations);

        // Act
        final result = await mockRepository.getSmartRecommendations();

        // Assert
        verify(mockRepository.getSmartRecommendations()).called(1);
        expect(result, equals(mockRecommendations));
        expect(result.length, equals(2));
        expect(result[0].text, contains('Increase protein at breakfast'));
        expect(result[1].text, contains('Schedule workouts'));
      });
    });
  });
}

// Mock class
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