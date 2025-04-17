// test/features/ai_api_scan/services/food/nutrition_label_analysis_service_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/services/food/nutrition_label_analysis_service.dart';

// Import the generated mock
import '../base/api_service_test.mocks.dart';

// Mock File
class MockFile extends Mock implements File {}

void main() {
  late MockApiServiceInterface mockApiService;
  late MockFile mockFile;
  late NutritionLabelAnalysisService service;

  setUp(() {
    mockApiService = MockApiServiceInterface();
    mockFile = MockFile();
    service = NutritionLabelAnalysisService(
      apiService: mockApiService,
    );
  });

  group('NutritionLabelAnalysisService', () {
    test('should analyze nutrition label successfully', () async {
      // Arrange
      const servings = 2.5;
      final validJsonResponse = {
        "food_name": "Cereal",
        "ingredients": [
          {"name": "Whole Grain Wheat", "servings": 60},
          {"name": "Sugar", "servings": 20}
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
      };

      // Set up mock
      when(mockApiService.postFileRequest('/food/analyze/nutrition-label',
              mockFile, 'image', {'servings': servings.toString()}))
          .thenAnswer((_) async => validJsonResponse);

      // Act
      final result = await service.analyze(mockFile, servings);

      // Assert
      expect(result.foodName, equals('Cereal'));
      expect(result.ingredients.length, equals(2));
      expect(result.nutritionInfo.calories, equals(120));
      expect(result.warnings, isEmpty);

      // Verify the API call was made with correct parameters
      verify(mockApiService.postFileRequest('/food/analyze/nutrition-label',
          mockFile, 'image', {'servings': servings.toString()})).called(1);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      const servings = 1.0;

      // Set up mock to throw exception
      when(mockApiService.postFileRequest('/food/analyze/nutrition-label',
              mockFile, 'image', {'servings': servings.toString()}))
          .thenThrow(ApiServiceException('File upload failed'));

      // Act & Assert
      expect(
        () => service.analyze(mockFile, servings),
        throwsA(isA<ApiServiceException>().having(
            (e) => e.message, 'error message', contains('File upload failed'))),
      );
    });

    test('should throw ApiServiceException when analysis fails', () async {
      // Arrange
      const servings = 2.5;
      final error = Exception('Analysis failed');

      // Set up mock to throw exception
      when(mockApiService.postFileRequest(
          '/food/analyze/nutrition-label',
          mockFile,
          'image',
          {'servings': servings.toString()})).thenThrow(error);

      // Act & Assert
      expect(
        () => service.analyze(mockFile, servings),
        throwsA(isA<ApiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Error analyzing nutrition label'),
        )),
      );
    });
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

      const userComment =
          'The cereal also contains dried fruit and has higher sugar content';
      const servings = 2.5;

      final validJsonResponse = {
        "food_name": "Fruit Cereal",
        "ingredients": [
          {"name": "Whole Grain Wheat", "servings": 60},
          {"name": "Sugar", "servings": 20},
          {"name": "Dried Fruit", "servings": 15}
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
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/food/correct/nutrition-label',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
          'servings': servings,
        },
      )).thenAnswer((_) async => validJsonResponse);

      // Act
      final result =
          await service.correctAnalysis(previousResult, userComment, servings);

      // Assert
      expect(result.foodName, equals('Fruit Cereal'));
      expect(result.ingredients.length, equals(3));
      expect(result.ingredients[2].name, equals('Dried Fruit'));
      expect(result.nutritionInfo.calories, equals(150));
      expect(result.nutritionInfo.sugar, equals(18));
      expect(result.nutritionInfo.fiber, equals(4));
      expect(result.warnings, isEmpty);

      // Verify the API call was made
      verify(mockApiService.postJsonRequest(
        '/food/correct/nutrition-label',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
          'servings': servings,
        },
      )).called(1);
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

      const userComment =
          'The sugar content is much higher, around 22g, and it has more sodium too';
      const servings = 2.5;

      final validJsonResponse = {
        "food_name": "Cereal",
        "ingredients": [
          {"name": "Whole Grain Wheat", "servings": 60},
          {"name": "Sugar", "servings": 30}
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
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/food/correct/nutrition-label',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
          'servings': servings,
        },
      )).thenAnswer((_) async => validJsonResponse);

      // Act
      final result =
          await service.correctAnalysis(previousResult, userComment, servings);

      // Assert
      expect(result.ingredients[1].servings,
          equals(30)); // Higher sugar in ingredients
      expect(result.nutritionInfo.sugar, equals(22));
      expect(result.nutritionInfo.sodium, equals(510));
      expect(result.warnings.length, equals(2));
      expect(result.warnings, contains('High sodium content'));
      expect(result.warnings, contains('High sugar content'));

      // Verify the API call was made
      verify(mockApiService.postJsonRequest(
        '/food/correct/nutrition-label',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
          'servings': servings,
        },
      )).called(1);
    });

    test('should throw exception when API call fails during correction',
        () async {
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

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/food/correct/nutrition-label',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
          'servings': servings,
        },
      )).thenThrow(ApiServiceException('API call failed'));

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment, servings),
        throwsA(isA<ApiServiceException>().having(
            (e) => e.message, 'error message', contains('API call failed'))),
      );
    });

    test('should throw ApiServiceException when correction fails', () async {
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
      final error = Exception('Correction failed');

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/food/correct/nutrition-label',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
          'servings': servings,
        },
      )).thenThrow(error);

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment, servings),
        throwsA(isA<ApiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Error correcting nutrition label analysis'),
        )),
      );
    });
  });
}
