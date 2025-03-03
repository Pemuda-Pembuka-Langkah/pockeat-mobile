// lib/pockeat/features/ai_api_scan/models/food_analysis.dart
class FoodAnalysisResult {
  final String foodName;
  final List<Ingredient> ingredients;
  final NutritionInfo nutritionInfo;
  
  FoodAnalysisResult({
    required this.foodName,
    required this.ingredients,
    required this.nutritionInfo,
  });
  
  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodName: json['food_name'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item))
          .toList() ?? [],
      nutritionInfo: NutritionInfo.fromJson(json['nutrition_info'] ?? {}),
    );
  }
}

class Ingredient {
  final String name;
  final double percentage;
  final bool allergen;
  
  Ingredient({
    required this.name,
    required this.percentage,
    required this.allergen,
  });
  
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      percentage: _parseDouble(json['percentage']),
      allergen: json['allergen'] ?? false,
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