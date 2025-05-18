// lib/features/weights_history/domain/repositories/weight_history_repository_impl.dart

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:pockeat/features/weight_history/domain/models/weight_history_entry.dart';
import 'package:pockeat/features/weight_history/domain/repositories/weight_history_repository.dart';

// coverage:ignore-start
class WeightHistoryRepositoryImpl implements WeightHistoryRepository {
  final FirebaseFirestore firestore;

  WeightHistoryRepositoryImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addWeightEntry({
    required String userId,
    required double weight,
    required DateTime timestamp,
  }) async {
    try {
      final entry = WeightHistoryEntry(weight: weight, timestamp: timestamp);

      await firestore
          .collection('health_metrics')
          .doc(userId)
          .collection('weights_history')
          .add(entry.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to add weight history: ${e.message}');
    }
  }
}
// coverage:ignore-end
