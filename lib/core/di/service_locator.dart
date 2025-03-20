// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/ai_api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/features/food_log_history/di/food_log_history_module.dart';
import 'package:pockeat/features/exercise_log_history/di/exercise_log_history_module.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';
import 'package:pockeat/features/authentication/services/register_service_impl.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';

final getIt = GetIt.instance;
// coverage:ignore-start
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

  getIt.registerSingleton<FoodTextInputRepository>(
    FoodTextInputRepository(),
  );

  getIt.registerSingleton<FoodTextInputService>(
    FoodTextInputService(),
  );

  getIt.registerSingleton<FoodScanRepository>(
    FoodScanRepository(),
  );

  // getIt.registerLazySingleton<FoodTextInputRepository>(
  // () => FoodTextInputRepository(),
  // );

  getIt.registerSingleton<FoodScanPhotoService>(
    FoodScanPhotoService(),
  );

  getIt.registerSingleton<GeminiService>(
    GeminiServiceImpl(
      foodTextAnalysisService: getIt<FoodTextAnalysisService>(),
      foodImageAnalysisService: getIt<FoodImageAnalysisService>(),
      nutritionLabelService: getIt<NutritionLabelAnalysisService>(),
      exerciseAnalysisService: getIt<ExerciseAnalysisService>(),
    ),
  );

  // Register UserRepository
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(),
  );

  // Register RegisterService
  getIt.registerSingleton<RegisterService>(
    RegisterServiceImpl(userRepository: getIt<UserRepository>()),
  );

  // Register DeepLinkService
  getIt.registerSingleton<DeepLinkService>(
    DeepLinkServiceImpl(userRepository: getIt<UserRepository>()),
  );

  // Register Food Log History module
  FoodLogHistoryModule.register();

  // Register Exercise Log History module
  ExerciseLogHistoryModule.register();
}
 // coverage:ignore-end