// // Package imports:
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_test/flutter_test.dart';

// // Project imports:
// import 'package:pockeat/features/api_scan/models/food_analysis.dart';
// import 'package:pockeat/features/api_scan/services/base/api_service.dart';

// void main() {
//   group('FoodAnalysisResult Model', () {
//     test('should create FoodAnalysisResult from JSON', () {
//       // Arrange
//       final json = {
//         'food_name': 'Apple',
//         'ingredients': [
//           {'name': 'Apple', 'servings': 100}
//         ],
//         'nutrition_info': {
//           'calories': 95,
//           'protein': 0.5,
//           'carbs': 25.1,
//           'fat': 0.3,
//           'sodium': 2,
//           'fiber': 4.4,
//           'sugar': 19.0
//         },
//         'timestamp': 1710320000000 // March 13, 2024 timestamp
//       };

//       // Act
//       final result = FoodAnalysisResult.fromJson(json);

//       // Assert
//       expect(result.foodName, 'Apple');
//       expect(result.ingredients.length, 1);
//       expect(result.ingredients[0].name, 'Apple');
//       expect(result.nutritionInfo.calories, 95);
//       expect(result.nutritionInfo.sodium, 2);
//       expect(result.nutritionInfo.fiber, 4.4);
//       expect(result.nutritionInfo.sugar, 19.0);
//       expect(result.warnings, isEmpty); // No warnings for normal sugar/sodium
//       expect(result.timestamp, isA<DateTime>());
//       expect(result.timestamp,
//           equals(DateTime.fromMillisecondsSinceEpoch(1710320000000)));
//     });

//     test('should set default timestamp when not provided in JSON', () {
//       // Arrange
//       final json = {
//         'food_name': 'Apple',
//         'ingredients': [
//           {'name': 'Apple', 'servings': 100}
//         ],
//         'nutrition_info': {
//           'calories': 95,
//           'protein': 0.5,
//           'carbs': 25.1,
//           'fat': 0.3,
//           'sodium': 2,
//           'fiber': 4.4,
//           'sugar': 19.0
//         }
//       };

//       // Act
//       final result = FoodAnalysisResult.fromJson(json);
//       final now = DateTime.now();

//       // Assert
//       expect(result.timestamp, isA<DateTime>());
//       // Timestamp should be recent (within the last second)
//       expect(now.difference(result.timestamp).inSeconds, lessThanOrEqualTo(1));
//     });

//     test('should handle Timestamp object in JSON', () {
//       // Arrange
//       final timestamp = DateTime(2024, 3, 13);
//       final timestampMillis = timestamp.millisecondsSinceEpoch;

//       final json = {
//         'food_name': 'Apple',
//         'ingredients': [
//           {'name': 'Apple', 'servings': 100}
//         ],
//         'nutrition_info': {
//           'calories': 95,
//           'protein': 0.5,
//           'carbs': 25.1,
//           'fat': 0.3,
//           'sodium': 2,
//           'fiber': 4.4,
//           'sugar': 19.0
//         },
//         'timestamp': timestampMillis
//       };

//       // Act
//       final result = FoodAnalysisResult.fromJson(json);

//       // Assert
//       expect(result.timestamp, equals(timestamp));
//     });

//     test('should handle string timestamp in JSON', () {
//       // Arrange
//       final timestamp = DateTime(2024, 3, 13);
//       final timestampString = timestamp.toIso8601String();

//       final json = {
//         'food_name': 'Apple',
//         'ingredients': [
//           {'name': 'Apple', 'servings': 100}
//         ],
//         'nutrition_info': {
//           'calories': 95,
//           'protein': 0.5,
//           'carbs': 25.1,
//           'fat': 0.3,
//           'sodium': 2,
//           'fiber': 4.4,
//           'sugar': 19.0
//         },
//         'timestamp': timestampString
//       };

//       // Act
//       final result = FoodAnalysisResult.fromJson(json);

//       // Assert
//       expect(result.timestamp, equals(timestamp));
//     });

