// test/pockeat/features/ai_api_scan/services/gemini_service_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/models/exercise_analysis.dart';
import 'gemini_service_test.mocks.dart';
@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late GeminiServiceImpl geminiService;
  
  setUp(() {
    mockClient = MockClient();
    geminiService = GeminiServiceImpl(client: mockClient, apiKey: 'test_key');
  });
  
  group('GeminiService - Food Analysis', () {
    test('analyzeFoodByText constructs correct prompt and returns parsed result', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '''
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "{\\"food_name\\":\\"Apple\\",\\"ingredients\\":[{\\"name\\":\\"Apple\\",\\"percentage\\":100,\\"allergen\\":false}],\\"nutrition_info\\":{\\"calories\\":95,\\"protein\\":0.5,\\"carbs\\":25.1,\\"fat\\":0.3,\\"sodium\\":2,\\"fiber\\":4.4,\\"sugar\\":19.0}}"
                  }
                ]
              }
            }
          ]
        }
        ''',
        200,
      ));
      
      // Act
      final result = await geminiService.analyzeFoodByText('Apple');
      
      // Assert
      verify(mockClient.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent'),
        headers: {'Content-Type': 'application/json', 'x-goog-api-key': 'test_key'},
        body: argThat(allOf(
          contains('Analyze this food description'),
          contains('ingredients'),
          contains('nutrition_info'),
          contains('sodium'),
          contains('fiber'),
          contains('sugar')
        )),
      )).called(1);
      
      expect(result.foodName, 'Apple');
      expect(result.nutritionInfo.sodium, 2);
      expect(result.nutritionInfo.fiber, 4.4);
      expect(result.nutritionInfo.sugar, 19.0);
    });
    
    test('analyzeFoodByImage encodes image correctly and returns parsed result', () async {
      // Arrange
      final tempDir = Directory.systemTemp.createTempSync();
      final testFile = File('${tempDir.path}/test_image.jpg')..writeAsStringSync('test image content');
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '''
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "{\\"food_name\\":\\"Pizza\\",\\"ingredients\\":[{\\"name\\":\\"Dough\\",\\"percentage\\":40,\\"allergen\\":true},{\\"name\\":\\"Cheese\\",\\"percentage\\":30,\\"allergen\\":true},{\\"name\\":\\"Tomato sauce\\",\\"percentage\\":20,\\"allergen\\":false}],\\"nutrition_info\\":{\\"calories\\":285,\\"protein\\":12,\\"carbs\\":36,\\"fat\\":10,\\"sodium\\":560,\\"fiber\\":2.5,\\"sugar\\":3.8}}"
                  }
                ]
              }
            }
          ]
        }
        ''',
        200,
      ));
      
      // Act
      final result = await geminiService.analyzeFoodByImage(testFile);
      
      // Assert
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: argThat(contains('inlineData')),
      )).called(1);
      
      expect(result.foodName, 'Pizza');
      expect(result.nutritionInfo.calories, 285);
      expect(result.nutritionInfo.sodium, 560);
      expect(result.nutritionInfo.fiber, 2.5);
      expect(result.nutritionInfo.sugar, 3.8);
      
      // Clean up
      tempDir.deleteSync(recursive: true);
    });
    
    test('analyzeNutritionLabel includes serving information in prompt', () async {
      // Arrange
      final tempDir = Directory.systemTemp.createTempSync();
      final testFile = File('${tempDir.path}/nutrition_label.jpg')..writeAsStringSync('test image content');
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '''
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "{\\"food_name\\":\\"Cereal\\",\\"ingredients\\":[{\\"name\\":\\"Wheat\\",\\"percentage\\":65,\\"allergen\\":true},{\\"name\\":\\"Sugar\\",\\"percentage\\":20,\\"allergen\\":false}],\\"nutrition_info\\":{\\"calories\\":240,\\"protein\\":4,\\"carbs\\":46,\\"fat\\":2,\\"sodium\\":320,\\"fiber\\":3.5,\\"sugar\\":12.0}}"
                  }
                ]
              }
            }
          ]
        }
        ''',
        200,
      ));
      
      // Act
      final result = await geminiService.analyzeNutritionLabel(testFile, 1.5);
      
      // Assert
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: argThat(contains('1.5 servings')),
      )).called(1);
      
      expect(result.foodName, 'Cereal');
      expect(result.nutritionInfo.calories, 240);
      expect(result.nutritionInfo.sodium, 320);
      expect(result.nutritionInfo.fiber, 3.5);
      expect(result.nutritionInfo.sugar, 12.0);
      
      // Clean up
      tempDir.deleteSync(recursive: true);
    });
  });
  
  group('GeminiService - Exercise Analysis', () {
    test('analyzeExercise constructs correct prompt and returns parsed result', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '''
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "{\\"exercise_type\\":\\"Running\\",\\"calories_burned\\":350,\\"duration_minutes\\":30,\\"intensity_level\\":\\"Moderate\\",\\"met_value\\":7.0}"
                  }
                ]
              }
            }
          ]
        }
        ''',
        200,
      ));
      
      // Act
      final result = await geminiService.analyzeExercise('30 minutes of running at 6mph');
      
      // Assert
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: argThat(allOf(
          contains('Calculate calories burned'),
          contains('exercise_type'),
          contains('calories_burned'),
          contains('duration_minutes')
        )),
      )).called(1);
      
      expect(result.exerciseType, 'Running');
      expect(result.caloriesBurned, 350);
      expect(result.durationMinutes, 30);
      expect(result.intensityLevel, 'Moderate');
      expect(result.metValue, 7.0);
    });
    
    test('analyzeExercise handles user weight parameter for more accurate calculations', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '''
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "{\\"exercise_type\\":\\"Running\\",\\"calories_burned\\":420,\\"duration_minutes\\":30,\\"intensity_level\\":\\"Moderate\\",\\"met_value\\":7.0}"
                  }
                ]
              }
            }
          ]
        }
        ''',
        200,
      ));
      
      // Act
      final result = await geminiService.analyzeExercise(
        '30 minutes of running at 6mph', 
        userWeightKg: 75 // Including user weight for more accurate calorie calculation
      );
      
      // Assert
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: argThat(allOf(
          contains('Calculate calories burned'),
          contains('user weighs 75 kg')
        )),
      )).called(1);
      
      expect(result.caloriesBurned, 420); // Different result based on weight
    });
  });
  
  group('GeminiService - Error Handling', () {
    test('handles API error responses appropriately', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"error": {"message": "API key not valid", "status": "INVALID_ARGUMENT"}}',
        400,
      ));
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByText('Apple'),
        throwsA(isA<GeminiServiceException>()),
      );
    });
    
    test('handles malformed JSON responses', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '''
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "This is not valid JSON"
                  }
                ]
              }
            }
          ]
        }
        ''',
        200,
      ));
      
      // Act & Assert
      expect(
        () => geminiService.analyzeFoodByText('Apple'),
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });
}