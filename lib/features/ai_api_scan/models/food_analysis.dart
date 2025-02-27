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
    // Not implemented yet - will fail tests
    throw UnimplementedError();
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
    // Not implemented yet - will fail tests
    throw UnimplementedError();
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
    required this.sugar ,
  });
  
  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    // Not implemented yet - will fail tests
    throw UnimplementedError();
  }
}

