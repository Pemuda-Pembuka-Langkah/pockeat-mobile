// test/features/ai_api_scan/services/food/food_image_analysis_service_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/api_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';

// Import the generated mock
import '../base/api_service_test.mocks.dart';

// Mock File
class MockFile extends Mock implements File {}

void main() {
  late MockApiServiceInterface mockApiService;
  late MockFile mockFile;
  late FoodImageAnalysisService service;

  setUp(() {
    mockApiService = MockApiServiceInterface();
    mockFile = MockFile();
    service = FoodImageAnalysisService(
      apiService: mockApiService,
    );
  });

  group('FoodImageAnalysisService', () {
    test('should analyze food by image successfully', () async {
      // Arrange
      final validJsonResponse = {
        "food_name": "Burger",
        "ingredients": [
          {"name": "Beef Patty", "servings": 45},
          {"name": "Burger Bun", "servings": 30}
        ],
        "nutrition_info": {
          "calories": 450,
          "protein": 25,
          "carbs": 35,
          "fat": 22,
          "sodium": 800,
          "fiber": 2,
          "sugar": 8
        },
        "warnings": ["High sodium content"]
      };

      // Set up mock
      when(mockApiService.postFileRequest(
              '/food/analyze/image', mockFile, 'image'))
          .thenAnswer((_) async => validJsonResponse);

      // Act
      final result = await service.analyze(mockFile);

      // Assert
      expect(result.foodName, equals('Burger'));
      expect(result.ingredients.length, equals(2));
      expect(result.nutritionInfo.calories, equals(450));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sodium content'));

      // Verify the API call was made with correct parameters
      verify(mockApiService.postFileRequest(
              '/food/analyze/image', mockFile, 'image'))
          .called(1);
    });

    test('should throw exception when API call fails', () async {
      // Set up mock to throw exception
      when(mockApiService.postFileRequest(
              '/food/analyze/image', mockFile, 'image'))
          .thenThrow(ApiServiceException('File upload failed'));

      // Act & Assert
      expect(
        () => service.analyze(mockFile),
        throwsA(isA<ApiServiceException>().having(
            (e) => e.message, 'error message', contains('File upload failed'))),
      );

      // Verify the API call was attempted
      verify(mockApiService.postFileRequest(
              '/food/analyze/image', mockFile, 'image'))
          .called(1);
    });
  });

  group('FoodImageAnalysisService correction functionality', () {
    test('should correct food analysis successfully based on user comment',
        () async {
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

      const userComment =
          'This is actually a vegetarian burger with a plant-based patty';

      final validJsonResponse = {
        "food_name": "Vegetarian Burger",
        "ingredients": [
          {"name": "Plant-based Patty", "servings": 45},
          {"name": "Burger Bun", "servings": 30}
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
        "warnings": ["High sodium content"]
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/food/correct/image',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).thenAnswer((_) async => validJsonResponse);

      // Act
      final result = await service.correctAnalysis(previousResult, userComment);

      // Assert
      expect(result.foodName, equals('Vegetarian Burger'));
      expect(result.ingredients.length, equals(2));
      expect(result.ingredients[0].name, equals('Plant-based Patty'));
      expect(result.nutritionInfo.calories, equals(380));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sodium content'));

      // Verify the API call was made
      verify(mockApiService.postJsonRequest(
        '/food/correct/image',
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

      const userComment = 'This is actually a vegetarian burger';

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/food/correct/image',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).thenThrow(ApiServiceException('API call failed'));

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<ApiServiceException>().having(
            (e) => e.message, 'error message', contains('API call failed'))),
      );
    });
  });
}
