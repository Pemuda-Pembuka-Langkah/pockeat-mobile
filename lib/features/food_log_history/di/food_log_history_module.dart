// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';

// coverage:ignore-start
/// Registers all dependencies for the Food Log History feature
class FoodLogHistoryModule {
  static void register() {
    final GetIt sl = getIt;

    sl.registerLazySingleton<FoodLogHistoryService>(
      () => FoodLogHistoryServiceImpl(
        foodScanRepository: sl<FoodScanRepository>(),
      ),
    );
  }
}
// coverage:ignore-end
