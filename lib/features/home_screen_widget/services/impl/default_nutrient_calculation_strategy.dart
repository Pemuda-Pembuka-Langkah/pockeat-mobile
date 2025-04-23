// Project imports:
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import '../nutrient_calculation_strategy.dart';

/// Default implementation of nutrient calculation strategy
class DefaultNutrientCalculationStrategy
    implements NutrientCalculationStrategy {
  @override
  double calculateNutrientFromLogs(
      List<FoodLogHistoryItem> logs, String nutrientType) {
    double total = 0;

    for (final log in logs) {
      switch (nutrientType) {
        case 'protein':
          if (log.protein != null) total += log.protein!;
          break;
        case 'carbs':
          if (log.carbs != null) total += log.carbs!;
          break;
        case 'fat':
          if (log.fat != null) total += log.fat!;
          break;
      }
    }

    return total;
  }
}
