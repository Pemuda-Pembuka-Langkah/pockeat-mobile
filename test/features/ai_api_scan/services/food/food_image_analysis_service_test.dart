// test/features/ai_api_scan/services/food/food_image_analysis_service_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

// Rename to avoid conflicts with generated mock
class ManualMockGenerativeModelWrapper extends Mock implements GenerativeModelWrapper {
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

class ManualMockFile extends Mock implements File {
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

// Use customMocks parameter to specify unique names
@GenerateMocks(
  [GenerativeModelWrapper, File],
  customMocks: [
    MockSpec<GenerativeModelWrapper>(as: #MockGenWrapper),
    MockSpec<File>(as: #MockFileWrapper),
  ]
)
void main() {
  late ManualMockGenerativeModelWrapper mockModelWrapper;
  late ManualMockFile mockFile;
  late FoodImageAnalysisService service;

  setUp(() {
    mockModelWrapper = ManualMockGenerativeModelWrapper();
    mockFile = ManualMockFile();
    service = FoodImageAnalysisService(
      apiKey: 'test-api-key',
      customModelWrapper: mockModelWrapper,
    );
  });

  // Rest of the test remains the same
  group('FoodImageAnalysisService', () {
    test('should analyze food by image successfully', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      const validJsonResponse = '''
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
          "sodium": 800,
          "fiber": 2,
          "sugar": 8
        },
        "warnings": ["High sodium content"]
      }
      ''';

      // Mock
      mockFile.bytesToReturn = mockBytes;
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.analyze(mockFile);

      // Assert
      expect(result.foodName, equals('Burger'));
      expect(result.ingredients.length, equals(2));
      expect(result.nutritionInfo.calories, equals(450));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sodium content'));
    });

    test('should throw exception when file read fails', () async {
      // Arrange
      mockFile.exceptionToThrow = Exception('File read error');

      // Act & Assert
      expect(
        () => service.analyze(mockFile),
        throwsA(isA<GeminiServiceException>()),
      );
    });

    test('should throw exception when API returns null response', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      mockFile.bytesToReturn = mockBytes;
      mockModelWrapper.responseText = null;

      // Act & Assert
      expect(
        () => service.analyze(mockFile),
        throwsA(isA<GeminiServiceException>()),
      );
    });

    test('should throw exception when API returns error response', () async {
      // Arrange
      final mockBytes = Uint8List.fromList([1, 2, 3, 4]);
      const errorResponse = '{"error": "No food detected in image"}';
      mockFile.bytesToReturn = mockBytes;
      mockModelWrapper.responseText = errorResponse;

      // Act & Assert
      expect(
        () => service.analyze(mockFile),
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });
}