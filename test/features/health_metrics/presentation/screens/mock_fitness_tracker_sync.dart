import 'package:pockeat/features/sync_fitness_tracker/services/health_connect_sync.dart';

// Mock version of FitnessTrackerSync for testing
class MockFitnessTrackerSync extends FitnessTrackerSync {
  bool _isAvailable = true;

  @override
  Future<bool> isHealthConnectAvailable() async {
    return _isAvailable;
  }

  @override
  Future<bool> requestAuthorization() async {
    // Do nothing in the mock
    return true;
  }

  // For testing
  void setAvailability(bool isAvailable) {
    _isAvailable = isAvailable;
  }
}
