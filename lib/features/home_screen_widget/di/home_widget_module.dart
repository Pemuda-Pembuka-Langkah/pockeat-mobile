// lib/features/home_screen_widget/di/home_widget_module.dart

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/detailed_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/food_tracking_client_controller_impl.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/simple_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/widget_installation_controller_impl.dart';
import 'package:pockeat/features/home_screen_widget/controllers/widget_installation_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_config.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/detailed_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/simple_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/widget_installation_service_impl.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_installation_service.dart';

// coverage:ignore-start
/// Module untuk dependency injection widget home screen
class HomeWidgetModule {
  /// Register semua dependency untuk module home screen widget
  static void register() {
    // 1. Register widget services
    getIt.registerLazySingleton<WidgetDataService<SimpleFoodTracking>>(
      () => SimpleFoodTrackingWidgetService(
        widgetName: HomeWidgetConfig.simpleWidgetName.value,
        appGroupId: HomeWidgetConfig.appGroupId.value,
      ),
    );

    getIt.registerLazySingleton<WidgetDataService<DetailedFoodTracking>>(
      () => DetailedFoodTrackingWidgetService(
        widgetName: HomeWidgetConfig.detailedWidgetName.value,
        appGroupId: HomeWidgetConfig.appGroupId.value,
      ),
    );

    // Register widget installation service
    getIt.registerLazySingleton<WidgetInstallationService>(
      () => WidgetInstallationServiceImpl(),
    );

    // 2. Register controller-controller spesifik
    getIt.registerLazySingleton<SimpleFoodTrackingController>(
      () => SimpleFoodTrackingController(
        widgetService: getIt<WidgetDataService<SimpleFoodTracking>>(),
        calorieStatsService: getIt<CalorieStatsService>(),
      ),
    );

    getIt.registerLazySingleton<DetailedFoodTrackingController>(
      () => DetailedFoodTrackingController(
        widgetService: getIt<WidgetDataService<DetailedFoodTracking>>(),
        calorieStatsService: getIt<CalorieStatsService>(),
        foodLogHistoryService: getIt<FoodLogHistoryService>(),
      ),
    );

    // 3. Register client controller yang mengelola keseluruhan widget
    getIt.registerLazySingleton<FoodTrackingClientController>(
      () => FoodTrackingClientControllerImpl(
        loginService: getIt<LoginService>(),
        caloricRequirementRepository: getIt<CaloricRequirementRepository>(),
        simpleController: getIt<SimpleFoodTrackingController>(),
        detailedController: getIt<DetailedFoodTrackingController>(),
      ),
    );

    // 4. Register widget installation controller
    getIt.registerLazySingleton<WidgetInstallationController>(
      () => WidgetInstallationControllerImpl(
        widgetInstallationService: getIt<WidgetInstallationService>(),
      ),
    );
  }

  /// Mendapatkan controller untuk simple food tracking
  static SimpleFoodTrackingController getSimpleController() {
    return getIt<SimpleFoodTrackingController>();
  }

  /// Mendapatkan controller untuk detailed food tracking
  static DetailedFoodTrackingController getDetailedController() {
    return getIt<DetailedFoodTrackingController>();
  }

  /// Mendapatkan client controller untuk koordinasi semua controller
  static FoodTrackingClientController getClientController() {
    return getIt<FoodTrackingClientController>();
  }

  /// Mendapatkan controller untuk instalasi dan manajemen widget
  static WidgetInstallationController getWidgetInstallationController() {
    return getIt<WidgetInstallationController>();
  }
}
// coverage:ignore-end
