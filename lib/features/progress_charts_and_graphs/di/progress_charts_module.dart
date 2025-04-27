import 'package:get_it/get_it.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';

// coverage:ignore-start
class ProgressChartsModule {
  static void register() {
    // Register FoodLogDataService
    // This will use the FoodLogHistoryService that should already be registered
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