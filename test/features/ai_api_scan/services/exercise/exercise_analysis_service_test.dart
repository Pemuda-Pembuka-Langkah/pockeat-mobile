// test/features/ai_api_scan/services/exercise/exercise_analysis_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';


// Manual mock implementation
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
  late ExerciseAnalysisService service;

  setUp(() {
    mockModelWrapper = MockGenerativeModelWrapper();
    service = ExerciseAnalysisService(
      apiKey: 'test-api-key',
      customModelWrapper: mockModelWrapper,
    );
  });

  group('ExerciseAnalysisService', () {
    // Tests remain the same
    test('should analyze exercise successfully', () async {
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

      // Mock
      mockModelWrapper.responseText = validJsonResponse;

      // Act
      final result = await service.analyze(exerciseDescription, userWeightKg: userWeight);

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

      // Mock
      mockModelWrapper.responseText = errorJsonResponse;

      // Act
      final result = await service.analyze(exerciseDescription);

      // Assert
      expect(result.exerciseType, equals('Unknown'));
      expect(result.estimatedCalories, equals(0));
      expect(result.intensity, equals('Not specified'));
      expect(result.metValue, equals(0.0));
      expect(result.summary, contains('Could not analyze exercise'));
      expect(result.missingInfo, contains('exercise_type'));
    });

    test('should throw exception when API returns null response', () async {
      // Arrange
      const exerciseDescription = 'Running 5km in 30 minutes';
      mockModelWrapper.responseText = null;

      // Act & Assert
      expect(
        () => service.analyze(exerciseDescription),
        throwsA(isA<GeminiServiceException>()),
      );
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      const exerciseDescription = 'Running 5km in 30 minutes';
      mockModelWrapper.exceptionToThrow = Exception('API call failed');

      // Act & Assert
      expect(
        () => service.analyze(exerciseDescription),
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });
}