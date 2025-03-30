import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/repositories/weight_repository.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/repositories/weight_repository_impl.dart';

void main() {
  late WeightRepository repository;

  setUp(() {
    repository = WeightRepositoryImpl();
  });

  group('WeightRepositoryImpl', () {
    test('getWeightData returns map of weight data for all periods', () async {
      // Act
      final result = await repository.getWeightData();

      // Assert
      expect(result, isA<Map<String, List<WeightData>>>());
      expect(result.keys, containsAll(['Daily', 'Weekly', 'Monthly']));
      
      // Check structure of daily data
      expect(result['Daily'], isA<List<WeightData>>());
      expect(result['Daily']!.length, 14); // Based on the implementation which has 14 daily records
      
      // Verify first daily item
      final firstDailyItem = result['Daily']!.first;
      expect(firstDailyItem.label, 'Jan 1');
      expect(firstDailyItem.weight, 75.5);
      expect(firstDailyItem.caloriesBurned, 400);
      expect(firstDailyItem.exerciseMinutes, 45);
      expect(firstDailyItem.dominantExercise, 'Running');
      
      // Check weekly data
      expect(result['Weekly']!.length, 4);
      
      // Check monthly data
      expect(result['Monthly']!.length, 3);
    });

    test('getWeightStatus returns expected weight status', () async {
      // Act
      final result = await repository.getWeightStatus();

      // Assert
      expect(result, isA<WeightStatus>());
      expect(result.currentWeight, 73.0);
      expect(result.weightLoss, 2.5);
      expect(result.progressToGoal, 0.71);
      expect(result.exerciseContribution, 0.45);
      expect(result.dietContribution, 0.55);
      expect(result.bmiValue, 22.5);
      expect(result.bmiCategory, 'Healthy');
    });

    test('getWeightGoal returns expected weight goal', () async {
      // Act
      final result = await repository.getWeightGoal();

      // Assert
      expect(result, isA<WeightGoal>());
      expect(result.startingWeight, '75.5 kg');
      expect(result.startingDate, 'Dec 1, 2024');
      expect(result.targetWeight, '70.0 kg');
      expect(result.targetDate, 'Mar 1, 2025');
      expect(result.remainingWeight, '3.0 kg');
      expect(result.daysLeft, '35 days left');
      expect(result.isOnTrack, true);
      expect(result.insightMessage, 'Maintaining current activity level, you\'ll reach your goal 5 days ahead of schedule!');
    });

    test('getWeeklyAnalysis returns expected weekly analysis', () async {
      // Act
      final result = await repository.getWeeklyAnalysis();

      // Assert
      expect(result, isA<WeeklyAnalysis>());
      expect(result.weightChange, '-0.3 kg');
      expect(result.caloriesBurned, '1,200 cal');
      expect(result.progressRate, '105%');
      expect(result.weeklyGoalPercentage, 0.85);
    });

    test('getSelectedPeriod returns default "Weekly" if not changed', () async {
      // Act
      final result = await repository.getSelectedPeriod();

      // Assert
      expect(result, 'Weekly');
    });

    test('setSelectedPeriod updates the selected period', () async {
      // Arrange
      const newPeriod = 'Monthly';
      
      // Act - set new period
      await repository.setSelectedPeriod(newPeriod);
      final result = await repository.getSelectedPeriod();

      // Assert
      expect(result, newPeriod);
    });

    test('setSelectedPeriod can update to different periods', () async {
      // Test all supported periods sequentially
      for (final period in ['Daily', 'Weekly', 'Monthly']) {
        // Act
        await repository.setSelectedPeriod(period);
        final result = await repository.getSelectedPeriod();
        
        // Assert
        expect(result, period);
      }
    });
  });
}