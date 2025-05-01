// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Package imports:
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';
import 'package:pockeat/features/saved_meals/presentation/screens/saved_meal_detail_page.dart';
import 'package:pockeat/features/saved_meals/presentation/screens/saved_meals_page.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/config/production.dart';
import 'package:pockeat/config/staging.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/core/screens/splash_screen_page.dart';
import 'package:pockeat/core/screens/streak_celebration_page.dart';
import 'package:pockeat/core/service/background_service_manager.dart';
import 'package:pockeat/core/service/permission_service.dart';
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/api_scan/presentation/pages/ai_analysis_page.dart';
import 'package:pockeat/features/authentication/domain/model/deep_link_result.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/presentation/screens/account_activated_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/change_password_error_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/change_password_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/edit_profile_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/email_verification_failed_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/login_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/profile_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/register_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/reset_password_request_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/welcome_page.dart';
import 'package:pockeat/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/presentation/screens/cardio_input_page.dart';
import 'package:pockeat/features/exercise_input_options/presentation/screens/exercise_input_page.dart';
import 'package:pockeat/features/exercise_log_history/presentation/screens/exercise_history_page.dart';
import 'package:pockeat/features/exercise_log_history/presentation/screens/exercise_log_detail_page.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/food_log_history/presentation/screens/food_detail_page.dart';
import 'package:pockeat/features/food_log_history/presentation/screens/food_history_page.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_input_page.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_scan_page.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/features/food_text_input/presentation/screens/food_text_input_page.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/activity_level_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/add_calories_back_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/birthdate_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/desired_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/diet_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/gender_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/goal_obstacle_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/health_metrics_goals_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/heard_about_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/height_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/review_submit_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/rollover_calories_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/speed_selection_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/thank_you_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/used_other_apps_page.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';
import 'package:pockeat/features/homepage/presentation/screens/homepage.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/notifications/domain/services/user_activity_service.dart';
import 'package:pockeat/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:pockeat/features/progress_charts_and_graphs/di/progress_module.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/repositories/progress_tabs_repository_impl.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/screens/progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/progress_tabs_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/screens/smart_exercise_log_page.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/presentation/screens/weightlifting_page.dart';

// Core imports:

// Single global NavigatorKey untuk seluruh aplikasi
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Initialize Instabug with token from .env file
Future<bool> _initializeInstabug(String flavor) async {
  try {
    // Ambil token dari dotenv sesuai konfigurasi di GitHub workflow
    final token = dotenv.env['INSTABUG_TOKEN'];
    if (token == null || token.isEmpty) {
      return false;
    }

    // Tentukan level log berdasarkan environment dari dotenv
    final LogLevel logLevel =
        flavor.toLowerCase() == 'production' ? LogLevel.error : LogLevel.error;

    // Inisialisasi SDK dengan token dari dotenv
    await Instabug.init(
      token: token,
      invocationEvents: [],
      debugLogsLevel: logLevel,
    );

    return true;
  } catch (e) {
    return false;
  }
}

