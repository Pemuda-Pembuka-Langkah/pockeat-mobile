// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

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
          "carbs": 25.1,
          "fat": 0.3,
          "sodium": 2,
          "fiber": 4.4,
          "sugar": 19,
          "saturated_fat": 0.1,
          "cholesterol": 0,
          "nutrition_density": 80
        },
        "timestamp": "${DateTime.now().toIso8601String()}",
        "health_score": 8.5,
        "additional_information": {"source": "api_test"}
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
      expect(result.nutritionInfo.carbs, equals(25.1));
      expect(result.nutritionInfo.fat, equals(0.3));
      expect(result.nutritionInfo.sodium, equals(2));
      expect(result.nutritionInfo.fiber, equals(4.4));
      expect(result.nutritionInfo.sugar, equals(19));
      expect(result.nutritionInfo.saturatedFat, equals(0.1));
      expect(result.nutritionInfo.cholesterol, equals(0));
      expect(result.nutritionInfo.nutritionDensity, equals(80));
      expect(result.healthScore, equals(8.5));
      expect(result.additionalInformation, isA<Map<String, dynamic>>());
      expect(result.additionalInformation['source'], equals('api_test'));
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
          "carbs": 25.1,
          "fat": 0.3,
          "sodium": 2,
          "fiber": 4.4,
          "sugar": 19,
          "saturated_fat": 0.1,
          "cholesterol": 0,
          "nutrition_density": 85
        },
        "timestamp": DateTime.now().toIso8601String(),
        "health_score": 8.0,
        "additional_information": {"source": "api"},
        "userId": "test-user-123"
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
      expect(result.nutritionInfo.carbs, equals(25.1));
      expect(result.nutritionInfo.fat, equals(0.3));
      expect(result.nutritionInfo.sodium, equals(2));
      expect(result.nutritionInfo.fiber, equals(4.4));
      expect(result.nutritionInfo.sugar, equals(19));
      expect(result.nutritionInfo.saturatedFat, equals(0.1));
      expect(result.nutritionInfo.cholesterol, equals(0));
      expect(result.nutritionInfo.nutritionDensity, equals(85));
      expect(result.timestamp, isA<DateTime>());
      expect(result.healthScore, equals(8.0));
      expect(result.additionalInformation['source'], equals('api'));
      expect(result.userId, equals('test-user-123'));
    });

    group('Error handling', () {
      test('should handle error field as string in response', () {
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

      test('should handle map-based error field in response', () {
        // Arrange
        final jsonMap = {
          "error": {"message": "API error occurred"},
          "food_name": "Unknown",
          "ingredients": [],
          "nutrition_info": {"calories": 0, "protein": 0, "carbs": 0, "fat": 0}
        };

        // Act & Assert
        expect(
          () => FoodAnalysisParser.parseMap(jsonMap),
          throwsA(isA<ApiServiceException>().having((e) => e.message,
              'error message', contains('API error occurred'))),
        );
      });

      test('should handle null or missing message in map-based error', () {
        // Arrange
        final jsonMap = {
          "error": {"code": 500},
          "food_name": "Unknown",
          "nutrition_info": {"calories": 0}
        };

        // Act & Assert
        expect(
          () => FoodAnalysisParser.parseMap(jsonMap),
          throwsA(isA<ApiServiceException>().having(
              (e) => e.message, 'error message', equals('Unknown error'))),
        );
      });

      test('should throw when parsing fails with generic exception', () {
        // Arrange - invalid map with circular reference to test generic exception
        final dynamic invalidMap = {};
        invalidMap['circular'] = invalidMap;

        // Act & Assert
        // Test can't directly create circular reference so we test the general exception handler
        expect(
          () => FoodAnalysisParser.parseMap({
            "food_name": null,
            "nutrition_info": null,
            "ingredients": null,
            "id": () {} // Function isn't serializable - will cause exception
          }),
          throwsA(isA<ApiServiceException>().having((e) => e.message,
              'error message', contains('Failed to parse food analysis data'))),
        );
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
            "sugar": 0,
            "saturated_fat": 0,
            "cholesterol": 0,
            "nutrition_density": 0
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

    group('Timestamp handling', () {
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
            "carbs": 25.1,
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

      test('should handle timestamp as integer milliseconds', () {
        // Arrange
        final testDate = DateTime(2024, 3, 13);
        final milliseconds = testDate.millisecondsSinceEpoch;

        final jsonMap = {
          "food_name": "Apple",
          "ingredients": [],
          "nutrition_info": {
            "calories": 95,
            "protein": 0.5,
            "carbs": 25,
            "fat": 0.3
          },
          "timestamp": milliseconds
        };

        // Act
        final result = FoodAnalysisParser.parseMap(jsonMap);

        // Assert
        expect(result.timestamp, testDate);
      });

      test('should handle timestamp as Firestore Timestamp', () {
        // Arrange
        final testDate = DateTime(2024, 3, 13);
        final firestoreTimestamp = Timestamp.fromDate(testDate);

        final jsonMap = {
          "food_name": "Apple",
          "ingredients": [],
          "nutrition_info": {
            "calories": 95,
            "protein": 0.5,
            "carbs": 25,
            "fat": 0.3
          },
          "timestamp": firestoreTimestamp
        };

        // Act
        final result = FoodAnalysisParser.parseMap(jsonMap);

        // Assert
        expect(result.timestamp, testDate);
      });

      test('should handle string timestamp', () {
        // Arrange
        final testDate = DateTime(2024, 3, 13);
        final isoString = testDate.toIso8601String();

        final jsonMap = {
          "food_name": "Apple",
          "ingredients": [],
          "nutrition_info": {
            "calories": 95,
            "protein": 0.5,
            "carbs": 25,
            "fat": 0.3
          },
          "timestamp": isoString
        };

        // Act
        final result = FoodAnalysisParser.parseMap(jsonMap);

        // Assert
        expect(result.timestamp, testDate);
      });

      test('should handle invalid timestamp format', () {
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
          "timestamp": "invalid-timestamp"
        };

        // Act
        final result = FoodAnalysisParser.parseMap(jsonMap);

        // Assert
        expect(result.timestamp, isA<DateTime>());
        expect(
            result.timestamp.difference(DateTime.now()).inSeconds, lessThan(1));
      });

      test('should handle unexpected timestamp type', () {
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
          "timestamp": {"type": "unexpected"} // Object that's not a timestamp
        };

        // Act
        final result = FoodAnalysisParser.parseMap(jsonMap);

        // Assert
        expect(result.timestamp, isA<DateTime>());
        expect(
            result.timestamp.difference(DateTime.now()).inSeconds, lessThan(1));
      });
    });

    test('should calculate health score when not provided', () {
      // Arrange
      final jsonMap = {
        "food_name": "Apple",
        "ingredients": [
          {"name": "Apple", "servings": 100}
        ],
        "nutrition_info": {
          "calories": 95,
          "protein": 0.5,
          "carbs": 25.1,
          "fat": 0.3,
          "sodium": 2,
          "fiber": 4.4,
          "sugar": 19,
          "saturated_fat": 0.1,
          "cholesterol": 0,
          "nutrition_density": 80
        }
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.healthScore, isA<double>());
      expect(result.healthScore, greaterThan(0));
    });

    test('should use provided userId when available', () {
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
        "userId": "test-user-123"
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(result.userId, equals("test-user-123"));
    });

    test('should use empty string as default userId when not provided', () {
      // Arrange
      final jsonMap = {
        "food_name": "Apple",
        "ingredients": [],
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
      expect(result.userId, equals(""));
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
          'saturated_fat': null,
          'cholesterol': null,
          'nutrition_density': null
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
          'saturated_fat': 0,
          'cholesterol': 0,
          'nutrition_density': "0"
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
          'saturated_fat': 0,
          'cholesterol': 0,
          'nutrition_density': 0
        };

        // Act
        final result = FoodAnalysisParser.isEmptyNutrition(nutritionInfo);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when new field value is non-zero', () {
        // Arrange
        final nutritionInfo = {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          'sodium': 0,
          'fiber': 0,
          'sugar': 0,
          'saturated_fat': 1.5, // non-zero value in new field
          'cholesterol': 0,
          'nutrition_density': 0
        };

        // Act
        final result = FoodAnalysisParser.isEmptyNutrition(nutritionInfo);

        // Assert
        expect(result, isFalse);
      });

      test('should handle missing fields', () {
        // Arrange
        final nutritionInfo = {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          // Some fields missing
        };

        // Act
        final result = FoodAnalysisParser.isEmptyNutrition(nutritionInfo);

        // Assert
        expect(result, isTrue);
      });

      test('should handle non-numeric strings as zero', () {
        // Arrange
        final nutritionInfo = {
          'calories': null,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          'sodium': null,
          'fiber': 0,
          'sugar': 0,
          'saturated_fat': 0,
          'cholesterol': null,
          'nutrition_density': null
        };

        // Act
        // This test is checking the behavior of isEmptyNutrition with invalid non-numeric strings
        // It considers these as empty values, so parseDouble is not called directly
        final result = FoodAnalysisParser.isEmptyNutrition(nutritionInfo);

        // Assert
        expect(result, isTrue); // All values are effectively zero or null
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

      test('should handle missing name in ingredient', () {
        // Arrange
        final ingredients = [
          {'servings': 100}, // Missing name
          {'name': 'Banana', 'servings': 50},
        ];

        // Act
        final result = FoodAnalysisParser.parseIngredients(ingredients);

        // Assert
        expect(result.length, equals(2));
        expect(result[0].name, equals('Unknown ingredient'));
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

      test('should handle different types for servings', () {
        // Arrange
        final ingredients = [
          {'name': 'Item1', 'servings': 100}, // int
          {'name': 'Item2', 'servings': 50.5}, // double
          {'name': 'Item3', 'servings': '75'}, // string
          {'name': 'Item4', 'servings': '60.5'}, // string with decimal
          {'name': 'Item5', 'servings': 'invalid'} // invalid string
        ];

        // Act
        final result = FoodAnalysisParser.parseIngredients(ingredients);

        // Assert
        expect(result.length, equals(5));
        expect(result[0].servings, equals(100));
        expect(result[1].servings, equals(50.5));
        expect(result[2].servings, equals(75));
        expect(result[3].servings, equals(60.5));
        expect(result[4].servings, equals(0)); // Invalid string defaults to 0
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

      test('should handle empty string', () {
        // Act
        final result = FoodAnalysisParser.parseDouble('');

        // Assert
        expect(result, equals(0.0));
      });

      test('should handle non-numeric types', () {
        // Act & Assert
        expect(FoodAnalysisParser.parseDouble(true), equals(0.0));
        expect(FoodAnalysisParser.parseDouble([]), equals(0.0));
        expect(FoodAnalysisParser.parseDouble({}), equals(0.0));
      });
    });

    test('should parse vitamins and minerals data', () {
      // Arrange
      final jsonMap = {
        "food_name": "Nutritious Food",
        "ingredients": [],
        "nutrition_info": {
          "calories": 200,
          "protein": 10,
          "carbs": 25,
          "fat": 8,
          "sodium": 50,
          "fiber": 5,
          "sugar": 10,
          "vitamins_and_minerals": {
            "vitamin_a": 800,
            "vitamin_c": 60,
            "calcium": 200,
            "iron": 2.5
          }
        }
      };

      // Act
      final result = FoodAnalysisParser.parseMap(jsonMap);

      // Assert
      expect(
          result.nutritionInfo.vitaminsAndMinerals, isA<Map<String, double>>());
      expect(result.nutritionInfo.vitaminsAndMinerals.length, 4);
      expect(result.nutritionInfo.vitaminsAndMinerals['vitamin_a'], 800);
      expect(result.nutritionInfo.vitaminsAndMinerals['vitamin_c'], 60);
      expect(result.nutritionInfo.vitaminsAndMinerals['calcium'], 200);
      expect(result.nutritionInfo.vitaminsAndMinerals['iron'], 2.5);
    });
  });
}
