// lib/features/ai_api_scan/services/food/food_text_analysis_service.dart
//coverage: ignore-file

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/api_scan/utils/food_analysis_parser.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';

class FoodTextAnalysisService {
  final ApiServiceInterface _apiService; // Change type to interface

  FoodTextAnalysisService({
    required ApiServiceInterface
        apiService, // Change parameter type to interface
  }) : _apiService = apiService;

  // coverage:ignore-start
  factory FoodTextAnalysisService.fromEnv({TokenManager? tokenManager}) {
    final ApiServiceInterface apiService =
        ApiService.fromEnv(tokenManager: tokenManager);
    return FoodTextAnalysisService(apiService: apiService);
  }
  // coverage:ignore-end

  Future<FoodAnalysisResult> analyze(String description) async {
    try {
      final responseData = await _apiService.postJsonRequest(
        '/food/analyze/text',
        {'description': description},
      );

      return FoodAnalysisParser.parseMap(responseData);
    } catch (e) {
      if (e is ApiServiceException) {
        rethrow;
      }
      throw ApiServiceException(
          "Failed to analyze food description '$description': $e");
    }
  }

  Future<FoodAnalysisResult> correctAnalysis(
      FoodAnalysisResult previousResult, String userComment) async {
    try {
      final responseData = await _apiService.postJsonRequest(
        '/food/correct/text',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      );

      final foodResult = FoodAnalysisResult.fromJson(responseData);

      // Even if there's an error field, return a FoodAnalysisResult
      // The fromJson method or caller can handle the error appropriately
      return foodResult;
    } catch (e) {
      if (e is ApiServiceException) {
        rethrow;
      }
      throw ApiServiceException("Failed to correct food analysis: $e");
    }
  }
}
