// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';

// coverage:ignore-start
/// Registers all dependencies for the Food Log History feature
class FoodLogHistoryModule {
  static void register() {
    final sl = GetIt.instance;

    // 1) Make Firestore available in the locator if it's not already registered
    if (!sl.isRegistered<FirebaseFirestore>()) {
      sl.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
      );
    }

    // 2) Inject both the repo and the Firestore into your service
    sl.registerLazySingleton<FoodLogHistoryService>(
      () => FoodLogHistoryServiceImpl(
        foodScanRepository: sl<FoodScanRepository>(),
        firestore: sl<FirebaseFirestore>(),
      ),
    );
  }
}
// coverage:ignore-end
