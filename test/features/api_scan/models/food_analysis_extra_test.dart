// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

void main() {
  group('FoodAnalysisResult Extra Coverage Tests', () {
    // Test for parsing non-list ingredients (coverage for line 150-153)
    test('should handle invalid ingredients data type', () {
      // Arrange - test private method _parseIngredients with non-list type
      final invalidResult = FoodAnalysisResult.fromJson({
        'food_name': 'Invalid Test',
        'ingredients': "not a list", // String instead of list
        'nutrition_info': {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          'sodium': 0,
          'fiber': 0,
          'sugar': 0,
        },
      });

      // Assert - should handle gracefully by returning empty list
      expect(invalidResult.ingredients, isEmpty);
    });
    
    // Test for userId field in toJson (coverage for line 111, 114)
    test('toJson should correctly serialize userId and isLowConfidence fields', () {
      // Arrange
      final result = FoodAnalysisResult(
        foodName: 'Test Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 100,
          protein: 5,
          carbs: 10, 
          fat: 2,
          sodium: 50,
          fiber: 3,
          sugar: 5,
        ),
        warnings: [],
        userId: 'test_user_123', // Set userId
        isLowConfidence: true,
      );

      // Act
      final json = result.toJson();

      // Assert
      expect(json['userId'], 'test_user_123');
      expect(json['is_low_confidence'], true);
    });
    
    // Test copyWith method thoroughly
    test('copyWith should correctly copy all fields', () {
      // Arrange
      final original = FoodAnalysisResult(
        foodName: 'Original Food',
        ingredients: [Ingredient(name: 'Original Ingredient', servings: 100)],
        nutritionInfo: NutritionInfo(calories: 100, protein: 5, carbs: 10, fat: 2, sodium: 50, fiber: 3, sugar: 5),
        warnings: ['Original Warning'],
        foodImageUrl: 'original.jpg',
        timestamp: DateTime(2024, 1, 1),
        id: 'original-id',
        isLowConfidence: false,
        userId: 'original-user',
      );
      
      // Act - copy with modified values
      final modified = original.copyWith(
        foodName: 'Modified Food',
        userId: 'modified-user',
        isLowConfidence: true,
      );
      
      // Assert - modified fields should change
      expect(modified.foodName, 'Modified Food');
      expect(modified.userId, 'modified-user');
      expect(modified.isLowConfidence, true);
      
      // Unmodified fields should remain the same
      expect(modified.ingredients, original.ingredients);
      expect(modified.nutritionInfo, original.nutritionInfo);
      expect(modified.warnings, original.warnings);
      expect(modified.foodImageUrl, original.foodImageUrl);
      expect(modified.timestamp, original.timestamp);
      expect(modified.id, original.id);
    });
    
    // Test untuk copyWith dengan userId dan isLowConfidence
    test('copyWith should correctly handle userId and isLowConfidence', () {
      // Arrange
      final original = FoodAnalysisResult(
        foodName: 'Original Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 100,
          protein: 5,
          carbs: 10, 
          fat: 2,
          sodium: 50,
          fiber: 3,
          sugar: 5,
        ),
        warnings: [],
        userId: '', // Start with empty string
        isLowConfidence: false,
      );
      
      // Act
      final modified = original.copyWith(
        userId: 'new-user-id',
        isLowConfidence: true,
      );
      
      // Assert
      expect(modified.userId, 'new-user-id');
      expect(modified.isLowConfidence, true);
      expect(modified.foodName, original.foodName); // Unchanged
    });
    
    // Test untuk timestamp menggunakan pendekatan berbeda
    test('should handle timestamp objects in JSON', () {
      // Arrange
      final date = DateTime(2024, 4, 22);
      final timestamp = Timestamp.fromDate(date);
      
      final json = {
        'food_name': 'Apple',
        'ingredients': [
          {'name': 'Apple', 'servings': 100}
        ],
        'nutrition_info': {
          'calories': 95,
          'protein': 0.5,
          'carbs': 20,
          'fat': 0.1,
          'sodium': 10,
          'fiber': 2,
          'sugar': 15,
        },
        'timestamp': timestamp
      };

      // Act
      final result = FoodAnalysisResult.fromJson(json);

      // Assert
      expect(result.timestamp, equals(date));
    });
  });
}
