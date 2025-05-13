// lib/core/di/service_locator.dart

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:pockeat/features/authentication/services/bug_report_service.dart';
import 'package:pockeat/features/authentication/services/bug_report_service_impl.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service_impl.dart';
import 'package:pockeat/features/authentication/services/change_password_service.dart';
import 'package:pockeat/features/authentication/services/change_password_service_impl.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/services/email_verification_deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service_impl.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/authentication/services/login_service_impl.dart';
import 'package:pockeat/features/authentication/services/logout_service.dart';
import 'package:pockeat/features/authentication/services/logout_service_impl.dart';
import 'package:pockeat/features/authentication/services/profile_service.dart';
import 'package:pockeat/features/authentication/services/profile_service_impl.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';
import 'package:pockeat/features/authentication/services/register_service_impl.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';
import 'package:pockeat/features/authentication/services/utils/instabug_client.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository_impl.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/calorie_stats/di/calorie_stats_module.dart';
import 'package:pockeat/features/exercise_log_history/di/exercise_log_history_module.dart';
import 'package:pockeat/features/food_database_input/services/food_database_module.dart';
import 'package:pockeat/features/food_log_history/di/food_log_history_module.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository_impl.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';
import 'package:pockeat/features/home_screen_widget/di/home_widget_module.dart';
import 'package:pockeat/features/notifications/domain/services/impl/notification_service_impl.dart';
import 'package:pockeat/features/notifications/domain/services/impl/user_activity_service_impl.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/notifications/domain/services/user_activity_service.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service_impl.dart';
import 'package:pockeat/features/saved_meals/domain/repositories/saved_meals_repository.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

final getIt = GetIt.instance;
// coverage:ignore-start
Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Register Firebase instances first
  getIt.registerSingleton<FirebaseAuth>(
    FirebaseAuth.instance,
  );

  getIt.registerSingleton<FirebaseFirestore>(
    FirebaseFirestore.instance,
  );

  getIt.registerSingleton<FirebaseMessaging>(
    FirebaseMessaging.instance,
  );

  // Register TokenManager before any services that need it
  getIt.registerSingleton<TokenManager>(TokenManager());

  // Register repositories before services that depend on them
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(),
  );

  getIt.registerSingleton<FoodTextInputRepository>(
    FoodTextInputRepository(),
  );

  getIt.registerSingleton<FoodScanRepository>(
    FoodScanRepository(),
  );

  getIt.registerSingleton<HealthMetricsRepository>(
    HealthMetricsRepositoryImpl(),
  );

  // Register API Services that depend on TokenManager
  getIt.registerSingleton<FoodTextAnalysisService>(
    FoodTextAnalysisService.fromEnv(tokenManager: getIt<TokenManager>()),
  );

  getIt.registerSingleton<FoodImageAnalysisService>(
    FoodImageAnalysisService.fromEnv(tokenManager: getIt<TokenManager>()),
  );

  getIt.registerSingleton<NutritionLabelAnalysisService>(
    NutritionLabelAnalysisService.fromEnv(tokenManager: getIt<TokenManager>()),
  );

  getIt.registerSingleton<ExerciseAnalysisService>(
    ExerciseAnalysisService.fromEnv(tokenManager: getIt<TokenManager>()),
  );

  // Register authentication related services
  getIt.registerSingleton<RegisterService>(
    RegisterServiceImpl(userRepository: getIt<UserRepository>()),
  );

  getIt.registerSingleton<LoginService>(
    LoginServiceImpl(userRepository: getIt<UserRepository>()),
  );

  getIt.registerSingleton<GoogleSignInService>(
    GoogleSignInServiceImpl(),
  );

  getIt.registerSingleton<ChangePasswordService>(
    ChangePasswordServiceImpl(),
  );

  // Register DeepLink Services
  getIt.registerSingleton<EmailVerificationDeepLinkService>(
    EmailVerificationDeepLinkServiceImpl(
        userRepository: getIt<UserRepository>()),
  );

  getIt.registerSingleton<ChangePasswordDeepLinkService>(
    ChangePasswordDeepLinkServiceImpl(),
  );

  getIt.registerSingleton<DeepLinkService>(
    DeepLinkServiceImpl(
      emailVerificationService: getIt<EmailVerificationDeepLinkService>(),
      changePasswordService: getIt<ChangePasswordDeepLinkService>(),
    ),
  );

  // Register Food and Exercise services
  getIt.registerSingleton<FoodTextInputService>(
    FoodTextInputService(
      getIt<FoodTextAnalysisService>(),
      getIt<FoodTextInputRepository>(),
    ),
  );

  getIt.registerSingleton<FoodScanPhotoService>(
    FoodScanPhotoService(),
  );

  getIt.registerSingleton<HealthMetricsCheckService>(
    HealthMetricsCheckService(),
  );

  getIt.registerSingleton<CaloricRequirementRepository>(
    CaloricRequirementRepositoryImpl(),
  );

  getIt.registerSingleton<CaloricRequirementService>(
    CaloricRequirementService(),
  );

  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin(),
  );

  // Register UserActivityService to track app usage (must be before NotificationService)
  getIt.registerSingleton<UserActivityService>(
    UserActivityServiceImpl(),
  );

  // Register feature modules first (before services that depend on them)
  FoodLogHistoryModule.register();
  ExerciseLogHistoryModule.register();
  CalorieStatsModule.register();

  // Now register NotificationService which depends on FoodLogHistoryService and UserActivityService
  getIt.registerSingleton<NotificationService>(
    NotificationServiceImpl(),
  );

  // Register Supabase nutrition database module
  NutritionDatabaseModule.register();

  // Register SavedMealsRepository before SavedMealService
  getIt.registerSingleton<SavedMealsRepository>(
    SavedMealsRepository(),
  );

  getIt.registerSingleton<SavedMealService>(
    SavedMealService(
      repository: getIt<SavedMealsRepository>(),
      textAnalysisService: getIt<FoodTextAnalysisService>(),
    ),
  );

  // Register UserPreferencesService
  getIt.registerSingleton<UserPreferencesService>(
    UserPreferencesService(),
  );

  // Register additional services
  getIt.registerSingleton<LogoutService>(
    LogoutServiceImpl(),
  );

  getIt.registerSingleton<ProfileService>(
    ProfileServiceImpl(),
  );

  // Register InstabugClient and BugReportService
  getIt.registerSingleton<InstabugClient>(
    InstabugClient(),
  );

  getIt.registerSingleton<BugReportService>(
    BugReportServiceImpl(instabugClient: getIt<InstabugClient>()),
  );

  // Register Analytics Service
  getIt.registerSingleton<AnalyticsService>(
    AnalyticsService(),
  );

  getIt.registerSingleton<PetService>(
    PetServiceImpl(),
  );

  HomeWidgetModule.register();
}
// coverage:ignore-end
