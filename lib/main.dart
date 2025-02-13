import 'package:pockeat/add_recipe_page.dart';
import 'package:pockeat/exercise_input_page.dart';
import 'package:pockeat/exercise_journal_page.dart';
import 'package:pockeat/food_input_page.dart';
import 'package:pockeat/food_scan_page.dart';
import 'package:pockeat/goals_and_journal_page.dart';
import 'package:pockeat/navigation.dart';
import 'package:pockeat/homepage.dart';
import 'package:pockeat/pet_store_page.dart';
import 'package:pockeat/planning_page.dart';
import 'package:pockeat/progress_page.dart';
import 'package:pockeat/running_input_page.dart';
import 'package:pockeat/weighting_input_page.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
        '/scan': (context) => const ScanFoodPage(),
        '/add-food-manual': (context) => const AddFoodLogPage(),
        '/analytic': (context) => const ProgressPage(),
        '/progress': (context) => const ProgressTrackingPage(),
        '/add-exercise': (context) => const ExerciseInputPage(),
        '/running-input': (context) => const RunningInputPage(),
        '/weightlifting-input': (context) => const WeightliftingPage(),
        '/smart-workout-log': (context) => const SmartJournalPage(),
        '/planning': (context) => const PlanningPage(),
        '/add-food': (context) => const FoodInputPage(),
        '/pet-store': (c) => const PetStorePage()
      },
    );
  }
}
