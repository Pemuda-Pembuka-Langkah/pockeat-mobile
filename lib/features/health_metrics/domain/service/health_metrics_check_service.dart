// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthMetricsCheckService {
  final FirebaseFirestore firestore;

  HealthMetricsCheckService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> hasCompletedOnboarding(String uid) async {
    try {
      final doc = await firestore.collection('health_metrics').doc(uid).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}
