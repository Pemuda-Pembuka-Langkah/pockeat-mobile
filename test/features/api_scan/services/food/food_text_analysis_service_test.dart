// test/features/ai_api_scan/services/food/food_text_analysis_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/api_scan/services/food/food_text_analysis_service.dart';

// Import the generated mock
import '../base/api_service_test.mocks.dart';

void main() {
  late MockApiServiceInterface mockApiService;
  late FoodTextAnalysisService service;

  setUp(() {
    mockApiService = MockApiServiceInterface();
    service = FoodTextAnalysisService(
      apiService: mockApiService,
    );
  });

  group('FoodTextAnalysisService', () {
    test('should analyze food by text successfully', () async {
      // Arrange
      const foodDescription = 'Apple pie with cinnamon';
      final validJsonResponse = {
        "food_name": "Apple Pie",
        "ingredients": [
          {"name": "Apples", "servings": 50},
          {"name": "Flour", "servings": 25}
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
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
              '/food/analyze/text', {'description': foodDescription}))
          .thenAnswer((_) async => validJsonResponse);

      // Act
      final result = await service.analyze(foodDescription);

      // Assert
      expect(result.foodName, equals('Apple Pie'));
      expect(result.ingredients.length, equals(2));
      expect(result.ingredients[0].name, equals('Apples'));
      expect(result.nutritionInfo.calories, equals(250));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sugar content'));

      // Verify the API call was made with correct parameters
      verify(mockApiService.postJsonRequest(
          '/food/analyze/text', {'description': foodDescription})).called(1);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      const foodDescription = 'Apple pie';

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
              '/food/analyze/text', {'description': foodDescription}))
          .thenThrow(ApiServiceException('Network error'));

      // Act & Assert
      expect(
        () => service.analyze(foodDescription),
        throwsA(isA<ApiServiceException>().having(
            (e) => e.message, 'error message', contains('Network error'))),
      );

      // Verify the API call was attempted
      verify(mockApiService.postJsonRequest(
          '/food/analyze/text', {'description': foodDescription})).called(1);
    });

    test('should throw exception when API returns error response', () async {
      // Arrange
      const foodDescription = 'Unknown food';

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
              '/food/analyze/text', {'description': foodDescription}))
          .thenThrow(ApiServiceException('Could not analyze food'));

      // Act & Assert
      expect(
        () => service.analyze(foodDescription),
        throwsA(isA<ApiServiceException>().having((e) => e.message,
            'error message', contains('Could not analyze food'))),
      );
    });

    test('should throw ApiServiceException when analysis fails', () async {
      // Arrange
      const foodDescription = 'Apple pie';
      final error = Exception('Analysis failed');

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/food/analyze/text',
        {'description': foodDescription},
      )).thenThrow(error);

      // Act & Assert
      expect(
        () => service.analyze(foodDescription),
        throwsA(isA<ApiServiceException>().having(
          (e) => e.message,
          'error message',
          contains("Failed to analyze food description '$foodDescription'"),
        )),
      );
    });
  });

  group('FoodTextAnalysisService correction functionality', () {
    test('should correct food analysis successfully based on user comment',
        () async {
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

      final validJsonResponse = {
        "food_name": "Apple Pie with Cinnamon",
        "ingredients": [
          {"name": "Apples", "servings": 50},
          {"name": "Flour", "servings": 25},
          {"name": "Butter", "servings": 15},
          {"name": "Cinnamon", "servings": 2}
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
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).thenAnswer((_) async => validJsonResponse);

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

      // Verify the API call was made
      verify(mockApiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).called(1);
    });

    test('should throw exception when API call fails during correction',
        () async {
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

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).thenThrow(ApiServiceException('Network error'));

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<ApiServiceException>().having(
            (e) => e.message, 'error message', contains('Network error'))),
      );
    });

    test('should throw ApiServiceException when correction fails', () async {
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
      final error = Exception('Correction failed');

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).thenThrow(error);

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<ApiServiceException>().having((e) => e.message,
            'error message', contains('Failed to correct food analysis'))),
      );
    });
  });
}
