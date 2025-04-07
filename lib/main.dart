import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pockeat/config/production.dart';
import 'package:pockeat/config/staging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockeat/core/screens/splash_screen_page.dart';
import 'package:pockeat/features/exercise_input_options/presentation/screens/exercise_input_page.dart';
import 'package:pockeat/features/homepage/presentation/screens/homepage.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/screens/smart_exercise_log_page.dart';
import 'package:camera/camera.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_scan_page.dart';
import 'package:provider/provider.dart';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_input_page.dart';
import 'package:pockeat/features/ai_api_scan/presentation/pages/ai_analysis_page.dart';
import 'package:pockeat/core/di/service_locator.dart';
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
import 'package:pockeat/features/notifications/domain/services/notification_initializer.dart';
import 'package:pockeat/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pockeat/features/authentication/presentation/screens/register_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/login_page.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/presentation/screens/account_activated_page.dart';
import 'package:pockeat/features/authentication/presentation/screens/email_verification_failed_page.dart';
import 'package:pockeat/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository_impl.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/health_metrics_goals_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/height_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/birthdate_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/diet_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/desired_weight_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/speed_selection_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/review_submit_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final flavor = dotenv.env['FLAVOR'] ?? 'dev';

  await Firebase.initializeApp(
    options: flavor == 'production'
        ? ProductionFirebaseOptions.currentPlatform
        : flavor == 'staging'
            ? StagingFirebaseOptions.currentPlatform
            : StagingFirebaseOptions.currentPlatform,
  );

  setupDependencies();

  if (!kIsWeb) {
    await NotificationInitializer().initialize();
  }

  if (flavor == 'dev') {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  await getIt<DeepLinkService>().initialize(navigatorKey: navigatorKey);

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
          create: (_) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              throw Exception('User must be logged in');
            }
            return HealthMetricsFormCubit(
              userId: user.uid,
              repository: getIt<HealthMetricsRepository>(),
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreenPage(),
        '/': (context) => const AuthWrapper(child: HomePage()),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/account-activated': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return AccountActivatedPage(email: args?['email'] as String? ?? '');
        },
        '/email-verification-failed': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return EmailVerificationFailedPage(
            error: args?['error'] as String? ?? 'Verification failed. Please try again.',
          );
        },
        '/onboarding/goal': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return const LoginPage();
          final cubit = BlocProvider.of<HealthMetricsFormCubit>(context);
          return AuthWrapper(
            child: BlocProvider.value(
              value: cubit,
              child: const HealthMetricsGoalsPage(),
            ),
          );
        },
        '/height-weight': (context) => const AuthWrapper(child: HeightWeightPage()),

        '/birthdate': (context) => const AuthWrapper(child: BirthdatePage()),

        '/diet': (context) => const AuthWrapper(child: DietPage()),

        '/desired-weight': (context) => const AuthWrapper(child: DesiredWeightPage()),

        '/speed': (context) => const AuthWrapper(child: SpeedSelectionPage()),

        '/review': (context) => const AuthWrapper(child: ReviewSubmitPage()),
        '/smart-exercise-log': (context) => AuthWrapper(child: SmartExerciseLogPage(repository: smartExerciseLogRepository)),
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
        '/food-text-input': (context) => const AuthWrapper(child: FoodTextInputPage()),
        '/food-analysis': (context) => const AuthWrapper(child: AIAnalysisScreen()),
        '/add-exercise': (context) => const AuthWrapper(child: ExerciseInputPage()),
        '/weightlifting-input': (context) => const AuthWrapper(child: WeightliftingPage()),
        '/cardio': (context) => const AuthWrapper(child: CardioInputPage()),
        '/exercise-history': (context) => const AuthWrapper(child: ExerciseHistoryPage()),
        '/food-history': (context) => AuthWrapper(
              child: FoodHistoryPage(
                service: Provider.of<FoodLogHistoryService>(context),
              ),
            ),
        '/exercise-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AuthWrapper(
            child: ExerciseLogDetailPage(
              exerciseId: args['exerciseId'] as String,
              activityType: args['activityType'] as String,
            ),
          );
        },
        '/food-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AuthWrapper(
            child: FoodDetailPage(
              foodId: args['foodId'] as String,
              foodRepository: Provider.of<FoodScanRepository>(context, listen: false),
              foodTextInputRepository: Provider.of<FoodTextInputRepository>(context, listen: false),
            ),
          );
        },
        '/notification-settings': (context) => const AuthWrapper(child: NotificationSettingsScreen()),
      },
    );
  }
}