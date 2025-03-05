// lib/pockeat/features/ai_api_scan/models/food_analysis.dart
class FoodAnalysisResult {
  final String foodName;
  final List<Ingredient> ingredients;
  final NutritionInfo nutritionInfo;
  final List<String> warnings;
  
  // Constants for warning messages to ensure consistency
  static const String HIGH_SODIUM_WARNING = "High sodium content";
  static const String HIGH_SUGAR_WARNING = "High sugar content";
  
  // Thresholds for warnings
  static const double HIGH_SODIUM_THRESHOLD = 500.0; // mg
  static const double HIGH_SUGAR_THRESHOLD = 20.0; // g
  
  FoodAnalysisResult({
    required this.foodName,
    required this.ingredients,
    required this.nutritionInfo,
    this.warnings = const [],
  });
  
  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    final nutritionInfo = NutritionInfo.fromJson(json['nutrition_info'] ?? {});
    
    // Generate warnings for high sodium or sugar if not provided in the JSON
    List<String> warnings = [];
    
    // If warnings are provided in the JSON, use those
    if (json['warnings'] != null) {
      warnings = List<String>.from(json['warnings']);
    } 
    // Otherwise generate warnings based on nutrition values
    else {
      if (nutritionInfo.sodium > HIGH_SODIUM_THRESHOLD) {
        warnings.add(HIGH_SODIUM_WARNING);
      }
      if (nutritionInfo.sugar > HIGH_SUGAR_THRESHOLD) {
        warnings.add(HIGH_SUGAR_WARNING);
      }
    }
    
    return FoodAnalysisResult(
      foodName: json['food_name'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item))
          .toList() ?? [],
      nutritionInfo: nutritionInfo,
      warnings: warnings,
    );
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
      name: json['name'] ?? '',
      servings: _parseDouble(json['servings'])
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
  
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}