import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/repositories/nutrition_repository.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryYellow = const Color(0xFFFFB946);

  @override
  Future<List<CalorieData>> getCalorieData(bool isWeeklyView) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (isWeeklyView) {
      return [
        CalorieData('M', 2100),
        CalorieData('T', 2300),
        CalorieData('W', 1950),
        CalorieData('T', 2200),
        CalorieData('F', 2400),
        CalorieData('S', 1800),
        CalorieData('S', 2000),
      ];
    } else {
      return [
        CalorieData('Week 1', 2150),
        CalorieData('Week 2', 2250),
        CalorieData('Week 3', 2050),
        CalorieData('Week 4', 2180),
      ];
    }
  }

  @override
  Future<List<NutritionStat>> getNutrientStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      NutritionStat(label: 'Consumed', value: '1,850', color: primaryPink),
      NutritionStat(label: 'Burned', value: '450', color: primaryGreen),
      NutritionStat(label: 'Net', value: '1,400', color: primaryPink),
    ];
  }

  @override
  Future<List<MacroNutrient>> getMacroNutrients() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      MacroNutrient(
        label: 'Protein',
        percentage: 25,
        detail: '75g/120g',
        color: primaryPink,
      ),
      MacroNutrient(
        label: 'Carbs',
        percentage: 55,
        detail: '138g/250g',
        color: primaryGreen,
      ),
      MacroNutrient(
        label: 'Fat',
        percentage: 20,
        detail: '32g/65g',
        color: primaryYellow,
      ),
    ];
  }

  @override
  Future<List<MicroNutrient>> getMicroNutrients() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      MicroNutrient(
        nutrient: 'Fiber',
        current: '12g',
        target: '25g',
        progress: 0.48,
        color: primaryGreen,
      ),
      MicroNutrient(
        nutrient: 'Sugar',
        current: '18g',
        target: '30g',
        progress: 0.6,
        color: primaryPink,
      ),
      MicroNutrient(
        nutrient: 'Sodium',
        current: '1200mg',
        target: '2300mg',
        progress: 0.52,
        color: primaryGreen,
      ),
      MicroNutrient(
        nutrient: 'Iron',
        current: '12mg',
        target: '18mg',
        progress: 0.67,
        color: primaryPink,
      ),
    ];
  }

  @override
  Future<List<Meal>> getMeals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      Meal(
        name: 'Breakfast',
        calories: 550,
        totalCalories: 2150,
        time: '7:30 AM',
        color: primaryPink,
      ),
      Meal(
        name: 'Lunch',
        calories: 750,
        totalCalories: 2150,
        time: '12:30 PM',
        color: primaryGreen,
      ),
      Meal(
        name: 'Dinner',
        calories: 650,
        totalCalories: 2150,
        time: '7:00 PM',
        color: primaryYellow,
      ),
    ];
  }
}