//     test('should convert to JSON with all fields', () {
//       // Arrange
//       final testDate = DateTime(2024, 3, 13);
//       final foodResult = FoodAnalysisResult(
//           id: 'test-id-123',
//           foodName: 'Test Food',
//           ingredients: [Ingredient(name: 'Test Ingredient', servings: 100)],
//           nutritionInfo: NutritionInfo(
//               calories: 100,
//               protein: 10,
//               carbs: 20,
//               fat: 5,
//               sodium: 100,
//               fiber: 5,
//               sugar: 10),
//           timestamp: testDate,
//           foodImageUrl: 'https://example.com/image.jpg');

//       // Act
//       final json = foodResult.toJson();

//       // Assert
//       expect(json['food_name'], 'Test Food');
//       expect(json['food_image_url'], 'https://example.com/image.jpg');
//       expect(json['id'], 'test-id-123');
//       expect(json['timestamp'], isA<Timestamp>());
//       expect((json['timestamp'] as Timestamp).toDate(), equals(testDate));
//     });

//     test('should parse empty or null ingredients correctly', () {
//       // Arrange
//       final jsonWithNull = {
//         'food_name': 'Test Food',
//         'ingredients': null,
//         'nutrition_info': {
//           'calories': 100,
//           'protein': 10,
//           'carbs': 20,
//           'fat': 5,
//           'sodium': 100,
//           'fiber': 5,
//           'sugar': 10
//         }
//       };

//       final jsonWithEmptyList = {
//         'food_name': 'Test Food',
//         'ingredients': [],
//         'nutrition_info': {
//           'calories': 100,
//           'protein': 10,
//           'carbs': 20,
//           'fat': 5,
//           'sodium': 100,
//           'fiber': 5,
//           'sugar': 10
//         }
//       };

//       // Act
//       final resultWithNull = FoodAnalysisResult.fromJson(jsonWithNull);
//       final resultWithEmptyList =
//           FoodAnalysisResult.fromJson(jsonWithEmptyList);

//       // Assert
//       expect(resultWithNull.ingredients, isEmpty);
//       expect(resultWithEmptyList.ingredients, isEmpty);
//     });

//     group('Warning generation', () {
//       test('should generate warning for high sodium', () {
//         // Arrange
//         final json = {
//           'food_name': 'Instant Soup',
//           'ingredients': [
//             {'name': 'Sodium', 'servings': 20}
//           ],
//           'nutrition_info': {
//             'calories': 200,
//             'protein': 5,
//             'carbs': 20,
//             'fat': 10,
//             'sodium': 800, // High sodium
//             'fiber': 1,
//             'sugar': 5
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.warnings, contains('High sodium content'));
//         expect(result.warnings.length, 1);
//       });

//       test('should generate warning for high sugar', () {
//         // Arrange
//         final json = {
//           'food_name': 'Candy',
//           'ingredients': [
//             {'name': 'Sugar', 'servings': 80}
//           ],
//           'nutrition_info': {
//             'calories': 300,
//             'protein': 0,
//             'carbs': 75,
//             'fat': 0,
//             'sodium': 10,
//             'fiber': 0,
//             'sugar': 70 // High sugar
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.warnings, contains('High sugar content'));
//         expect(result.warnings.length, 1);
//       });

//       test('should generate warning for high cholesterol', () {
//         // Arrange
//         final json = {
//           'food_name': 'High Cholesterol Food',
//           'ingredients': [
//             {'name': 'Egg Yolk', 'servings': 50}
//           ],
//           'nutrition_info': {
//             'calories': 200,
//             'protein': 15,
//             'carbs': 5,
//             'fat': 15,
//             'sodium': 100,
//             'fiber': 0,
//             'sugar': 2,
//             'cholesterol': 250 // High cholesterol (>200mg)
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.warnings, contains('High cholesterol content'));
//         expect(result.warnings.length, 1);
//       });

//       test('should generate warning for high saturated fat', () {
//         // Arrange
//         final json = {
//           'food_name': 'High Fat Food',
//           'ingredients': [
//             {'name': 'Butter', 'servings': 30}
//           ],
//           'nutrition_info': {
//             'calories': 200,
//             'protein': 2,
//             'carbs': 5,
//             'fat': 20,
//             'saturated_fat': 12, // High saturated fat (>5g)
//             'sodium': 100,
//             'fiber': 0,
//             'sugar': 2
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.warnings, contains('High saturated fat content'));
//         expect(result.warnings.length, 1);
//       });

