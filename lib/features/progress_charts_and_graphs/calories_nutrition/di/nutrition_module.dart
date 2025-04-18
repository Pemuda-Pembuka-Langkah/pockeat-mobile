import 'package:get_it/get_it.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/repositories/nutrition_repository.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/repositories/nutrition_repository_impl.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/services/nutrition_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';

// coverage:ignore-start
class NutritionModule {
  static void register() {
    final GetIt getIt = GetIt.instance;

    // Register repository
    getIt.registerLazySingleton<NutritionRepository>(
      () => NutritionRepositoryImpl(
        foodLogService: getIt<FoodLogHistoryService>(),
        exerciseLogService: getIt<ExerciseLogHistoryService>(),
      ),
    );
    
    // Register service
    getIt.registerLazySingleton<NutritionService>(
      () => NutritionService(getIt<NutritionRepository>()),
    );
  }
}
// coverage:ignore-end