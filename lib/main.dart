import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pockeat/config/production.dart';
import 'package:pockeat/config/staging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
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
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/exercise_log_history/presentation/screens/exercise_log_detail_page.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/presentation/screens/weightlifting_page.dart';
import 'package:pockeat/features/food_log_history/presentation/screens/food_history_page.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/presentation/screens/food_detail_page.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Default ke dev untuk development yang aman
  // Load dotenv dulu
  await dotenv.load(fileName: '.env');

  // Ambil flavor dari dotenv
  final flavor = dotenv.env['FLAVOR'] ?? 'dev';

  await Firebase.initializeApp(
      options: flavor == 'production'
          ? ProductionFirebaseOptions.currentPlatform
          : flavor == 'staging'
              ? StagingFirebaseOptions.currentPlatform
              : StagingFirebaseOptions
                  .currentPlatform // Dev pake config staging tapi nanti connect ke emulator
      );

  setupDependencies();
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
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get repositories from context
    final smartExerciseLogRepository =
        Provider.of<SmartExerciseLogRepository>(context);

    return MaterialApp(
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
        // Tambah ini
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor:
                Colors.white, // Ini akan membuat teks button jadi putih
            backgroundColor: Colors.blue[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/smart-exercise-log': (context) => SmartExerciseLogPage(
              repository: smartExerciseLogRepository,
            ),
        '/scan': (context) => ScanFoodPage(
                cameraController: CameraController(
              CameraDescription(
                name: '0',
                lensDirection: CameraLensDirection.back,
                sensorOrientation: 0,
              ),
              ResolutionPreset.max,
            )),
        '/add-food': (context) => const FoodInputPage(),
        '/food-analysis': (context) => const AIAnalysisScreen(),
        '/add-exercise': (context) => const ExerciseInputPage(),
        '/weightlifting-input': (context) => const WeightliftingPage(),
        '/cardio': (context) => const CardioInputPage(),
        '/exercise-history': (context) => const ExerciseHistoryPage(),
        '/food-history': (context) => FoodHistoryPage(
              service: Provider.of<FoodLogHistoryService>(context),
            ),
        '/exercise-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ExerciseLogDetailPage(
            exerciseId: args['exerciseId'] as String,
            activityType: args['activityType'] as String,
          );
        },
        '/food-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return FoodDetailPage(
            foodId: args['foodId'] as String,
            foodRepository:
                Provider.of<FoodScanRepository>(context, listen: false),
            foodTextInputRepository:
                Provider.of<FoodTextInputRepository>(context, listen: false),
          );
        },
      },
      onGenerateRoute: (settings) {
        // Default jika tidak ada rute yang cocok
        return null;
      },
    );
  }
}
