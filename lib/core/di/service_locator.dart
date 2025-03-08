// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/ai_api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register specialized services
  getIt.registerSingleton<FoodTextAnalysisService>(
    FoodTextAnalysisService.fromEnv(),
  );
  
  getIt.registerSingleton<FoodImageAnalysisService>(
    FoodImageAnalysisService.fromEnv(),
  );
  
  getIt.registerSingleton<NutritionLabelAnalysisService>(
    NutritionLabelAnalysisService.fromEnv(),
  );
  
  getIt.registerSingleton<ExerciseAnalysisService>(
    ExerciseAnalysisService.fromEnv(),
  );
  
  getIt.registerSingleton<GeminiService>(
    GeminiServiceImpl(
      foodTextAnalysisService: getIt<FoodTextAnalysisService>(),
      foodImageAnalysisService: getIt<FoodImageAnalysisService>(),
      nutritionLabelService: getIt<NutritionLabelAnalysisService>(),
      exerciseAnalysisService: getIt<ExerciseAnalysisService>(),
    ),
  );
}