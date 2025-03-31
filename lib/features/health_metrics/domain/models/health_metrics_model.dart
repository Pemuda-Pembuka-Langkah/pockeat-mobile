import 'package:cloud_firestore/cloud_firestore.dart';

class HealthMetricsModel {
  final String userId; // Firestore doc ID

  final double height; // in "cm"

  final double weight; // in "kg"

  final int age; // year old

  final String fitnessGoal;

  HealthMetricsModel({
    required this.userId,
    required this.height,
    required this.weight,
    required this.age,
    required this.fitnessGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'height': height,
      'weight': weight,
      'age': age,
      'fitnessGoal': fitnessGoal,
    };
  }

  factory HealthMetricsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HealthMetricsModel(
      userId: doc.id, // Firestore doc ID should be the userId
      height: (data['height'] as num).toDouble(),
      weight: (data['weight'] as num).toDouble(),
      age: data['age'] as int,
      fitnessGoal: data['fitnessGoal'] as String,
    );
  }
}