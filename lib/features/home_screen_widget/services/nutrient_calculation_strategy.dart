// Project imports:
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';

/// Strategy interface for calculating nutrients from food logs
abstract class NutrientCalculationStrategy {
  /// Generic method to calculate any nutrient type from a list of food logs
  double calculateNutrientFromLogs(
      List<FoodLogHistoryItem> logs, String nutrientType);
}
