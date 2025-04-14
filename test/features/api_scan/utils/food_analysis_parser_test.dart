import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/utils/food_analysis_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    test('should handle is_low_confidence flag', () {
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
        "timestamp": DateTime.now().toIso8601String(),
        "is_low_confidence": true
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.isLowConfidence, isTrue);
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
  });
}
