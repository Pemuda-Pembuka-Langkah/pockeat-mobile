import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_log_history/di/food_log_history_module.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';

// Mock classes
class MockFoodScanRepository extends Mock implements FoodScanRepository {}
class MockFoodTextInputRepository extends Mock implements FoodTextInputRepository {}
class MockFoodLogHistoryService extends Mock implements FoodLogHistoryService {}

void main() {
  group('FoodLogHistoryModule', () {
    late GetIt sl;
    late MockFoodScanRepository mockFoodScanRepository;
    late MockFoodTextInputRepository mockFoodTextInputRepository;

    setUp(() {
      // Reset service locator before each test
      serviceLocatorReset();
      sl = getIt;

      // Register mocks
      mockFoodScanRepository = MockFoodScanRepository();
      mockFoodTextInputRepository = MockFoodTextInputRepository();
      sl.registerSingleton<FirebaseFirestore>(FakeFirebaseFirestore());
      sl.registerSingleton<FoodScanRepository>(mockFoodScanRepository);
      sl.registerSingleton<FoodTextInputRepository>(mockFoodTextInputRepository);
    });

    test('register should register FoodLogHistoryService', () {
      // Act
      FoodLogHistoryModule.register();

      // Assert
      expect(sl.isRegistered<FoodLogHistoryService>(), true);

      // Verify the service is registered as a lazy singleton
      final instance = sl<FoodLogHistoryService>();

      expect(instance, isA<FoodLogHistoryService>());
    });
  });
}

// Helper function to reset service locator
void serviceLocatorReset() {
  final GetIt sl = GetIt.instance;
  if (sl.isRegistered<FoodScanRepository>()) {
    sl.unregister<FoodScanRepository>();
  }
  if (sl.isRegistered<FoodTextInputRepository>()) {
    sl.unregister<FoodTextInputRepository>();
  }
  if (sl.isRegistered<FoodLogHistoryService>()) {
    sl.unregister<FoodLogHistoryService>();
  }
}
