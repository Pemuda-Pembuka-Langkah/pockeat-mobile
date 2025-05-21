
// coverage:ignore-file

// Project imports:
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_widget_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';
import 'package:flutter/foundation.dart';
/// Controller khusus untuk simple food tracking widget
/// Implementasi dari [FoodTrackingWidgetController] untuk widget simple
/// Controller untuk Simple Food Tracking Widget
class SimpleFoodTrackingController implements FoodTrackingWidgetController {
  final WidgetDataService<SimpleFoodTracking> _widgetService;
  final CalorieStatsService _calorieStatsService;

  SimpleFoodTrackingController({
    required WidgetDataService<SimpleFoodTracking> widgetService,
    required CalorieStatsService calorieStatsService,
  })  : _widgetService = widgetService,
        _calorieStatsService = calorieStatsService;

  /// Inisialisasi controller
  @override
  Future<void> initialize() async {
    try {
      await _widgetService.initialize();
    } catch (e) {
      throw WidgetInitializationException(
          'Failed to initialize simple widget controller: $e');
    }
  }

  /// Memperbarui data widget dengan user yang aktif
  @override
  Future<void> updateWidgetData(UserModel? user, {int? targetCalories}) async {
    if (user == null) {
      await cleanupData();
      return;
    }

    try {
      final userId = user.uid;
      final userPreferencesService = GetIt.instance<UserPreferencesService>();

      // Hitung total kalori hari ini menggunakan CalorieStatsService
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dailyStats =
          await _calorieStatsService.calculateStatsForDate(userId, today);
      int consumedCalories = dailyStats.caloriesConsumed;
      final caloriesBurned = dailyStats.caloriesBurned;
      debugPrint('Consumed calories: $consumedCalories');
      
      // Base target kalori dihitung oleh client controller dan diberikan sebagai parameter
      int calculatedTarget = targetCalories ?? 0;
      
      // Ambil preferensi untuk fitur calorie compensation dan rollover
      final isCalorieCompensationEnabled = await userPreferencesService.isExerciseCalorieCompensationEnabled();
      final isRolloverCaloriesEnabled = await userPreferencesService.isRolloverCaloriesEnabled();
      
      // Tambahkan calories burned ke target jika kompensasi kalori diaktifkan
      if (isCalorieCompensationEnabled) {
        calculatedTarget += caloriesBurned;
        debugPrint('Added $caloriesBurned burned calories to target');
      }
      
      // Tambahkan rollover calories ke target jika fitur rollover diaktifkan
      if (isRolloverCaloriesEnabled) {
        final rolloverCalories = await userPreferencesService.getRolloverCalories();
        calculatedTarget += rolloverCalories;
        debugPrint('Added $rolloverCalories rollover calories to target');
      }

      // Round target calories to nearest multiple of 5 for consistency
      calculatedTarget = ((calculatedTarget + 2.5) ~/ 5) * 5;
      
      // Round consumed calories to nearest multiple of 5 for consistency
      consumedCalories = ((consumedCalories + 2.5) ~/ 5) * 5;
      
      // Calculate remaining calories (just like in CaloriesTodayWidget)
      int caloriesDifference = calculatedTarget - consumedCalories;
      bool isExceeded = caloriesDifference < 0;
      int remainingCalories = isExceeded ? 0 : caloriesDifference;
      
      // For simplicity, we'll report the consumed calories as (targetCalories - remainingCalories)
      // This ensures the widget shows correct remaining calories
      int adjustedConsumedCalories = calculatedTarget - remainingCalories;
      
      // Update data widget
      final simpleFoodTracking = SimpleFoodTracking(
        caloriesNeeded: calculatedTarget,
        currentCaloriesConsumed: adjustedConsumedCalories,
        userId: userId,
      );
      
      debugPrint('Simple widget - Target: $calculatedTarget, Consumed: $adjustedConsumedCalories, Remaining: $remainingCalories');

      await _widgetService.updateData(simpleFoodTracking);
      await _widgetService.updateWidget();
    } catch (e) {
      throw WidgetUpdateException('Failed to update simple widget: $e');
    }
  }

  /// Membersihkan data saat logout/app reset
  @override
  Future<void> cleanupData() async {
    try {
      final emptyData = SimpleFoodTracking.empty();
      await _widgetService.updateData(emptyData);
      await _widgetService.updateWidget();
    } catch (e) {
      throw WidgetCleanupException('Failed to clean up simple widget data: $e');
    }
  }
}
