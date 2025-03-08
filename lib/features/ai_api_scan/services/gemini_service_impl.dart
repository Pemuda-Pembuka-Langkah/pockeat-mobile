// lib/features/ai_api_scan/services/gemini_service_impl.dart
import 'dart:io';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

/// Implementation that delegates to specialized services
class GeminiServiceImpl implements GeminiService {
  final FoodTextAnalysisService _foodTextAnalysisService;
  final FoodImageAnalysisService _foodImageAnalysisService;
  final NutritionLabelAnalysisService _nutritionLabelService;
  final ExerciseAnalysisService _exerciseAnalysisService;
  
  GeminiServiceImpl({
    required FoodTextAnalysisService foodTextAnalysisService,
    required FoodImageAnalysisService foodImageAnalysisService,
    required NutritionLabelAnalysisService nutritionLabelService,
    required ExerciseAnalysisService exerciseAnalysisService,
  }) : 
    _foodTextAnalysisService = foodTextAnalysisService,
    _foodImageAnalysisService = foodImageAnalysisService,
    _nutritionLabelService = nutritionLabelService,
    _exerciseAnalysisService = exerciseAnalysisService;

  factory GeminiServiceImpl.fromEnv() {
    return GeminiServiceImpl(
      foodTextAnalysisService: FoodTextAnalysisService.fromEnv(),
      foodImageAnalysisService: FoodImageAnalysisService.fromEnv(),
      nutritionLabelService: NutritionLabelAnalysisService.fromEnv(),
      exerciseAnalysisService: ExerciseAnalysisService.fromEnv(),
    );
  }

  @override
  Future<FoodAnalysisResult> analyzeFoodByText(String description) {
    return _foodTextAnalysisService.analyze(description);
  }

  @override
  Future<FoodAnalysisResult> analyzeFoodByImage(File imageFile) {
    return _foodImageAnalysisService.analyze(imageFile);
  }

  @override
  Future<FoodAnalysisResult> analyzeNutritionLabel(
      File imageFile, double servings) {
    return _nutritionLabelService.analyze(imageFile, servings);
  }

  @override
  Future<ExerciseAnalysisResult> analyzeExercise(String description,
      {double? userWeightKg}) {
    return _exerciseAnalysisService.analyze(
      description,
      userWeightKg: userWeightKg,
    );
  }
}