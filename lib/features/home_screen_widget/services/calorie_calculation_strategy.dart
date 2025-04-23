import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';

/// Unified calorie calculation strategy interface
abstract class CalorieCalculationStrategy {
  /// Calculate total consumed calories from food logs
  Future<int> calculateTodayTotalCalories(
      FoodLogHistoryService foodLogHistoryService, String userId);

  /// Calculate target calories for a user
  Future<int> calculateTargetCalories(
      HealthMetricsRepository healthMetricsRepository,
      CaloricRequirementService caloricRequirementService,
      String userId);
}
