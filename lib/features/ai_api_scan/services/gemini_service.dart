// lib/pockeat/features/ai_api_scan/services/gemini_service.dart
import 'dart:io';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

abstract class GeminiService {
  Future<FoodAnalysisResult> analyzeFoodByText(String description);
  Future<FoodAnalysisResult> analyzeFoodByImage(File imageFile);
  Future<FoodAnalysisResult> analyzeNutritionLabel(
      File imageFile, double servings);
  Future<ExerciseAnalysisResult> analyzeExercise(String description,
      {double? userWeightKg});
  Future<ExerciseAnalysisResult> correctExerciseAnalysis(
      ExerciseAnalysisResult previousResult, String userComment);
}

class GeminiServiceException implements Exception {
  final String message;

  GeminiServiceException(this.message);

  @override
  String toString() => 'GeminiServiceException: $message';
}
