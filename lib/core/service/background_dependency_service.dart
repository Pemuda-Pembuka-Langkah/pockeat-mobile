// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/config/production.dart';
import 'package:pockeat/config/staging.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:pockeat/features/authentication/services/login_service_impl.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository_impl.dart';
import 'package:pockeat/features/calorie_stats/domain/repositories/calorie_stats_repository.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository_impl.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service_impl.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_config.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/detailed_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/simple_food_tracking_widget_service.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository_impl.dart';
import 'package:pockeat/features/sync_fitness_tracker/services/third_party_tracker_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository_impl.dart';

// coverage:ignore-start
/// Service for setting up dependencies needed by background tasks
class BackgroundDependencyService {
  /// Setup all required dependencies for background tasks
  static Future<Map<String, dynamic>> setupDependencies() async {
    final services = <String, dynamic>{};
    // Initialize environment and Firebase
    await _setupEnvironment(services);

    // Setup notification dependencies
    await setupNotificationDependencies(services);

    // Setup widget dependencies
    await setupWidgetDependencies(services);

    return services;
  }

  /// Setup environment variables and Firebase
  static Future<void> _setupEnvironment(Map<String, dynamic> services) async {
    // Load environment variables
    String flavor = 'staging';
    try {
      await dotenv.load();
      flavor = dotenv.env['FLAVOR'] ?? 'staging';
    } catch (dotenvError) {
      debugPrint('Could not load .env: $dotenvError, using default flavor');
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
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      // Continue anyway, we'll try to work with what we have
    }
  }

  /// Setup dependencies needed for notifications
  static Future<void> setupNotificationDependencies(
      Map<String, dynamic> services) async {
    try {
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
      final foodLogHistoryService = FoodLogHistoryServiceImpl(
        foodScanRepository:
            services['foodScanRepository'] as FoodScanRepository,
      );
      services['foodLogHistoryService'] = foodLogHistoryService;
      GetIt.instance
          .registerSingleton<FoodLogHistoryService>(foodLogHistoryService);

      // Get Firestore instance for repositories
      final firestore = FirebaseFirestore.instance;
      services['firestore'] = firestore;

      final userPreferencesService = UserPreferencesService(
        auth: services['auth'] as FirebaseAuth,
        firestore: services['firestore'] as FirebaseFirestore,
      );
      services['userPreferencesService'] = userPreferencesService;

      // Register UserPreferencesService in GetIt for rollover calories and calorie compensation
      GetIt.instance
          .registerSingleton<UserPreferencesService>(userPreferencesService);

      // Register repositories needed by ExerciseLogHistoryService
      final smartExerciseLogRepository =
          SmartExerciseLogRepositoryImpl(firestore: firestore);
      services['smartExerciseLogRepository'] = smartExerciseLogRepository;
      GetIt.instance.registerSingleton<SmartExerciseLogRepository>(
          smartExerciseLogRepository);

      final cardioRepository = CardioRepositoryImpl(firestore: firestore);
      services['cardioRepository'] = cardioRepository;
      GetIt.instance.registerSingleton<CardioRepository>(cardioRepository);

      final weightLiftingRepository =
          WeightLiftingRepositoryImpl(firestore: firestore);
      services['weightLiftingRepository'] = weightLiftingRepository;
      GetIt.instance
          .registerSingleton<WeightLiftingRepository>(weightLiftingRepository);

      // Create exercise log service required for CalorieStatsService
      final exerciseService = ExerciseLogHistoryServiceImpl();
      services['exerciseLogHistoryService'] = exerciseService;
      GetIt.instance
          .registerSingleton<ExerciseLogHistoryService>(exerciseService);

      // Create CalorieStatsRepository
      final calorieStatsRepository = CalorieStatsRepositoryImpl();
      services['calorieStatsRepository'] =
          calorieStatsRepository; // Register ThirdPartyTrackerService
      final thirdPartyTrackerService = ThirdPartyTrackerService();
      services['thirdPartyTrackerService'] = thirdPartyTrackerService;
      GetIt.instance.registerSingleton<ThirdPartyTrackerService>(
          thirdPartyTrackerService);

      // Create CalorieStatsService required for PetService
      final calorieStatsService = CalorieStatsServiceImpl(
          repository: calorieStatsRepository,
          exerciseService: exerciseService,
          foodService: foodLogHistoryService,
          trackerService: thirdPartyTrackerService);
      services['calorieStatsService'] = calorieStatsService;
      GetIt.instance
          .registerSingleton<CalorieStatsService>(calorieStatsService);
      GetIt.instance.registerSingleton<FirebaseFirestore>(firestore);

      // Now we can create the real PetService since all dependencies are registered
      services['petService'] = PetServiceImpl();

      // Flutter local notifications plugin
      services['flutterLocalNotificationsPlugin'] =
          FlutterLocalNotificationsPlugin();
    } catch (e) {
      debugPrint('Failed to setup notification dependencies: $e');
    }
  }

  /// Setup dependencies needed for home screen widgets
  static Future<void> setupWidgetDependencies(
      Map<String, dynamic> services) async {
    try {
      // Widget services for home screen widgets
      services['simpleWidgetService'] = SimpleFoodTrackingWidgetService(
        widgetName: HomeWidgetConfig.simpleWidgetName.value,
        appGroupId: HomeWidgetConfig.appGroupId.value,
      );
      services['detailedWidgetService'] = DetailedFoodTrackingWidgetService(
        widgetName: HomeWidgetConfig.detailedWidgetName.value,
        appGroupId: HomeWidgetConfig.appGroupId.value,
      );
      services['nutrientCalculationStrategy'] =
          DefaultNutrientCalculationStrategy();
      services['caloricRequirementRepository'] =
          CaloricRequirementRepositoryImpl();

      services['caloricStatsRepository'] = CalorieStatsRepositoryImpl();
      // Create CalorieStatsService and register in GetIt
      final calorieStatsService = CalorieStatsServiceImpl(
          repository:
              services['caloricStatsRepository'] as CalorieStatsRepositoryImpl,
          exerciseService: services['exerciseLogHistoryService']
              as ExerciseLogHistoryService,
          foodService:
              services['foodLogHistoryService'] as FoodLogHistoryService,
          trackerService:
              services['thirdPartyTrackerService'] as ThirdPartyTrackerService);
      services['caloricStatsService'] = calorieStatsService;

      // If not registered yet, register with GetIt
      if (!GetIt.instance.isRegistered<CalorieStatsService>()) {
        GetIt.instance
            .registerSingleton<CalorieStatsService>(calorieStatsService);
      }
    } catch (e) {
      final errorMsg = 'Failed to setup widget dependencies: $e';
      debugPrint(errorMsg);
    }
  }
}

// coverage:ignore-end
