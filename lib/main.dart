import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pockeat/config/production.dart';
import 'package:pockeat/config/staging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/exercise_input_options/presentation/screens/exercise_input_page.dart';
import 'package:pockeat/features/homepage/presentation/homepage.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/screens/smart_exercise_log_page.dart';
import 'package:camera/camera.dart';
import 'package:pockeat/features/food_scan_ai/presentation/food_scan_page.dart';
import 'package:provider/provider.dart';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/food_scan_ai/presentation/food_input_page.dart';
import 'package:pockeat/features/weight_training_log/presentation/screens/weightlifting_page.dart';
// Import dependencies untuk DI
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository_impl.dart';
import 'package:pockeat/features/cardio_log/presentation/screens/cardio_input_page.dart';
import 'package:pockeat/core/di/service_locator.dart';

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

  // Wrap the app with MultiProvider to make NavigationProvider available
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
    return MaterialApp(
      title: 'CalculATE',
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
              // Langsung berikan dependensi yang dibutuhkan
              geminiService: getIt<GeminiService>(),
              repository: SmartExerciseLogRepositoryImpl(
                  firestore: FirebaseFirestore.instance),
            ),
        '/scan': (context) => ScanFoodPage(
                cameraController: CameraController(
              CameraDescription(
                name: '0',
                lensDirection: CameraLensDirection.back,
                sensorOrientation: 0,
              ),
              ResolutionPreset.medium,
            )),
        '/add-food': (context) => const FoodInputPage(),
        '/add-exercise': (context) => const ExerciseInputPage(),
        '/cardio': (context) => const CardioInputPage(),
        '/weightlifting-input': (context) => const WeightliftingPage(),
      },
    );
  }
}
