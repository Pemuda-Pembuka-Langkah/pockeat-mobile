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
  });
}
