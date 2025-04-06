import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/services/nutrition_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/progress_overview_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/nutrient_progress_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/meal_patterns_widget.dart';

// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';

final logger = Logger();

class NutritionProgressPage extends StatefulWidget {
  final NutritionService service;
  
  const NutritionProgressPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<NutritionProgressPage> createState() => _NutritionProgressPageState();
}

class _NutritionProgressPageState extends State<NutritionProgressPage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  
  bool isWeeklyView = true;
  bool isLoading = true;
  bool isChartLoading = false;
  
  // Use direct state variables instead of futures
  List<CalorieData> _calorieData = [];
  List<NutritionStat> _nutritionStats = [];
  List<MacroNutrient> _macroNutrients = [];
  List<MicroNutrient> _microNutrients = [];
  List<Meal> _meals = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Load all data in parallel
      final results = await Future.wait([
        widget.service.getCalorieData(isWeeklyView),
        widget.service.getNutrientStats(),
        widget.service.getMacroNutrients(),
        widget.service.getMicroNutrients(),
        widget.service.getMeals(),
      ]);
      
      setState(() {
        _calorieData = results[0] as List<CalorieData>;
        _nutritionStats = results[1] as List<NutritionStat>;
        _macroNutrients = results[2] as List<MacroNutrient>;
        _microNutrients = results[3] as List<MicroNutrient>;
        _meals = results[4] as List<Meal>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      logger.e('Error loading nutrition data: $e');
    }
  }

  void _toggleView(bool weekly) async {
    if (weekly == isWeeklyView) return;
    
    setState(() {
      isWeeklyView = weekly;
      // Only set chart loading to true, don't clear the data
      isChartLoading = true;
    });
    
    try {
      // Only reload the calorie data (chart data)
      final newCalorieData = await widget.service.getCalorieData(weekly);
      
      setState(() {
        _calorieData = newCalorieData;
        isChartLoading = false;
      });
    } catch (e) {
      setState(() {
        isChartLoading = false;
      });
      logger.e('Error toggling view: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              isWeeklyView: isWeeklyView,
              onToggleView: _toggleView,
              primaryColor: primaryPink,
            ),
            const SizedBox(height: 24),
            ProgressOverviewWidget(
              calorieData: _calorieData,
              nutritionStats: _nutritionStats,
              primaryGreen: primaryGreen,
              primaryPink: primaryPink,
              isLoading: isChartLoading,
            ),
            const SizedBox(height: 24),
            NutrientProgressWidget(
              macroNutrients: _macroNutrients,
              microNutrients: _microNutrients,
            ),
            const SizedBox(height: 24),
            MealPatternsWidget(
              meals: _meals,
              primaryGreen: primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}