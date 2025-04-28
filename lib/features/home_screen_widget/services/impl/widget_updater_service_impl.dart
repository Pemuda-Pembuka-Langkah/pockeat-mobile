// Dart imports:
import 'dart:async';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
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
  @override
  Future<void> updateWidgets(Map<String, dynamic> services) async {
    try {
      // Get the current user
      final auth = services['auth'] as FirebaseAuth;
      if (auth.currentUser == null) {
        return;
      }

      final userId = auth.currentUser!.uid;
      final simpleWidgetService = services['simpleWidgetService']
          as WidgetDataService<SimpleFoodTracking>;
      final detailedWidgetService = services['detailedWidgetService']
          as WidgetDataService<DetailedFoodTracking>;

      // 1. Calculate total calories consumed today
      final int totalCalories =
          await calculateConsumedCalories(services, userId);

      // 2. Calculate target calories using the same service as client controller
      final int targetCalories =
          await calculateTargetCalories(services, userId);

      // 3. Update simple widget
      await simpleWidgetService.updateData(SimpleFoodTracking(
        userId: userId,
        caloriesNeeded: targetCalories,
        currentCaloriesConsumed: totalCalories,
      ));
      await simpleWidgetService.updateWidget();

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

      // Calculate nutrients using the strategy
      final protein =
          nutrientStrategy.calculateNutrientFromLogs(todayLogs, 'protein');
      final carbs =
          nutrientStrategy.calculateNutrientFromLogs(todayLogs, 'carbs');
      final fat = nutrientStrategy.calculateNutrientFromLogs(todayLogs, 'fat');

      await detailedWidgetService.updateData(DetailedFoodTracking(
        userId: userId,
        caloriesNeeded: targetCalories,
        currentCaloriesConsumed: totalCalories,
        currentProtein: protein,
        currentCarb: carbs,
        currentFat: fat,
      ));
      await detailedWidgetService.updateWidget();
    } catch (e) {
      // Error handling without logging
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
      return 0; // Default fallback
    }
  }
}

// coverage:ignore-end
