// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_updater_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

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
      int totalCalories =
          await calculateConsumedCalories(services, userId);

      // 2. Calculate target calories using the same service as client controller
      int targetCalories =
          await calculateTargetCalories(services, userId);

      // Round target calories to nearest multiple of 5 for consistency
      targetCalories = ((targetCalories + 2.5) ~/ 5) * 5;
      
      // Round consumed calories to nearest multiple of 5 for consistency
      totalCalories = ((totalCalories + 2.5) ~/ 5) * 5;
      
      // Calculate remaining calories (just like in CaloriesTodayWidget)
      int caloriesDifference = targetCalories - totalCalories;
      bool isExceeded = caloriesDifference < 0;
      int remainingCalories = isExceeded ? 0 : caloriesDifference;
      
      // For simplicity, we'll report the consumed calories as (targetCalories - remainingCalories)
      // This ensures the widget shows correct remaining calories
      int adjustedConsumedCalories = targetCalories - remainingCalories;
      
      debugPrint('Widget updater - Target: $targetCalories, Consumed: $adjustedConsumedCalories, Remaining: $remainingCalories');

      // 3. Update simple widget
      await simpleWidgetService.updateData(SimpleFoodTracking(
        userId: userId,
        caloriesNeeded: targetCalories,
        currentCaloriesConsumed: adjustedConsumedCalories,
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
        currentCaloriesConsumed: adjustedConsumedCalories,
        currentProtein: protein,
        currentCarb: carbs,
        currentFat: fat,
      ));
      await detailedWidgetService.updateWidget();
    } catch (e) {
      debugPrint('Error updating widgets: $e');
    }
  }

  @override
  Future<int> calculateConsumedCalories(
      Map<String, dynamic> services, String userId) async {
    try {
      // Use CalorieStatsService to get consumed calories
      final calorieStatsService =
          services['caloricStatsService'] as CalorieStatsService;
      final today = DateTime.now();

      // Get daily stats for today
      final stats = await calorieStatsService.calculateStatsForDate(userId, today);
      int consumedCalories = stats.caloriesConsumed;
      
      return consumedCalories;
    } catch (e) {
      debugPrint('Error calculating consumed calories: $e');
      return 0; // Default fallback if error
    }
  }

  @override
  Future<int> calculateTargetCalories(
      Map<String, dynamic> services, String userId) async {
    try {
      // Use CaloricRequirementRepository to get target calories
      final caloricRequirementRepository =
          services['caloricRequirementRepository']
              as CaloricRequirementRepository;
      final calorieStatsService =
          services['caloricStatsService'] as CalorieStatsService;
      final userPreferencesService =
          services['userPreferencesService'] as UserPreferencesService;

      // Get caloric requirement for the user
      final caloricRequirement =
          await caloricRequirementRepository.getCaloricRequirement(userId);

      // Use TDEE from caloric requirement or default to 2000 if not found
      int targetCalories = 2000; // Default if not found

      if (caloricRequirement != null) {
        // TDEE is the total daily energy expenditure - calories needed per day
        targetCalories = caloricRequirement.tdee.toInt();
      }
      
      // Check user preferences for exercise calorie compensation
      final isCalorieCompensationEnabled = 
          await userPreferencesService.isExerciseCalorieCompensationEnabled();
      
      // Check user preferences for rollover calories
      final isRolloverCaloriesEnabled = 
          await userPreferencesService.isRolloverCaloriesEnabled();
      
      // Add burned calories if compensation is enabled
      if (isCalorieCompensationEnabled) {
        final today = DateTime.now();
        final stats = await calorieStatsService.calculateStatsForDate(userId, today);
        final caloriesBurned = stats.caloriesBurned;
        targetCalories += caloriesBurned;
        debugPrint('Added $caloriesBurned burned calories to target in widget');
      }
      
      // Add rollover calories if enabled
      if (isRolloverCaloriesEnabled) {
        final rolloverCalories = await userPreferencesService.getRolloverCalories();
        targetCalories += rolloverCalories;
        debugPrint('Added $rolloverCalories rollover calories to target in widget');
      }

      return targetCalories;
    } catch (e) {
      debugPrint('Error calculating target calories: $e');
      return 2000; // Default fallback
    }
  }
}

// coverage:ignore-end
