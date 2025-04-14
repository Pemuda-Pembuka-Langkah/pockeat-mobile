import 'package:cloud_firestore/cloud_firestore.dart';

class CaloricRequirementModel {
  final String userId; // Firestore doc ID
  final double bmr;
  final double tdee;
  final DateTime timestamp;

  CaloricRequirementModel({
    required this.userId,
    required this.bmr,
    required this.tdee,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bmr': bmr,
      'tdee': tdee,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CaloricRequirementModel.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    if (rawData == null) throw Exception("Document data is null");

    final data = rawData as Map<String, dynamic>;
    return CaloricRequirementModel(
      userId: doc.id,
      bmr: (data['bmr'] as num).toDouble(),
      tdee: (data['tdee'] as num).toDouble(),
      timestamp: DateTime.parse(data['timestamp']),
    );
  }
}