//       test(
//           'should generate multiple warnings when both sugar and sodium are high',
//           () {
//         // Arrange
//         final json = {
//           'food_name': 'Sweetened Canned Food',
//           'ingredients': [
//             {'name': 'Sugar', 'servings': 40},
//             {'name': 'Salt', 'servings': 10}
//           ],
//           'nutrition_info': {
//             'calories': 400,
//             'protein': 5,
//             'carbs': 80,
//             'fat': 5,
//             'sodium': 1200, // High sodium
//             'fiber': 1,
//             'sugar': 50 // High sugar
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.warnings, contains('High sodium content'));
//         expect(result.warnings, contains('High sugar content'));
//         expect(result.warnings.length, 2);
//       });

//       test('should use provided warnings when available in JSON', () {
//         // Arrange
//         final json = {
//           'food_name': 'Custom Food',
//           'ingredients': [
//             {'name': 'Ingredient', 'servings': 100}
//           ],
//           'nutrition_info': {
//             'calories': 200,
//             'protein': 5,
//             'carbs': 20,
//             'fat': 10,
//             'sodium': 200, // Not high
//             'fiber': 2,
//             'sugar': 5 // Not high
//           },
//           'warnings': ['Contains artificial colors', 'Contains preservatives']
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.warnings, contains('Contains artificial colors'));
//         expect(result.warnings, contains('Contains preservatives'));
//         expect(result.warnings.length, 2);
//       });
//     });

//     group('Numeric value conversion', () {
//       test('should handle string values in nutrition info', () {
//         // Arrange
//         final json = {
//           'food_name': 'Banana',
//           'ingredients': [],
//           'nutrition_info': {
//             'calories': '105',
//             'protein': '1.3',
//             'carbs': '27',
//             'fat': '0.4',
//             'sodium': '1',
//             'fiber': '3.1',
//             'sugar': '14.4'
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.nutritionInfo.calories, 105.0);
//         expect(result.nutritionInfo.protein, 1.3);
//         expect(result.nutritionInfo.carbs, 27.0);
//         expect(result.nutritionInfo.fat, 0.4);
//         expect(result.nutritionInfo.sodium, 1.0);
//         expect(result.nutritionInfo.fiber, 3.1);
//         expect(result.nutritionInfo.sugar, 14.4);
//         expect(result.warnings, isEmpty); // No warnings
//       });

//       test('should handle numeric values with different types', () {
//         // Arrange
//         final json = {
//           'food_name': 'Mixed Types',
//           'ingredients': [],
//           'nutrition_info': {
//             'calories': 100, // int
//             'protein': 2.5, // double
//             'carbs': '30.5', // string
//             'fat': '0', // string zero
//             'sodium': 5, // int
//             'fiber': '3.5', // string
//             'sugar': null // null value should default to 0.0
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.nutritionInfo.calories, 100.0);
//         expect(result.nutritionInfo.protein, 2.5);
//         expect(result.nutritionInfo.carbs, 30.5);
//         expect(result.nutritionInfo.fat, 0.0);
//         expect(result.nutritionInfo.sodium, 5.0);
//         expect(result.nutritionInfo.fiber, 3.5);
//         expect(result.nutritionInfo.sugar, 0.0); // Default for null
//         expect(result.warnings, isEmpty); // No warnings
//       });

//       test('should handle invalid string values', () {
//         // Arrange
//         final json = {
//           'food_name': 'Invalid Data',
//           'ingredients': [],
//           'nutrition_info': {
//             'calories': 'not-a-number',
//             'protein': 'abc',
//             'carbs': '5g',
//             'fat': '',
//             'sodium': 'N/A',
//             'fiber': '~2.5',
//             'sugar': '?'
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         // All invalid string values should default to 0.0
//         expect(result.nutritionInfo.calories, 0.0);
//         expect(result.nutritionInfo.protein, 0.0);
//         expect(result.nutritionInfo.carbs, 0.0);
//         expect(result.nutritionInfo.fat, 0.0);
//         expect(result.nutritionInfo.sodium, 0.0);
//         expect(result.nutritionInfo.fiber, 0.0);
//         expect(result.nutritionInfo.sugar, 0.0);
//         expect(result.warnings, isEmpty); // No warnings for zero values
//       });
//     });

