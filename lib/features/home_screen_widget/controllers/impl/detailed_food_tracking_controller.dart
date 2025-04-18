import 'package:flutter/material.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_nutrient_calculation_strategy.dart';
import '../../services/calorie_calculation_strategy.dart';
import '../../services/nutrient_calculation_strategy.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_widget_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_event_type.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';

/// Controller khusus untuk detailed food tracking widget
/// Implementasi dari [FoodTrackingWidgetController] untuk widget detail
/// Controller untuk Detailed Food Tracking Widget
typedef RefreshCallback = void Function(FoodWidgetEventType event);

class DetailedFoodTrackingController implements FoodTrackingWidgetController {
  final WidgetDataService<DetailedFoodTracking> _widgetService;
  final FoodLogHistoryService _foodLogHistoryService;
  
  /// Navigator key untuk navigasi antar halaman
  late GlobalKey<NavigatorState> _navigatorKey;
  
  /// Callback untuk event refresh, diset oleh client controller
  RefreshCallback? _refreshCallback;

  /// Strategies for calorie and nutrient calculations
  final CalorieCalculationStrategy _calorieCalculationStrategy;
  final NutrientCalculationStrategy _nutrientCalculationStrategy;

  DetailedFoodTrackingController({
    required WidgetDataService<DetailedFoodTracking> widgetService,
    required FoodLogHistoryService foodLogHistoryService,
    CalorieCalculationStrategy? calorieCalculationStrategy,
    NutrientCalculationStrategy? nutrientCalculationStrategy,
  })  : _widgetService = widgetService,
        _foodLogHistoryService = foodLogHistoryService,
        _calorieCalculationStrategy = calorieCalculationStrategy ?? DefaultCalorieCalculationStrategy(),
        _nutrientCalculationStrategy = nutrientCalculationStrategy ?? DefaultNutrientCalculationStrategy();

  /// Inisialisasi controller
  @override
  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey}) async {
    try {
      // Set navigator key
      _navigatorKey = navigatorKey;
      await _widgetService.initialize();
      await registerWidgetClickCallback();
    } catch (e) {
      throw WidgetInitializationException('Failed to initialize detailed widget controller: $e');
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
      final consumedCalories = await _calorieCalculationStrategy.calculateTodayTotalCalories(
        _foodLogHistoryService, 
        userId
      );
      
      // Dapatkan data untuk nutrisi
      final DateTime now = DateTime.now();
      final DateTime startOfDay = DateTime(now.year, now.month, now.day);
      final todayLogs = await _foodLogHistoryService.getFoodLogsByDate(userId, startOfDay);
      
      // Hitung nutrisi menggunakan strategy
      final protein = _nutrientCalculationStrategy.calculateNutrientFromLogs(todayLogs, 'protein');
      final carbs = _nutrientCalculationStrategy.calculateNutrientFromLogs(todayLogs, 'carbs');
      final fat = _nutrientCalculationStrategy.calculateNutrientFromLogs(todayLogs, 'fat');
      
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
  
  /// Menangani interaksi dari widget
  @override
  Future<void> handleWidgetInteraction(FoodWidgetEventType eventType) async {
    try {
      switch (eventType) {
        case FoodWidgetEventType.clicked:
          // Navigasi ke halaman home
          _navigatorKey.currentState?.pushNamed('/');
          break;
        case FoodWidgetEventType.refresh:
          // Panggil refresh callback jika ada
          _refreshCallback?.call(eventType);
          break;
        case FoodWidgetEventType.quicklog:
          // Navigasi ke halaman tambah makanan
          _navigatorKey.currentState?.pushNamed('/add-food');
          break;
        case FoodWidgetEventType.other:
          // Handle other events
          break;
      }
    } catch (e) {
      throw HomeScreenWidgetException('Failed to handle widget interaction: $e');
    }
  }
  
  /// Set refresh callback dari client controller
  void setRefreshCallback(RefreshCallback callback) {
    _refreshCallback = callback;
  }
  
  /// Mendaftarkan callback untuk widget events
  @override
  Future<void> registerWidgetClickCallback() async {
    try {
      await _widgetService.registerWidgetClickCallback();
      _widgetService.widgetEvents.listen((event) {
        handleWidgetInteraction(event);
      });
    } catch (e) {
      throw WidgetCallbackRegistrationException('Failed to register widget callbacks: $e');
    }
  }
  
  /// Membersihkan data saat logout/app reset
  @override
  Future<void> cleanupData() async {
    try {
      final emptyData = DetailedFoodTracking.empty();
      await _widgetService.updateData(emptyData);
      await _widgetService.updateWidget();
    } catch (e) {
      throw WidgetCleanupException('Failed to clean up detailed widget data: $e');
    }
  }
  
 
  

}
