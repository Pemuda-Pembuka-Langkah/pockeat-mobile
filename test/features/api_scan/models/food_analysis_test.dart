// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';

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
        'timestamp': 1710320000000, // March 13, 2024 timestamp
        'health_score': 8.5
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
      expect(result.timestamp,
          equals(DateTime.fromMillisecondsSinceEpoch(1710320000000)));
      expect(result.healthScore, 8.5);
      expect(result.additionalInformation, isEmpty);
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

    test('should handle string timestamp in JSON', () {
      // Arrange
      final timestamp = DateTime(2024, 3, 13);
      final timestampString = timestamp.toIso8601String();

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
        'timestamp': timestampString
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
          sugar: 10,
          saturatedFat: 2.0,
          cholesterol: 15.0,
          nutritionDensity: 80.0,
        ),
        timestamp: testDate,
        foodImageUrl: 'https://example.com/image.jpg',
        additionalInformation: {'source': 'manual_entry'},
        healthScore: 7.5,
      );

      // Act
      final json = foodResult.toJson();

      // Assert
      expect(json['food_name'], 'Test Food');
      expect(json['food_image_url'], 'https://example.com/image.jpg');
      expect(json['id'], 'test-id-123');
      expect(json['timestamp'], isA<String>());
      expect(DateTime.parse(json['timestamp']), equals(testDate));
      expect(json['additional_information'], isA<Map>());
      expect(json['additional_information']['source'], 'manual_entry');
      expect(json['health_score'], 7.5);

      // Verify nutrition info with new fields
      final nutritionJson = json['nutrition_info'];
      expect(nutritionJson['saturated_fat'], 2.0);
      expect(nutritionJson['cholesterol'], 15.0);
      expect(nutritionJson['nutrition_density'], 80.0);
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
            'sodium': 800, // High sodium (> 500mg threshold)
            'fiber': 1,
            'sugar': 5
          }
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings, contains(FoodAnalysisResult.highSodiumWarning));
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
            'sugar': 70 // High sugar (> 20g threshold)
          }
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings, contains(FoodAnalysisResult.highSugarWarning));
        expect(result.warnings.length, 1);
      });

      test('should generate warning for high cholesterol', () {
        // Arrange
        final json = {
          'food_name': 'Fried Food',
          'ingredients': [
            {'name': 'Egg', 'servings': 50}
          ],
          'nutrition_info': {
            'calories': 250,
            'protein': 12,
            'carbs': 15,
            'fat': 18,
            'sodium': 100,
            'fiber': 0,
            'sugar': 2,
            'cholesterol': 300 // High cholesterol (> 200mg threshold)
          }
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings,
            contains(FoodAnalysisResult.highCholesterolWarning));
        expect(result.warnings.length, 1);
      });

      test('should generate warning for high saturated fat', () {
        // Arrange
        final json = {
          'food_name': 'Fatty Meat',
          'ingredients': [
            {'name': 'Pork', 'servings': 150}
          ],
          'nutrition_info': {
            'calories': 400,
            'protein': 25,
            'carbs': 0,
            'fat': 35,
            'saturated_fat': 12, // High saturated fat (> 5g threshold)
            'sodium': 200,
            'fiber': 0,
            'sugar': 0
          }
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings,
            contains(FoodAnalysisResult.highSaturatedFatWarning));
        expect(result.warnings.length, 1);
      });

      test(
          'should generate multiple warnings when several nutrition values are high',
          () {
        // Arrange
        final json = {
          'food_name': 'Unhealthy Processed Food',
          'ingredients': [
            {'name': 'Sugar', 'servings': 40},
            {'name': 'Salt', 'servings': 10},
            {'name': 'Fat', 'servings': 30}
          ],
          'nutrition_info': {
            'calories': 550,
            'protein': 5,
            'carbs': 60,
            'fat': 35,
            'saturated_fat': 12, // High saturated fat
            'sodium': 1200, // High sodium
            'fiber': 1,
            'sugar': 45, // High sugar
            'cholesterol': 250 // High cholesterol
          }
        };

        // Act
        final result = FoodAnalysisResult.fromJson(json);

        // Assert
        expect(result.warnings, contains(FoodAnalysisResult.highSodiumWarning));
        expect(result.warnings, contains(FoodAnalysisResult.highSugarWarning));
        expect(result.warnings,
            contains(FoodAnalysisResult.highCholesterolWarning));
        expect(result.warnings,
            contains(FoodAnalysisResult.highSaturatedFatWarning));
        expect(result.warnings.length, 4);
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
            'sugar': '14.4',
            'saturated_fat': '0.1',
            'cholesterol': '0',
            'nutrition_density': '85.5'
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
        expect(result.nutritionInfo.saturatedFat, 0.1);
        expect(result.nutritionInfo.cholesterol, 0.0);
        expect(result.nutritionInfo.nutritionDensity, 85.5);
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
            'sugar': null, // null value should default to 0.0
            'saturated_fat': null, // null
            'cholesterol': '15', // string
            'nutrition_density': 65 // int
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
        expect(result.nutritionInfo.saturatedFat, 0.0); // Default for null
        expect(result.nutritionInfo.cholesterol, 15.0);
        expect(result.nutritionInfo.nutritionDensity, 65.0);
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
            'sugar': '?',
            'saturated_fat': 'unknown',
            'cholesterol': 'TBD',
            'nutrition_density': '-'
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
        expect(result.nutritionInfo.saturatedFat, 0.0);
        expect(result.nutritionInfo.cholesterol, 0.0);
        expect(result.nutritionInfo.nutritionDensity, 0.0);
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

    test('should handle Firestore Timestamp object in JSON', () {
      // Arrange
      final testDate = DateTime(2024, 3, 13);
      final timestampMock =
          Timestamp.fromDate(testDate); // Create actual Firestore Timestamp

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
        'timestamp': timestampMock
      };

      // Act
      final result = FoodAnalysisResult.fromJson(json);

      // Assert
      expect(result.timestamp, equals(testDate));
    });

    test('should handle non-standard timestamp format in JSON', () {
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
        'timestamp': 'invalid-timestamp-format' // Non-standard format
      };

      // Act
      final result = FoodAnalysisResult.fromJson(json);
      final now = DateTime.now();

      // Assert
      expect(result.timestamp, isA<DateTime>());
      // Timestamp should be recent (within the last second)
      expect(now.difference(result.timestamp).inSeconds, lessThanOrEqualTo(1));
    });

    test('should throw ApiServiceException when error is present in JSON', () {
      // Arrange
      final jsonWithStringError = {'error': 'API connection failed'};

      final jsonWithMapError = {
        'error': {'message': 'Invalid food data format'}
      };

      // Act & Assert
      expect(() => FoodAnalysisResult.fromJson(jsonWithStringError),
          throwsA(isA<ApiServiceException>()));
      expect(() => FoodAnalysisResult.fromJson(jsonWithMapError),
          throwsA(isA<ApiServiceException>()));
    });
  });

  group('Health Score Functionality', () {
    test('should calculate health score when not provided in JSON', () {
      // Arrange
      final json = {
        'food_name': 'Healthy Salad',
        'ingredients': [
          {'name': 'Mixed Greens', 'servings': 100}
        ],
        'nutrition_info': {
          'calories': 120,
          'protein': 5,
          'carbs': 15,
          'fat': 3,
          'sodium': 80, // Low sodium
          'fiber': 5, // Good fiber
          'sugar': 5, // Low sugar
          'saturated_fat': 0.5,
          'cholesterol': 0,
          'nutrition_density': 90
        }
      };

      // Act
      final result = FoodAnalysisResult.fromJson(json);

      // Assert
      expect(result.healthScore, isA<double>());
      expect(result.healthScore, greaterThan(7.0)); // Should be a good score
    });

    test('should use provided health score when available in JSON', () {
      // Arrange
      final json = {
        'food_name': 'Custom Food',
        'ingredients': [],
        'nutrition_info': {
          'calories': 200,
          'protein': 5,
          'carbs': 30,
          'fat': 8,
          'sodium': 150,
          'fiber': 2,
          'sugar': 10
        },
        'health_score': 6.5 // Provided score
      };

      // Act
      final result = FoodAnalysisResult.fromJson(json);

      // Assert
      expect(result.healthScore, 6.5); // Should use the provided value
    });

    test('should return correct health score category', () {
      // Arrange - create foods with different health scores
      final excellentFood = FoodAnalysisResult(
          foodName: 'Super Healthy',
          ingredients: [],
          nutritionInfo: NutritionInfo(
              calories: 100,
              protein: 10,
              carbs: 15,
              fat: 2,
              sodium: 50,
              fiber: 6,
              sugar: 2),
          healthScore: 9.0);

      final goodFood = FoodAnalysisResult(
          foodName: 'Good Food',
          ingredients: [],
          nutritionInfo: NutritionInfo(
              calories: 200,
              protein: 8,
              carbs: 25,
              fat: 5,
              sodium: 150,
              fiber: 3,
              sugar: 8),
          healthScore: 7.5);

      final fairFood = FoodAnalysisResult(
          foodName: 'Average Food',
          ingredients: [],
          nutritionInfo: NutritionInfo(
              calories: 300,
              protein: 4,
              carbs: 40,
              fat: 12,
              sodium: 300,
              fiber: 2,
              sugar: 15),
          healthScore: 5.5);

      final poorFood = FoodAnalysisResult(
          foodName: 'Unhealthy Food',
          ingredients: [],
          nutritionInfo: NutritionInfo(
              calories: 500,
              protein: 2,
              carbs: 60,
              fat: 25,
              sodium: 800,
              fiber: 1,
              sugar: 35),
          healthScore: 3.5);

      final veryPoorFood = FoodAnalysisResult(
          foodName: 'Extremely Unhealthy',
          ingredients: [],
          nutritionInfo: NutritionInfo(
              calories: 600,
              protein: 1,
              carbs: 70,
              fat: 35,
              sodium: 1500,
              fiber: 0,
              sugar: 50),
          healthScore: 1.5);

      // Assert
      expect(excellentFood.getHealthScoreCategory(), 'Excellent');
      expect(goodFood.getHealthScoreCategory(), 'Good');
      expect(fairFood.getHealthScoreCategory(), 'Fair');
      expect(poorFood.getHealthScoreCategory(), 'Poor');
      expect(veryPoorFood.getHealthScoreCategory(), 'Very Poor');
    });
  });

  group('FoodAnalysisResult Additional Coverage Tests', () {
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

    test('toJson should correctly serialize additionalInformation', () {
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
          additionalInformation: {
            'source': 'api',
            'confidence': 0.95,
            'analyzed_date': '2025-04-30'
          });

      // Act
      final json = result.toJson();

      // Assert
      expect(json['additional_information'], isA<Map>());
      expect(json['additional_information']['source'], 'api');
      expect(json['additional_information']['confidence'], 0.95);
      expect(json['additional_information']['analyzed_date'], '2025-04-30');
    });

    test('copyWith should correctly copy all fields including new ones', () {
      // Arrange
      final original = FoodAnalysisResult(
        foodName: 'Original Food',
        ingredients: [Ingredient(name: 'Original Ingredient', servings: 100)],
        nutritionInfo: NutritionInfo(
            calories: 100,
            protein: 5,
            carbs: 10,
            fat: 2,
            sodium: 50,
            fiber: 3,
            sugar: 5,
            saturatedFat: 1.0,
            cholesterol: 10,
            nutritionDensity: 75),
        warnings: ['Original Warning'],
        foodImageUrl: 'original.jpg',
        timestamp: DateTime(2024, 1, 1),
        id: 'original-id',
        additionalInformation: {'type': 'original'},
        healthScore: 6.5,
      );

      // Act - copy with modified values
      final modified = original.copyWith(
        foodName: 'Modified Food',
        additionalInformation: {'type': 'modified'},
        healthScore: 8.0,
      );

      // Assert - modified fields should change
      expect(modified.foodName, 'Modified Food');
      expect(modified.additionalInformation['type'], 'modified');
      expect(modified.healthScore, 8.0);

      // Unmodified fields should remain the same
      expect(modified.ingredients, original.ingredients);
      expect(modified.nutritionInfo, original.nutritionInfo);
      expect(modified.warnings, original.warnings);
      expect(modified.foodImageUrl, original.foodImageUrl);
      expect(modified.timestamp, original.timestamp);
      expect(modified.id, original.id);
    });

    test('NutritionInfo copyWith should correctly copy all fields', () {
      // Arrange
      final original = NutritionInfo(
          calories: 100,
          protein: 5,
          carbs: 10,
          fat: 2,
          sodium: 50,
          fiber: 3,
          sugar: 5,
          saturatedFat: 0.5,
          cholesterol: 10,
          nutritionDensity: 80,
          vitaminsAndMinerals: {'vitamin_c': 15, 'iron': 2});

      // Act
      final modified = original.copyWith(
          calories: 150,
          protein: 8,
          vitaminsAndMinerals: {'vitamin_c': 20, 'iron': 3, 'calcium': 100});

      // Assert
      expect(modified.calories, 150);
      expect(modified.protein, 8);
      expect(modified.vitaminsAndMinerals['vitamin_c'], 20);
      expect(modified.vitaminsAndMinerals['iron'], 3);
      expect(modified.vitaminsAndMinerals['calcium'], 100);

      // Unchanged fields
      expect(modified.carbs, original.carbs);
      expect(modified.fat, original.fat);
      expect(modified.sodium, original.sodium);
      expect(modified.fiber, original.fiber);
      expect(modified.sugar, original.sugar);
      expect(modified.saturatedFat, original.saturatedFat);
      expect(modified.cholesterol, original.cholesterol);
      expect(modified.nutritionDensity, original.nutritionDensity);
    });

    test('should parse vitamins and minerals from JSON', () {
      // Arrange
      final json = {
        'food_name': 'Nutritious Food',
        'ingredients': [],
        'nutrition_info': {
          'calories': 200,
          'protein': 10,
          'carbs': 25,
          'fat': 8,
          'sodium': 100,
          'fiber': 5,
          'sugar': 5,
          'vitamins_and_minerals': {
            'vitamin_a': 800,
            'vitamin_c': 60,
            'calcium': 200,
            'iron': 2.5
          }
        }
      };

      // Act
      final result = FoodAnalysisResult.fromJson(json);

      // Assert
      expect(
          result.nutritionInfo.vitaminsAndMinerals, isA<Map<String, double>>());
      expect(result.nutritionInfo.vitaminsAndMinerals['vitamin_a'], 800);
      expect(result.nutritionInfo.vitaminsAndMinerals['vitamin_c'], 60);
      expect(result.nutritionInfo.vitaminsAndMinerals['calcium'], 200);
      expect(result.nutritionInfo.vitaminsAndMinerals['iron'], 2.5);
    });
  });
}
