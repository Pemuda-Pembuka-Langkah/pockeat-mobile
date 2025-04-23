import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';

class HealthMetricsRepositoryImpl implements HealthMetricsRepository {
  final FirebaseFirestore firestore;

  HealthMetricsRepositoryImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveHealthMetrics(HealthMetricsModel metrics) async {
    try {
      await firestore
          .collection('health_metrics')
          .doc(metrics.userId)
          .set(metrics.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Failed to save health metrics: ${e.message}');
    }
  }

  @override
  Future<HealthMetricsModel?> getHealthMetrics(String userId) async {
    try {
      final doc =
          await firestore.collection('health_metrics').doc(userId).get();

      if (!doc.exists) return null;

      return HealthMetricsModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch health metrics: ${e.message}');
    }
  }
}
