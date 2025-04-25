// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/config/production.dart';
import 'package:pockeat/config/staging.dart';
import 'package:pockeat/core/utils/background_logger.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:pockeat/features/authentication/services/login_service_impl.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository_impl.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_config.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/detailed_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/simple_food_tracking_widget_service.dart';

// coverage:ignore-start
/// Service for setting up dependencies needed by background tasks
class BackgroundDependencyService {
  static const String _tag = "BACKGROUND_DEPS";

  /// Setup all required dependencies for background tasks
  static Future<Map<String, dynamic>> setupDependencies() async {
    final services = <String, dynamic>{};

    try {
      await BackgroundLogger.log("Setting up background service dependencies",
          tag: _tag);

      // Initialize environment and Firebase
      await _setupEnvironment(services);

      // Setup notification dependencies
      await setupNotificationDependencies(services);

      // Setup widget dependencies
      await setupWidgetDependencies(services);

      await BackgroundLogger.log(
          "Background dependencies setup complete with ${services.length} services",
          tag: _tag);
      return services;
    } catch (e) {
      await BackgroundLogger.log("Error setting up background dependencies: $e",
          tag: _tag);
      return services;
    }
  }

  /// Setup environment variables and Firebase
  static Future<void> _setupEnvironment(Map<String, dynamic> services) async {
    // Load environment variables
    String flavor = 'staging';
    try {
      await dotenv.load();
      flavor = dotenv.env['FLAVOR'] ?? 'staging';
      await BackgroundLogger.log("Loaded flavor: $flavor", tag: _tag);
    } catch (dotenvError) {
      await BackgroundLogger.log(
          "Could not load .env: $dotenvError, using default flavor",
          tag: _tag);
    }

    // Initialize Firebase with flavor-specific options
    try {
      await Firebase.initializeApp(
        options: flavor == 'production'
            ? ProductionFirebaseOptions.currentPlatform
            : flavor == 'staging'
                ? StagingFirebaseOptions.currentPlatform
                : StagingFirebaseOptions.currentPlatform,
      );
      await BackgroundLogger.log(
          "Firebase initialized successfully with flavor: $flavor",
          tag: _tag);
    } catch (e) {
      await BackgroundLogger.log("Failed to initialize Firebase: $e",
          tag: _tag);
      // Continue anyway, we'll try to work with what we have
    }
  }

  /// Setup dependencies needed for notifications
  static Future<void> setupNotificationDependencies(
      Map<String, dynamic> services) async {
    try {
      await BackgroundLogger.log("Setting up notification dependencies",
          tag: _tag);

      // Set up the bare minimum services needed for the notification task
      final prefs = await SharedPreferences.getInstance();
      services['sharedPreferences'] = prefs;

      // Auth for login state
      services['auth'] = FirebaseAuth.instance;

      // User repository for login service
      final userRepository = UserRepositoryImpl();
      services['userRepository'] = userRepository;

      // Login service for getting current user
      services['loginService'] = LoginServiceImpl(
        userRepository: userRepository,
      );

      // Food scan repository for streak calculation
      services['foodScanRepository'] = FoodScanRepository();

      // Food log history service for streak calculation
      services['foodLogHistoryService'] = FoodLogHistoryServiceImpl(
        foodScanRepository:
            services['foodScanRepository'] as FoodScanRepository,
      );

      // Flutter local notifications plugin
      services['flutterLocalNotificationsPlugin'] =
          FlutterLocalNotificationsPlugin();

      await BackgroundLogger.log("Notification dependencies setup complete",
          tag: _tag);
    } catch (e) {
      await BackgroundLogger.log(
          "Failed to setup notification dependencies: $e",
          tag: _tag);
    }
  }

  /// Setup dependencies needed for home screen widgets
  static Future<void> setupWidgetDependencies(
      Map<String, dynamic> services) async {
    try {
      await BackgroundLogger.log("Setting up widget dependencies", tag: _tag);

      // Widget services for home screen widgets
      services['simpleWidgetService'] = SimpleFoodTrackingWidgetService(
        widgetName: HomeWidgetConfig.simpleWidgetName.value,
        appGroupId: HomeWidgetConfig.appGroupId.value,
      );

      services['detailedWidgetService'] = DetailedFoodTrackingWidgetService(
        widgetName: HomeWidgetConfig.detailedWidgetName.value,
        appGroupId: HomeWidgetConfig.appGroupId.value,
      );

      // Setup strategy classes for calorie and nutrient calculations
      services['calorieCalculationStrategy'] =
          DefaultCalorieCalculationStrategy();
      services['nutrientCalculationStrategy'] =
          DefaultNutrientCalculationStrategy();

      // Try to get GetIt dependencies (may fail in background)
      try {
        services['caloricRequirementService'] = CaloricRequirementService();
        services['healthMetricsRepository'] = HealthMetricsRepositoryImpl();
        services['healthMetricsCheckService'] = HealthMetricsCheckService();
      } catch (e) {
        await BackgroundLogger.log("Failed to get some GetIt services: $e",
            tag: _tag);
      }

      await BackgroundLogger.log("Widget dependencies setup complete",
          tag: _tag);
    } catch (e) {
      await BackgroundLogger.log("Failed to setup widget dependencies: $e",
          tag: _tag);
    }
  }
}

// coverage:ignore-end
