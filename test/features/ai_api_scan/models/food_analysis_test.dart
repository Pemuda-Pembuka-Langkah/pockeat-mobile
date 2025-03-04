import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

void main() {
  group('FoodAnalysisResult Model', () {
    test('should create FoodAnalysisResult from JSON', () {
      // Arrange
      final json = {
        'food_name': 'Apple',
        'ingredients': [
          {'name': 'Apple', 'servings': 100, 'allergen': false}
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

    group('Numeric value conversion', () {
      test('should handle string values in nutrition info', () {
        // Arrange
        final json = {
          'food_name': 'Banana',
          'ingredients': [],
          'nutrition_info': {
            'calories': '105',
            'protein': '1.3',
            'carbs': '27',
            'fat': '0.4',
            'sodium': '1',
            'fiber': '3.1',
            'sugar': '14.4'
          }
        };
        
        // Act
        final result = FoodAnalysisResult.fromJson(json);
        
        // Assert
        expect(result.nutritionInfo.calories, 105.0);
        expect(result.nutritionInfo.protein, 1.3);
        expect(result.nutritionInfo.carbs, 27.0);
        expect(result.nutritionInfo.fat, 0.4);
        expect(result.nutritionInfo.sodium, 1.0);
        expect(result.nutritionInfo.fiber, 3.1);
        expect(result.nutritionInfo.sugar, 14.4);
      });
      
      test('should handle numeric values with different types', () {
        // Arrange
        final json = {
          'food_name': 'Mixed Types',
          'ingredients': [],
          'nutrition_info': {
            'calories': 100,  // int
            'protein': 2.5,   // double
            'carbs': '30.5',  // string
            'fat': '0',       // string zero
            'sodium': 5,      // int
            'fiber': '3.5',   // string
            'sugar': null     // null value should default to 0.0
          }
        };
        
        // Act
        final result = FoodAnalysisResult.fromJson(json);
        
        // Assert
        expect(result.nutritionInfo.calories, 100.0);
        expect(result.nutritionInfo.protein, 2.5);
        expect(result.nutritionInfo.carbs, 30.5);
        expect(result.nutritionInfo.fat, 0.0);
        expect(result.nutritionInfo.sodium, 5.0);
        expect(result.nutritionInfo.fiber, 3.5);
        expect(result.nutritionInfo.sugar, 0.0);  // Default for null
      });
      
      test('should handle invalid string values', () {
        // Arrange
        final json = {
          'food_name': 'Invalid Data',
          'ingredients': [],
          'nutrition_info': {
            'calories': 'not-a-number',
            'protein': 'abc',
            'carbs': '5g',
            'fat': '',
            'sodium': 'N/A',
            'fiber': '~2.5',
            'sugar': '?'
          }
        };
        
        // Act
        final result = FoodAnalysisResult.fromJson(json);
        
        // Assert
        // All invalid string values should default to 0.0
        expect(result.nutritionInfo.calories, 0.0);
        expect(result.nutritionInfo.protein, 0.0);
        expect(result.nutritionInfo.carbs, 0.0);
        expect(result.nutritionInfo.fat, 0.0);
        expect(result.nutritionInfo.sodium, 0.0);
        expect(result.nutritionInfo.fiber, 0.0);
        expect(result.nutritionInfo.sugar, 0.0);
      });
    });

    group('Ingredient servings handling', () {
      test('should handle different types for ingredient servings', () {
        // Arrange
        final json = {
          'food_name': 'Mixed Salad',
          'ingredients': [
            {'name': 'Lettuce', 'servings': 50.5, 'allergen': false},
            {'name': 'Tomato', 'servings': '25.5', 'allergen': false},
            {'name': 'Cucumber', 'servings': 15, 'allergen': false},
            {'name': 'Nuts', 'servings': '9', 'allergen': true}
          ],
          'nutrition_info': {
            'calories': 100,
            'protein': 2,
            'carbs': 10,
            'fat': 5,
            'sodium': 10,
            'fiber': 3,
            'sugar': 2
          }
        };
        
        // Act
        final result = FoodAnalysisResult.fromJson(json);
        
        // Assert
        expect(result.ingredients.length, 4);
        expect(result.ingredients[0].servings, 50.5);
        expect(result.ingredients[1].servings, 25.5);
        expect(result.ingredients[2].servings, 15.0);
        expect(result.ingredients[3].servings, 9.0);
      });
      
      test('should handle invalid servings values', () {
        // Arrange
        final json = {
          'food_name': 'Problem Data',
          'ingredients': [
            {'name': 'Valid', 'servings': 80, 'allergen': false},
            {'name': 'Invalid', 'servings': 'unknown', 'allergen': false}
          ],
          'nutrition_info': {
            'calories': 100,
            'protein': 2,
            'carbs': 10,
            'fat': 5,
            'sodium': 10,
            'fiber': 3,
            'sugar': 2
          }
        };
        
        // Act
        final result = FoodAnalysisResult.fromJson(json);
        
        // Assert
        expect(result.ingredients.length, 2);
        expect(result.ingredients[0].servings, 80.0);
        expect(result.ingredients[1].servings, 0.0);  // Default for invalid string
      });
    });
  });
}