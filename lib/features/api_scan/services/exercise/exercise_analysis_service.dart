// lib/features/ai_api_scan/services/exercise/exercise_analysis_service.dart

//coverage: ignore-file

// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

class ExerciseAnalysisService {
  final ApiServiceInterface _apiService; // Change type to interface

  ExerciseAnalysisService({
    required ApiServiceInterface
        apiService, // Change parameter type to interface
  }) : _apiService = apiService;

  // coverage:ignore-start
  factory ExerciseAnalysisService.fromEnv({TokenManager? tokenManager}) {
    final ApiServiceInterface apiService =
        ApiService.fromEnv(tokenManager: tokenManager);
    return ExerciseAnalysisService(apiService: apiService);
  }
  // coverage:ignore-end

  Future<ExerciseAnalysisResult> analyze(String description,
      {String userId = "", double? userWeightKg}) async {
    try {
      final Map<String, dynamic> requestBody = {
        'description': description,
      };

      if (userWeightKg != null) {
        requestBody['user_weight_kg'] = userWeightKg;
      }

      final responseData = await _apiService.postJsonRequest(
        '/exercise/analyze',
        requestBody,
      );

      return parseExerciseResponse(responseData, description, userId);
    } catch (e) {
      if (e is ApiServiceException) {
        rethrow;
      }
      //coverage:ignore-start
      throw ApiServiceException("Error analyzing exercise: $e");
      //coverage:ignore-end
    }
  }

  ExerciseAnalysisResult parseExerciseResponse(
      Map<String, dynamic> jsonData, String originalInput, String userId) {
    try {
      // Check for error field in different formats
      if (jsonData.containsKey('error') && jsonData['error'] != null) {
        // Instead of throwing an exception, create a result with the error
        // This matches how your Python API handles errors
        return ExerciseAnalysisResult(
          exerciseType: jsonData['exercise_type'] ?? 'unknown',
          duration: "0 minutes",
          intensity: jsonData['intensity'] ?? 'unknown',
          estimatedCalories: 0,
          metValue: (jsonData['met_value'] ?? 0.0).toDouble(),
          summary: "Could not analyze exercise: ${jsonData['error']}",
          timestamp: DateTime.now(),
          originalInput: originalInput,
          missingInfo: ["exercise_type", "duration", "intensity"],
          userId: userId,
        );
      }

      final exerciseType = jsonData['exercise_type'] ?? 'unknown';
      final caloriesBurned = jsonData['calories_burned'] ?? 0;
      final durationAPI = jsonData['duration'] ?? '0 minutes';

      // The API sends lowercase intensity values (low, medium, high)
      // Capitalize the first letter for display in the Flutter app
      String intensity = jsonData['intensity'] ?? 'unknown';
      intensity = intensity.isNotEmpty
          ? intensity[0].toUpperCase() + intensity.substring(1)
          : 'unknown';

      final metValue = (jsonData['met_value'] ?? 0.0).toDouble();

      // Create a summary
      final summary =
          'You performed $exerciseType for $durationAPI at $intensity intensity, burning approximately $caloriesBurned calories.';

      // Check if any required fields are missing
      final List<String> missingInfo = [];
      if (exerciseType == 'unknown') missingInfo.add('exercise_type');
      if (durationAPI == '0 minutes') missingInfo.add('duration');
      if (intensity == 'unknown') missingInfo.add('intensity');

      // Create the exercise analysis result in the app's model format
      return ExerciseAnalysisResult(
        exerciseType: exerciseType,
        duration: durationAPI.toString().trim(),
        intensity: intensity,
        estimatedCalories:
            caloriesBurned is int ? caloriesBurned : caloriesBurned.toInt(),
        metValue: metValue,
        summary: summary,
        timestamp: DateTime.now(),
        originalInput: originalInput,
        missingInfo: missingInfo.isNotEmpty ? missingInfo : null,
        userId: userId,
      );
    } catch (e) {
      // Create a result with the error instead of throwing
      return ExerciseAnalysisResult(
        exerciseType: 'unknown',
        duration: '0 minutes',
        intensity: 'unknown',
        estimatedCalories: 0,
        metValue: 0.0,
        summary: "Failed to parse exercise analysis response: $e",
        timestamp: DateTime.now(),
        originalInput: originalInput,
        missingInfo: ["exercise_type", "duration", "intensity"],
        userId: userId,
      );
    }
  }

