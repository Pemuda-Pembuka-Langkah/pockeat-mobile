import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/generative_model_wrapper.dart';

// Custom mock class yang lebih sederhana
class MockGenerativeModelWrapper extends Mock implements GenerativeModelWrapper {
  String? responseText;
  Exception? exceptionToThrow;
  
  @override
  Future<dynamic> generateContent(dynamic _) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    
    // Return minimal fake response object
    return _MockGenerateContentResponse(responseText);
  }
  
  void setResponse(String? text) {
    responseText = text;
  }
  
  void setException(Exception exception) {
    exceptionToThrow = exception;
  }
}

// Class pengganti yang sederhana - tidak perlu implementasi penuh
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
  
  void setBytes(Uint8List bytes) {
    bytesToReturn = bytes;
  }
  
  void setException(Exception exception) {
    exceptionToThrow = exception;
  }
}

void main() {
  late MockGenerativeModelWrapper mockModelWrapper;
  late MockFile mockFile;
  late GeminiServiceImpl geminiService;
  
  setUp(() {
    mockModelWrapper = MockGenerativeModelWrapper();
    mockFile = MockFile();
    
    geminiService = GeminiServiceImpl(
      apiKey: 'fake-api-key',
      modelWrapper: mockModelWrapper,
    );
  });
  
  group('analyzeFoodByText', () {
    test('should return food analysis when API returns valid response', () async {
      // Arrange
      const foodDescription = 'Apple pie with cinnamon';
      const validJsonResponse = '''
      {
        "food_name": "Apple Pie",
        "ingredients": [
          {
            "name": "Apples",
            "percentage": 50,
            "allergen": false
          },
          {
            "name": "Flour",
            "percentage": 25,
            "allergen": true
          },
          {
            "name": "Sugar",
            "percentage": 15,
            "allergen": false
          },
          {
            "name": "Cinnamon",
            "percentage": 5,
            "allergen": false
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
        }
      }
      ''';
      
      // Mock the response
      mockModelWrapper.setResponse(validJsonResponse);
      
      // Act
      final result = await geminiService.analyzeFoodByText(foodDescription);
      
      // Assert
      expect(result.foodName, equals('Apple Pie'));
      expect(result.ingredients.length, equals(4));
      expect(result.ingredients[0].name, equals('Apples'));
      expect(result.ingredients[0].percentage, equals(50));
      expect(result.ingredients[0].allergen, equals(false));
      expect(result.nutritionInfo.calories, equals(250));
      expect(result.nutritionInfo.protein, equals(2));
      expect(result.nutritionInfo.carbs, equals(40));
    });
    
    test('should throw exception when API response is null', () async {
      // Arrange
      const foodDescription = 'Apple pie with cinnamon';
      
      // Mock the response with null text
      mockModelWrapper.setResponse(null);
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByText(foodDescription),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 'message', contains('No response text generated')
        ))
      );
    });
    
    test('should throw exception when API returns invalid JSON', () async {
      // Arrange
      const foodDescription = 'Apple pie with cinnamon';
      const invalidResponse = 'This is not a valid JSON';
      
      // Mock the response
      mockModelWrapper.setResponse(invalidResponse);
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByText(foodDescription),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 'message', contains('No valid JSON found in response')
        ))
      );
    });
    
    test('should handle error response with string error', () async {
      // Arrange
      const foodDescription = 'Apple pie with cinnamon';
      const errorJsonResponse = '''
      {
        "error": "Cannot analyze this food",
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
      }
      ''';
      
      // Mock the response
      mockModelWrapper.setResponse(errorJsonResponse);
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByText(foodDescription),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 'message', contains('Cannot analyze this food')
        ))
      );
    });
    
    test('should handle error response with object error', () async {
      // Arrange
      const foodDescription = 'Apple pie with cinnamon';
      const errorJsonResponse = '''
      {
        "error": {"message": "API error occurred"},
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
      }
      ''';
      
      // Mock the response
      mockModelWrapper.setResponse(errorJsonResponse);
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByText(foodDescription),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 'message', contains('API error occurred')
        ))
      );
    });
    
    test('should throw exception when network error occurs', () async {
      // Arrange
      const foodDescription = 'Apple pie with cinnamon';
      
      // Mock network error
      mockModelWrapper.setException(Exception('Network error'));
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByText(foodDescription),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 'message', contains('Error analyzing food')
        ))
      );
    });
  });
  
  group('analyzeFoodByImage', () {
    test('should return food analysis when API returns valid response', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]); // Dummy image bytes
      
      const validJsonResponse = '''
      {
        "food_name": "Burger",
        "ingredients": [
          {
            "name": "Beef Patty",
            "percentage": 45,
            "allergen": false
          },
          {
            "name": "Burger Bun",
            "percentage": 30,
            "allergen": true
          },
          {
            "name": "Lettuce",
            "percentage": 10,
            "allergen": false
          }
        ],
        "nutrition_info": {
          "calories": 450,
          "protein": 25,
          "carbs": 35,
          "fat": 22,
          "sodium": 800,
          "fiber": 2,
          "sugar": 8
        }
      }
      ''';
      
      // Mock file read
      mockFile.setBytes(mockBytes);
      
      // Mock API response
      mockModelWrapper.setResponse(validJsonResponse);
      
      // Act
      final result = await geminiService.analyzeFoodByImage(mockFile);
      
      // Assert
      expect(result.foodName, equals('Burger'));
      expect(result.ingredients.length, equals(3));
      expect(result.nutritionInfo.calories, equals(450));
      expect(result.nutritionInfo.sodium, equals(800));
    });
    
    test('should throw exception when file read fails', () async {
      // Arrange
      mockFile.setException(FileSystemException('File read error'));
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByImage(mockFile),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 'message', contains('Error analyzing food image')
        ))
      );
    });
    
    test('should handle no food detected error response', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      const errorJsonResponse = '''
      {
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
      }
      ''';
      
      // Mock
      mockFile.setBytes(mockBytes);
      mockModelWrapper.setResponse(errorJsonResponse);
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByImage(mockFile),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 'message', contains('No food detected in image')
        ))
      );
    });
  });
  
  group('analyzeNutritionLabel', () {
    test('should return nutrition analysis when API returns valid response', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      const servings = 2.5;
      
      const validJsonResponse = '''
      {
        "food_name": "Cereal",
        "ingredients": [
          {
            "name": "Whole Grain Wheat",
            "percentage": 60,
            "allergen": false
          },
          {
            "name": "Sugar",
            "percentage": 20,
            "allergen": false
          },
          {
            "name": "Salt",
            "percentage": 5,
            "allergen": false
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
        }
      }
      ''';
      
      // Mock
      mockFile.setBytes(mockBytes);
      mockModelWrapper.setResponse(validJsonResponse);
      
      // Act
      final result = await geminiService.analyzeNutritionLabel(mockFile, servings);
      
      // Assert
      expect(result.foodName, equals('Cereal'));
      expect(result.ingredients.length, equals(3));
      expect(result.ingredients[0].name, equals('Whole Grain Wheat'));
      expect(result.nutritionInfo.calories, equals(120));
    });
    
    test('should handle no nutrition label detected error', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      const servings = 1.0;
      const errorJsonResponse = '''
      {
        "error": "No nutrition label detected",
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
      }
      ''';
      
      // Mock
      mockFile.setBytes(mockBytes);
      mockModelWrapper.setResponse(errorJsonResponse);
      
      // Act & Assert
      expect(
        () => geminiService.analyzeNutritionLabel(mockFile, servings),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message, 'message', contains('No nutrition label detected')
        ))
      );
    });
  });
  
  group('analyzeExercise', () {
    test('should return exercise analysis when API returns valid response', () async {
      // Arrange
      const exerciseDescription = 'Running 5km in 30 minutes';
      const userWeight = 70.0;
      
      const validJsonResponse = '''
      {
        "exercise_type": "Running",
        "calories_burned": 350,
        "duration_minutes": 30,
        "intensity_level": "Moderate",
        "met_value": 8.5
      }
      ''';
      
      // Mock the response
      mockModelWrapper.setResponse(validJsonResponse);
      
      // Act
      final result = await geminiService.analyzeExercise(exerciseDescription, userWeightKg: userWeight);
      
      // Assert
      expect(result.exerciseType, equals('Running'));
      expect(result.estimatedCalories, equals(350));
      expect(result.duration, equals('30 minutes'));
      expect(result.intensity, equals('Moderate'));
      expect(result.metValue, equals(8.5));
      expect(result.originalInput, equals(exerciseDescription));
    });
    
    test('should handle error but still return result with default values', () async {
      // Arrange
      const exerciseDescription = 'Standing still';
      
      const errorJsonResponse = '''
      {
        "error": "Could not determine exercise details",
        "exercise_type": "Unknown",
        "calories_burned": 0,
        "duration_minutes": 0,
        "intensity_level": "Unknown",
        "met_value": 0
      }
      ''';
      
      // Mock the response
      mockModelWrapper.setResponse(errorJsonResponse);
      
      // Act
      final result = await geminiService.analyzeExercise(exerciseDescription);
      
      // Assert - unlike food analysis, exercise returns a result with default values rather than throwing
      expect(result.exerciseType, equals('Unknown'));
      expect(result.estimatedCalories, equals(0));
      expect(result.intensity, equals('Not specified'));
      expect(result.metValue, equals(0.0));
      expect(result.summary, contains('Could not determine exercise details'));
      expect(result.missingInfo, contains('exercise_type'));
    });
  });
  
  group('_extractJson utility', () {
    test('should handle JSON embedded in text', () async {
      // Arrange
      const foodDescription = 'Banana';
      const mixedResponse = '''
      Here is your food analysis:
      
      {
        "food_name": "Banana",
        "ingredients": [
          {
            "name": "Banana",
            "percentage": 100,
            "allergen": false
          }
        ],
        "nutrition_info": {
          "calories": 105,
          "protein": 1.3,
          "carbs": 27,
          "fat": 0.4,
          "sodium": 1,
          "fiber": 3.1,
          "sugar": 14
        }
      }
      
      I hope this analysis helps!
      ''';
      
      // Mock
      mockModelWrapper.setResponse(mixedResponse);
      
      // Act
      final result = await geminiService.analyzeFoodByText(foodDescription);
      
      // Assert - the function should extract the JSON correctly
      expect(result.foodName, equals('Banana'));
      expect(result.ingredients.length, equals(1));
      expect(result.nutritionInfo.calories, equals(105));
    });
  });
}