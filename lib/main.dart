import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pockeat/config/production.dart';
import 'package:pockeat/config/staging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pockeat/features/cardio_log/presentation/screens/cardio_input_page.dart';

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
        : StagingFirebaseOptions.currentPlatform // Dev pake config staging tapi nanti connect ke emulator
  );

  // Setup emulator kalau di dev mode
  if (flavor == 'dev') {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(
    const MyApp(),

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

      },
      // TODO: Jangan lupa hapus kalo mau push
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const CardioInputPage(),
        );
      },
      // TODO: Jangan lupa hapus kalo mau push
    );
  }
}
