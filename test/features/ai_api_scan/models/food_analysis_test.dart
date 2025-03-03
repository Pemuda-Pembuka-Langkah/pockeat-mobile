// test/pockeat/features/ai_api_scan/models/food_analysis_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

void main() {
  group('FoodAnalysisResult Model', () {
    test('should create FoodAnalysisResult from JSON', () {
      // Arrange
      final json = {
        'food_name': 'Apple',
        'ingredients': [
          {'name': 'Apple', 'percentage': 100, 'allergen': false}
        ],
        'nutrition_info': {
          'calories': 95,
          'protein': 0.5,
          'carbs': 25.1,
          'fat': 0.3,
          'sodium': 2,
          'fiber': 4.4,
          'sugar': 19.0
        }
      };
      
      // Act
      final result = FoodAnalysisResult.fromJson(json);
      
      // Assert
      expect(result.foodName, 'Apple');
      expect(result.ingredients.length, 1);
      expect(result.ingredients[0].name, 'Apple');
      expect(result.nutritionInfo.calories, 95);
      expect(result.nutritionInfo.sodium, 2);
      expect(result.nutritionInfo.fiber, 4.4);
      expect(result.nutritionInfo.sugar, 19.0);
    });
  });
}

