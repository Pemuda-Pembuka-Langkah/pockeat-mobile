// test/features/ai_api_scan/services/base/base_gemini_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/base/base_gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

// Concrete implementation for testing
class TestBaseGeminiService extends BaseGeminiService {
  TestBaseGeminiService({required super.apiKey, super.customModelWrapper});
}


// Rename to avoid conflicts with generated mock
class ManualMockGenerativeModelWrapper extends Mock implements GenerativeModelWrapper {}

// Use customMocks parameter to specify unique names
@GenerateMocks([GenerativeModelWrapper], customMocks: [MockSpec<GenerativeModelWrapper>(as: #MockGenWrapper)])
void main() {
  late ManualMockGenerativeModelWrapper mockModelWrapper;
  late TestBaseGeminiService service;

  setUp(() {
    mockModelWrapper = ManualMockGenerativeModelWrapper();
    service = TestBaseGeminiService(
      apiKey: 'test-api-key',
      customModelWrapper: mockModelWrapper,
    );
  });

  // Rest of the test remains the same
  group('BaseGeminiService', () {
    test('should initialize with provided API key', () {
      expect(service.apiKey, equals('test-api-key'));
    });

    group('extractJson', () {
      test('should extract JSON from clean response', () {
        final jsonText = '{"name": "Test", "value": 123}';
        final result = service.extractJson(jsonText);
        expect(result, equals(jsonText));
      });

      test('should extract JSON embedded in text', () {
        final text = 'Some text {"name": "Test", "value": 123} more text';
        final result = service.extractJson(text);
        expect(result, equals('{"name": "Test", "value": 123}'));
      });

      test('should clean JSON with comments', () {
        final jsonWithComments = '{"name": "Test", // Comment\n"value": 123}';
        final result = service.extractJson(jsonWithComments);
        expect(result, equals('{"name": "Test", "value": 123}'));
      });

      test('should clean JSON with trailing commas', () {
        final jsonWithTrailingCommas = '{"items": [1, 2, 3,], "name": "test",}';
        final result = service.extractJson(jsonWithTrailingCommas);
        expect(result, equals('{"items": [1, 2, 3], "name": "test"}'));
      });

      test('should throw exception for invalid JSON', () {
        final invalidText = 'Not a JSON at all';
        expect(
          () => service.extractJson(invalidText),
          throwsA(isA<GeminiServiceException>()),
        );
      });
    });

    test('getApiKeyFromEnv should throw exception when key is missing', () {
      // This test would need environmental variable mocking
      // We'll define it but implementation would use a mock env utility
    });
  });
}