//     group('Ingredient servings handling', () {
//       test('should handle different types for ingredient servings', () {
//         // Arrange
//         final json = {
//           'food_name': 'Mixed Salad',
//           'ingredients': [
//             {'name': 'Lettuce', 'servings': 50.5},
//             {'name': 'Tomato', 'servings': '25.5'},
//             {'name': 'Cucumber', 'servings': 15},
//             {'name': 'Nuts', 'servings': '9'}
//           ],
//           'nutrition_info': {
//             'calories': 100,
//             'protein': 2,
//             'carbs': 10,
//             'fat': 5,
//             'sodium': 10,
//             'fiber': 3,
//             'sugar': 2
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.ingredients.length, 4);
//         expect(result.ingredients[0].servings, 50.5);
//         expect(result.ingredients[1].servings, 25.5);
//         expect(result.ingredients[2].servings, 15.0);
//         expect(result.ingredients[3].servings, 9.0);
//         expect(result.warnings, isEmpty); // No warnings
//       });

//       test('should handle invalid servings values', () {
//         // Arrange
//         final json = {
//           'food_name': 'Problem Data',
//           'ingredients': [
//             {'name': 'Valid', 'servings': 80},
//             {'name': 'Invalid', 'servings': 'unknown'}
//           ],
//           'nutrition_info': {
//             'calories': 100,
//             'protein': 2,
//             'carbs': 10,
//             'fat': 5,
//             'sodium': 10,
//             'fiber': 3,
//             'sugar': 2
//           }
//         };

//         // Act
//         final result = FoodAnalysisResult.fromJson(json);

//         // Assert
//         expect(result.ingredients.length, 2);
//         expect(result.ingredients[0].servings, 80.0);
//         expect(
//             result.ingredients[1].servings, 0.0); // Default for invalid string
//         expect(result.warnings, isEmpty); // No warnings
//       });
//     });

//     test('should handle Firestore Timestamp object in JSON', () {
//       // Arrange
//       final testDate = DateTime(2024, 3, 13);
//       final timestampMock =
//           Timestamp.fromDate(testDate); // Create actual Firestore Timestamp

//       final json = {
//         'food_name': 'Apple',
//         'ingredients': [
//           {'name': 'Apple', 'servings': 100}
//         ],
//         'nutrition_info': {
//           'calories': 95,
//           'protein': 0.5,
//           'carbs': 25.1,
//           'fat': 0.3,
//           'sodium': 2,
//           'fiber': 4.4,
//           'sugar': 19.0
//         },
//         'timestamp': timestampMock
//       };

//       // Act
//       final result = FoodAnalysisResult.fromJson(json);

//       // Assert
//       expect(result.timestamp, equals(testDate));
//     });

//     test('should handle non-standard timestamp format in JSON', () {
//       // Arrange
//       final json = {
//         'food_name': 'Apple',
//         'ingredients': [
//           {'name': 'Apple', 'servings': 100}
//         ],
//         'nutrition_info': {
//           'calories': 95,
//           'protein': 0.5,
//           'carbs': 25.1,
//           'fat': 0.3,
//           'sodium': 2,
//           'fiber': 4.4,
//           'sugar': 19.0
//         },
//         'timestamp': 'invalid-timestamp-format' // Non-standard format
//       };

//       // Act
//       final result = FoodAnalysisResult.fromJson(json);
//       final now = DateTime.now();

//       // Assert
//       expect(result.timestamp, isA<DateTime>());
//       // Timestamp should be recent (within the last second)
//       expect(now.difference(result.timestamp).inSeconds, lessThanOrEqualTo(1));
//     });

