// lib/pockeat/features/ai_api_scan/models/food_analysis.dart

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:pockeat/features/api_scan/services/base/api_service.dart';

class FoodAnalysisResult {
  final String foodName;
  final List<Ingredient> ingredients;
  final NutritionInfo nutritionInfo;
  final List<String> warnings;
  String? foodImageUrl;
  final DateTime timestamp;
  final String id;
  final String userId;
  final Map<String, dynamic> additionalInformation;
  final double healthScore; // Added health score field

  // Constants for warning messages to ensure consistency
  static const String highSodiumWarning = "High sodium content";
  static const String highSugarWarning = "High sugar content";
  static const String highCholesterolWarning = "High cholesterol content";
  static const String highSaturatedFatWarning = "High saturated fat content";

  // Thresholds for warnings
  static const double highSodiumThreshold = 500; // mg
  static const double highSugarThreshold = 20.0; // g
  static const double highCholesterolThreshold = 200.0; // mg
  static const double highSaturatedFatThreshold = 5.0; // g

  FoodAnalysisResult({
    required this.foodName,
    required this.ingredients,
    required this.nutritionInfo,
    this.warnings = const [],
    this.foodImageUrl,
    DateTime? timestamp,
    String? id,
    this.userId = '', // Add userId parameter with default value
    this.additionalInformation = const {},
    double? healthScore, // Add health score parameter with calculated default
  })  : timestamp = timestamp ?? DateTime.now(),
        id = id ?? const Uuid().v4(),
        healthScore = healthScore ?? _calculateHealthScore(nutritionInfo);

  // Enhanced health score calculation method on a scale of 1-10 with 0.5 increments
  static double _calculateHealthScore(NutritionInfo nutrition) {
    // Base score starts at 7.5 (middle-high range)
    double score = 7.5;

    // Deductions for high sodium (over 0.5g = 500mg)
    if (nutrition.sodium > highSodiumThreshold) {
      // Deduct points based on how much it exceeds the threshold
      double deduction =
          ((nutrition.sodium - highSodiumThreshold) / 0.25).clamp(0.0, 3.0);
      score -= deduction;
    }

    // Deductions for high sugar (over 20g)
    if (nutrition.sugar > highSugarThreshold) {
      // Deduct points based on how much it exceeds the threshold
      double deduction =
          ((nutrition.sugar - highSugarThreshold) / 10).clamp(0.0, 2.5);
      score -= deduction;
    }

    // Additions for high protein (up to 1.5 bonus points)
    double proteinBonus = (nutrition.protein / 20).clamp(0.0, 1.5);
    score += proteinBonus;

    // Additions for fiber (up to 1 bonus point)
    double fiberBonus = (nutrition.fiber / 5).clamp(0.0, 1.0);
    score += fiberBonus;

    // Fat evaluation with consideration for saturated fat
    if (nutrition.fat > 15) {
      double baseFatDeduction = ((nutrition.fat - 15) / 10).clamp(0.0, 1.5);
      score -= baseFatDeduction;

      // Extra penalty for high saturated fat proportion
      if (nutrition.saturatedFat > 0 && nutrition.fat > 0) {
        double satFatRatio = nutrition.saturatedFat / nutrition.fat;
        if (satFatRatio > 0.3) {
          // If more than 30% of fat is saturated
          double satFatDeduction = ((satFatRatio - 0.3) * 2).clamp(0.0, 1.0);
          score -= satFatDeduction;
        }
      }
    }

    // Cholesterol consideration
    if (nutrition.cholesterol > highCholesterolThreshold) {
      double cholDeduction =
          ((nutrition.cholesterol - highCholesterolThreshold) / 100)
              .clamp(0.0, 1.0);
      score -= cholDeduction;
    }

    // Bonus for nutrition density
    if (nutrition.nutritionDensity > 0) {
      double densityBonus = (nutrition.nutritionDensity / 100).clamp(0.0, 1.0);
      score += densityBonus;
    }

    // Round to nearest 0.5
    score = (score * 2.0).round() / 2.0;

    // Ensure score stays within 1-10 range with 0.5 increments
    return score.clamp(1.0, 10.0);
  }

