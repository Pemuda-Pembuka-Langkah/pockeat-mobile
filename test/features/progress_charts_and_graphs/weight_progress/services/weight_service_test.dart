// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/repositories/weight_repository.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/services/weight_service.dart';
import 'weight_service_test.mocks.dart';

// Generate mocks for WeightRepository
@GenerateMocks([WeightRepository])

void main() {
  late MockWeightRepository mockRepository;
  late WeightService weightService;

  setUp(() {
    mockRepository = MockWeightRepository();
    weightService = WeightService(mockRepository);
  });

  group('WeightService', () {
    test('getWeightData delegates to repository and returns data', () async {
      // Arrange
      final expectedData = {
        'Weekly': [
          WeightData('Jan 1', 75.5, 400, 45, 'Running'),
          WeightData('Jan 8', 74.5, 460, 55, 'Weightlifting'),
        ]
      };
      when(mockRepository.getWeightData()).thenAnswer((_) async => expectedData);

      // Act
      final result = await weightService.getWeightData();

      // Assert
      expect(result, equals(expectedData));
      verify(mockRepository.getWeightData()).called(1);
    });

    test('getWeightStatus delegates to repository and returns status', () async {
      // Arrange
      final expectedStatus = WeightStatus(
        currentWeight: 74.5,
        weightLoss: 1.0,
        progressToGoal: 0.5,
        exerciseContribution: 0.7,
        dietContribution: 0.3,
        bmiValue: 23.5,
        bmiCategory: 'Healthy',
      );
      when(mockRepository.getWeightStatus()).thenAnswer((_) async => expectedStatus);

      // Act
      final result = await weightService.getWeightStatus();

      // Assert
      expect(result, equals(expectedStatus));
      verify(mockRepository.getWeightStatus()).called(1);
    });

    test('getWeightGoal delegates to repository and returns goal', () async {
      // Arrange
      final expectedGoal = WeightGoal(
        startingWeight: '75.5 kg',
        startingDate: 'Jan 1, 2025',
        targetWeight: '70.0 kg',
        targetDate: 'Mar 1, 2025',
        remainingWeight: '4.5 kg',
        daysLeft: '59 days',
        isOnTrack: true,
        insightMessage: 'You are on track to reach your goal!',
      );
      when(mockRepository.getWeightGoal()).thenAnswer((_) async => expectedGoal);

      // Act
      final result = await weightService.getWeightGoal();

      // Assert
      expect(result, equals(expectedGoal));
      verify(mockRepository.getWeightGoal()).called(1);
    });

    test('getWeeklyAnalysis delegates to repository and returns analysis', () async {
      // Arrange
      final expectedAnalysis = WeeklyAnalysis(
        weightChange: '-0.7 kg',
        caloriesBurned: '2500 kcal',
        progressRate: 'Good',
        weeklyGoalPercentage: 0.75,
      );
      when(mockRepository.getWeeklyAnalysis()).thenAnswer((_) async => expectedAnalysis);

      // Act
      final result = await weightService.getWeeklyAnalysis();

      // Assert
      expect(result, equals(expectedAnalysis));
      verify(mockRepository.getWeeklyAnalysis()).called(1);
    });

    test('getSelectedPeriod delegates to repository and returns period', () async {
      // Arrange
      const expectedPeriod = 'Weekly';
      when(mockRepository.getSelectedPeriod()).thenAnswer((_) async => expectedPeriod);

      // Act
      final result = await weightService.getSelectedPeriod();

      // Assert
      expect(result, equals(expectedPeriod));
      verify(mockRepository.getSelectedPeriod()).called(1);
    });

    test('setSelectedPeriod delegates to repository with correct period', () async {
      // Arrange
      const period = 'Monthly';
      when(mockRepository.setSelectedPeriod(period)).thenAnswer((_) async {});

      // Act
      await weightService.setSelectedPeriod(period);

      // Assert
      verify(mockRepository.setSelectedPeriod(period)).called(1);
    });
  });
}