  Future<ExerciseAnalysisResult> correctAnalysis(
      ExerciseAnalysisResult previousResult, String userComment) async {
    try {
      // Convert ExerciseAnalysisResult to API format
      final Map<String, dynamic> apiFormat =
          _exerciseResultToApiFormat(previousResult);

      final responseData = await _apiService.postJsonRequest(
        '/exercise/correct',
        {
          'previous_result': apiFormat,
          'user_comment': userComment,
        },
      );

      return parseCorrectionResponse(
          jsonEncode(responseData), previousResult, userComment);
    } catch (e) {
      if (e is ApiServiceException) {
        throw ApiServiceException("API call failed: ${e.message}");
      }
      throw ApiServiceException("API call failed: $e");
    }
  }

  ExerciseAnalysisResult parseCorrectionResponse(String responseText,
      ExerciseAnalysisResult previousResult, String userComment) {
    try {
      // Reuse the existing parsing logic
      final jsonData = jsonDecode(responseText);

      // Validate required fields
      if (!jsonData.containsKey('exercise_type') ||
          !jsonData.containsKey('duration') ||
          !jsonData.containsKey('intensity')) {
        throw const FormatException(
            "Missing required fields in correction response");
      }

      // Extract values from JSON, defaulting to previous values if not provided
      final exerciseType =
          jsonData['exercise_type'] ?? previousResult.exerciseType;
      final caloriesBurned =
          jsonData['calories_burned'] ?? previousResult.estimatedCalories;

      // Handle duration as string directly from API
      final durationValue = jsonData['duration'] ?? previousResult.duration;

      // Handle the intensity, capitalizing the first letter
      String intensity = jsonData['intensity'] ?? previousResult.intensity;
      if (intensity != previousResult.intensity) {
        intensity = intensity.isNotEmpty
            ? intensity[0].toUpperCase() + intensity.substring(1)
            : 'unknown';
      }

      final metValue =
          (jsonData['met_value'] ?? previousResult.metValue).toDouble();
      final correctionApplied = jsonData['correction_applied'] ??
          'Adjustments applied based on user feedback';

      // Create a summary incorporating the correction information
      final summary =
          'You performed $exerciseType for $durationValue at $intensity intensity, burning approximately $caloriesBurned calories. ($correctionApplied)';

      // Create the corrected exercise analysis result
      return ExerciseAnalysisResult(
        exerciseType: exerciseType,
        duration: durationValue.toString().trim(),
        intensity: intensity,
        estimatedCalories:
            caloriesBurned is int ? caloriesBurned : caloriesBurned.toInt(),
        metValue: metValue,
        summary: summary,
        timestamp: DateTime.now(),
        originalInput: previousResult.originalInput,
        userId: previousResult.userId,
      );
    } catch (e) {
      throw ApiServiceException(
          "Failed to parse exercise correction response: $e");
    }
  }

  // Helper method to convert ExerciseAnalysisResult to API format
  Map<String, dynamic> _exerciseResultToApiFormat(
      ExerciseAnalysisResult result) {
    // Convert to lowercase to match API expectations
    final intensityLowercase = result.intensity.toLowerCase();

    return {
      'exercise_type': result.exerciseType,
      'calories_burned': result.estimatedCalories,
      'duration': result.duration, // Keep as string
      'intensity': intensityLowercase,
      'user_comment': result.originalInput, // Include original input as comment
    };
  }
}
