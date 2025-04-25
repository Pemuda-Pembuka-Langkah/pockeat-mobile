// Dart imports:
import 'dart:async';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:pockeat/core/utils/background_logger.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_updater_service.dart';

// Firebase imports:

// coverage:ignore-start
/// Implementation of WidgetUpdaterService that handles widget updates
class WidgetUpdaterServiceImpl implements WidgetUpdaterService {
  /// Tag for logging
  static const String _tag = "WIDGET_UPDATER";

  @override
  Future<void> updateWidgets(Map<String, dynamic> services) async {
    try {
      await BackgroundLogger.log("Starting widget update process", tag: _tag);

      // Get the current user
      final auth = services['auth'] as FirebaseAuth;
      if (auth.currentUser == null) {
        await BackgroundLogger.log("No user logged in, skipping widget update",
            tag: _tag);
        return;
      }

      final userId = auth.currentUser!.uid;
      final simpleWidgetService = services['simpleWidgetService']
          as WidgetDataService<SimpleFoodTracking>;
      final detailedWidgetService = services['detailedWidgetService']
          as WidgetDataService<DetailedFoodTracking>;

      await BackgroundLogger.log("Got widget services for user: $userId",
          tag: _tag);

      // 1. Calculate total calories consumed today
      final int totalCalories =
          await calculateConsumedCalories(services, userId);
      await BackgroundLogger.log("Calculated consumed calories: $totalCalories",
          tag: _tag);

      // 2. Calculate target calories using the same service as client controller
      final int targetCalories =
          await calculateTargetCalories(services, userId);
      await BackgroundLogger.log("Calculated target calories: $targetCalories",
          tag: _tag);

      // 3. Update simple widget
      await simpleWidgetService.updateData(SimpleFoodTracking(
        userId: userId,
        caloriesNeeded: targetCalories,
        currentCaloriesConsumed: totalCalories,
      ));
      await simpleWidgetService.updateWidget();
      await BackgroundLogger.log("Updated simple widget", tag: _tag);

      // 4. Update detailed widget with nutrients
      final nutrientStrategy = services['nutrientCalculationStrategy']
          as NutrientCalculationStrategy;
      final foodLogService =
          services['foodLogHistoryService'] as FoodLogHistoryService;

      // Get food logs for today to calculate nutrients
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final todayLogs =
          await foodLogService.getFoodLogsByDate(userId, startOfDay);
      await BackgroundLogger.log(
          "Retrieved ${todayLogs.length} food logs for today",
          tag: _tag);

      // Calculate nutrients using the strategy
      final protein =
          nutrientStrategy.calculateNutrientFromLogs(todayLogs, 'protein');
      final carbs =
          nutrientStrategy.calculateNutrientFromLogs(todayLogs, 'carbs');
      final fat = nutrientStrategy.calculateNutrientFromLogs(todayLogs, 'fat');

      await BackgroundLogger.log(
          "Calculated nutrients - Protein: $protein, Carbs: $carbs, Fat: $fat",
          tag: _tag);

      await detailedWidgetService.updateData(DetailedFoodTracking(
        userId: userId,
        caloriesNeeded: targetCalories,
        currentCaloriesConsumed: totalCalories,
        currentProtein: protein,
        currentCarb: carbs,
        currentFat: fat,
      ));
      await detailedWidgetService.updateWidget();
      await BackgroundLogger.log("Updated detailed widget", tag: _tag);

      await BackgroundLogger.log("Widget update completed successfully",
          tag: _tag);
    } catch (e) {
      await BackgroundLogger.log("Error updating widgets: $e", tag: _tag);
    }
  }

  @override
  Future<int> calculateConsumedCalories(
      Map<String, dynamic> services, String userId) async {
    try {
      final calorieStrategy =
          services['calorieCalculationStrategy'] as CalorieCalculationStrategy;
      final foodLogService =
          services['foodLogHistoryService'] as FoodLogHistoryService;

      // Use strategy to calculate total calories
      return await calorieStrategy.calculateTodayTotalCalories(
          foodLogService, userId);
    } catch (e) {
      await BackgroundLogger.log("Error calculating consumed calories: $e",
          tag: _tag);
      return 0; // Default fallback if error
    }
  }

  @override
  Future<int> calculateTargetCalories(
      Map<String, dynamic> services, String userId) async {
    try {
      final calorieStrategy =
          services['calorieCalculationStrategy'] as CalorieCalculationStrategy;
      final healthMetricsRepository =
          services['healthMetricsRepository'] as HealthMetricsRepository;
      final caloricRequirementService =
          services['caloricRequirementService'] as CaloricRequirementService;

      // Use strategy to calculate target calories
      return await calorieStrategy.calculateTargetCalories(
          healthMetricsRepository, caloricRequirementService, userId);
    } catch (e) {
      await BackgroundLogger.log("Error calculating target calories: $e",
          tag: _tag);
      return 0; // Default fallback
    }
  }
}

// coverage:ignore-end
