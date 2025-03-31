// lib/features/ai_api_scan/services/exercise/exercise_analysis_service.dart
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/services/base/base_gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

class ExerciseAnalysisService extends BaseGeminiService {
  ExerciseAnalysisService({
    required super.apiKey,
    super.customModelWrapper,
  });
// coverage:ignore-start
  factory ExerciseAnalysisService.fromEnv() {
    return ExerciseAnalysisService(
        apiKey: BaseGeminiService.getApiKeyFromEnv());
  }
// coverage:ignore-end

  Future<ExerciseAnalysisResult> analyze(String description,
      {double? userWeightKg, String userId = ''}) async {
    try {
      final weightInfo =
          userWeightKg != null ? "The user weighs $userWeightKg kg." : "";

      final prompt = '''
      Calculate calories burned from this exercise description: "$description"
      $weightInfo
      
      Please analyze this exercise and provide:
      - Type of exercise
      - Calories burned
      - Duration in minutes
      - Intensity level
      - MET value
      
      Return your response as a strict JSON object with this exact format:
      {
        "exercise_type": "string",
        "calories_burned": number,
        "duration_minutes": number,
        "intensity_level": "string",
        "met_value": number
      }
      
      If you cannot determine the exercise details, use this format:
      {
        "error": "Could not determine exercise details",
        "exercise_type": "Unknown",
        "calories_burned": 0,
        "duration_minutes": 0,
        "intensity_level": "Unknown",
        "met_value": 0
      }
      ''';

      final response =
          await modelWrapper.generateContent([Content.text(prompt)]);
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }

      return parseExerciseResponse(response.text!, description, userId);
    } catch (e) {
      throw GeminiServiceException("Error analyzing exercise: $e");
    }
  }

  ExerciseAnalysisResult parseExerciseResponse(
      String responseText, String originalInput, String userId) {
    try {
      // Extract JSON from response text
      final jsonString = extractJson(responseText);
      final jsonData = jsonDecode(jsonString);

      // Check for error
      if (jsonData.containsKey('error')) {
        // We have an error but we'll still create a result with default values
        return ExerciseAnalysisResult(
          exerciseType: 'Unknown',
          duration: 'Not specified',
          intensity: 'Not specified',
          estimatedCalories: 0,
          metValue: 0.0,
          summary: 'Could not analyze exercise: ${jsonData['error']}',
          timestamp: DateTime.now(),
          originalInput: originalInput,
          missingInfo: ['exercise_type', 'duration', 'intensity'],
          userId: userId, // Add userId parameter
        );
      }

      final exerciseType = jsonData['exercise_type'] ?? 'Unknown';
      final caloriesBurned = jsonData['calories_burned'] ?? 0;
      final durationMinutes = jsonData['duration_minutes'] ?? 0;
      final intensityLevel = jsonData['intensity_level'] ?? 'Unknown';
      final metValue = (jsonData['met_value'] ?? 0.0).toDouble();

      // Create a summary
      final summary =
          'You performed $exerciseType for $durationMinutes minutes at $intensityLevel intensity, burning approximately $caloriesBurned calories.';

      // Determine duration string format
      final duration = '$durationMinutes minutes';

      // Create the exercise analysis result in the app's model format
      return ExerciseAnalysisResult(
        exerciseType: exerciseType,
        duration: duration,
        intensity: intensityLevel,
        estimatedCalories:
            caloriesBurned is int ? caloriesBurned : caloriesBurned.toInt(),
        metValue: metValue,
        summary: summary,
        timestamp: DateTime.now(),
        originalInput: originalInput,
        userId: userId,
      );
    } catch (e) {
      throw GeminiServiceException(
          "Failed to parse exercise analysis response: $e");
    }
  }

  Future<ExerciseAnalysisResult> correctAnalysis(
      ExerciseAnalysisResult previousResult, String userComment) async {
    try {
      final prompt = '''
      Original exercise analysis:
      - Exercise type: ${previousResult.exerciseType}
      - Duration: ${previousResult.duration}
      - Intensity: ${previousResult.intensity}
      - Calories burned: ${previousResult.estimatedCalories}
      - MET value: ${previousResult.metValue}
      
      User correction comment: "$userComment"
      
      Please correct the exercise analysis based on the user's comment. 
      Only modify values that need to be changed according to the user's feedback.
      
      Return your response as a strict JSON object with this exact format:
      {
        "exercise_type": "string",
        "calories_burned": number,
        "duration_minutes": number,
        "intensity_level": "string",
        "met_value": number,
        "correction_applied": "string explaining what was corrected"
      }
      ''';

      final response =
          await modelWrapper.generateContent([Content.text(prompt)]);
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }

      return parseCorrectionResponse(
          response.text!, previousResult, userComment);
    } catch (e) {
      throw GeminiServiceException("Error correcting exercise analysis: $e");
    }
  }

  ExerciseAnalysisResult parseCorrectionResponse(String responseText,
      ExerciseAnalysisResult previousResult, String userComment) {
    try {
      // Extract JSON from response text
      final jsonString = extractJson(responseText);
      final jsonData = jsonDecode(jsonString);

      // Extract values from JSON, defaulting to previous values if not provided
      final exerciseType =
          jsonData['exercise_type'] ?? previousResult.exerciseType;
      final caloriesBurned =
          jsonData['calories_burned'] ?? previousResult.estimatedCalories;

      // Handle duration which might be in string format in previousResult
      int durationMinutes;
      if (jsonData['duration_minutes'] != null) {
        durationMinutes = jsonData['duration_minutes'];
      } else {
        // Try to extract numbers from the previous duration string
        final durationString = previousResult.duration;
        final numbers = RegExp(r'\d+').allMatches(durationString);
        durationMinutes =
            numbers.isNotEmpty ? int.parse(numbers.first.group(0)!) : 0;
      }

      final intensityLevel =
          jsonData['intensity_level'] ?? previousResult.intensity;
      final metValue =
          (jsonData['met_value'] ?? previousResult.metValue).toDouble();
      final correctionApplied = jsonData['correction_applied'] ??
          'Adjustments applied based on user feedback';

      // Create a summary incorporating the correction information
      final summary =
          'You performed $exerciseType for $durationMinutes minutes at $intensityLevel intensity, burning approximately $caloriesBurned calories. ($correctionApplied)';

      // Determine duration string format
      final duration = '$durationMinutes minutes';

      // Create the corrected exercise analysis result
      return ExerciseAnalysisResult(
        exerciseType: exerciseType,
        duration: duration,
        intensity: intensityLevel,
        estimatedCalories:
            caloriesBurned is int ? caloriesBurned : caloriesBurned.toInt(),
        metValue: metValue,
        summary: summary,
        timestamp: DateTime.now(),
        originalInput: previousResult.originalInput,
      userId: previousResult.userId,
      );
    } catch (e) {
      throw GeminiServiceException(
          "Failed to parse exercise correction response: $e");
    }
  }
}