//     test('should calculate health score correctly', () {
//       // Create test foods with different nutritional profiles
//       final healthyFood = FoodAnalysisResult(
//         foodName: 'Healthy Food',
//         ingredients: [Ingredient(name: 'Ingredients', servings: 100)],
//         nutritionInfo: NutritionInfo(
//           calories: 200,
//           protein: 20, // High protein (good)
//           carbs: 30,
//           fat: 5, // Low fat (good)
//           saturatedFat: 1, // Low saturated fat (good)
//           sodium: 100, // Low sodium (good)
//           fiber: 8, // High fiber (good)
//           sugar: 5, // Low sugar (good)
//           cholesterol: 20, // Low cholesterol (good)
//           nutritionDensity: 80, // High nutrition density (good)
//         ),
//       );

//       final unhealthyFood = FoodAnalysisResult(
//         foodName: 'Unhealthy Food',
//         ingredients: [Ingredient(name: 'Ingredients', servings: 100)],
//         nutritionInfo: NutritionInfo(
//           calories: 400,
//           protein: 5, // Low protein
//           carbs: 50,
//           fat: 30, // High fat
//           saturatedFat: 15, // High saturated fat
//           sodium: 1000, // High sodium
//           fiber: 1, // Low fiber
//           sugar: 35, // High sugar
//           cholesterol: 250, // High cholesterol
//           nutritionDensity: 20, // Low nutrition density
//         ),
//       );

//       // Assert health scores are in expected ranges
//       expect(healthyFood.healthScore, greaterThan(7.0));
//       expect(unhealthyFood.healthScore, lessThan(5.0));

//       // Check that scores are multiples of 0.5
//       expect(healthyFood.healthScore * 2,
//           equals((healthyFood.healthScore * 2).floor()));
//       expect(unhealthyFood.healthScore * 2,
//           equals((unhealthyFood.healthScore * 2).floor()));
//     });

//     test('should provide correct health score category', () {
//       // Create test foods for each category
//       final excellentFood = FoodAnalysisResult(
//         foodName: 'Excellent Food',
//         ingredients: [],
//         nutritionInfo: NutritionInfo(
//           calories: 100,
//           protein: 15,
//           carbs: 20,
//           fat: 2,
//           sodium: 50,
//           fiber: 5,
//           sugar: 2,
//         ),
//         healthScore: 9.0,
//       );

//       final goodFood = FoodAnalysisResult(
//         foodName: 'Good Food',
//         ingredients: [],
//         nutritionInfo: NutritionInfo(
//           calories: 100,
//           protein: 10,
//           carbs: 30,
//           fat: 5,
//           sodium: 200,
//           fiber: 3,
//           sugar: 5,
//         ),
//         healthScore: 7.5,
//       );

//       final fairFood = FoodAnalysisResult(
//         foodName: 'Fair Food',
//         ingredients: [],
//         nutritionInfo: NutritionInfo(
//           calories: 100,
//           protein: 5,
//           carbs: 40,
//           fat: 10,
//           sodium: 300,
//           fiber: 2,
//           sugar: 10,
//         ),
//         healthScore: 5.5,
//       );

//       final poorFood = FoodAnalysisResult(
//         foodName: 'Poor Food',
//         ingredients: [],
//         nutritionInfo: NutritionInfo(
//           calories: 100,
//           protein: 2,
//           carbs: 40,
//           fat: 20,
//           sodium: 700,
//           fiber: 1,
//           sugar: 25,
//         ),
//         healthScore: 3.5,
//       );

//       final veryPoorFood = FoodAnalysisResult(
//         foodName: 'Very Poor Food',
//         ingredients: [],
//         nutritionInfo: NutritionInfo(
//           calories: 100,
//           protein: 1,
//           carbs: 30,
//           fat: 30,
//           sodium: 1200,
//           fiber: 0,
//           sugar: 40,
//         ),
//         healthScore: 1.5,
//       );

