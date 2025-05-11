// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class CaloricRequirementModel {
  final String userId; // Firestore doc ID
  final double bmr;
  final double tdee;
  final DateTime timestamp;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;


  CaloricRequirementModel({
    required this.userId,
    required this.bmr,
    required this.tdee,
    required this.timestamp,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bmr': bmr,
      'tdee': tdee,
      'timestamp': timestamp.toIso8601String(),
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams, 
      'fatGrams': fatGrams,

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
      proteinGrams: (data['proteinGrams'] as num).toDouble(),
      carbsGrams: (data['carbsGrams'] as num).toDouble(),
      fatGrams: (data['fatGrams'] as num).toDouble(),
    );
  }
}
