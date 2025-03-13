import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';


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
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('No response text generated')
        )),
      );
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      const exerciseDescription = 'Running 5km in 30 minutes';
      mockModelWrapper.exceptionToThrow = Exception('API call failed');

      // Act & Assert
      expect(
        () => service.analyze(exerciseDescription),
        throwsA(isA<GeminiServiceException>().having(
          (e) => e.message,
          'error message',
          contains('API call failed')
        )),
      );
    });
  });

  group('ExerciseAnalysisService error handling', () {
    test('parseExerciseResponse should throw GeminiServiceException when extractJson fails', () {
      // Arrange - String without clear JSON format
      final invalidText = 'Ini bukan JSON sama sekali';
      
      // Act & Assert
      expect(
        () => service.parseExerciseResponse(invalidText, 'jogging'),
        throwsA(
          isA<GeminiServiceException>()
            .having((e) => e.message, 'message', contains('Failed to parse exercise analysis response'))
        ),
      );
    });
    
    test('parseExerciseResponse should throw GeminiServiceException when jsonDecode fails', () {
      // Arrange - String with malformed JSON format
      // JSON-like format but invalid (unbalanced curly braces)
      final malformedJson = '{"exercise_type": "Running", "calories_burned": 300,';
      
      // Act & Assert
      expect(
        () => service.parseExerciseResponse(malformedJson, 'running'),
        throwsA(
          isA<GeminiServiceException>()
            .having((e) => e.message, 'message', contains('Failed to parse exercise analysis response'))
        ),
      );
    });
    
    test('parseExerciseResponse should propagate exception message from parsing failure', () {
      final brokenJson = '{ "this": "is", broken": "json" }';
      
      // Act
      try {
        service.parseExerciseResponse(brokenJson, 'exercise');
        fail('Expected exception was not thrown');
      } catch (e) {
        // Assert
        expect(e, isA<GeminiServiceException>());
        expect((e as GeminiServiceException).message, startsWith('Failed to parse exercise analysis response:'));

        // Check for FormatException instead of SyntaxException
        expect(e.message, contains('FormatException'));
      }
    });
  });


  group('ExerciseAnalysisService correction functionality', () {
  test('should successfully correct exercise analysis based on user comment', () async {
    // Arrange
    final previousResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'Moderate',
      estimatedCalories: 350,
      metValue: 8.5,
      summary: 'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 5km in 30 minutes',
    );
    
    const userComment = 'I actually ran for 45 minutes, not 30';
    
    const correctionJsonResponse = '''
    {
      "exercise_type": "Running",
      "calories_burned": 525,
      "duration_minutes": 45,
      "intensity_level": "Moderate",
      "met_value": 8.5,
      "correction_applied": "Updated duration from 30 to 45 minutes and recalculated calories"
    }
    ''';

    // Mock
    mockModelWrapper.responseText = correctionJsonResponse;

    // Act
    final result = await service.correctAnalysis(previousResult, userComment);

    // Assert
    expect(result.exerciseType, equals('Running'));
    expect(result.estimatedCalories, equals(525));
    expect(result.duration, equals('45 minutes'));
    expect(result.intensity, equals('Moderate'));
    expect(result.metValue, equals(8.5));
    expect(result.originalInput, equals('Running 5km in 30 minutes'));
    expect(result.summary, contains('You performed Running for 45 minutes'));
    expect(result.summary, contains('Updated duration from 30 to 45 minutes'));
  });

  test('should preserve unchanged values when only some fields are corrected', () async {
    // Arrange
    final previousResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'Moderate',
      estimatedCalories: 350,
      metValue: 8.5,
      summary: 'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 5km in 30 minutes',
    );
    
    const userComment = 'It was actually high intensity';
    
    const correctionJsonResponse = '''
    {
      "exercise_type": "Running",
      "calories_burned": 420,
      "duration_minutes": 30,
      "intensity_level": "High",
      "met_value": 10.2,
      "correction_applied": "Updated intensity from Moderate to High and adjusted calories and MET value"
    }
    ''';

    // Mock
    mockModelWrapper.responseText = correctionJsonResponse;

    // Act
    final result = await service.correctAnalysis(previousResult, userComment);

    // Assert
    expect(result.exerciseType, equals('Running'));
    expect(result.estimatedCalories, equals(420));
    expect(result.duration, equals('30 minutes')); // Unchanged
    expect(result.intensity, equals('High')); // Changed
    expect(result.metValue, equals(10.2)); // Changed
    expect(result.originalInput, equals('Running 5km in 30 minutes'));
  });

  test('should handle incomplete JSON response by using previous values', () async {
    // Arrange
    final previousResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'Moderate',
      estimatedCalories: 350,
      metValue: 8.5,
      summary: 'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 5km in 30 minutes',
    );
    
    const userComment = 'I actually ran for 45 minutes';
    
    const partialJsonResponse = '''
    {
      "exercise_type": "Swimming",
      "correction_applied": "Changed exercise type from Running to Swimming"
    }
    ''';

    // Mock
    mockModelWrapper.responseText = partialJsonResponse;

    // Act
    final result = await service.correctAnalysis(previousResult, userComment);

    // Assert
    expect(result.exerciseType, equals('Swimming')); // Changed
    expect(result.estimatedCalories, equals(350)); // Preserved from previous
    expect(result.duration, equals('30 minutes')); // Preserved from previous
    expect(result.intensity, equals('Moderate')); // Preserved from previous
    expect(result.metValue, equals(8.5)); // Preserved from previous

  });

  test('should throw exception when API returns null response', () async {
    // Arrange
    final previousResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'Moderate',
      estimatedCalories: 350,
      metValue: 8.5,
      summary: 'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 5km in 30 minutes',
    );
    
    const userComment = 'I actually ran for 45 minutes';
    mockModelWrapper.responseText = null;

    // Act & Assert
    expect(
      () => service.correctAnalysis(previousResult, userComment),
      throwsA(isA<GeminiServiceException>().having(
        (e) => e.message,
        'error message',
        contains('No response text generated')
      )),
    );
  });

  test('should throw exception when API call fails', () async {
    // Arrange
    final previousResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'Moderate',
      estimatedCalories: 350,
      metValue: 8.5,
      summary: 'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 5km in 30 minutes',
    );
    
    const userComment = 'I actually ran for 45 minutes';
    mockModelWrapper.exceptionToThrow = Exception('API call failed');

    // Act & Assert
    expect(
      () => service.correctAnalysis(previousResult, userComment),
      throwsA(isA<GeminiServiceException>().having(
        (e) => e.message,
        'error message',
        contains('Error correcting exercise analysis')
      )),
    );
  });

  test('parseCorrectionResponse should handle invalid JSON format', () {
    // Arrange
    final previousResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'Moderate',
      estimatedCalories: 350,
      metValue: 8.5,
      summary: 'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 5km in 30 minutes',
    );
    
    const userComment = 'I actually ran for 45 minutes';
    final malformedJson = '{"exercise_type": "Swimming", "calories_burned": 400,';
    
    // Act & Assert
    expect(
      () => service.parseCorrectionResponse(malformedJson, previousResult, userComment),
      throwsA(
        isA<GeminiServiceException>()
          .having((e) => e.message, 'message', contains('Failed to parse exercise correction response'))
      ),
    );
  });

  test('should correctly extract duration minutes from string format', () async {
    // Arrange
    final previousResult = ExerciseAnalysisResult(
      exerciseType: 'Running',
      duration: '30 minutes and 15 seconds', // More complex duration string
      intensity: 'Moderate',
      estimatedCalories: 350,
      metValue: 8.5,
      summary: 'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
      timestamp: DateTime.now(),
      originalInput: 'Running 5km in 30 minutes',
    );
    
    const userComment = 'I ran longer';
    
    const correctionJsonResponse = '''
    {
      "exercise_type": "Running",
      "calories_burned": 525,
      "duration_minutes": 45,
      "intensity_level": "Moderate",
      "met_value": 8.5,
      "correction_applied": "Updated duration from 30 to 45 minutes and recalculated calories"
    }
    ''';

    // Mock
    mockModelWrapper.responseText = correctionJsonResponse;

    // Act
    final result = await service.correctAnalysis(previousResult, userComment);

    // Assert
    expect(result.duration, equals('45 minutes'));
    expect(result.estimatedCalories, equals(525));
  });
});
}