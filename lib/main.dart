import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pockeat/config/production.dart';
import 'package:pockeat/config/staging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'dart:async';
import 'package:pockeat/core/screens/splash_screen_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/reset_password_request_page.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
import 'package:pockeat/features/exercise_input_options/presentation/screens/exercise_input_page.dart';
import 'package:pockeat/features/homepage/presentation/screens/homepage.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/screens/smart_exercise_log_page.dart';
import 'package:camera/camera.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_scan_page.dart';
import 'package:provider/provider.dart';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_input_page.dart';
import 'package:pockeat/features/api_scan/presentation/pages/ai_analysis_page.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/cardio_log/presentation/screens/cardio_input_page.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/presentation/screens/exercise_history_page.dart';
import 'package:pockeat/features/exercise_log_history/presentation/screens/exercise_log_detail_page.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/presentation/screens/weightlifting_page.dart';
import 'package:pockeat/features/food_log_history/presentation/screens/food_history_page.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/presentation/screens/food_detail_page.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/features/food_text_input/presentation/screens/food_text_input_page.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/health_metrics_goals_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/height_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/birthdate_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/diet_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/desired_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/speed_selection_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/review_submit_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/gender_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/activity_level_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pockeat/features/authentication/presentation/screens/register_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/login_page.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/presentation/screens/account_activated_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/email_verification_failed_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/change_password_error_page.dart';
import 'package:pockeat/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:pockeat/features/authentication/presentation/screens/welcome_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/screens/progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/repositories/progress_tabs_repository_impl.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/progress_tabs_service.dart';
import 'package:pockeat/features/authentication/presentation/screens/change_password_page.dart';
import 'package:pockeat/features/authentication/domain/model/deep_link_result.dart';
import 'package:pockeat/features/authentication/presentation/screens/profile_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/edit_profile_page.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

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

    default:
      debugPrint('Unknown deep link type: ${result.type}');
      break;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final flavor = dotenv.env['FLAVOR'] ?? 'dev';

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

  // Initialize notifications
  if (!kIsWeb) {
    await getIt<FoodTrackingClientController>().initialize();
    await getIt<NotificationService>().initialize();
  }

  // Setup emulator kalau di dev mode
  if (flavor == 'dev') {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkSubscription?.cancel();
    super.dispose();
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
          child: HomePage(),
          redirectUrlIfNotLoggedIn: '/welcome',
        ),
        '/welcome': (context) {
            return const AuthWrapper(
              requireAuth: false,
              redirectUrlIfLoggedIn: '/',
              child: WelcomePage(),
            );
          }
          ,
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
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
        '/height-weight': (context) =>
            const AuthWrapper(child: HeightWeightPage()),
        '/birthdate': (context) => const AuthWrapper(child: BirthdatePage()),
        '/gender': (context) => const AuthWrapper(child: GenderPage()),
        '/activity-level': (context) =>
            const AuthWrapper(child: ActivityLevelPage()),
        '/diet': (context) => const AuthWrapper(child: DietPage()),
        '/desired-weight': (context) =>
            const AuthWrapper(child: DesiredWeightPage()),
        '/speed': (context) => const AuthWrapper(child: SpeedSelectionPage()),
        '/review': (context) => const AuthWrapper(child: ReviewSubmitPage()),
        '/smart-exercise-log': (context) => AuthWrapper(
            child:
                SmartExerciseLogPage(repository: smartExerciseLogRepository)),
        '/scan': (context) => AuthWrapper(
              child: ScanFoodPage(
                cameraController: CameraController(
                  CameraDescription(
                    name: '0',
                    lensDirection: CameraLensDirection.back,
                    sensorOrientation: 0,
                  ),
                  ResolutionPreset.max,
                ),
              ),
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
        '/analytic': (context) => ProgressPage(
              service: ProgressTabsService(ProgressTabsRepositoryImpl()),
            ),
        '/notification-settings': (context) =>
            const AuthWrapper(child: NotificationSettingsScreen()),
        '/edit-profile': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as UserModel?;
          return AuthWrapper(
            child: EditProfilePage(initialUser: user),
          );
        },
      },
    );
  }
}
