// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_widget_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import '../../services/nutrient_calculation_strategy.dart';

/// Controller khusus untuk detailed food tracking widget
/// Implementasi dari [FoodTrackingWidgetController] untuk widget detail
/// Controller untuk Detailed Food Tracking Widget

class DetailedFoodTrackingController implements FoodTrackingWidgetController {
  final WidgetDataService<DetailedFoodTracking> _widgetService;
  final FoodLogHistoryService _foodLogHistoryService;
  final CalorieStatsService _calorieStatsService;

  /// Strategy for nutrient calculations
  final NutrientCalculationStrategy _nutrientCalculationStrategy;

  DetailedFoodTrackingController({
    required WidgetDataService<DetailedFoodTracking> widgetService,
    required FoodLogHistoryService foodLogHistoryService,
    required CalorieStatsService calorieStatsService,
    NutrientCalculationStrategy? nutrientCalculationStrategy,
  })  : _widgetService = widgetService,
        _foodLogHistoryService = foodLogHistoryService,
        _calorieStatsService = calorieStatsService,
        _nutrientCalculationStrategy =
            nutrientCalculationStrategy ?? DefaultNutrientCalculationStrategy();

  /// Inisialisasi controller
  @override
  Future<void> initialize() async {
    try {
      await _widgetService.initialize();
    } catch (e) {
      throw WidgetInitializationException(
          'Failed to initialize detailed widget controller: $e');
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

      // Hitung total kalori hari ini menggunakan CalorieStatsService
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dailyStats =
          await _calorieStatsService.getStatsByDate(userId, today);
      final consumedCalories = dailyStats.caloriesConsumed;

      // Dapatkan data untuk nutrisi
      final todayLogs =
          await _foodLogHistoryService.getFoodLogsByDate(userId, today);

      // Hitung nutrisi menggunakan strategy
      final protein = _nutrientCalculationStrategy.calculateNutrientFromLogs(
          todayLogs, 'protein');
      final carbs = _nutrientCalculationStrategy.calculateNutrientFromLogs(
          todayLogs, 'carbs');
      final fat = _nutrientCalculationStrategy.calculateNutrientFromLogs(
          todayLogs, 'fat');

      // Target kalori sekarang dihitung oleh client controller dan diberikan sebagai parameter
      final calculatedTarget = targetCalories ?? 0;

      // Update data widget
      final detailedFoodTracking = DetailedFoodTracking(
        caloriesNeeded: calculatedTarget,
        currentCaloriesConsumed: consumedCalories,
        currentProtein: protein,
        currentCarb: carbs,
        currentFat: fat,
        userId: userId,
      );

      await _widgetService.updateData(detailedFoodTracking);
      await _widgetService.updateWidget();
    } catch (e) {
      throw WidgetUpdateException('Failed to update detailed widget: $e');
    }
  }

// Membersihkan data saat logout/app reset
  @override
  Future<void> cleanupData() async {
    try {
      final emptyData = DetailedFoodTracking.empty();
      await _widgetService.updateData(emptyData);
      await _widgetService.updateWidget();
    } catch (e) {
      throw WidgetCleanupException(
          'Failed to clean up detailed widget data: $e');
    }
  }
}