  // Health score interpretation helper method for 1-10 scale with 0.5 increments
  String getHealthScoreCategory() {
    if (healthScore >= 8.5) return "Excellent";
    if (healthScore >= 7.0) return "Good";
    if (healthScore >= 5.0) return "Fair";
    if (healthScore >= 3.0) return "Poor";
    return "Very Poor";
  }

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json, {String? id}) {
    // Check if response contains error field
    if (json.containsKey('error') &&
        json['error'] != null &&
        json['error'] != 'null') {
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
      if (nutritionInfo.cholesterol > highCholesterolThreshold) {
        warnings.add(highCholesterolWarning);
      }
      if (nutritionInfo.saturatedFat > highSaturatedFatThreshold) {
        warnings.add(highSaturatedFatWarning);
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

    // Get health score from JSON or calculate it based on nutrition data
    double healthScore;
    if (json['health_score'] != null) {
      healthScore = NutritionInfo._parseDouble(json['health_score']);
    } else {
      // Calculate the health score directly if not provided in JSON
      // This ensures we always have a valid health score even if API doesn't provide one
      healthScore = _calculateHealthScore(nutritionInfo);
    }

    return FoodAnalysisResult(
      foodName: json['food_name'] ?? '',
      ingredients: _parseIngredients(json['ingredients']),
      nutritionInfo: nutritionInfo,
      warnings: warnings,
      foodImageUrl: json['food_image_url'],
      timestamp: parsedTimestamp,
      id: id ?? json['id'] ?? 'food_${DateTime.now().millisecondsSinceEpoch}',
      userId: json['userId'] ?? '',
      additionalInformation: json['additional_information'] ?? {},
      healthScore: healthScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'nutrition_info': nutritionInfo.toJson(),
      'warnings': warnings,
      'food_image_url': foodImageUrl,
      'timestamp': timestamp
          .toIso8601String(), // Use ISO string format instead of Timestamp object
      'id': id,
      'userId': userId,
      'additional_information': additionalInformation,
      'health_score': healthScore,
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
    String? userId,
    Map<String, dynamic>? additionalInformation,
    double? healthScore,
  }) {
    return FoodAnalysisResult(
      foodName: foodName ?? this.foodName,
      ingredients: ingredients ?? this.ingredients,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      warnings: warnings ?? this.warnings,
      foodImageUrl: foodImageUrl ?? this.foodImageUrl,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      additionalInformation:
          additionalInformation ?? this.additionalInformation,
      healthScore: healthScore ?? this.healthScore,
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
  final double servings; //kcal

  Ingredient({
    required this.name,
    required this.servings,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    // Make sure servings is always handled as a double
    var servingsValue = json['servings'];
    double servings = 0.0;
    if (servingsValue is int) {
      servings = servingsValue.toDouble();
    } else if (servingsValue is double) {
      servings = servingsValue;
    } else if (servingsValue is String) {
      servings = double.tryParse(servingsValue) ?? 0.0;
    }

    return Ingredient(
      name: json['name'] ?? '',
      servings: servings, // Now safely converted to double
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'servings': servings, //kcal
    };
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double saturatedFat; // Added field
  final double sodium;
  final double fiber;
  final double sugar;
  final double cholesterol; // Added field
  final double nutritionDensity; // Added field
  final Map<String, double>
      vitaminsAndMinerals; // For storing additional nutrients

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.saturatedFat = 0,
    required this.sodium,
    required this.fiber,
    required this.sugar,
    this.cholesterol = 0,
    this.nutritionDensity = 0,
    this.vitaminsAndMinerals = const {},
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    // Create a map for vitamins and minerals
    Map<String, double> vitaminsAndMinerals = {};

    // Check if the json contains a vitamins_and_minerals field
    if (json['vitamins_and_minerals'] != null &&
        json['vitamins_and_minerals'] is Map) {
      json['vitamins_and_minerals'].forEach((key, value) {
        vitaminsAndMinerals[key] = _parseDouble(value);
      });
    }

    // Ensure all values are properly converted to double
    return NutritionInfo(
      calories: _parseDouble(json['calories']),
      protein: _parseDouble(json['protein']),
      carbs: _parseDouble(json['carbs']),
      fat: _parseDouble(json['fat']),
      saturatedFat: _parseDouble(json['saturated_fat']),
      sodium: _parseDouble(json['sodium']),
      fiber: _parseDouble(json['fiber']),
      sugar: _parseDouble(json['sugar']),
      cholesterol: _parseDouble(json['cholesterol']),
      nutritionDensity: _parseDouble(json['nutrition_density']),
      vitaminsAndMinerals: vitaminsAndMinerals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'saturated_fat': saturatedFat,
      'sodium': sodium,
      'fiber': fiber,
      'sugar': sugar,
      'cholesterol': cholesterol,
      'nutrition_density': nutritionDensity,
      'vitamins_and_minerals': vitaminsAndMinerals,
    };
  }

  // Add a copyWith method to create a new instance with modified values
  NutritionInfo copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? saturatedFat,
    double? sodium,
    double? fiber,
    double? sugar,
    double? cholesterol,
    double? nutritionDensity,
    Map<String, double>? vitaminsAndMinerals,
  }) {
    return NutritionInfo(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      sodium: sodium ?? this.sodium,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      cholesterol: cholesterol ?? this.cholesterol,
      nutritionDensity: nutritionDensity ?? this.nutritionDensity,
      vitaminsAndMinerals: vitaminsAndMinerals ?? this.vitaminsAndMinerals,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