/// Handler untuk deep link results
void _handleDeepLink(DeepLinkResult result) {
  switch (result.type) {
    case DeepLinkType.emailVerification:
      if (result.success) {
        final email = result.data?['email'] ?? '';
        navigatorKey.currentState?.pushReplacementNamed(
          '/account-activated',
          arguments: {'email': email},
        );
      } else {
        final error = result.error ?? 'Email verification failed';
        navigatorKey.currentState?.pushReplacementNamed(
          '/email-verification-failed',
          arguments: {'error': error},
        );
      }
      break;

    case DeepLinkType.changePassword:
      if (result.success) {
        final oobCode = result.data?['oobCode'] ?? '';
        navigatorKey.currentState?.pushReplacementNamed(
          '/change-password',
          arguments: {'oobCode': oobCode},
        );
      } else {
        final error = result.error ?? 'Password reset failed';
        navigatorKey.currentState?.pushReplacementNamed(
          '/change-password-error',
          arguments: {'error': error},
        );
      }
      break;

    case DeepLinkType.quickLog:
      // Deep link untuk 'Log Food' dari widget
      if (result.success) {
        final widgetName = result.data?['widgetName'] ?? '';
        // Arahkan ke halaman input makanan
        navigatorKey.currentState?.pushNamed(
          '/add-food',
        );
        debugPrint('Navigated to food input from widget: $widgetName');
      }
      break;

    case DeepLinkType.login:
      // Deep link untuk 'Login' dari widget
      if (result.success) {
        final widgetName = result.data?['widgetName'] ?? '';
        // Arahkan ke halaman login
        navigatorKey.currentState?.pushNamed(
          '/login',
        );
        debugPrint('Navigated to login from widget: $widgetName');
      }
      break;

    case DeepLinkType.dashboard:
      // Deep link untuk home dari klik area utama widget
      if (result.success) {
        final widgetName = result.data?['widgetName'] ?? '';
        // Arahkan ke halaman home
        navigatorKey.currentState?.pushReplacementNamed(
          '/',
        );
        debugPrint('Navigated to home from widget: $widgetName');
      }
      break;

    case DeepLinkType.streakCelebration:
      // Deep link untuk streak celebration notification
      if (result.success) {
        final streakDays = result.data?['streakDays'] ?? 0;
        // Navigate to streak page or show streak celebration
        debugPrint(
            'Streak celebration link handled with streak days: $streakDays');

        // Navigate to home screen to show the streak dialog
        navigatorKey.currentState?.pushReplacementNamed(
          '/streak-celebration',
          arguments: {'showStreakCelebration': true, 'streakDays': streakDays},
        );
      }
      break;

    default:
      debugPrint('Unknown deep link type: ${result.type}');
      break;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final flavor = dotenv.env['FLAVOR'] ?? 'dev';

  // Inisialisasi required services
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // Initialize Instabug
  await _initializeInstabug(flavor);

  await Firebase.initializeApp(
    options: flavor == 'production'
        ? ProductionFirebaseOptions.currentPlatform
        : flavor == 'staging'
            ? StagingFirebaseOptions.currentPlatform
            : StagingFirebaseOptions.currentPlatform,
  );

  await setupDependencies();
  ProgressModule.register(); // <-- Add this line

  // Initialize Google Analytics
  await getIt<AnalyticsService>().initialize();

  // Initialize permissions and notifications
  if (!kIsWeb) {
    // Daftarkan PermissionService ke GetIt
    final permissionService = PermissionService();
    getIt.registerSingleton(permissionService);

    // Minta semua permission terlebih dahulu
    await permissionService.requestAllPermissions();

    // Setelah permission diperoleh, inisialisasi service lainnya
    await BackgroundServiceManager.initialize();
    await getIt<FoodTrackingClientController>().initialize();
    await getIt<NotificationService>().initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        Provider<ExerciseLogHistoryService>(
          create: (_) => getIt<ExerciseLogHistoryService>(),
        ),
        Provider<SmartExerciseLogRepository>(
          create: (_) => getIt<SmartExerciseLogRepository>(),
        ),
        Provider<CardioRepository>(
          create: (_) => getIt<CardioRepository>(),
        ),
        Provider<WeightLiftingRepository>(
          create: (_) => getIt<WeightLiftingRepository>(),
        ),
        Provider<FoodLogHistoryService>(
          create: (_) => getIt<FoodLogHistoryService>(),
        ),
        Provider<FoodScanRepository>(
          create: (_) => getIt<FoodScanRepository>(),
        ),
        Provider<FoodTextInputRepository>(
          create: (_) => getIt<FoodTextInputRepository>(),
        ),
        Provider<SavedMealService>(
          create: (_) => getIt<SavedMealService>(),
        ),
        Provider<CaloricRequirementService>(
            create: (_) => getIt<CaloricRequirementService>()),
        BlocProvider<HealthMetricsFormCubit>(
          create: (_) => HealthMetricsFormCubit(
            repository: getIt<HealthMetricsRepository>(),
            caloricRequirementRepository: getIt<CaloricRequirementRepository>(),
            caloricRequirementService: getIt<CaloricRequirementService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inisialisasi DeepLinkService di _MyAppState
    _initializeDeepLinkService();

    // Cek notifikasi di initState untuk menangani cold start dari notifikasi
    _checkNotificationLaunch();

    // Track app open saat aplikasi pertama kali dibuka
    _trackAppOpen();
  }

  // Track app open menggunakan UserActivityService
  Future<void> _trackAppOpen() async {
    try {
      final userActivityService = getIt<UserActivityService>();
      await userActivityService.trackAppOpen();
      debugPrint('Tracked app open at startup');
    } catch (e) {
      debugPrint('Error tracking app open: $e');
    }
  }

  Future<void> _initializeDeepLinkService() async {
    try {
      // Inisialisasi DeepLinkService
      final deepLinkService = getIt<DeepLinkService>();
      final coldStartResult = await deepLinkService.getColdStartResult();

      // Langsung handle deep link tanpa penundaan
      if (coldStartResult != null) {
        _handleDeepLink(coldStartResult);
      }

      await deepLinkService.initialize();

      // Setup listener untuk deep link events
      _deepLinkSubscription =
          getIt<DeepLinkService>().onDeepLinkResult.listen((result) {
        // Langsung handle deep link tanpa penundaan
        _handleDeepLink(result);
      });
    } catch (e) {
      debugPrint('Error initializing deep link service: $e');
    }
  }

  /// Cek apakah aplikasi dibuka dari notifikasi dan navigasi ke halaman yang sesuai
  Future<void> _checkNotificationLaunch() async {
    try {
      // Periksa apakah aplikasi dibuka dari notifikasi
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await getIt<FlutterLocalNotificationsPlugin>()
              .getNotificationAppLaunchDetails();

      // Jika aplikasi dibuka dari notifikasi, handle sesuai payload
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        final payload =
            notificationAppLaunchDetails!.notificationResponse?.payload;
        debugPrint('App launched from notification with payload: $payload');

        if (payload == NotificationConstants.dailyStreakPayload) {
          // Untuk streak notification, navigate dengan deeplink
          try {
            final loginService = getIt<LoginService>();
            final foodLogHistoryService = getIt<FoodLogHistoryService>();
            final userId = (await loginService.getCurrentUser())?.uid;

            // Default streak adalah 0 jika user belum login
            int streakDays = 0;

            if (userId != null) {
              // Jika user sudah login, hitung streak aktual
              streakDays =
                  await foodLogHistoryService.getFoodStreakDays(userId);
              debugPrint('Loaded streak days for notification: $streakDays');
            }

            // Navigasi langsung ke streak celebration page menggunakan navigatorKey
            navigatorKey.currentState?.pushNamed('/streak-celebration',
                arguments: {
                  'showStreakCelebration': true,
                  'streakDays': streakDays
                });
          } catch (e) {
            debugPrint('Error handling streak notification: $e');
          }
        }
        // Handle pet sadness notification (cold start via notification)
        else if (payload == NotificationConstants.petSadnessPayload) {
          debugPrint('App launched from pet sadness notification');

          try {
            // Track app open untuk reset inactiveDuration
            await _trackAppOpen();

            // Langsung navigasi ke halaman utama/dashboard menggunakan navigatorKey
            navigatorKey.currentState?.pushReplacementNamed('/');
            debugPrint('Navigated to dashboard from pet sadness notification');
          } catch (e) {
            debugPrint('Error handling pet sadness notification: $e');
          }
        }
        // Handle pet status notification (cold start via notification)
        else if (payload == NotificationConstants.petStatusPayload) {
          debugPrint('App launched from pet status notification');

          try {
            // Track app open
            await _trackAppOpen();

            // Navigate to the main dashboard screen
            navigatorKey.currentState?.pushReplacementNamed('/');
            debugPrint('Navigated to dashboard from pet status notification');
          } catch (e) {
            debugPrint('Error handling pet status notification: $e');
          }
        } else if (payload == NotificationConstants.mealReminderPayload) {
          // Untuk meal notification, navigate dengan deeplink
          try {
            navigatorKey.currentState?.pushNamed(
              '/add-food',
              arguments: {'type': 'log'},
            );
          } catch (e) {
            debugPrint('Error handling meal notification: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking notification launch: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Track when app is resumed from background
      _trackAppOpen();
      debugPrint('App resumed from background, tracked activity');
    }
  }

  @override
  Widget build(BuildContext context) {
    final smartExerciseLogRepository =
        Provider.of<SmartExerciseLogRepository>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Pockeat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Konfigurasi rute awal berdasarkan kondisi
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreenPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/': (context) => const AuthWrapper(
              redirectUrlIfNotLoggedIn: '/welcome',
              child: HomePage(),
            ),
        '/welcome': (context) => const WelcomePage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/streak-celebration': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return StreakCelebrationPage(
            streak: args?['streakDays'] as int? ?? 0,
          );
        },
        '/profile': (context) => const AuthWrapper(child: ProfilePage()),
        '/change-password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return AuthWrapper(
            requireAuth: args?['oobCode'] != null ? false : true,
            child: ChangePasswordPage(
              oobCode: args?['oobCode'] as String?,
            ),
          );
        },
        '/change-password-error': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return ChangePasswordErrorPage(
            error: args?['error'] as String? ??
                'Password reset failed. Please try again.',
          );
        },
        '/account-activated': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return AccountActivatedPage(
            email: args?['email'] as String? ?? '',
          );
        },
        '/email-verification-failed': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return EmailVerificationFailedPage(
            error: args?['error'] as String? ??
                'Verification failed. Please try again.',
          );
        },
        '/onboarding/goal': (context) {
          return BlocProvider.value(
            value: context.read<HealthMetricsFormCubit>(),
            child: const HealthMetricsGoalsPage(),
          );
        },
        '/height-weight': (context) => const HeightWeightPage(),
        '/birthdate': (context) => const BirthdatePage(),
        '/gender': (context) => const GenderPage(),
        '/activity-level': (context) => const ActivityLevelPage(),
        '/diet': (context) => const DietPage(),
        '/desired-weight': (context) => const DesiredWeightPage(),
        '/speed': (context) => const SpeedSelectionPage(),
        '/goal-obstacle': (context) => const GoalObstaclePage(),
        '/add-calories-back': (context) => const AddCaloriesBackPage(),
        '/heard-about': (context) => const HeardAboutPage(),
        '/rollover-calories': (context) => const RolloverCaloriesPage(),
        '/thank-you': (context) => const ThankYouPage(),
        '/used-other-apps': (context) => const UsedOtherAppsPage(),
        '/review': (context) => BlocProvider.value(
         value: context.read<HealthMetricsFormCubit>(),
          child: const ReviewSubmitPage(),
        ),
        '/smart-exercise-log': (context) => AuthWrapper(
            child:
                SmartExerciseLogPage(repository: smartExerciseLogRepository)),
        '/scan': (context) => FutureBuilder<List<CameraDescription>>(
              future: availableCameras(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.data?.isEmpty ?? true) {
                    return const Center(
                      child: Text('Tidak ada kamera yang tersedia'),
                    );
                  }

                  return AuthWrapper(
                    child: ScanFoodPage(
                      cameraController: CameraController(
                        snapshot
                            .data![0], // Menggunakan kamera pertama (belakang)
                        ResolutionPreset.max,
                        enableAudio: false,
                        imageFormatGroup: ImageFormatGroup.jpeg,
                      ),
                    ),
                  );
                }

                // Tampilkan loading selama menunggu kamera
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              },
            ),
        '/add-food': (context) => const AuthWrapper(child: FoodInputPage()),
        '/food-text-input': (context) =>
            const AuthWrapper(child: FoodTextInputPage()),
        '/food-analysis': (context) =>
            const AuthWrapper(child: AIAnalysisScreen()),
        '/add-exercise': (context) =>
            const AuthWrapper(child: ExerciseInputPage()),
        '/weightlifting-input': (context) =>
            const AuthWrapper(child: WeightliftingPage()),
        '/cardio': (context) => const AuthWrapper(child: CardioInputPage()),
        '/exercise-history': (context) =>
            const AuthWrapper(child: ExerciseHistoryPage()),
        '/food-history': (context) => AuthWrapper(
              child: FoodHistoryPage(
                service: Provider.of<FoodLogHistoryService>(context),
              ),
            ),
        '/exercise-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return AuthWrapper(
            child: ExerciseLogDetailPage(
              exerciseId: args['exerciseId'] as String,
              activityType: args['activityType'] as String,
            ),
          );
        },
        '/food-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return AuthWrapper(
            child: FoodDetailPage(
              foodId: args['foodId'] as String,
              foodTrackingController: getIt<FoodTrackingClientController>(),
              foodRepository:
                  Provider.of<FoodScanRepository>(context, listen: false),
              foodTextInputRepository:
                  Provider.of<FoodTextInputRepository>(context, listen: false),
            ),
          );
        },
        '/analytic': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return ProgressPage(
            service: ProgressTabsService(ProgressTabsRepositoryImpl()),
            initialTabIndex: args?['initialTabIndex'] as int? ?? 0,
          );
        },
        '/notification-settings': (context) =>
            const AuthWrapper(child: NotificationSettingsScreen()),
        '/edit-profile': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as UserModel?;
          return AuthWrapper(
            child: EditProfilePage(initialUser: user),
          );
        },
        '/saved-meals': (context) => AuthWrapper(
              child: SavedMealsPage(
                savedMealService: getIt<SavedMealService>(),
              ),
            ),
        '/saved-meal-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return AuthWrapper(
            child: SavedMealDetailPage(
              savedMealId: args['savedMealId'] as String,
              savedMealService: getIt<SavedMealService>(),
            ),
          );
        },
      },
    );
  }
}
