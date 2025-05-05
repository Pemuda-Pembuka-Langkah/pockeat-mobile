// Package imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/domain/repositories/calorie_stats_repository.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';

// coverage:ignore-start
abstract class CalorieStatsService {
  Future<DailyCalorieStats> getStatsByDate(String userId, DateTime date);
  Future<List<DailyCalorieStats>> getStatsByDateRange(
      String userId, DateTime startDate, DateTime endDate);
  Future<DailyCalorieStats> calculateStatsForDate(String userId, DateTime date);
}

class CalorieStatsServiceImpl implements CalorieStatsService {
  final CalorieStatsRepository _repository;
  final ExerciseLogHistoryService _exerciseService;
  final FoodLogHistoryService _foodService;

  CalorieStatsServiceImpl({
    required CalorieStatsRepository repository,
    required ExerciseLogHistoryService exerciseService,
    required FoodLogHistoryService foodService,
  })  : _repository = repository,
        _exerciseService = exerciseService,
        _foodService = foodService;

  @override
  Future<DailyCalorieStats> getStatsByDate(String userId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Try to get cached stats first
    final cachedStats =
        await _repository.getStatsByDate(userId, normalizedDate);
    if (cachedStats != null) return cachedStats;

    // If not cached, calculate and cache them
    return await calculateStatsForDate(userId, normalizedDate);
  }

  @override
  Future<List<DailyCalorieStats>> getStatsByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    final normalizedStart =
        DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    final daysDifference = normalizedEnd.difference(normalizedStart).inDays;

    List<DailyCalorieStats> results = [];

    // Collect stats for each day in the range
    for (int i = 0; i <= daysDifference; i++) {
      final date = normalizedStart.add(Duration(days: i));
      final stats = await getStatsByDate(userId, date);
      results.add(stats);
    }

    return results;
  }

  @override
  Future<DailyCalorieStats> calculateStatsForDate(
      String userId, DateTime date) async {
    // Get exercise logs for the day
    final exerciseLogs =
        await _exerciseService.getExerciseLogsByDate(userId, date);
    for (var log in exerciseLogs) {
      int caloriesBurned = log.caloriesBurned.toInt();
      debugPrint("exerciseLog: $caloriesBurned");
    }

    // Calculate total calories burned
    final caloriesBurned = exerciseLogs.fold<int>(
        0, (sum, log) => sum + log.caloriesBurned.toInt());
    debugPrint("caloriesBurned: $caloriesBurned");
    // Get food logs for the day
    final foodLogs = await _foodService.getFoodLogsByDate(userId, date);
    debugPrint("date: $date");
    debugPrint("userId: $userId");
    // Calculate total calories consumed
    final caloriesConsumed =
        foodLogs.fold<int>(0, (sum, log) => sum + log.calories.toInt());

    // Create stats object
    final stats = DailyCalorieStats(
      userId: userId,
      date: date,
      caloriesBurned: caloriesBurned,
      caloriesConsumed: caloriesConsumed,
    );

    // Cache the results
    await _repository.saveStats(stats);

    return stats;
  }
}
// coverage:ignore-end
