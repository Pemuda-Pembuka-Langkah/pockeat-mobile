// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';

// coverage:ignore-start
class ProgressModule {
  static void register() {
    // Register FoodLogDataService
    if (!getIt.isRegistered<FoodLogDataService>()) {
      getIt.registerLazySingleton<FoodLogDataService>(
        () => FoodLogDataService(
          foodLogService: getIt<FoodLogHistoryService>(),
        ),
      );
    }
  }
}
// coverage:ignore-end
