// lib/features/health_metrics/caloric_requirement/domain/repositories/caloric_requirement_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
import 'caloric_requirement_repository.dart';

class CaloricRequirementRepositoryImpl implements CaloricRequirementRepository {
  final FirebaseFirestore firestore;

  CaloricRequirementRepositoryImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveCaloricRequirement({
    required String userId,
    required CaloricRequirementModel result,
  }) async {
    try {
      await firestore
          .collection('caloric_requirements')
          .doc(userId)
          .set(result.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save caloric requirement: $e');
    }
  }

  @override
  Future<CaloricRequirementModel?> getCaloricRequirement(String userId) async {
    try {
      final doc = await firestore.collection('caloric_requirements').doc(userId).get();
      if (!doc.exists) return null;

      return CaloricRequirementModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch caloric requirement: $e');
    }
  }
}