import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

// Add these test cases to your existing test file
void main() {
  late MockGenerativeModelWrapper mockModelWrapper;
  late FoodImageAnalysisService service;

  setUp(() {
    mockModelWrapper = MockGenerativeModelWrapper();
    service = FoodImageAnalysisService(
      apiKey: 'test-api-key',
      customModelWrapper: mockModelWrapper,
    );
  });

  group('FoodImageAnalysisService correction functionality', () {
    test('should successfully correct food analysis based on user comment', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [
          Ingredient(name: 'Beef Patty', servings: 45),
          Ingredient(name: 'Burger Bun', servings: 30),
        ],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 25,
          carbs: 35,
          fat: 22,
          sodium: 800,
          fiber: 2,
          sugar: 8,
        ),
        warnings: ['High sodium content'],
      );
      
      const userComment = 'This is actually a vegetarian burger with a plant-based patty';
      
      const correctionJsonResponse = '''
      {
        "food_name": "Vegetarian Burger",
        "ingredients": [
          {
            "name": "Plant-based Patty",
            "servings": 45
          },
          {
            "name": "Burger Bun",
            "servings": 30
          }
        ],
        "nutrition_info": {
          "calories": 380,
          "protein": 18,
          "carbs": 40,
          "fat": 18,
          "sodium": 750,
          "fiber": 4,
          "sugar": 6
        },
        "warnings": ["High sodium content"],
        "correction_applied": "Changed from beef to plant-based burger, updated nutritional information"
      }
      ''';

      // Mock
      mockModelWrapper.responseText = correctionJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment);

      // Assert
      expect(result.foodName, equals('Vegetarian Burger'));
      expect(result.ingredients.length, equals(2));
      expect(result.ingredients[0].name, equals('Plant-based Patty'));
      expect(result.nutritionInfo.calories, equals(380));
      expect(result.nutritionInfo.protein, equals(18));
      expect(result.correctionComment, equals(userComment));
      expect(result.isUserCorrected, isTrue);
      expect(result.correctionDetails, contains('Changed from beef to plant-based burger'));
    });

    test('should preserve unchanged values when only some fields are corrected', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [
          Ingredient(name: 'Beef Patty', servings: 45),
          Ingredient(name: 'Burger Bun', servings: 30),
        ],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 25,
          carbs: 35,
          fat: 22,
          sodium: 800,
          fiber: 2,
          sugar: 8,
        ),
        warnings: ['High sodium content'],
      );
      
      const userComment = 'The burger has cheese too';
      
      const correctionJsonResponse = '''
      {
        "food_name": "Cheeseburger",
        "ingredients": [
          {
            "name": "Beef Patty",
            "servings": 45
          },
          {
            "name": "Burger Bun",
            "servings": 30
          },
          {
            "name": "Cheddar Cheese",
            "servings": 15
          }
        ],
        "nutrition_info": {
          "calories": 520,
          "protein": 30,
          "carbs": 36,
          "fat": 28,
          "sodium": 950,
          "fiber": 2,
          "sugar": 8
        },
        "warnings": ["High sodium content"],
        "correction_applied": "Added cheese to ingredients and updated nutritional values"
      }
      ''';

      // Mock
      mockModelWrapper.responseText = correctionJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment);

      // Assert
      expect(result.foodName, equals('Cheeseburger'));
      expect(result.ingredients.length, equals(3));
      expect(result.ingredients[2].name, equals('Cheddar Cheese'));
      expect(result.nutritionInfo.calories, equals(520));
      expect(result.nutritionInfo.sodium, equals(950));
      expect(result.isUserCorrected, isTrue);
    });

    test('should correctly update warnings based on nutrition changes', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Fruit Smoothie',
        ingredients: [
          Ingredient(name: 'Banana', servings: 120),
          Ingredient(name: 'Strawberries', servings: 80),
          Ingredient(name: 'Yogurt', servings: 100),
        ],
        nutritionInfo: NutritionInfo(
          calories: 220,
          protein: 8,
          carbs: 45,
          fat: 3,
          sodium: 60,
          fiber: 5,
          sugar: 18,
        ),
        warnings: [],
      );
      
      const userComment = 'The smoothie has honey in it too';
      
      const correctionJsonResponse = '''
      {
        "food_name": "Fruit Smoothie with Honey",
        "ingredients": [
          {
            "name": "Banana",
            "servings": 120
          },
          {
            "name": "Strawberries",
            "servings": 80
          },
          {
            "name": "Yogurt",
            "servings": 100
          },
          {
            "name": "Honey",
            "servings": 30
          }
        ],
        "nutrition_info": {
          "calories": 270,
          "protein": 8,
          "carbs": 60,
          "fat": 3,
          "sodium": 60,
          "fiber": 5,
          "sugar": 28
        },
        "warnings": ["High sugar content"],
        "correction_applied": "Added honey to ingredients and updated nutritional values, now exceeds sugar threshold"
      }
      ''';

      // Mock
      mockModelWrapper.responseText = correctionJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment);

      // Assert
      expect(result.foodName, equals('Fruit Smoothie with Honey'));
      expect(result.ingredients.length, equals(4));
      expect(result.ingredients[3].name, equals('Honey'));
      expect(result.nutritionInfo.sugar, equals(28));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sugar content'));
      expect(result.correctionDetails, contains('exceeds sugar threshold'));
    });

    test('should handle missing correction_applied field gracefully', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [
          Ingredient(name: 'Beef Patty', servings: 45),
          Ingredient(name: 'Burger Bun', servings: 30),
        ],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 25,
          carbs: 35,
          fat: 22,
          sodium: 800,
          fiber: 2,
          sugar: 8,
        ),
        warnings: ['High sodium content'],
      );
      
      const userComment = 'The sodium content is actually less';
      
      const correctionJsonResponse = '''
      {
        "food_name": "Burger",
        "ingredients": [
          {
            "name": "Beef Patty",
            "servings": 45
          },
          {
            "name": "Burger Bun",
            "servings": 30
          }
        ],
        "nutrition_info": {
          "calories": 450,
          "protein": 25,
          "carbs": 35,
          "fat": 22,
          "sodium": 480,
          "fiber": 2,
          "sugar": 8
        },
        "warnings": []
      }
      ''';

      // Mock
      mockModelWrapper.responseText = correctionJsonResponse;

      // Act
      final result = await service.correctAnalysis(previousResult, userComment);

      // Assert
      expect(result.nutritionInfo.sodium, equals(480));
      expect(result.warnings.length, equals(0));
      expect(result.isUserCorrected, isTrue);
      expect(result.correctionDetails, equals('Adjustments applied based on user feedback'));
    });

    test('should throw exception when API returns null response', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [
          Ingredient(name: 'Beef Patty', servings: 45),
          Ingredient(name: 'Burger Bun', servings: 30),
        ],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 25,
          carbs: 35,
          fat: 22,
          sodium: 800,
          fiber: 2,
          sugar: 8,
        ),
        warnings: ['High sodium content'],
      );
      
      const userComment = 'The sodium content is actually less';
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

    test('should throw exception when API call fails', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [
          Ingredient(name: 'Beef Patty', servings: 45),
          Ingredient(name: 'Burger Bun', servings: 30),
        ],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 25,
          carbs: 35,
          fat: 22,
          sodium: 800,
          fiber: 2,
          sugar: 8,
        ),
        warnings: ['High sodium content'],
      );
      
      const userComment = 'The sodium content is actually less';
      mockModelWrapper.exceptionToThrow = Exception('API call failed');

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Error correcting food analysis')
        )),
      );
    });

    test('should handle invalid JSON format', () {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [
          Ingredient(name: 'Beef Patty', servings: 45),
          Ingredient(name: 'Burger Bun', servings: 30),
        ],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 25,
          carbs: 35,
          fat: 22,
          sodium: 800,
          fiber: 2,
          sugar: 8,
        ),
        warnings: ['High sodium content'],
      );
      
      const userComment = 'This is a vegetarian burger';
      final malformedJson = '{"food_name": "Vegetarian Burger", "ingredients": [';
      mockModelWrapper.responseText = malformedJson;
      
      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });
}

