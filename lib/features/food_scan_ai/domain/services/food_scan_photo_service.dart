import 'dart:io';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:uuid/uuid.dart';

class FoodScanPhotoService {
  final FoodImageAnalysisService _foodImageAnalysisService = getIt<FoodImageAnalysisService>();
  final Uuid _uuid = Uuid();

  final FoodScanRepository _foodScanRepository = getIt<FoodScanRepository>();

  FoodScanPhotoService();

  /// Analyzes a food photo and returns the analysis result
  /// 
  /// [photo] is the image file to be analyzed
  /// Returns [FoodAnalysisResult] containing the food information
  Future<FoodAnalysisResult> analyzeFoodPhoto(File photo) async {
    try {
      final result = await _foodImageAnalysisService.analyze(photo);
      return result;
    } catch (e) {
      throw Exception('Failed to analyze food photo: ${e.toString()}');
    }
  }

  /// Saves the food analysis result to the database
  /// 
  /// [analysisResult] is the food analysis result to be saved
  /// Returns a success message if data is saved successfully
  Future<String> saveFoodAnalysis(FoodAnalysisResult analysisResult) async {
    await _foodScanRepository.save(analysisResult, _uuid.v4());
    return 'Successfully saved food analysis';
  }
  
  /// Corrects a food analysis result based on user feedback
  /// 
  /// [previousResult] is the previous analysis result
  /// [userComment] is the user's correction or feedback
  /// Returns [FoodAnalysisResult] that has been corrected
  Future<FoodAnalysisResult> correctFoodAnalysis(
      FoodAnalysisResult previousResult, String userComment) async {
    try {
      final correctedResult = await _foodImageAnalysisService.correctAnalysis(
          previousResult, userComment);
      return correctedResult;
    } catch (e) {
      throw Exception('Failed to correct food analysis: ${e.toString()}');
    }
  }
}