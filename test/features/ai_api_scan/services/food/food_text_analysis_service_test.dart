// test/features/ai_api_scan/services/food/food_text_analysis_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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
    // Tests remain the same
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
        throwsA(isA<GeminiServiceException>()),
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
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });

  test('parse should handle error as Map correctly', () {
  // Arrange
  final jsonText = '{"error": {"message": "Custom error message"}}';
  
  // Act & Assert
  expect(
    () => FoodAnalysisParser.parse(jsonText),
    throwsA(isA<GeminiServiceException>().having(
      (e) => e.message, 'message', 'Custom error message'
    )),
  );
});

test('parse should handle error as Map without message correctly', () {
  // Arrange
  final jsonText = '{"error": {}}'; // Error sebagai Map kosong
  
  // Act & Assert
  expect(
    () => FoodAnalysisParser.parse(jsonText),
    throwsA(isA<GeminiServiceException>().having(
      (e) => e.message, 'message', 'Unknown error'
    )),
  );
});
}