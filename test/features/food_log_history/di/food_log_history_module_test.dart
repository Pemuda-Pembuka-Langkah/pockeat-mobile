import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_log_history/di/food_log_history_module.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';

// Mock classes
class MockFoodScanRepository extends Mock implements FoodScanRepository {}

void main() {
  group('FoodLogHistoryModule', () {
    late GetIt sl;
    late MockFoodScanRepository mockFoodScanRepository;

    setUp(() {
      // Reset service locator before each test
      serviceLocatorReset();
      sl = getIt;

      // Register mocks
      mockFoodScanRepository = MockFoodScanRepository();
      sl.registerSingleton<FoodScanRepository>(mockFoodScanRepository);
    });

    test('register should register FoodLogHistoryService', () {
      // Act
      FoodLogHistoryModule.register();

      // Assert
      expect(sl.isRegistered<FoodLogHistoryService>(), true);

      // Verify the service is registered as a lazy singleton
      final instance = sl<FoodLogHistoryService>();
      expect(instance, isNotNull);
    });
  });
}

// Helper function to reset service locator
void serviceLocatorReset() {
  final GetIt sl = GetIt.instance;
  if (sl.isRegistered<FoodScanRepository>()) {
    sl.unregister<FoodScanRepository>();
  }
  if (sl.isRegistered<FoodLogHistoryService>()) {
    sl.unregister<FoodLogHistoryService>();
  }
}
