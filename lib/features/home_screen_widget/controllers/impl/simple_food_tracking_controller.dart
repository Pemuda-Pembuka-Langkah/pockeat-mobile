// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_widget_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import '../../services/calorie_calculation_strategy.dart';

/// Controller khusus untuk simple food tracking widget
/// Implementasi dari [FoodTrackingWidgetController] untuk widget simple
/// Controller untuk Simple Food Tracking Widget
class SimpleFoodTrackingController implements FoodTrackingWidgetController {
  final WidgetDataService<SimpleFoodTracking> _widgetService;
  final FoodLogHistoryService _foodLogHistoryService;
  final CalorieCalculationStrategy _calorieCalculationStrategy;

  SimpleFoodTrackingController({
    required WidgetDataService<SimpleFoodTracking> widgetService,
    required FoodLogHistoryService foodLogHistoryService,
    CalorieCalculationStrategy? calorieCalculationStrategy,
  })  : _widgetService = widgetService,
        _foodLogHistoryService = foodLogHistoryService,
        _calorieCalculationStrategy =
            calorieCalculationStrategy ?? DefaultCalorieCalculationStrategy();

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

      // Hitung total kalori hari ini menggunakan strategy
      final consumedCalories = await _calorieCalculationStrategy
          .calculateTodayTotalCalories(_foodLogHistoryService, userId);

      // Target kalori sekarang dihitung oleh client controller dan diberikan sebagai parameter
      final calculatedTarget = targetCalories ?? 0;

      // Update data widget
      final simpleFoodTracking = SimpleFoodTracking(
        caloriesNeeded: calculatedTarget,
        currentCaloriesConsumed: consumedCalories,
        userId: userId,
      );

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
