import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/repositories/weight_repository.dart';

// Generate mocks for the WeightRepository
@GenerateMocks([WeightRepository])
import 'weight_repository_test.mocks.dart';

void main() {
  late MockWeightRepository mockRepository;

  setUp(() {
    mockRepository = MockWeightRepository();
  });

  group('WeightRepository', () {
    test('getWeightData returns Map of weight data', () async {
      // Arrange
      final weightData = {
        'Weekly': [
          WeightData('Jan 1', 75.5, 400, 45, 'Running'),
          WeightData('Jan 8', 74.5, 460, 55, 'Weightlifting'),
        ]
      };
      when(mockRepository.getWeightData()).thenAnswer((_) async => weightData);

      // Act
      final result = await mockRepository.getWeightData();

      // Assert
      expect(result, equals(weightData));
      verify(mockRepository.getWeightData()).called(1);
    });

    test('getWeightStatus returns weight status', () async {
      // Arrange
      final weightStatus = WeightStatus(
        currentWeight: 74.5,
        weightLoss: 1.0,
        progressToGoal: 0.5,
        exerciseContribution: 0.7,
        dietContribution: 0.3,
        bmiValue: 23.5,
        bmiCategory: 'Healthy',
      );
      when(mockRepository.getWeightStatus()).thenAnswer((_) async => weightStatus);

      // Act
      final result = await mockRepository.getWeightStatus();

      // Assert
      expect(result, equals(weightStatus));
      verify(mockRepository.getWeightStatus()).called(1);
    });

    test('getWeightGoal returns weight goal', () async {
      // Arrange
      final weightGoal = WeightGoal(
        startingWeight: '75.5 kg',
        startingDate: 'Jan 1, 2025',
        targetWeight: '70.0 kg',
        targetDate: 'Mar 1, 2025',
        remainingWeight: '4.5 kg',
        daysLeft: '59 days',
        isOnTrack: true,
        insightMessage: 'You are on track to reach your goal!',
      );
      when(mockRepository.getWeightGoal()).thenAnswer((_) async => weightGoal);

      // Act
      final result = await mockRepository.getWeightGoal();

      // Assert
      expect(result, equals(weightGoal));
      verify(mockRepository.getWeightGoal()).called(1);
    });

    test('getWeeklyAnalysis returns weekly analysis', () async {
      // Arrange
      final weeklyAnalysis = WeeklyAnalysis(
        weightChange: '-0.7 kg',
        caloriesBurned: '2500 kcal',
        progressRate: 'Good',
        weeklyGoalPercentage: 0.75,
      );
      when(mockRepository.getWeeklyAnalysis()).thenAnswer((_) async => weeklyAnalysis);

      // Act
      final result = await mockRepository.getWeeklyAnalysis();

      // Assert
      expect(result, equals(weeklyAnalysis));
      verify(mockRepository.getWeeklyAnalysis()).called(1);
    });

    test('getSelectedPeriod returns selected period string', () async {
      // Arrange
      const period = 'Weekly';
      when(mockRepository.getSelectedPeriod()).thenAnswer((_) async => period);

      // Act
      final result = await mockRepository.getSelectedPeriod();

      // Assert
      expect(result, equals(period));
      verify(mockRepository.getSelectedPeriod()).called(1);
    });

    test('setSelectedPeriod completes successfully', () async {
      // Arrange
      const period = 'Monthly';
      when(mockRepository.setSelectedPeriod(period)).thenAnswer((_) async {});

      // Act
      await mockRepository.setSelectedPeriod(period);

      // Assert
      verify(mockRepository.setSelectedPeriod(period)).called(1);
    });
  });
}