//       // Assert
//       expect(excellentFood.getHealthScoreCategory(), equals('Excellent'));
//       expect(goodFood.getHealthScoreCategory(), equals('Good'));
//       expect(fairFood.getHealthScoreCategory(), equals('Fair'));
//       expect(poorFood.getHealthScoreCategory(), equals('Poor'));
//       expect(veryPoorFood.getHealthScoreCategory(), equals('Very Poor'));
//     });

//     test('should correctly handle copyWith method', () {
//       // Arrange
//       final original = FoodAnalysisResult(
//           id: 'original-id',
//           foodName: 'Original Food',
//           ingredients: [Ingredient(name: 'Original Ingredient', servings: 100)],
//           nutritionInfo: NutritionInfo(
//               calories: 200,
//               protein: 10,
//               carbs: 20,
//               fat: 5,
//               sodium: 150,
//               fiber: 3,
//               sugar: 10),
//           warnings: ['Original Warning'],
//           foodImageUrl: 'http://original.com/image.jpg',
//           userId: 'original-user',
//           healthScore: 6.5,
//           additionalInformation: {'source': 'original'});

//       // Act - Create a copy with some fields changed
//       final modified = original.copyWith(
//           foodName: 'Modified Food',
//           warnings: ['Modified Warning'],
//           healthScore: 7.5,
//           additionalInformation: {'source': 'modified', 'extra': 'data'});

//       // Assert - Check modified fields
//       expect(modified.foodName, 'Modified Food');
//       expect(modified.warnings, ['Modified Warning']);
//       expect(modified.healthScore, 7.5);
//       expect(modified.additionalInformation['source'], 'modified');
//       expect(modified.additionalInformation['extra'], 'data');

//       // Assert - Check preserved fields
//       expect(modified.id, 'original-id');
//       expect(modified.ingredients.length, 1);
//       expect(modified.ingredients[0].name, 'Original Ingredient');
//       expect(modified.foodImageUrl, 'http://original.com/image.jpg');
//       expect(modified.userId, 'original-user');
//     });

//     test(
//         'should handle complex nutrition information with vitamins and minerals',
//         () {
//       // Arrange
//       final json = {
//         'food_name': 'Complete Food',
//         'ingredients': [
//           {'name': 'Main Ingredient', 'servings': 100}
//         ],
//         'nutrition_info': {
//           'calories': 200,
//           'protein': 10,
//           'carbs': 25,
//           'fat': 8,
//           'saturated_fat': 2.5,
//           'sodium': 300,
//           'fiber': 4,
//           'sugar': 8,
//           'cholesterol': 25,
//           'nutrition_density': 75,
//           'vitamins_and_minerals': {
//             'vitamin_a': 500,
//             'vitamin_c': 20,
//             'calcium': 150,
//             'iron': 2.5,
//             'potassium': 300
//           }
//         }
//       };

//       // Act
//       final result = FoodAnalysisResult.fromJson(json);

//       // Assert
//       expect(result.nutritionInfo.saturatedFat, equals(2.5));
//       expect(result.nutritionInfo.cholesterol, equals(25));
//       expect(result.nutritionInfo.nutritionDensity, equals(75));
//       expect(
//           result.nutritionInfo.vitaminsAndMinerals["vitamin_a"], equals(500));
//       expect(result.nutritionInfo.vitaminsAndMinerals["iron"], equals(2.5));
//     });

//     test('should handle API error responses', () {
//       // Arrange
//       final errorJson = {'error': 'Failed to analyze food image'};
//       final detailedErrorJson = {
//         'error': {'message': 'Invalid image format', 'code': 400}
//       };

//       // Act & Assert
//       expect(
//           () => FoodAnalysisResult.fromJson(errorJson),
//           throwsA(isA<ApiServiceException>().having(
//               (e) => e.message, 'message', 'Failed to analyze food image')));

//       expect(
//           () => FoodAnalysisResult.fromJson(detailedErrorJson),
//           throwsA(isA<ApiServiceException>()
//               .having((e) => e.message, 'message', 'Invalid image format')));
//     });
//   });
// }

// // Mock class for Timestamp
// class MockTimestamp {
//   final DateTime _dateTime;

//   MockTimestamp(this._dateTime);

//   DateTime toDate() {
//     return _dateTime;
//   }
// }
