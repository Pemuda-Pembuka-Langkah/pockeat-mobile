// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/sync_fitness_tracker/services/third_party_tracker_service.dart';

/// Module for registering sync_fitness_tracker dependencies
class SyncFitnessTrackerModule {
  /// Register all dependencies for the sync_fitness_tracker feature
  static void register() {
    final getIt = GetIt.instance;

    try {
      // Register ThirdPartyTrackerService if not already registered
      if (!getIt.isRegistered<ThirdPartyTrackerService>()) {
        final trackerService = ThirdPartyTrackerService();
        getIt.registerSingleton<ThirdPartyTrackerService>(trackerService);
        debugPrint('Registered ThirdPartyTrackerService');
      }
    } catch (e) {
      debugPrint('Error registering SyncFitnessTrackerModule dependencies: $e');
    }
  }
}
