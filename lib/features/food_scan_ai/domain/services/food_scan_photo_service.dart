// Dart imports:
//

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';

class FoodScanPhotoService {
  final FoodImageAnalysisService _foodImageAnalysisService =
      getIt<FoodImageAnalysisService>();

  final NutritionLabelAnalysisService _nutritionLabelAnalysisService =
      getIt<NutritionLabelAnalysisService>();

  final FoodScanRepository _foodScanRepository = getIt<FoodScanRepository>();

  final FirebaseAuth firebaseAuth = getIt<FirebaseAuth>();

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
    // Get current user's ID
    final userId = firebaseAuth.currentUser?.uid ?? '';

    // Create a new analysis result with userId
    final resultWithUserId = analysisResult.copyWith(userId: userId);

    await _foodScanRepository.save(resultWithUserId, resultWithUserId.id);
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

  // get all food analysis
  Future<List<FoodAnalysisResult>> getAllFoodAnalysis() async {
    return await _foodScanRepository.getAll();
  }

  /// Analyzes a nutrition label photo and returns the analysis result
  ///
  /// [photo] is the image file to be analyzed
  /// Returns [FoodAnalysisResult] containing the food information
  Future<FoodAnalysisResult> analyzeNutritionLabelPhoto(
      File photo, double servingSize) async {
    try {
      final result =
          await _nutritionLabelAnalysisService.analyze(photo, servingSize);
      return result;
    } catch (e) {
      throw Exception('Failed to analyze food photo: ${e.toString()}');
    }
  }

  // correct the nutrition label analysis result
  Future<FoodAnalysisResult> correctNutritionLabelAnalysis(
      FoodAnalysisResult previousResult,
      String userComment,
      double servingSize) async {
    try {
      final correctedResult = await _nutritionLabelAnalysisService
          .correctAnalysis(previousResult, userComment, servingSize);
      return correctedResult;
    } catch (e) {
      throw Exception('Failed to correct food analysis: ${e.toString()}');
    }
  }
}
