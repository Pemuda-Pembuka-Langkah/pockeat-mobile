// test/features/api_scan/services/food/food_image_analysis_service_test.dart

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/services/food/food_image_analysis_service.dart';
import '../base/api_service_test.mocks.dart';

// Mock File class implementation
class MockFile extends Mock implements File {
  final String _mockPath = 'mock_image.jpg';

  @override
  String get path => _mockPath;

  @override
  bool existsSync() => true;
}

void main() {
  late MockApiServiceInterface mockApiService;
  late MockFile mockFile;
  late FoodImageAnalysisService service;

  setUp(() {
    mockApiService = MockApiServiceInterface();
    mockFile = MockFile();
    service = FoodImageAnalysisService(apiService: mockApiService);
  });

  group('FoodImageAnalysisService', () {
    test('should analyze food image successfully', () async {
      // Arrange
      final validJsonResponse = {
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
          "sugar": 19.0
        },
        "timestamp": DateTime.now().toIso8601String()
      };

      // Set up mock
      when(mockApiService.postFileRequest(
        '/food/analyze/image',
        mockFile,
        'image',
      )).thenAnswer((_) async => validJsonResponse);

      // Act
      final result = await service.analyze(mockFile);

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
      expect(result.nutritionInfo.sugar, equals(19.0));

      // Verify the API call was made with correct parameters
      verify(mockApiService.postFileRequest(
        '/food/analyze/image',
        mockFile,
        'image',
      )).called(1);
    });

    test('should handle error as an exception when error field is present',
        () async {
      // Arrange
      final errorJsonResponse = {
        "error": "Could not analyze image",
        "food_name": "Unknown",
        "ingredients": [],
        "nutrition_info": {"calories": 0, "protein": 0, "carbs": 0, "fat": 0}
      };

      // Set up mock
      when(mockApiService.postFileRequest(
        '/food/analyze/image',
        mockFile,
        'image',
      )).thenAnswer((_) async => errorJsonResponse);

      // Act & Assert
      expect(
        () => service.analyze(mockFile),
        throwsA(isA<ApiServiceException>().having(
          (e) => e.message, 
          'error message', 
          equals('Could not analyze image')
        )),
      );
    });

    test('should throw exception when API returns error', () async {
      // Arrange
      // Set up mock to throw exception
      when(mockApiService.postFileRequest(
        '/food/analyze/image',
        mockFile,
        'image',
      )).thenThrow(ApiServiceException('API request failed'));

      // Act & Assert
      expect(
        () => service.analyze(mockFile),
        throwsA(isA<ApiServiceException>().having(
            (e) => e.message, 'error message', contains('API request failed'))),
      );
    });

    test('should throw ApiServiceException when analysis fails', () async {
      // Arrange
      final error = Exception('Analysis failed');

      // Set up mock to throw exception
      when(mockApiService.postFileRequest(
        '/food/analyze/image',
        mockFile,
        'image',
      )).thenThrow(error);

      // Act & Assert
      expect(
        () => service.analyze(mockFile),
        throwsA(isA<ApiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Error analyzing food from image'),
        )),
      );
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
          "sugar": 6,
          "saturated_fat": 2.5,
          "cholesterol": 0
        },
        "warnings": ["High sodium content"],
        "health_score": 6.5,
        "additional_information": {"source": "user_correction"}
      };

      // Set up mock - using the correct endpoint in the service implementation
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
      expect(result.foodName, equals('Vegetarian Burger'));
      expect(result.ingredients.length, equals(2));
      expect(result.ingredients[0].name, equals('Plant-based Patty'));
      expect(result.nutritionInfo.calories, equals(380));
      expect(result.nutritionInfo.protein, equals(18));
      expect(result.nutritionInfo.carbs, equals(40));
      expect(result.nutritionInfo.fat, equals(18));
      expect(result.nutritionInfo.sodium, equals(750));
      expect(result.nutritionInfo.fiber, equals(4));
      expect(result.nutritionInfo.sugar, equals(6));
      expect(result.nutritionInfo.saturatedFat, equals(2.5));
      expect(result.nutritionInfo.cholesterol, equals(0));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sodium content'));
      expect(result.healthScore, equals(6.5));
      expect(result.additionalInformation["source"], equals("user_correction"));

      // Verify the API call was made with correct parameters
      verify(mockApiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).called(1);
    });

    test('should handle error in response during correction', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [
          Ingredient(name: 'Beef Patty', servings: 45),
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
      );

      const userComment = 'This is a vegetarian burger';

      final errorJsonResponse = {
        "error": "Failed to correct analysis",
        "food_name": "Unknown",
        "nutrition_info": {"calories": 0, "protein": 0, "carbs": 0, "fat": 0}
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).thenAnswer((_) async => errorJsonResponse);

      // Act & Assert
      expect(
        () => service.correctAnalysis(previousResult, userComment),
        throwsA(isA<ApiServiceException>().having(
          (e) => e.message, 
          'error message', 
          equals('Failed to correct analysis')
        )),
      );
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
      );

      const userComment = 'This is a vegetarian burger';

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/food/correct/text',
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

    test('should handle general exception during correction', () async {
      // Arrange
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [
          Ingredient(name: 'Beef Patty', servings: 45),
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
      );

      const userComment = 'This is a vegetarian burger';
      final error = Exception('Network error');

      // Set up mock to throw general exception
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
        throwsA(isA<ApiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('Error correcting food analysis'),
        )),
      );
    });

    test('should log response during correction (debug print test)', () async {
      // Arrange - This test is to cover the print statement in the service
      final previousResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 25,
          carbs: 35,
          fat: 22,
          sodium: 800,
          fiber: 2,
          sugar: 8,
        ),
      );

      const userComment = 'This is a vegetarian burger';

      final validResponse = {
        "food_name": "Vegetarian Burger",
        "ingredients": [],
        "nutrition_info": {
          "calories": 380,
          "protein": 18,
          "carbs": 40,
          "fat": 18,
          "sodium": 750,
          "fiber": 4,
          "sugar": 6
        }
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).thenAnswer((_) async => validResponse);

      // Act
      await service.correctAnalysis(previousResult, userComment);

      // Assert - verify the API was called
      verify(mockApiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      )).called(1);
      
      // We're not directly testing the print statement
      // Just ensuring that branch is covered for code coverage
    });
  });
}
