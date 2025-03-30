// lib/features/ai_api_scan/services/exercise/exercise_analysis_service.dart
import 'dart:convert';
import 'package:pockeat/features/ai_api_scan/services/base/api_service.dart';
import 'package:pockeat/features/ai_api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

class ExerciseAnalysisService {
  final ApiServiceInterface _apiService; // Change type to interface

  ExerciseAnalysisService({
    required ApiServiceInterface
        apiService, // Change parameter type to interface
  }) : _apiService = apiService;

  // coverage:ignore-start
  factory ExerciseAnalysisService.fromEnv() {
    final apiService = ApiService.fromEnv();
    return ExerciseAnalysisService(apiService: apiService);
  }
  // coverage:ignore-end

  Future<ExerciseAnalysisResult> analyze(String description,
      {double? userWeightKg}) async {
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

      // Print respons dengan format yang lebih jelas
      print("\n\n===== EXERCISE API RESPONSE =====");
      print("RAW RESPONSE JSON:");
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      String prettyJson = encoder.convert(responseData);
      print(prettyJson);
      print("\n");

      // Print keys yang ada di respons
      print("AVAILABLE KEYS: ${responseData.keys.toList()}");

      // Print nilai field utama dengan pengecekan null
      print("\nKEY VALUES:");
      print("exercise_type: ${responseData['exercise_type']}");
      print("calories_burned: ${responseData['calories_burned']}");
      print("duration: ${responseData['duration']}");
      print("intensity: ${responseData['intensity']}");
      print("intensity: ${responseData['intensity']}");
      print("met_value: ${responseData['met_value']}");
      print("error: ${responseData['error']}");
      print("================================\n\n");

      return parseExerciseResponse(responseData, description);
    } catch (e) {
      print("Error during exercise analysis: $e");
      if (e is ApiServiceException) {
        rethrow;
      }
      throw ApiServiceException("Error analyzing exercise: $e");
    }
  }

  ExerciseAnalysisResult parseExerciseResponse(
      Map<String, dynamic> jsonData, String originalInput) {
    try {
      print("Debug: Processing exercise analysis response");
      print("Debug: Error field value: ${jsonData['error']}");
      print("Debug: Exercise type: ${jsonData['exercise_type']}");

      // Check for error field in different formats
      if (jsonData.containsKey('error') && jsonData['error'] != null) {
        // Instead of throwing an exception, create a result with the error
        // This matches how your Python API handles errors
        print("Debug: Error field is not null, creating error result");

        return ExerciseAnalysisResult(
          exerciseType: jsonData['exercise_type'] ?? 'Unknown',
          duration: "Not specified",
          intensity: jsonData['intensity'] ?? 'Unknown',
          estimatedCalories: 0,
          metValue: (jsonData['met_value'] ?? 0.0).toDouble(),
          summary: "Could not analyze exercise: ${jsonData['error']}",
          timestamp: DateTime.now(),
          originalInput: originalInput,
          missingInfo: ["exercise_type", "duration", "intensity"],
        );
      }

      print("Debug: Passed error check");

      final exerciseType = jsonData['exercise_type'] ?? 'Unknown';
      final caloriesBurned = jsonData['calories_burned'] ?? 0;
      final durationMinutes = jsonData['duration'] ?? 0;
      final intensityLevel = jsonData['intensity'] ?? 'Unknown';
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
      );
    } catch (e) {
      print("Debug: Caught exception in parseExerciseResponse: $e");
      // Create a result with the error instead of throwing
      return ExerciseAnalysisResult(
        exerciseType: 'Unknown',
        duration: 'Not specified',
        intensity: 'Unknown',
        estimatedCalories: 0,
        metValue: 0.0,
        summary: "Failed to parse exercise analysis response: $e",
        timestamp: DateTime.now(),
        originalInput: originalInput,
        missingInfo: ["exercise_type", "duration", "intensity"],
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
        rethrow;
      }
      throw ApiServiceException("Error correcting exercise analysis: $e");
    }
  }

  ExerciseAnalysisResult parseCorrectionResponse(String responseText,
      ExerciseAnalysisResult previousResult, String userComment) {
    try {
      // Reuse the existing parsing logic
      final jsonData = jsonDecode(responseText);

      // Extract values from JSON, defaulting to previous values if not provided
      final exerciseType =
          jsonData['exercise_type'] ?? previousResult.exerciseType;
      final caloriesBurned =
          jsonData['calories_burned'] ?? previousResult.estimatedCalories;

      // Handle duration which might be in string format in previousResult
      int durationMinutes;
      if (jsonData['duration'] != null) {
        durationMinutes = jsonData['duration'];
      } else {
        // Try to extract numbers from the previous duration string
        final durationString = previousResult.duration;
        final numbers = RegExp(r'\d+').allMatches(durationString);
        durationMinutes =
            numbers.isNotEmpty ? int.parse(numbers.first.group(0)!) : 0;
      }

      final intensityLevel = jsonData['intensity'] ?? previousResult.intensity;
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
      );
    } catch (e) {
      throw ApiServiceException(
          "Failed to parse exercise correction response: $e");
    }
  }

  // Helper method to convert ExerciseAnalysisResult to API format
  Map<String, dynamic> _exerciseResultToApiFormat(
      ExerciseAnalysisResult result) {
    // Extract duration minutes as a number
    final durationStr = result.duration;
    final numbers = RegExp(r'\d+').allMatches(durationStr);
    final durationMinutes =
        numbers.isNotEmpty ? int.parse(numbers.first.group(0)!) : 0;

    return {
      'exercise_type': result.exerciseType,
      'calories_burned': result.estimatedCalories,
      'duration': durationMinutes,
      'intensity': result.intensity,
      'met_value': result.metValue,
      'description': result.originalInput,
    };
  }
}
