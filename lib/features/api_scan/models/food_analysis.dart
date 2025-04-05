// lib/pockeat/features/ai_api_scan/models/food_analysis.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:uuid/uuid.dart';

class FoodAnalysisResult {
  final String foodName;
  final List<Ingredient> ingredients;
  final NutritionInfo nutritionInfo;
  final List<String> warnings;
  String? foodImageUrl;
  final DateTime timestamp;
  final String id;
  final bool isLowConfidence; // Added low confidence flag

  // Constants for warning messages to ensure consistency
  static const String highSodiumWarning = "High sodium content";
  static const String highSugarWarning = "High sugar content";
  static const String lowConfidenceWarning =
      "Analysis confidence is low - nutrition values may be less accurate";

  // Thresholds for warnings
  static const double highSodiumThreshold = 500.0; // mg
  static const double highSugarThreshold = 20.0; // g

  FoodAnalysisResult({
    required this.foodName,
    required this.ingredients,
    required this.nutritionInfo,
    this.warnings = const [],
    this.foodImageUrl,
    DateTime? timestamp,
    String? id,
    this.isLowConfidence = false, // Default to high confidence
  })  : timestamp = timestamp ?? DateTime.now(),
        id = id ?? const Uuid().v4();

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json, {String? id}) {
    // Check if response contains error field
    if (json.containsKey('error')) {
      String errorMessage = json['error'] is String
          ? json['error']
          : json['error'] is Map
              ? (json['error']['message'] ?? 'Unknown error')
              : 'Unknown error';
      throw ApiServiceException(errorMessage);
    }

    final nutritionInfo = NutritionInfo.fromJson(json['nutrition_info'] ?? {});

    // Generate warnings for high sodium or sugar if not provided in the JSON
    List<String> warnings = [];

    // If warnings are provided in the JSON, use those
    if (json['warnings'] != null) {
      warnings = List<String>.from(json['warnings']);
    }
    // Otherwise generate warnings based on nutrition values
    else {
      if (nutritionInfo.sodium > highSodiumThreshold) {
        warnings.add(highSodiumWarning);
      }
      if (nutritionInfo.sugar > highSugarThreshold) {
        warnings.add(highSugarWarning);
      }
    }

    DateTime parsedTimestamp;
    if (json['timestamp'] != null) {
      // Handle different timestamp formats
      if (json['timestamp'] is Timestamp) {
        parsedTimestamp = (json['timestamp'] as Timestamp).toDate();
      } else if (json['timestamp'] is int) {
        parsedTimestamp =
            DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int);
      } else if (json['timestamp'] is String) {
        try {
          parsedTimestamp = DateTime.parse(json['timestamp'] as String);
        } catch (e) {
          parsedTimestamp = DateTime.now();
        }
      } else {
        parsedTimestamp = DateTime.now();
      }
    } else {
      parsedTimestamp = DateTime.now();
    }

    // Check for low confidence flag
    bool isLowConfidence = json['is_low_confidence'] == true;

    return FoodAnalysisResult(
      foodName: json['food_name'] ?? '',
      ingredients: _parseIngredients(json['ingredients']),
      nutritionInfo: nutritionInfo,
      warnings: warnings,
      foodImageUrl: json['food_image_url'],
      timestamp: parsedTimestamp,
      id: id ?? json['id'] ?? 'food_${DateTime.now().millisecondsSinceEpoch}',
      isLowConfidence: isLowConfidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'nutrition_info': nutritionInfo.toJson(),
      'warnings': warnings,
      'food_image_url': foodImageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'id': id,
      'is_low_confidence': isLowConfidence,
    };
  }

  // Create a copy with modified fields
  FoodAnalysisResult copyWith({
    String? foodName,
    List<Ingredient>? ingredients,
    NutritionInfo? nutritionInfo,
    List<String>? warnings,
    String? foodImageUrl,
    DateTime? timestamp,
    String? id,
    bool? isLowConfidence,
  }) {
    return FoodAnalysisResult(
      foodName: foodName ?? this.foodName,
      ingredients: ingredients ?? this.ingredients,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      warnings: warnings ?? this.warnings,
      foodImageUrl: foodImageUrl ?? this.foodImageUrl,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
      isLowConfidence: isLowConfidence ?? this.isLowConfidence,
    );
  }

  static List<Ingredient> _parseIngredients(dynamic ingredientsData) {
    if (ingredientsData == null) return [];

    if (ingredientsData is List) {
      return ingredientsData.map((item) => Ingredient.fromJson(item)).toList();
    }

    return [];
  }
}

class Ingredient {
  final String name;
  final double servings;

  Ingredient({
    required this.name,
    required this.servings,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
        name: json['name'] ?? '', servings: _parseDouble(json['servings']));
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'servings': servings,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sodium;
  final double fiber;
  final double sugar;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sodium,
    required this.fiber,
    required this.sugar,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: _parseDouble(json['calories']),
      protein: _parseDouble(json['protein']),
      carbs: _parseDouble(json['carbs']),
      fat: _parseDouble(json['fat']),
      sodium: _parseDouble(json['sodium']),
      fiber: _parseDouble(json['fiber']),
      sugar: _parseDouble(json['sugar']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'sodium': sodium,
      'fiber': fiber,
      'sugar': sugar,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
