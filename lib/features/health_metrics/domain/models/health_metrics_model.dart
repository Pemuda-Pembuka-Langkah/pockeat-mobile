// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthMetricsModel {
  final String userId; // Firestore doc ID

  final double height; // in "cm"

  final double weight; // in "kg"

  final int age; // year old

  final String gender; // male or female

  // sedentary, light, moderate, active, very active, extra active
  final String activityLevel;

  final String fitnessGoal;

  final double bmi; // User's BMI calculated from height and weight

  final String bmiCategory; // Category based on BMI value

  final double desiredWeight; // User's desired weight based on their input

  HealthMetricsModel({
    required this.userId,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.fitnessGoal,
    required this.bmi,
    required this.bmiCategory,
    required this.desiredWeight,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'fitnessGoal': fitnessGoal,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'desiredWeight': desiredWeight,
    };
  }

  factory HealthMetricsModel.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    if (rawData == null) throw Exception("Document data is null");

    final data = rawData as Map<String, dynamic>;
    return HealthMetricsModel(
      userId: doc.id,
      height: (data['height'] as num).toDouble(),
      weight: (data['weight'] as num).toDouble(),
      age: data['age'] as int,
      gender: data['gender'] as String,
      activityLevel: data['activityLevel'] as String,
      fitnessGoal: data['fitnessGoal'] as String,
      bmi: (data['bmi'] as num).toDouble(),
      bmiCategory: data['bmiCategory'] as String,
      desiredWeight: (data['desiredWeight'] as num).toDouble(),
    );
  }
}
