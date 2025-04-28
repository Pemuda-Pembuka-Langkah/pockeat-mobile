// lib/features/saved_meals/models/saved_meal.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class SavedMeal {
  final String id;
  final String userId;
  final String name;
  final FoodAnalysisResult foodAnalysis;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedMeal({
    required this.id,
    required this.userId,
    required this.name,
    required this.foodAnalysis,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from Firestore document
  factory SavedMeal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedMeal(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Unnamed meal',
      foodAnalysis: FoodAnalysisResult.fromJson(data['foodAnalysis'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'foodAnalysis': foodAnalysis.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy of this SavedMeal with optional field modifications
  SavedMeal copyWith({
    String? id,
    String? userId,
    String? name,
    FoodAnalysisResult? foodAnalysis,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedMeal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      foodAnalysis: foodAnalysis ?? this.foodAnalysis,
      createdAt: createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? DateTime.now(), // Default to current time when updating
    );
  }
}
