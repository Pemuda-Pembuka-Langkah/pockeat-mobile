import 'package:pockeat/add-recipe-page.dart';
import 'package:pockeat/exercise_input_page.dart';
import 'package:pockeat/exercise_journal_page.dart';
import 'package:pockeat/food_input_page.dart';
import 'package:pockeat/food_scan_page.dart';
import 'package:pockeat/goals_and_journal_page.dart';
import 'package:pockeat/navigation.dart';
import 'package:pockeat/new_homepage.dart';
import 'package:pockeat/pet_store_page.dart';
import 'package:pockeat/planning_page.dart';
import 'package:pockeat/progress_page.dart';
import 'package:pockeat/running_input_page.dart';
import 'package:pockeat/weighting_input_page.dart';
import 'package:flutter/material.dart';
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
        appBarTheme: AppBarTheme(
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
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/scan': (context) => ScanFoodPage(),
        '/add-food-manual': (context) => AddFoodLogPage(),
        '/analytic': (context) => ProgressPage(),
        '/progress': (context) => ProgressTrackingPage(),
        '/add-exercise': (context) => ExerciseInputPage(),
        '/running-input': (context) => RunningInputPage(),
        '/weightlifting-input': (context) => WeightliftingPage(),
        '/smart-workout-log': (context) => SmartJournalPage(),
        '/planning': (context) => PlanningPage(),
        '/add-food': (context) => FoodInputPage(),
        '/pet-store': (c) => PetStorePage()
      },
    );
  }
}
