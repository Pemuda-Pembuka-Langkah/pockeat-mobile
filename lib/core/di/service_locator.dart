// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pockeat/features/api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';
import 'package:pockeat/features/calorie_stats/di/calorie_stats_module.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/features/food_log_history/di/food_log_history_module.dart';
import 'package:pockeat/features/exercise_log_history/di/exercise_log_history_module.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';
import 'package:pockeat/features/authentication/services/register_service_impl.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/email_verification_deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/authentication/services/login_service_impl.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service_impl.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service_impl.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository_impl.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/services/change_password_service.dart';
import 'package:pockeat/features/authentication/services/change_password_service_impl.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service_impl.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/di/nutrition_module.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/di/exercise_progress_module.dart';
import 'package:pockeat/features/authentication/services/logout_service.dart';
import 'package:pockeat/features/authentication/services/logout_service_impl.dart';
import 'package:pockeat/features/authentication/services/profile_service.dart';
import 'package:pockeat/features/authentication/services/profile_service_impl.dart';

final getIt = GetIt.instance;
// coverage:ignore-start
Future<void> setupDependencies() async {
  // Register Firebase instances first
  getIt.registerSingleton<FirebaseAuth>(
    FirebaseAuth.instance,
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

  // Register Notification services
  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin(),
  );

  getIt.registerSingleton<NotificationService>(
    NotificationServiceImpl(),
  );
  
  // Initialize notifications
  await getIt<NotificationService>().initialize();

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  // Register feature modules
  // Make sure to register these modules after all their dependencies
  FoodLogHistoryModule.register();
  ExerciseLogHistoryModule.register();
  CalorieStatsModule.register();
  NutritionModule.register();
  ExerciseProgressModule.register();

  // Register additional services
  getIt.registerSingleton<LogoutService>(
    LogoutServiceImpl(),
  );

  getIt.registerSingleton<ProfileService>(
    ProfileServiceImpl(),
  );
}
// coverage:ignore-end