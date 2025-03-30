// test/features/ai_api_scan/services/exercise/exercise_analysis_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/services/base/api_service.dart';
import 'package:pockeat/features/ai_api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

// Import the generated mock
import '../base/api_service_test.mocks.dart';

void main() {
  late MockApiServiceInterface mockApiService;
  late ExerciseAnalysisService service;

  setUp(() {
    mockApiService = MockApiServiceInterface();
    service = ExerciseAnalysisService(
      apiService: mockApiService,
    );
  });

  group('ExerciseAnalysisService', () {
    test('should analyze exercise successfully', () async {
      // Arrange
      const exerciseDescription = 'Running 5km in 30 minutes';
      const userWeight = 70.0;
      final validJsonResponse = {
        "exercise_type": "Running",
        "calories_burned": 350,
        "duration_minutes": 30,
        "intensity_level": "Moderate",
        "met_value": 8.5
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/exercise/analyze',
        {
          'description': exerciseDescription,
          'user_weight_kg': userWeight,
        },
      )).thenAnswer((_) async => validJsonResponse);

      // Act
      final result =
          await service.analyze(exerciseDescription, userWeightKg: userWeight);

      // Assert
      expect(result.exerciseType, equals('Running'));
      expect(result.estimatedCalories, equals(350));
      expect(result.duration, equals('30 minutes'));
      expect(result.intensity, equals('Moderate'));
      expect(result.metValue, equals(8.5));
      expect(result.originalInput, equals(exerciseDescription));

      // Verify the API call was made with correct parameters
      verify(mockApiService.postJsonRequest(
        '/exercise/analyze',
        {
          'description': exerciseDescription,
          'user_weight_kg': userWeight,
        },
      )).called(1);
    });

    test('should handle error but still return result with default values',
        () async {
      // Arrange
      const exerciseDescription = 'Standing still';
      final errorJsonResponse = {
        "error": "Could not determine exercise details",
        "exercise_type": "Unknown",
        "calories_burned": 0,
        "duration_minutes": 0,
        "intensity_level": "Unknown",
        "met_value": 0
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/exercise/analyze',
        {'description': exerciseDescription},
      )).thenAnswer((_) async => errorJsonResponse);

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

    test('should throw exception when API returns error', () async {
      // Arrange
      const exerciseDescription = 'Running 5km in 30 minutes';

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/exercise/analyze',
        {'description': exerciseDescription},
      )).thenThrow(ApiServiceException('API request failed'));

      // Act & Assert
      expect(
        () => service.analyze(exerciseDescription),
        throwsA(isA<ApiServiceException>().having(
            (e) => e.message, 'error message', contains('API request failed'))),
      );
    });
  });

  group('ExerciseAnalysisService error handling', () {
    test(
        'parseExerciseResponse should throw ApiServiceException when extractJson fails',
        () {
      // Arrange - String without clear JSON format
      final invalidText = 'This is not JSON at all';

      // Act & Assert
      expect(
        () => service.parseExerciseResponse(invalidText as Map<String, dynamic>, 'jogging'),
        throwsA(isA<ApiServiceException>().having((e) => e.message, 'message',
            contains('Failed to parse exercise analysis response'))),
      );
    });
  });

  group('ExerciseAnalysisService correction functionality', () {
    test('should successfully correct exercise analysis based on user comment',
        () async {
      // Arrange
      final previousResult = ExerciseAnalysisResult(
        exerciseType: 'Running',
        duration: '30 minutes',
        intensity: 'Moderate',
        estimatedCalories: 350,
        metValue: 8.5,
        summary:
            'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
        timestamp: DateTime.now(),
        originalInput: 'Running 5km in 30 minutes',
      );

      const userComment = 'I actually ran for 45 minutes, not 30';

      // Convert ExerciseAnalysisResult to API format first
      final apiFormat = {
        'exercise_type': 'Running',
        'calories_burned': 350,
        'duration_minutes': 30,
        'intensity_level': 'Moderate',
        'met_value': 8.5,
        'description': 'Running 5km in 30 minutes',
      };

      final correctionJsonResponse = {
        "exercise_type": "Running",
        "calories_burned": 525,
        "duration_minutes": 45,
        "intensity_level": "Moderate",
        "met_value": 8.5,
        "correction_applied":
            "Updated duration from 30 to 45 minutes and recalculated calories"
      };

      // Set up mock
      when(mockApiService.postJsonRequest(
        '/exercise/correct',
        {
          'previous_result': apiFormat,
          'user_comment': userComment,
        },
      )).thenAnswer((_) async => correctionJsonResponse);

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
      expect(
          result.summary, contains('Updated duration from 30 to 45 minutes'));

      // Verify the API call was made with correct parameters
      verify(mockApiService.postJsonRequest(
        '/exercise/correct',
        {
          'previous_result': apiFormat,
          'user_comment': userComment,
        },
      )).called(1);
    });

    test('should throw exception when API call fails during correction',
        () async {
      // Arrange
      final previousResult = ExerciseAnalysisResult(
        exerciseType: 'Running',
        duration: '30 minutes',
        intensity: 'Moderate',
        estimatedCalories: 350,
        metValue: 8.5,
        summary:
            'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
        timestamp: DateTime.now(),
        originalInput: 'Running 5km in 30 minutes',
      );

      const userComment = 'I actually ran for 45 minutes';

      // Convert ExerciseAnalysisResult to API format first
      final apiFormat = {
        'exercise_type': 'Running',
        'calories_burned': 350,
        'duration_minutes': 30,
        'intensity_level': 'Moderate',
        'met_value': 8.5,
        'description': 'Running 5km in 30 minutes',
      };

      // Set up mock to throw exception
      when(mockApiService.postJsonRequest(
        '/exercise/correct',
        {
          'previous_result': apiFormat,
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
