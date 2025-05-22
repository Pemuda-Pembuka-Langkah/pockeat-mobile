// coverage:ignore-start
abstract class WeightHistoryRepository {
  Future<void> addWeightEntry({
    required String userId,
    required double weight,
    required DateTime timestamp,
  });
}
// coverage:ignore-end
