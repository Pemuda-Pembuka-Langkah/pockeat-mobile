// test/features/ai_api_scan/services/food/food_text_analysis_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/food_analysis_parser.dart';
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

void main() {
  late MockGenerativeModelWrapper mockModelWrapper;
  late FoodTextAnalysisService service;

  setUp(() {
    mockModelWrapper = MockGenerativeModelWrapper();
    service = FoodTextAnalysisService(
      apiKey: 'test-api-key',
      customModelWrapper: mockModelWrapper,
    );
  });

  group('FoodTextAnalysisService', () {
    test('should analyze food by text successfully', () async {
      // Arrange
      const foodDescription = 'Apple pie with cinnamon';
      const validJsonResponse = '''
      {
        "food_name": "Apple Pie",
        "ingredients": [
          {
            "name": "Apples",
            "servings": 50
          },
          {
            "name": "Flour",
            "servings": 25
          }
        ],
        "nutrition_info": {
          "calories": 250,
          "protein": 2,
          "carbs": 40,
          "fat": 12,
          "sodium": 150,
          "fiber": 3,
          "sugar": 25
        },
        "warnings": ["High sugar content"]
      }
      ''';

      // Mock
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.analyze(foodDescription);

      // Assert
      expect(result.foodName, equals('Apple Pie'));
      expect(result.ingredients.length, equals(2));
      expect(result.ingredients[0].name, equals('Apples'));
      expect(result.nutritionInfo.calories, equals(250));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sugar content'));
    });

    test('should throw exception when API returns null response', () async {
      // Arrange
      const foodDescription = 'Unknown food';
      mockModelWrapper.responseText = null;

      // Act & Assert
      expect(
        () => service.analyze(foodDescription),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 
          'error message', 
          contains('No response text generated')
        )),
      );
    });

    test('should throw exception when API returns error response', () async {
      // Arrange
      const foodDescription = 'Unknown food';
      const errorResponse = '{"error": "Could not analyze food"}';
      mockModelWrapper.responseText = errorResponse;

      // Act & Assert
      expect(
        () => service.analyze(foodDescription),
        throwsA(isA<GeminiServiceException>()),
      );
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      const foodDescription = 'Apple pie';
      mockModelWrapper.exceptionToThrow = Exception('Network error');

      // Act & Assert
      expect(
        () => service.analyze(foodDescription),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Failed to analyze food description')
        )),
      );
    });
  });

  group('FoodAnalysisParser', () {
    test('parse should handle error as Map correctly', () {
      // Arrange
      final jsonText = '{"error": {"message": "Custom error message"}}';
      
      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(jsonText),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 
          'message', 
          contains('Custom error message')
        )),
      );
    });

    test('parse should handle error as Map without message correctly', () {
      // Arrange
      final jsonText = '{"error": {}}'; // Empty error Map
      
      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(jsonText),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 
          'message', 
          contains('Unknown error')
        )),
      );
    });
  });

  group('FoodTextAnalysisService correction functionality', () {
    test('should correct food analysis successfully based on user comment', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Apple Pie',
        ingredients: [
          Ingredient(name: 'Apples', servings: 50),
          Ingredient(name: 'Flour', servings: 25),
        ],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 2,
          carbs: 40,
          fat: 12,
          sodium: 150,
          fiber: 3,
          sugar: 25,
        ),
        warnings: ['High sugar content'],
      );
      
      const userComment = 'This apple pie also has cinnamon and butter';
      
      const validJsonResponse = '''
      {
        "food_name": "Apple Pie with Cinnamon",
        "ingredients": [
          {
            "name": "Apples",
            "servings": 50
          },
          {
            "name": "Flour",
            "servings": 25
          },
          {
            "name": "Butter",
            "servings": 15
          },
          {
            "name": "Cinnamon",
            "servings": 2
          }
        ],
        "nutrition_info": {
          "calories": 320,
          "protein": 2,
          "carbs": 42,
          "fat": 18,
          "sodium": 180,
          "fiber": 3,
          "sugar": 26
        },
        "warnings": ["High sugar content"]
      }
      ''';

      // Mock
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment);

      // Assert
      expect(result.foodName, equals('Apple Pie with Cinnamon'));
      expect(result.ingredients.length, equals(4));
      expect(result.ingredients[2].name, equals('Butter'));
      expect(result.ingredients[3].name, equals('Cinnamon'));
      expect(result.nutritionInfo.calories, equals(320));
      expect(result.nutritionInfo.fat, equals(18));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sugar content'));
    });

    test('should handle food names and ingredients with special characters during correction', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Apple "Pie"',
        ingredients: [
          Ingredient(name: 'Apples\nGranny Smith', servings: 50),
          Ingredient(name: 'Flour', servings: 25),
        ],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 2,
          carbs: 40,
          fat: 12,
          sodium: 150,
          fiber: 3,
          sugar: 25,
        ),
        warnings: ['High "sugar" content'],
      );
      
      const userComment = 'Add cinnamon';
      
      const validJsonResponse = '''
      {
        "food_name": "Apple Pie with Cinnamon",
        "ingredients": [
          {
            "name": "Apples",
            "servings": 50
          },
          {
            "name": "Flour",
            "servings": 25
          },
          {
            "name": "Cinnamon",
            "servings": 2
          }
        ],
        "nutrition_info": {
          "calories": 255,
          "protein": 2,
          "carbs": 41,
          "fat": 12,
          "sodium": 150,
          "fiber": 3,
          "sugar": 25
        },
        "warnings": ["High sugar content"]
      }
      ''';

      // Mock
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment);

      // Assert
      expect(result.foodName, equals('Apple Pie with Cinnamon'));
      expect(result.ingredients.length, equals(3));
      expect(result.ingredients[2].name, equals('Cinnamon'));
    });

    test('should correct nutrition values based on user comment', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Chocolate Brownie',
        ingredients: [
          Ingredient(name: 'Chocolate', servings: 30),
          Ingredient(name: 'Flour', servings: 25),
          Ingredient(name: 'Sugar', servings: 40),
        ],
        nutritionInfo: NutritionInfo(
          calories: 350,
          protein: 4,
          carbs: 45,
          fat: 18,
          sodium: 120,
          fiber: 2,
          sugar: 30,
        ),
        warnings: ['High sugar content'],
      );
      
      const userComment = 'This is a low-sugar version with stevia instead of sugar';
      
      const validJsonResponse = '''
      {
        "food_name": "Low-Sugar Chocolate Brownie",
        "ingredients": [
          {
            "name": "Chocolate",
            "servings": 30
          },
          {
            "name": "Flour",
            "servings": 25
          },
          {
            "name": "Stevia",
            "servings": 5
          }
        ],
        "nutrition_info": {
          "calories": 280,
          "protein": 4,
          "carbs": 28,
          "fat": 18,
          "sodium": 120,
          "fiber": 2,
          "sugar": 8
        },
        "warnings": []
      }
      ''';

      // Mock
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment);

      // Assert
      expect(result.foodName, equals('Low-Sugar Chocolate Brownie'));
      expect(result.ingredients.length, equals(3));
      expect(result.ingredients[2].name, equals('Stevia'));
      expect(result.nutritionInfo.sugar, equals(8));
      expect(result.warnings.isEmpty, isTrue);
    });

    test('should throw exception when API returns null response during correction', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Apple Pie',
        ingredients: [
          Ingredient(name: 'Apples', servings: 50),
          Ingredient(name: 'Flour', servings: 25),
        ],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 2,
          carbs: 40,
          fat: 12,
          sodium: 150,
          fiber: 3,
          sugar: 25,
        ),
        warnings: ['High sugar content'],
      );
      
      const userComment = 'This is not accurate';
      mockModelWrapper.responseText = null;

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 
          'error message', 
          contains('No response text generated')
        )),
      );
    });

    test('should throw exception when API call fails during correction', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Apple Pie',
        ingredients: [
          Ingredient(name: 'Apples', servings: 50),
          Ingredient(name: 'Flour', servings: 25),
        ],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 2,
          carbs: 40,
          fat: 12,
          sodium: 150,
          fiber: 3,
          sugar: 25,
        ),
        warnings: ['High sugar content'],
      );
      
      const userComment = 'This is not accurate';
      mockModelWrapper.exceptionToThrow = Exception('Network error');

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Failed to correct food analysis')
        )),
      );
    });

    test('should throw exception when API returns error response during correction', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Apple Pie',
        ingredients: [
          Ingredient(name: 'Apples', servings: 50),
          Ingredient(name: 'Flour', servings: 25),
        ],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 2,
          carbs: 40,
          fat: 12,
          sodium: 150,
          fiber: 3,
          sugar: 25,
        ),
        warnings: ['High sugar content'],
      );
      
      const userComment = 'This is not accurate';
      const errorResponse = '{"error": "Could not process correction"}';
      mockModelWrapper.responseText = errorResponse;

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });
}