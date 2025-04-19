import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';

/// Default implementation with more complex logic
class DefaultCalorieCalculationStrategy implements CalorieCalculationStrategy {
  @override
  Future<int> calculateTodayTotalCalories(
      FoodLogHistoryService foodLogHistoryService, String userId) async {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);
    return (await foodLogHistoryService.getFoodLogsByDate(
            userId, startOfDay))
        .fold<int>(0, (total, log) => total + log.calories.toInt());
  }

  @override
  Future<int> calculateTargetCalories(
      HealthMetricsRepository healthMetricsRepository,
      CaloricRequirementService caloricRequirementService,
      String userId) async {
    int targetCalories = 0;
    final healthMetrics = await healthMetricsRepository.getHealthMetrics(userId);
    if(healthMetrics != null) {
      targetCalories = caloricRequirementService.analyze(userId: userId, 
      model: healthMetrics).tdee.toInt();
    }
    return targetCalories;
  }
}
