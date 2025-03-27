// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pockeat/features/ai_api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart';
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
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service_impl.dart';
import 'package:pockeat/features/authentication/services/change_password_service.dart';
import 'package:pockeat/features/authentication/services/change_password_service_impl.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service_impl.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';

final getIt = GetIt.instance;
// coverage:ignore-start
void setupDependencies() {
  // Register specialized services
  getIt.registerSingleton<FoodTextAnalysisService>(
    FoodTextAnalysisService.fromEnv(),
  );

  getIt.registerSingleton<FoodImageAnalysisService>(
    FoodImageAnalysisService.fromEnv(),
  );

  getIt.registerSingleton<NutritionLabelAnalysisService>(
    NutritionLabelAnalysisService.fromEnv(),
  );

  getIt.registerSingleton<ExerciseAnalysisService>(
    ExerciseAnalysisService.fromEnv(),
  );

  getIt.registerSingleton<FoodTextInputRepository>(
    FoodTextInputRepository(),
  );

  getIt.registerSingleton<FoodTextInputService>(
    FoodTextInputService(
      getIt<FoodTextAnalysisService>(), // Will fail if not registered first!
      getIt<FoodTextInputRepository>(),
    ),
  );

  getIt.registerSingleton<FoodScanRepository>(
    FoodScanRepository(),
  );

  getIt.registerSingleton<FoodScanPhotoService>(
    FoodScanPhotoService(),
  );

  // Register UserRepository
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(),
  );

  // Register RegisterService
  getIt.registerSingleton<RegisterService>(
    RegisterServiceImpl(userRepository: getIt<UserRepository>()),
  );

  // Register LoginService
  getIt.registerSingleton<LoginService>(
    LoginServiceImpl(userRepository: getIt<UserRepository>()),
  );

  // Register GoogleSignInService
  getIt.registerSingleton<GoogleSignInService>(
    GoogleSignInServiceImpl(),
  );

  // Register ChangePasswordService
  getIt.registerSingleton<ChangePasswordService>(
    ChangePasswordServiceImpl(),
  );

  // Register Email Verification DeepLink Service
  getIt.registerSingleton<EmailVerificationDeepLinkService>(
    EmailVerificationDeepLinkServiceImpl(
        userRepository: getIt<UserRepository>()),
  );

  // Register Change Password DeepLink Service
  getIt.registerSingleton<ChangePasswordDeepLinkService>(
    ChangePasswordDeepLinkServiceImpl(),
  );

  // Register DeepLink Facade Service
  getIt.registerSingleton<DeepLinkService>(
    DeepLinkServiceImpl(
      emailVerificationService: getIt<EmailVerificationDeepLinkService>(),
      changePasswordService: getIt<ChangePasswordDeepLinkService>(),
    ),
  );

  // Register Food Log History module
  FoodLogHistoryModule.register();

  // Register Exercise Log History module
  ExerciseLogHistoryModule.register();

  getIt.registerSingleton<FirebaseMessaging>(
    FirebaseMessaging.instance,
  );

  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin(),
  );
}
 // coverage:ignore-end