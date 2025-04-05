// lib/features/ai_api_scan/services/food/food_image_analysis_service.dart
import 'dart:io';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/api_scan/utils/food_analysis_parser.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';

class FoodImageAnalysisService {
  final ApiServiceInterface _apiService; // Interface type

  FoodImageAnalysisService({
    required ApiServiceInterface apiService, // Interface parameter
  }) : _apiService = apiService;

// coverage:ignore-start
  factory FoodImageAnalysisService.fromEnv({TokenManager? tokenManager}) {
  final ApiServiceInterface apiService = ApiService.fromEnv(tokenManager: tokenManager);
  return FoodImageAnalysisService(apiService: apiService);
}
// coverage:ignore-end
  Future<FoodAnalysisResult> analyze(File imageFile) async {
    try {
      final responseData = await _apiService.postFileRequest(
        '/food/analyze/image',
        imageFile,
        'image',
      );

      // Even if there's an error field, return a FoodAnalysisResult
      // The fromJson method or caller can handle the error appropriately
      return FoodAnalysisParser.parseMap(responseData);
    } catch (e) {
      if (e is ApiServiceException) {
        rethrow;
      }
      throw ApiServiceException("Error analyzing food from image: $e");
    }
  }

  Future<FoodAnalysisResult> correctAnalysis(
      FoodAnalysisResult previousResult, String userComment) async {
    try {
      final responseData = await _apiService.postJsonRequest(
        '/food/correct/image',
        {
          'previous_result': previousResult.toJson(),
          'user_comment': userComment,
        },
      );

      // Even if there's an error field, return a FoodAnalysisResult
      // The fromJson method or caller can handle the error appropriately
      return FoodAnalysisResult.fromJson(responseData);
    } catch (e) {
      if (e is ApiServiceException) {
        rethrow;
      }
      throw ApiServiceException("Error correcting food analysis: $e");
    }
  }
}
