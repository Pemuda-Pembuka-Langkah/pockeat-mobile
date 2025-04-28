// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/repositories/calorie_stats_repository.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';

// coverage:ignore-start
class CalorieStatsModule {
  static void register() {
    final getIt = GetIt.instance;

    // Register repository
    getIt.registerSingleton<CalorieStatsRepository>(
      CalorieStatsRepositoryImpl(),
    );

    // Register service
    getIt.registerSingleton<CalorieStatsService>(
      CalorieStatsServiceImpl(
        repository: getIt<CalorieStatsRepository>(),
        exerciseService: getIt<ExerciseLogHistoryService>(),
        foodService: getIt<FoodLogHistoryService>(),
      ),
    );
  }
}
// coverage:ignore-end
