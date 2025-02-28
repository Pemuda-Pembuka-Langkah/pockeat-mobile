// test/pockeat/features/ai_api_scan/services/gemini_service_test.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';
import 'test_gemini_service.dart';

void main() {
  late TestGeminiService geminiService;
  
  setUp(() {
    geminiService = TestGeminiService();
  });
  
  group('GeminiService - Food Analysis', () {
    test('analyzeFoodByText returns parsed result', () async {
      // Arrange
      final testJson = '''{
        "food_name": "Apple",
        "ingredients": [
          {"name": "Apple", "percentage": 100, "allergen": false}
        ],
        "nutrition_info": {
          "calories": 95,
          "protein": 0.5,
          "carbs": 25.1,
          "fat": 0.3,
          "sodium": 2,
          "fiber": 4.4,
          "sugar": 19.0
        }
      }''';
      
      geminiService.setFoodTextResponse('Apple', testJson);
      
      // Act
      final result = await geminiService.analyzeFoodByText('Apple');
      
      // Assert
      expect(geminiService.calls, contains('analyzeFoodByText: Apple'));
      
      // Verify structure, not specific values
      expect(result, isA<FoodAnalysisResult>());
      expect(result.foodName, isA<String>());
      expect(result.ingredients, isA<List<Ingredient>>());
      expect(result.nutritionInfo, isA<NutritionInfo>());
      expect(result.nutritionInfo.calories, isA<double>());
      expect(result.nutritionInfo.protein, isA<double>());
      expect(result.nutritionInfo.carbs, isA<double>());
      expect(result.nutritionInfo.fat, isA<double>());
      expect(result.nutritionInfo.sodium, isA<double>());
      expect(result.nutritionInfo.fiber, isA<double>());
      expect(result.nutritionInfo.sugar, isA<double>());
    });
    
    test('analyzeFoodByImage returns parsed result', () async {
      // Arrange
      final tempDir = Directory.systemTemp.createTempSync();
      final testFile = File('${tempDir.path}/test_image.jpg')..writeAsStringSync('test image content');
      
      final testJson = '''{
        "food_name": "Pizza",
        "ingredients": [
          {"name": "Dough", "percentage": 40, "allergen": true},
          {"name": "Cheese", "percentage": 30, "allergen": true},
          {"name": "Tomato sauce", "percentage": 20, "allergen": false}
        ],
        "nutrition_info": {
          "calories": 285,
          "protein": 12,
          "carbs": 36,
          "fat": 10,
          "sodium": 560,
          "fiber": 2.5,
          "sugar": 3.8
        }
      }''';
      
      geminiService.setFoodImageResponse(testFile.path, testJson);
      
      // Act
      final result = await geminiService.analyzeFoodByImage(testFile);
      
      // Assert
      expect(geminiService.calls, contains('analyzeFoodByImage: ${testFile.path}'));
      
      // Verify structure, not specific values
      expect(result, isA<FoodAnalysisResult>());
      expect(result.foodName, isA<String>());
      expect(result.ingredients, isA<List<Ingredient>>());
      expect(result.nutritionInfo, isA<NutritionInfo>());
      
      // Clean up
      tempDir.deleteSync(recursive: true);
    });
    
    test('analyzeNutritionLabel returns parsed result', () async {
      // Arrange
      final tempDir = Directory.systemTemp.createTempSync();
      final testFile = File('${tempDir.path}/nutrition_label.jpg')..writeAsStringSync('test image content');
      final servings = 1.5;
      
      final testJson = '''{
        "food_name": "Cereal",
        "ingredients": [
          {"name": "Wheat", "percentage": 65, "allergen": true},
          {"name": "Sugar", "percentage": 20, "allergen": false}
        ],
        "nutrition_info": {
          "calories": 240,
          "protein": 4,
          "carbs": 46,
          "fat": 2,
          "sodium": 320,
          "fiber": 3.5,
          "sugar": 12.0
        }
      }''';
      
      geminiService.setNutritionLabelResponse(testFile.path, servings, testJson);
      
      // Act
      final result = await geminiService.analyzeNutritionLabel(testFile, servings);
      
      // Assert
      expect(geminiService.calls, contains('analyzeNutritionLabel: ${testFile.path}_$servings'));
      
      // Verify structure, not specific values
      expect(result, isA<FoodAnalysisResult>());
      expect(result.foodName, isA<String>());
      expect(result.ingredients, isA<List<Ingredient>>());
      expect(result.nutritionInfo, isA<NutritionInfo>());
      
      // Clean up
      tempDir.deleteSync(recursive: true);
    });
    
    test('handles case when food is not detected in image', () async {
      // Arrange
      final tempDir = Directory.systemTemp.createTempSync();
      final testFile = File('${tempDir.path}/not_food.jpg')..writeAsStringSync('test image content');
      
      final testJson = '''{
        "error": "No food detected in image",
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
        }
      }''';
      
      geminiService.setFoodImageResponse(testFile.path, testJson);
      
      // Act
      final result = await geminiService.analyzeFoodByImage(testFile);
      
      // Assert
      expect(result, isA<FoodAnalysisResult>());
      expect(result.foodName, 'Unknown');
      expect(result.ingredients, isEmpty);
      
      // Clean up
      tempDir.deleteSync(recursive: true);
    });
  });
  
  group('GeminiService - Exercise Analysis', () {
    test('analyzeExercise returns parsed result', () async {
      // Arrange
      final description = '30 minutes of running at 6mph';
      final testJson = '''{
        "exercise_type": "Running",
        "calories_burned": 350,
        "duration_minutes": 30,
        "intensity_level": "Moderate",
        "met_value": 7.0
      }''';
      
      geminiService.setExerciseResponse(description, testJson);
      
      // Act
      final result = await geminiService.analyzeExercise(description);
      
      // Assert
      expect(geminiService.calls, contains('analyzeExercise: $description'));
      
      // Verify structure, not specific values
      expect(result, isA<ExerciseAnalysisResult>());
      expect(result.exerciseType, isA<String>());
      expect(result.estimatedCalories, isA<int>());
      expect(result.duration, isA<String>());
      expect(result.intensity, isA<String>());
      expect(result.metValue, isA<double>());
    });
    
    test('analyzeExercise with user weight parameter returns parsed result', () async {
      // Arrange
      final description = '30 minutes of running at 6mph';
      final weight = 75.0;
      final testJson = '''{
        "exercise_type": "Running",
        "calories_burned": 420,
        "duration_minutes": 30,
        "intensity_level": "Moderate",
        "met_value": 7.0
      }''';
      
      geminiService.setExerciseResponseWithWeight(description, weight, testJson);
      
      // Act
      final result = await geminiService.analyzeExercise(description, userWeightKg: weight);
      
      // Assert
      expect(geminiService.calls, contains('analyzeExercise: ${description}_w$weight'));
      
      // Verify structure, not specific values
      expect(result, isA<ExerciseAnalysisResult>());
      expect(result.estimatedCalories, isA<int>());
    });
  });
  
  group('GeminiService - Error Handling', () {
    test('handles error responses appropriately', () async {
      // Arrange
      // Setup the service to throw an error on analyzeFoodByText
      expect(
        () => geminiService.throwError('analyzeFoodByText', 'API key not valid'),
        throwsA(isA<GeminiServiceException>()),
      );
    });
    
    test('handles malformed JSON responses', () async {
      // Arrange
      geminiService.setFoodTextResponse('Invalid', 'This is not valid JSON');
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByText('Invalid'),
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });
}