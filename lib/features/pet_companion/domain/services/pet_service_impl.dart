// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';

class PetServiceImpl implements PetService {
  final GetIt _getIt = GetIt.instance;
  late final FoodLogHistoryService foodLogHistoryService;
  late final CalorieStatsService calorieStatsService;

  PetServiceImpl() {
    foodLogHistoryService = _getIt<FoodLogHistoryService>();
    calorieStatsService = _getIt<CalorieStatsService>();
  }

  @override
  Future<String> getPetMood(String userId) async {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final isLogToday =
        await foodLogHistoryService.getFoodLogsByDate(userId, today);

    if (isLogToday.isNotEmpty) {
      return 'happy';
    } else {
      return 'sad';
    }
  }

  @override
  Future<int> getPetHeart(String userId) async {
    final stats =
        await calorieStatsService.calculateStatsForDate(userId, DateTime.now());

    const targetCalories = 2000; // static for now

    final percentage = stats.caloriesConsumed / targetCalories;

    if (percentage > 0.75) {
      return 4;
    } else if (percentage > 0.5) {
      return 3;
    } else if (percentage > 0.25) {
      return 2;
    } else if (percentage > 0) {
      return 1;
    } else {
      return 0;
    }
  }
}
