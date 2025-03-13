// test/features/ai_api_scan/services/food/nutrition_label_analysis_service_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

class MockGenerativeModelWrapper extends Mock implements GenerativeModelWrapper {
  String? responseText;
  Exception? exceptionToThrow;

  @override
  Future<dynamic> generateContent(dynamic _) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return _MockGenerateContentResponse(responseText);
  }
}

class _MockGenerateContentResponse {
  final String? text;
  _MockGenerateContentResponse(this.text);
}

class MockFile extends Mock implements File {
  Uint8List? bytesToReturn;
  Exception? exceptionToThrow;

  @override
  Future<Uint8List> readAsBytes() async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return bytesToReturn ?? Uint8List(0);
  }
}

void main() {
  late MockGenerativeModelWrapper mockModelWrapper;
  late MockFile mockFile;
  late NutritionLabelAnalysisService service;

  setUp(() {
    mockModelWrapper = MockGenerativeModelWrapper();
    mockFile = MockFile();
    service = NutritionLabelAnalysisService(
      apiKey: 'test-api-key',
      customModelWrapper: mockModelWrapper,
    );
  });

  group('NutritionLabelAnalysisService', () {
    // Tests remain the same
    test('should analyze nutrition label successfully', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      const servings = 2.5;
      const validJsonResponse = '''
      {
        "food_name": "Cereal",
        "ingredients": [
          {
            "name": "Whole Grain Wheat",
            "servings": 60
          },
          {
            "name": "Sugar",
            "servings": 20
          }
        ],
        "nutrition_info": {
          "calories": 120,
          "protein": 3,
          "carbs": 24,
          "fat": 1,
          "sodium": 210,
          "fiber": 3,
          "sugar": 12
        },
        "warnings": []
      }
      ''';

      // Mock
      mockFile.bytesToReturn = mockBytes;
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.analyze(mockFile, servings);

      // Assert
      expect(result.foodName, equals('Cereal'));
      expect(result.ingredients.length, equals(2));
      expect(result.nutritionInfo.calories, equals(120));
      expect(result.warnings, isEmpty);
    });

    test('should throw exception when file read fails', () async {
      // Arrange
      const servings = 1.0;
      mockFile.exceptionToThrow = Exception('File read error');

      // Act & Assert
      expect(
        () => service.analyze(mockFile, servings),
        throwsA(isA<GeminiServiceException>()),
      );
    });


    test('should throw exception when API returns error response', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      const servings = 1.0;
      const errorResponse = '{"error": "No nutrition label detected"}';
      mockFile.bytesToReturn = mockBytes;
      mockModelWrapper.responseText = errorResponse;

      // Act & Assert
      expect(
        () => service.analyze(mockFile, servings),
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });

    test('should throw exception when response text is null', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      const servings = 1.0;
      mockFile.bytesToReturn = mockBytes;
      mockModelWrapper.responseText = null; // Setting response text to null

      // Act & Assert
      expect(
        () => service.analyze(mockFile, servings),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 
          'error message', 
          'No response text generated'
        )),
      );
    });

    group('NutritionLabelAnalysisService correction functionality', () {
    test('should correct nutrition label analysis successfully', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Cereal',
        ingredients: [
          Ingredient(name: 'Whole Grain Wheat', servings: 60),
          Ingredient(name: 'Sugar', servings: 20),
        ],
        nutritionInfo: NutritionInfo(
          calories: 120,
          protein: 3,
          carbs: 24,
          fat: 1,
          sodium: 210,
          fiber: 3,
          sugar: 12,
        ),
        warnings: [],
      );
      
      const userComment = 'The cereal also contains dried fruit and has higher sugar content';
      const servings = 2.5;
      
      const validJsonResponse = '''
      {
        "food_name": "Fruit Cereal",
        "ingredients": [
          {
            "name": "Whole Grain Wheat",
            "servings": 60
          },
          {
            "name": "Sugar",
            "servings": 20
          },
          {
            "name": "Dried Fruit",
            "servings": 15
          }
        ],
        "nutrition_info": {
          "calories": 150,
          "protein": 3,
          "carbs": 30,
          "fat": 1,
          "sodium": 210,
          "fiber": 4,
          "sugar": 18
        },
        "warnings": []
      }
      ''';

      // Mock
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment, servings);

      // Assert
      expect(result.foodName, equals('Fruit Cereal'));
      expect(result.ingredients.length, equals(3));
      expect(result.ingredients[2].name, equals('Dried Fruit'));
      expect(result.nutritionInfo.calories, equals(150));
      expect(result.nutritionInfo.sugar, equals(18));
      expect(result.nutritionInfo.fiber, equals(4));
      expect(result.warnings, isEmpty);
    });

    test('should update warnings when nutritional values change', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Cereal',
        ingredients: [
          Ingredient(name: 'Whole Grain Wheat', servings: 60),
          Ingredient(name: 'Sugar', servings: 20),
        ],
        nutritionInfo: NutritionInfo(
          calories: 120,
          protein: 3,
          carbs: 24,
          fat: 1,
          sodium: 210,
          fiber: 3,
          sugar: 12,
        ),
        warnings: [],
      );
      
      const userComment = 'The sugar content is much higher, around 22g, and it has more sodium too';
      const servings = 2.5;
      
      const validJsonResponse = '''
      {
        "food_name": "Cereal",
        "ingredients": [
          {
            "name": "Whole Grain Wheat",
            "servings": 60
          },
          {
            "name": "Sugar",
            "servings": 30
          }
        ],
        "nutrition_info": {
          "calories": 140,
          "protein": 3,
          "carbs": 30,
          "fat": 1,
          "sodium": 510,
          "fiber": 3,
          "sugar": 22
        },
        "warnings": ["High sodium content", "High sugar content"]
      }
      ''';

      // Mock
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment, servings);

      // Assert
      expect(result.ingredients[1].servings, equals(30)); // Higher sugar in ingredients
      expect(result.nutritionInfo.sugar, equals(22));
      expect(result.nutritionInfo.sodium, equals(510));
      expect(result.warnings.length, equals(2));
      expect(result.warnings, contains('High sodium content'));
      expect(result.warnings, contains('High sugar content'));
    });

    test('should handle servings adjustment correctly', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Cereal',
        ingredients: [
          Ingredient(name: 'Whole Grain Wheat', servings: 60),
          Ingredient(name: 'Sugar', servings: 20),
        ],
        nutritionInfo: NutritionInfo(
          calories: 120,
          protein: 3,
          carbs: 24,
          fat: 1,
          sodium: 210,
          fiber: 3,
          sugar: 12,
        ),
        warnings: [],
      );
      
      const userComment = 'I\'m actually having a double serving';
      const servings = 5.0; // Changed from original 2.5
      
      const validJsonResponse = '''
      {
        "food_name": "Cereal (Double Serving)",
        "ingredients": [
          {
            "name": "Whole Grain Wheat",
            "servings": 120
          },
          {
            "name": "Sugar",
            "servings": 40
          }
        ],
        "nutrition_info": {
          "calories": 240,
          "protein": 6,
          "carbs": 48,
          "fat": 2,
          "sodium": 420,
          "fiber": 6,
          "sugar": 24
        },
        "warnings": ["High sugar content"]
      }
      ''';

      // Mock
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment, servings);

      // Assert
      expect(result.foodName, equals('Cereal (Double Serving)'));
      expect(result.nutritionInfo.calories, equals(240));
      expect(result.nutritionInfo.sugar, equals(24));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sugar content'));
    });

    test('should throw exception when response text is null', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Cereal',
        ingredients: [
          Ingredient(name: 'Whole Grain Wheat', servings: 60),
          Ingredient(name: 'Sugar', servings: 20),
        ],
        nutritionInfo: NutritionInfo(
          calories: 120,
          protein: 3,
          carbs: 24,
          fat: 1,
          sodium: 210,
          fiber: 3,
          sugar: 12,
        ),
        warnings: [],
      );
      
      const userComment = 'The sugar content is wrong';
      const servings = 2.5;
      mockModelWrapper.responseText = null;

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment, servings),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 
          'error message', 
          'No response text generated'
        )),
      );
    });

    test('should throw exception when API returns error response', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Cereal',
        ingredients: [
          Ingredient(name: 'Whole Grain Wheat', servings: 60),
          Ingredient(name: 'Sugar', servings: 20),
        ],
        nutritionInfo: NutritionInfo(
          calories: 120,
          protein: 3,
          carbs: 24,
          fat: 1,
          sodium: 210,
          fiber: 3,
          sugar: 12,
        ),
        warnings: [],
      );
      
      const userComment = 'The sugar content is wrong';
      const servings = 2.5;
      const errorResponse = '{"error": "Could not process correction"}';
      mockModelWrapper.responseText = errorResponse;

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment, servings),
        throwsA(isA<GeminiServiceException>()),
      );
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Cereal',
        ingredients: [
          Ingredient(name: 'Whole Grain Wheat', servings: 60),
          Ingredient(name: 'Sugar', servings: 20),
        ],
        nutritionInfo: NutritionInfo(
          calories: 120,
          protein: 3,
          carbs: 24,
          fat: 1,
          sodium: 210,
          fiber: 3,
          sugar: 12,
        ),
        warnings: [],
      );
      
      const userComment = 'The sugar content is wrong';
      const servings = 2.5;
      mockModelWrapper.exceptionToThrow = Exception('Network error');

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment, servings),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Error correcting nutrition label analysis')
        )),
      );
    });
  });
}
