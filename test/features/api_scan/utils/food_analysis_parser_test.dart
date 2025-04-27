// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

// Project imports:
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/utils/food_analysis_parser.dart';

void main() {
  group('FoodAnalysisParser', () {
    test('should parse valid JSON string', () {
      // Arrange
      final jsonString = '''
      {
        "food_name": "Apple",
        "ingredients": [
          {"name": "Apple", "servings": 100}
        ],
        "nutrition_info": {
          "calories": 95,
          "protein": 0.5,
          "carbs": 25,
          "fat": 0.3
        },
        "timestamp": "${DateTime.now().toIso8601String()}"
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonString);

      // Assert
      expect(result.foodName, equals('Apple'));
      expect(result.ingredients.length, equals(1));
      expect(result.ingredients[0].name, equals('Apple'));
      expect(result.ingredients[0].servings, equals(100));
      expect(result.nutritionInfo.calories, equals(95));
      expect(result.nutritionInfo.protein, equals(0.5));
      expect(result.nutritionInfo.carbs, equals(25));
      expect(result.nutritionInfo.fat, equals(0.3));
      expect(result.timestamp, isA<DateTime>());
      expect(result.healthScore, isA<double>());
      expect(result.healthScore, greaterThanOrEqualTo(1.0));
      expect(result.healthScore, lessThanOrEqualTo(10.0));
    });

    test('should throw ApiServiceException when JSON is invalid', () {
      // Arrange
      final invalidJsonString = '{"invalid": json}';

      // Act & Assert
      expect(() => FoodAnalysisParser.parse(invalidJsonString),
          throwsA(isA<ApiServiceException>()));
    });

    test('should parse valid JSON map', () {
      // Arrange
      final jsonMap = {
        "food_name": "Apple",
        "ingredients": [
          {"name": "Apple", "servings": 100}
        ],
        "nutrition_info": {
          "calories": 95,
          "protein": 0.5,
          "carbs": 25,
          "fat": 0.3
        },
        "timestamp": DateTime.now().toIso8601String()
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.foodName, equals('Apple'));
      expect(result.ingredients.length, equals(1));
      expect(result.ingredients[0].name, equals('Apple'));
      expect(result.ingredients[0].servings, equals(100));
      expect(result.nutritionInfo.calories, equals(95));
      expect(result.nutritionInfo.protein, equals(0.5));
      expect(result.nutritionInfo.carbs, equals(25));
      expect(result.nutritionInfo.fat, equals(0.3));
      expect(result.timestamp, isA<DateTime>());
    });

    test('should handle error field in response', () {
      // Arrange
      final jsonMap = {
        "error": "Could not analyze food",
        "food_name": "Unknown",
        "ingredients": [],
        "nutrition_info": {"calories": 0, "protein": 0, "carbs": 0, "fat": 0},
        "timestamp": DateTime.now().toIso8601String()
      };

      // Act & Assert
      expect(
        () => FoodAnalysisParser.parseMap(jsonMap),
        throwsA(isA<ApiServiceException>().having((e) => e.message,
            'error message', contains('Could not analyze food'))),
      );
    });

    test('should handle missing timestamp', () {
      // Arrange
      final jsonMap = {
        "food_name": "Apple",
        "ingredients": [
          {"name": "Apple", "servings": 100}
        ],
        "nutrition_info": {
          "calories": 95,
          "protein": 0.5,
          "carbs": 25,
          "fat": 0.3
        }
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.timestamp, isA<DateTime>());
      expect(
          result.timestamp.difference(DateTime.now()).inSeconds, lessThan(1));
    });

    test('should handle invalid timestamp format', () {
      // Arrange
      final jsonMap = {
        "food_name": "Apple",
        "ingredients": [
          {"name": "Apple", "servings": 100}
        ],
        "nutrition_info": {
          "calories": 95,
          "protein": 0.5,
          "carbs": 25,
          "fat": 0.3
        },
        "timestamp": "invalid-timestamp"
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.timestamp, isA<DateTime>());
      expect(
          result.timestamp.difference(DateTime.now()).inSeconds, lessThan(1));
    });

    // Testing health score calculation and warnings
    test('should calculate health score and generate warnings appropriately',
        () {
      // Arrange - Food with high sodium, high sugar, high cholesterol and high saturated fat
      final jsonMap = {
        "food_name": "Unhealthy Food",
        "ingredients": [
          {"name": "Ingredient", "servings": 100}
        ],
        "nutrition_info": {
          "calories": 400,
          "protein": 5,
          "carbs": 30,
          "fat": 25,
          "saturated_fat": 10, // High saturated fat (>5g)
          "sodium":
              700, // High sodium (>500mg) - updated to match the actual threshold
          "fiber": 1,
          "sugar": 35, // High sugar (>20g)
          "cholesterol": 250 // High cholesterol (>200mg)
        }
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(
          result.healthScore, lessThan(5.0)); // Should have a low health score
      expect(result.warnings.length, 4); 
      expect(result.warnings, contains(FoodAnalysisResult.highSodiumWarning));
      expect(result.warnings, contains(FoodAnalysisResult.highSugarWarning));
      expect(
          result.warnings, contains(FoodAnalysisResult.highCholesterolWarning));
      expect(result.warnings,
          contains(FoodAnalysisResult.highSaturatedFatWarning));

      // Check health score category
      expect(result.getHealthScoreCategory(),
          anyOf(equals("Poor"), equals("Very Poor")));
    });

    test('should parse JSON with health_score field', () {
      // Arrange
      final jsonMap = {
        "food_name": "Apple",
        "ingredients": [],
        "nutrition_info": {
          "calories": 95,
          "protein": 0.5,
          "carbs": 25,
          "fat": 0.3
        },
        "health_score": 8.5
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.healthScore, 8.5);
      expect(result.getHealthScoreCategory(), equals("Excellent"));
    });

    test('should parse JSON with userId and additionalInformation fields', () {
      // Arrange
      final jsonMap = {
        "food_name": "Custom Food",
        "ingredients": [],
        "nutrition_info": {
          "calories": 200,
          "protein": 10,
          "carbs": 20,
          "fat": 5
        },
        "userId": "user-123",
        "additional_information": {"source": "custom", "diet": "vegetarian"}
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.userId, equals("user-123"));
      expect(result.additionalInformation["source"], equals("custom"));
      expect(result.additionalInformation["diet"], equals("vegetarian"));
    });

    group('isEmptyNutrition', () {
      test('should return true when all values are null', () {
        // Arrange
        final nutritionInfo = {
          'calories': null,
          'protein': null,
          'carbs': null,
          'fat': null,
          'sodium': null,
          'fiber': null,
          'sugar': null,
        };

        // Act
        final result = FoodAnalysisParser.isEmptyNutrition(nutritionInfo);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when all values are zero', () {
        // Arrange
        final nutritionInfo = {
          'calories': 0,
          'protein': 0.0,
          'carbs': "0",
          'fat': "0.0",
          'sodium': 0,
          'fiber': 0.0,
          'sugar': "0",
        };

        // Act
        final result = FoodAnalysisParser.isEmptyNutrition(nutritionInfo);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when any value is non-zero', () {
        // Arrange
        final nutritionInfo = {
          'calories': 100,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          'sodium': 0,
          'fiber': 0,
          'sugar': 0,
        };

        // Act
        final result = FoodAnalysisParser.isEmptyNutrition(nutritionInfo);

        // Assert
        expect(result, isFalse);
      });
    });

    group('parseIngredients', () {
      test('should return empty list for null ingredients', () {
        // Act
        final result = FoodAnalysisParser.parseIngredients(null);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list for non-list ingredients', () {
        // Act
        final result = FoodAnalysisParser.parseIngredients({'invalid': 'data'});

        // Assert
        expect(result, isEmpty);
      });

      test('should parse valid ingredient list', () {
        // Arrange
        final ingredients = [
          {'name': 'Apple', 'servings': 100},
          {'name': 'Banana', 'servings': 50},
        ];

        // Act
        final result = FoodAnalysisParser.parseIngredients(ingredients);

        // Assert
        expect(result.length, equals(2));
        expect(result[0].name, equals('Apple'));
        expect(result[0].servings, equals(100));
        expect(result[1].name, equals('Banana'));
        expect(result[1].servings, equals(50));
      });

      test('should handle invalid ingredient items', () {
        // Arrange
        final ingredients = [
          {'name': 'Apple', 'servings': 100},
          'invalid',
          {'invalid': 'data'},
        ];

        // Act
        final result = FoodAnalysisParser.parseIngredients(ingredients);

        // Assert
        expect(result.length, equals(3));
        expect(result[0].name, equals('Apple'));
        expect(result[0].servings, equals(100));
        expect(result[1].name, equals('Unknown ingredient'));
        expect(result[1].servings, equals(0));
        expect(result[2].name, equals('Unknown ingredient'));
        expect(result[2].servings, equals(0));
      });
    });

    group('parseDouble', () {
      test('should return 0.0 for null value', () {
        // Act
        final result = FoodAnalysisParser.parseDouble(null);

        // Assert
        expect(result, equals(0.0));
      });

      test('should convert int to double', () {
        // Act
        final result = FoodAnalysisParser.parseDouble(100);

        // Assert
        expect(result, equals(100.0));
      });

      test('should return double as is', () {
        // Act
        final result = FoodAnalysisParser.parseDouble(100.5);

        // Assert
        expect(result, equals(100.5));
      });

      test('should parse valid string to double', () {
        // Act
        final result = FoodAnalysisParser.parseDouble('100.5');

        // Assert
        expect(result, equals(100.5));
      });

      test('should return 0.0 for invalid string', () {
        // Act
        final result = FoodAnalysisParser.parseDouble('invalid');

        // Assert
        expect(result, equals(0.0));
      });
    });

    test(
        'should throw ApiServiceException for unknown food with empty nutrition',
        () {
      // Arrange
      final jsonMap = {
        "food_name": "Unknown",
        "ingredients": [],
        "nutrition_info": {
          "calories": 0,
          "protein": 0,
          "carbs": 0,
          "fat": 0,
          "sodium": 0,
          "fiber": 0,
          "sugar": 0
        },
        "timestamp": DateTime.now().toIso8601String()
      };

      // Act & Assert
      expect(
        () => FoodAnalysisParser.parseMap(jsonMap),
        throwsA(isA<ApiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Cannot identify food from provided information'),
        )),
      );
    });

    test('should parse complex nutrition data', () {
      // Arrange
      final jsonMap = {
        "food_name": "Complete Food",
        "ingredients": [
          {"name": "Main Ingredient", "servings": 100}
        ],
        "nutrition_info": {
          "calories": 200,
          "protein": 10,
          "carbs": 25,
          "fat": 8,
          "saturated_fat": 2.5,
          "sodium": 300,
          "fiber": 4,
          "sugar": 8,
          "cholesterol": 25,
          "nutrition_density": 75,
          "vitamins_and_minerals": {
            "vitamin_a": 500,
            "vitamin_c": 20,
            "calcium": 150,
            "iron": 2.5,
            "potassium": 300
          }
        }
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.nutritionInfo.saturatedFat, equals(2.5));
      expect(result.nutritionInfo.cholesterol, equals(25));
      expect(result.nutritionInfo.nutritionDensity, equals(75));
      expect(
          result.nutritionInfo.vitaminsAndMinerals["vitamin_a"], equals(500));
      expect(result.nutritionInfo.vitaminsAndMinerals["iron"], equals(2.5));
    });
  });
}
