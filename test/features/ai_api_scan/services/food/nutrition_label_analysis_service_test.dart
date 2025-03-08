// test/features/ai_api_scan/services/food/nutrition_label_analysis_service_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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

@GenerateMocks([GenerativeModelWrapper, File])
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
}