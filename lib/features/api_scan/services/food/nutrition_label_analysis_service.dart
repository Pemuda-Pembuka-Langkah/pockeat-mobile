// lib/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart

// Dart imports:
import 'dart:io';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/api_scan/utils/food_analysis_parser.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';

class NutritionLabelAnalysisService {
  final ApiServiceInterface _apiService; // Change type to interface

  NutritionLabelAnalysisService({
    required ApiServiceInterface
        apiService, // Change parameter type to interface
  }) : _apiService = apiService;

  // coverage:ignore-start
  factory NutritionLabelAnalysisService.fromEnv({TokenManager? tokenManager}) {
    final ApiServiceInterface apiService =
        ApiService.fromEnv(tokenManager: tokenManager);
    return NutritionLabelAnalysisService(apiService: apiService);
  }
  // coverage:ignore-end

  Future<FoodAnalysisResult> analyze(File imageFile, double servings) async {
    try {
      final responseData = await _apiService.postFileRequest(
        '/food/analyze/nutrition-label',
        imageFile,
        'image',
        {'servings': servings.toString()},
      );

      return FoodAnalysisParser.parseMap(responseData);
    } catch (e) {
      if (e is ApiServiceException) {
        rethrow;
      }
      throw ApiServiceException("Error analyzing nutrition label: $e");
    }
  }

  Future<FoodAnalysisResult> correctAnalysis(FoodAnalysisResult previousResult,
      String userComment, double servings) async {
    try {
      final responseData = await _apiService.postJsonRequest(
        '/food/correct/nutrition-label',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
          'servings': servings,
        },
      );

      return FoodAnalysisResult.fromJson(responseData);
    } catch (e) {
      if (e is ApiServiceException) {
        rethrow;
      }
      throw ApiServiceException(
          "Error correcting nutrition label analysis: $e");
    }
  }
}
