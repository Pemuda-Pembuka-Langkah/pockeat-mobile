// lib/features/home_screen_widget/services/widget_background_service.dart
// coverage:ignore-file

import 'dart:async';

import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/background_service_config.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_config.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/simple_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/detailed_food_tracking_widget_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_nutrient_calculation_strategy.dart';

/// Class untuk mengatur background service widget updates
class WidgetBackgroundService {
  /// Initialize workmanager
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set ke true untuk debugging
    );
  }

  /// Register periodic task untuk update widget
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      BackgroundServiceConfig.periodicUpdateTaskId.value,
      BackgroundServiceConfig.periodicUpdateTaskName.value,
      frequency: BackgroundServiceConfig.minimumFetchInterval.value,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  /// Register one-time task untuk midnight update (00:00)
  static Future<void> registerMidnightTask() async {
    // Hitung waktu untuk besok 00:00
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0);
    final initialDelay = midnight.difference(now);

    await Workmanager().registerOneOffTask(
      BackgroundServiceConfig.midnightUpdateTaskId.value,
      BackgroundServiceConfig.midnightUpdateTaskName.value,
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false, // Tidak perlu sedang mengisi daya
      ),
    );
  }

  /// Batalkan semua task yang terdaftar
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
}

/// Service locator untuk background service
class WidgetServiceLocator {
  /// Setup services untuk background tasks
  /// Menggunakan service yang identik dengan yang ada di main app
  static Future<Map<String, dynamic>> setupBackgroundServices() async {
    final services = <String, dynamic>{};

    // Widget services yang tidak ada di service locator
    services['simpleWidgetService'] = SimpleFoodTrackingWidgetService(
      widgetName: HomeWidgetConfig.simpleWidgetName.value,
      appGroupId: HomeWidgetConfig.appGroupId.value,
    );

    services['detailedWidgetService'] = DetailedFoodTrackingWidgetService(
      widgetName: HomeWidgetConfig.detailedWidgetName.value,
      appGroupId: HomeWidgetConfig.appGroupId.value,
    );

    // Setup strategy classes
    services['calorieCalculationStrategy'] =
        DefaultCalorieCalculationStrategy();
    services['nutrientCalculationStrategy'] =
        DefaultNutrientCalculationStrategy();

    // Setup FoodLogHistoryService
    services['foodLogHistoryService'] = getIt<FoodLogHistoryService>();

    // Simpan semua services yang dibutuhkan dalam map
    services['auth'] = FirebaseAuth.instance;
    services['firestore'] = FirebaseFirestore.instance;
    services['caloricRequirementService'] = getIt<CaloricRequirementService>();
    services['healthMetricsRepository'] = getIt<HealthMetricsRepository>();
    services['healthMetricsCheckService'] = getIt<HealthMetricsCheckService>();

    return services;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final services = await WidgetServiceLocator.setupBackgroundServices();

      switch (task) {
        case BackgroundServiceConfig.PERIODIC_UPDATE_TASK_ID:
          await _updateWidgets(services);

          // Setup lagi midnight task jika periodic task berjalan
          await WidgetBackgroundService.registerMidnightTask();
          break;

        case BackgroundServiceConfig.MIDNIGHT_UPDATE_TASK_ID:
          await _updateWidgets(services);

          // Re-schedule task untuk midnight besok
          await WidgetBackgroundService.registerMidnightTask();
          break;

        default:
          break;
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

/// Fungsi helper untuk memperbarui widget
Future<void> _updateWidgets(Map<String, dynamic> services) async {
  try {
    // Dapatkan user yang sedang login
    final auth = services['auth'] as FirebaseAuth;
    if (auth.currentUser == null) return;

    final userId = auth.currentUser!.uid;
    final simpleWidgetService = services['simpleWidgetService']
        as WidgetDataService<SimpleFoodTracking>;
    final detailedWidgetService = services['detailedWidgetService']
        as WidgetDataService<DetailedFoodTracking>;

    // 1. Hitung total kalori yang dikonsumsi hari ini
    final int totalCalories =
        await _calculateConsumedCalories(services, userId);

    // 2. Hitung target kalori dengan service yang sama seperti di client controller
    final int targetCalories = await _calculateTargetCalories(services, userId);

    // 3. Update simple widget
    await simpleWidgetService.updateData(SimpleFoodTracking(
      userId: userId,
      caloriesNeeded: targetCalories,
      currentCaloriesConsumed: totalCalories,
    ));
    await simpleWidgetService.updateWidget();

    // 4. Update detailed widget with nutrients
    final nutrientStrategy =
        services['nutrientCalculationStrategy'] as NutrientCalculationStrategy;
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
    // Log error secara silent
  }
}

/// Menghitung total kalori yang dikonsumsi hari ini menggunakan CalorieCalculationStrategy
Future<int> _calculateConsumedCalories(
    Map<String, dynamic> services, String userId) async {
  try {
    final calorieStrategy =
        services['calorieCalculationStrategy'] as CalorieCalculationStrategy;
    final foodLogService =
        services['foodLogHistoryService'] as FoodLogHistoryService;

    // Gunakan strategy untuk menghitung total kalori
    return await calorieStrategy.calculateTodayTotalCalories(
        foodLogService, userId);
  } catch (e) {
    return 0; // Default fallback jika error
  }
}

/// Menghitung target kalori berdasarkan health metrics menggunakan CalorieCalculationStrategy
Future<int> _calculateTargetCalories(
    Map<String, dynamic> services, String userId) async {
  try {
    final calorieStrategy =
        services['calorieCalculationStrategy'] as CalorieCalculationStrategy;
    final healthMetricsRepository =
        services['healthMetricsRepository'] as HealthMetricsRepository;
    final caloricRequirementService =
        services['caloricRequirementService'] as CaloricRequirementService;

    // Gunakan strategy untuk menghitung target kalori
    return await calorieStrategy.calculateTargetCalories(
        healthMetricsRepository, caloricRequirementService, userId);
  } catch (e) {
    return 0; // Default fallback
  }
}
