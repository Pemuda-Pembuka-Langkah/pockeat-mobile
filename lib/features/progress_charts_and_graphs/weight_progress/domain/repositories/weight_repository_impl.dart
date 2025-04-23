import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/repositories/weight_repository.dart';

class WeightRepositoryImpl implements WeightRepository {
  String _selectedPeriod = 'Weekly';

  // Mock data for weight progress
  final Map<String, List<WeightData>> _periodData = {
    'Daily': [
      WeightData('Jan 1', 75.5, 400, 45, 'Running'),
      WeightData('Jan 2', 75.4, 350, 60, 'Weightlifting'),
      WeightData('Jan 3', 75.3, 300, 30, 'HIIT'),
      WeightData('Jan 4', 75.1, 450, 50, 'Running'),
      WeightData('Jan 5', 75.0, 500, 65, 'Weightlifting'),
      WeightData('Jan 6', 74.8, 380, 40, 'HIIT'),
      WeightData('Jan 7', 74.7, 420, 45, 'Running'),
      WeightData('Jan 8', 74.5, 460, 55, 'Weightlifting'),
      WeightData('Jan 9', 74.3, 350, 35, 'HIIT'),
      WeightData('Jan 10', 74.2, 400, 45, 'Running'),
      WeightData('Jan 11', 74.0, 480, 60, 'Weightlifting'),
      WeightData('Jan 12', 73.8, 320, 30, 'HIIT'),
      WeightData('Jan 13', 73.6, 440, 50, 'Running'),
      WeightData('Jan 14', 73.4, 500, 65, 'Weightlifting'),
    ],
    'Weekly': [
      WeightData('Week 1', 75.5, 1200, 180, 'Running'),
      WeightData('Week 2', 74.8, 1500, 210, 'Weightlifting'),
      WeightData('Week 3', 74.0, 1800, 240, 'Running'),
      WeightData('Week 4', 73.4, 1600, 200, 'HIIT'),
    ],
    'Monthly': [
      WeightData('Nov', 76.0, 4800, 600, 'Mixed'),
      WeightData('Dec', 75.0, 5200, 680, 'Mixed'),
      WeightData('Jan', 73.4, 6100, 830, 'Mixed'),
    ],
  };

  @override
  Future<Map<String, List<WeightData>>> getWeightData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _periodData;
  }

  @override
  Future<WeightStatus> getWeightStatus() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    return WeightStatus(
      currentWeight: 73.0,
      weightLoss: 2.5,
      progressToGoal: 0.71,
      exerciseContribution: 0.45,
      dietContribution: 0.55,
      bmiValue: 22.5,
      bmiCategory: 'Healthy',
    );
  }

  @override
  Future<WeightGoal> getWeightGoal() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    return WeightGoal(
      startingWeight: '75.5 kg',
      startingDate: 'Dec 1, 2024',
      targetWeight: '70.0 kg',
      targetDate: 'Mar 1, 2025',
      remainingWeight: '3.0 kg',
      daysLeft: '35 days left',
      isOnTrack: true,
      insightMessage:
          'Maintaining current activity level, you\'ll reach your goal 5 days ahead of schedule!',
    );
  }

  @override
  Future<WeeklyAnalysis> getWeeklyAnalysis() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    return WeeklyAnalysis(
      weightChange: '-0.3 kg',
      caloriesBurned: '1,200 cal',
      progressRate: '105%',
      weeklyGoalPercentage: 0.85,
    );
  }

  @override
  Future<String> getSelectedPeriod() async {
    return _selectedPeriod;
  }

  @override
  Future<void> setSelectedPeriod(String period) async {
    _selectedPeriod = period;
  }
}
