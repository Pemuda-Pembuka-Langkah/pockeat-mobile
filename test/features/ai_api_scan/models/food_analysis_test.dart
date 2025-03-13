import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('FoodAnalysisResult Model', () {
    test('should create FoodAnalysisResult from JSON', () {
      // Arrange
      final json = {
        'food_name': 'Apple',
        'ingredients': [
          {'name': 'Apple', 'servings': 100}
        ],
        'nutrition_info': {
          'calories': 95,
          'protein': 0.5,
          'carbs': 25.1,
          'fat': 0.3,
          'sodium': 2,
          'fiber': 4.4,
          'sugar': 19.0
        },
        'timestamp': 1710320000000 // March 13, 2024 timestamp
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
      expect(result.warnings, isEmpty); // No warnings for normal sugar/sodium
      expect(result.timestamp, isA<DateTime>());
      expect(result.timestamp.millisecondsSinceEpoch, 1710320000000);
    });

    test('should set default timestamp when not provided in JSON', () {
      // Arrange
      final json = {
        'food_name': 'Apple',
        'ingredients': [
          {'name': 'Apple', 'servings': 100}
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
      final now = DateTime.now();

      // Assert
      expect(result.timestamp, isA<DateTime>());
      // Timestamp should be recent (within the last second)
      expect(now.difference(result.timestamp).inSeconds, lessThanOrEqualTo(1));
    });

    test('should handle Timestamp object in JSON', () {
      // Arrange
      final timestamp = DateTime(2024, 3, 13);
      final timestampMillis = timestamp.millisecondsSinceEpoch;

      final json = {
        'food_name': 'Apple',
        'ingredients': [
          {'name': 'Apple', 'servings': 100}
        ],
        'nutrition_info': {
          'calories': 95,
          'protein': 0.5,
          'carbs': 25.1,
          'fat': 0.3,
          'sodium': 2,
          'fiber': 4.4,
          'sugar': 19.0
        },
        'timestamp': timestampMillis
      };

      // Act
      final result = FoodAnalysisResult.fromJson(json);

      // Assert
      expect(result.timestamp, equals(timestamp));
    });

    test('should convert to JSON with all fields', () {
      // Arrange
      final testDate = DateTime(2024, 3, 13);
      final foodResult = FoodAnalysisResult(
          id: 'test-id-123',
          foodName: 'Test Food',
          ingredients: [Ingredient(name: 'Test Ingredient', servings: 100)],
          nutritionInfo: NutritionInfo(
              calories: 100,
              protein: 10,
              carbs: 20,
              fat: 5,
              sodium: 100,
              fiber: 5,
              sugar: 10),
          timestamp: testDate,
          foodImageUrl: 'https://example.com/image.jpg');

      // Act
      final json = foodResult.toJson();

      // Assert
      expect(json['food_name'], 'Test Food');
      expect(json['food_image_url'], 'https://example.com/image.jpg');
      expect(json['id'], 'test-id-123');
      expect(json['timestamp'], isA<dynamic>());
    });

    test('should parse empty or null ingredients correctly', () {
      // Arrange
      final jsonWithNull = {
        'food_name': 'Test Food',
        'ingredients': null,
        'nutrition_info': {
          'calories': 100,
          'protein': 10,
          'carbs': 20,
          'fat': 5,
          'sodium': 100,
          'fiber': 5,
          'sugar': 10
        }
      };

      final jsonWithEmptyList = {
        'food_name': 'Test Food',
        'ingredients': [],
        'nutrition_info': {
          'calories': 100,
          'protein': 10,
          'carbs': 20,
          'fat': 5,
          'sodium': 100,
          'fiber': 5,
          'sugar': 10
        }
      };

      // Act
      final resultWithNull = FoodAnalysisResult.fromJson(jsonWithNull);
      final resultWithEmptyList =
          FoodAnalysisResult.fromJson(jsonWithEmptyList);

      // Assert
      expect(resultWithNull.ingredients, isEmpty);
      expect(resultWithEmptyList.ingredients, isEmpty);
    });

    group('Warning generation', () {
      test('should generate warning for high sodium', () {
        // Arrange
        final json = {
          'food_name': 'Instant Soup',
          'ingredients': [
            {'name': 'Sodium', 'servings': 20}
          ],
          'nutrition_info': {
            'calories': 200,
            'protein': 5,
            'carbs': 20,
            'fat': 10,
            'sodium': 800, // High sodium
            'fiber': 1,
            'sugar': 5
          }
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings, contains('High sodium content'));
        expect(result.warnings.length, 1);
      });

      test('should generate warning for high sugar', () {
        // Arrange
        final json = {
          'food_name': 'Candy',
          'ingredients': [
            {'name': 'Sugar', 'servings': 80}
          ],
          'nutrition_info': {
            'calories': 300,
            'protein': 0,
            'carbs': 75,
            'fat': 0,
            'sodium': 10,
            'fiber': 0,
            'sugar': 70 // High sugar
          }
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings, contains('High sugar content'));
        expect(result.warnings.length, 1);
      });

      test(
          'should generate multiple warnings when both sugar and sodium are high',
          () {
        // Arrange
        final json = {
          'food_name': 'Sweetened Canned Food',
          'ingredients': [
            {'name': 'Sugar', 'servings': 40},
            {'name': 'Salt', 'servings': 10}
          ],
          'nutrition_info': {
            'calories': 400,
            'protein': 5,
            'carbs': 80,
            'fat': 5,
            'sodium': 1200, // High sodium
            'fiber': 1,
            'sugar': 50 // High sugar
          }
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings, contains('High sodium content'));
        expect(result.warnings, contains('High sugar content'));
        expect(result.warnings.length, 2);
      });

      test('should use provided warnings when available in JSON', () {
        // Arrange
        final json = {
          'food_name': 'Custom Food',
          'ingredients': [
            {'name': 'Ingredient', 'servings': 100}
          ],
          'nutrition_info': {
            'calories': 200,
            'protein': 5,
            'carbs': 20,
            'fat': 10,
            'sodium': 200, // Not high
            'fiber': 2,
            'sugar': 5 // Not high
          },
          'warnings': ['Contains artificial colors', 'Contains preservatives']
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings, contains('Contains artificial colors'));
        expect(result.warnings, contains('Contains preservatives'));
        expect(result.warnings.length, 2);
      });
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
        expect(result.warnings, isEmpty); // No warnings
      });

      test('should handle numeric values with different types', () {
        // Arrange
        final json = {
          'food_name': 'Mixed Types',
          'ingredients': [],
          'nutrition_info': {
            'calories': 100, // int
            'protein': 2.5, // double
            'carbs': '30.5', // string
            'fat': '0', // string zero
            'sodium': 5, // int
            'fiber': '3.5', // string
            'sugar': null // null value should default to 0.0
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
        expect(result.nutritionInfo.sugar, 0.0); // Default for null
        expect(result.warnings, isEmpty); // No warnings
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
        expect(result.warnings, isEmpty); // No warnings for zero values
      });
    });

    group('Ingredient servings handling', () {
      test('should handle different types for ingredient servings', () {
        // Arrange
        final json = {
          'food_name': 'Mixed Salad',
          'ingredients': [
            {'name': 'Lettuce', 'servings': 50.5},
            {'name': 'Tomato', 'servings': '25.5'},
            {'name': 'Cucumber', 'servings': 15},
            {'name': 'Nuts', 'servings': '9'}
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
        expect(result.warnings, isEmpty); // No warnings
      });

      test('should handle invalid servings values', () {
        // Arrange
        final json = {
          'food_name': 'Problem Data',
          'ingredients': [
            {'name': 'Valid', 'servings': 80},
            {'name': 'Invalid', 'servings': 'unknown'}
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
        expect(
            result.ingredients[1].servings, 0.0); // Default for invalid string
        expect(result.warnings, isEmpty); // No warnings
      });
    });
  });
}

// Mock class for Timestamp
class MockTimestamp {
  final DateTime _dateTime;

  MockTimestamp(this._dateTime);

  DateTime toDate() {
    return _dateTime;
  }
}
