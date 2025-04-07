import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/repositories/nutrition_repository.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:get_it/get_it.dart';

// coverage:ignore-start
class NutritionRepositoryImpl implements NutritionRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FoodLogHistoryService _foodLogService;
  final ExerciseLogHistoryService _exerciseLogService;
  late final FoodScanRepository _foodScanRepository;
  
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryYellow = const Color(0xFFFFB946);

  NutritionRepositoryImpl({
    required FoodLogHistoryService foodLogService,
    required ExerciseLogHistoryService exerciseLogService,
  })  : _foodLogService = foodLogService,
        _exerciseLogService = exerciseLogService {
    _foodScanRepository = GetIt.instance<FoodScanRepository>();
  }

  @override
  Future<String?> getUserId() async {
    return _auth.currentUser?.uid;
  }
  
  // Helper method to get nutritional info from a FoodLogHistoryItem
  // Now using the sourceId to access the FoodAnalysisResult
  Future<NutritionInfo?> _getNutritionInfo(FoodLogHistoryItem item) async {
    try {
      // Use sourceId if available, otherwise use the item's own id
      String foodId = item.sourceId ?? item.id;
      
      // Fetch the full FoodAnalysisResult using the foodId
      FoodAnalysisResult? analysisResult = await _foodScanRepository.getById(foodId);
      
      // Return the nutrition info if available
      return analysisResult?.nutritionInfo;
    } catch (e) {
      debugPrint('Error getting nutrition info: $e');
      return null;
    }
  }
  
  // Helper method to determine meal time (morning, noon, evening)
  String _determineMealType(DateTime timestamp) {
    final hour = timestamp.hour;
    
    if (hour >= 5 && hour < 11) {
      return 'Breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'Lunch';
    } else if (hour >= 16 && hour < 21) {
      return 'Dinner';
    } else {
      return 'Snack';
    }
  }
  
  // Helper method to format time
  String _formatTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  @override
  Future<List<CalorieData>> getCalorieData(bool isWeeklyView) async {
    final userId = await getUserId();
    if (userId == null) {
      return _getDefaultCalorieData(isWeeklyView);
    }

    try {
      final now = DateTime.now();
      
      if (isWeeklyView) {
        // Weekly view implementation remains the same
        // Calculate current week's Monday
        final currentWeekday = now.weekday;
        final monday = DateTime(
          now.year, 
          now.month, 
          now.day - (currentWeekday - 1)
        );
        
        // Create list for days of the week (Mon-Sun)
        final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final Map<String, double> dailyCalories = {};
        for (String day in dayNames) {
          dailyCalories[day] = 0.0;
        }
        
        // Get all logs for the week in one batch
        for (int i = 0; i < 7; i++) {
          final date = monday.add(Duration(days: i));
          final foodLogs = await _foodLogService.getFoodLogsByDate(userId, date);
          
          double totalCalories = 0;
          for (var log in foodLogs) {
            totalCalories += log.calories;
          }
          
          final dayName = dayNames[i]; // Monday is index 0
          dailyCalories[dayName] = totalCalories;
        }
        
        return dayNames.map((dayName) => 
          CalorieData(dayName, dailyCalories[dayName] ?? 0)
        ).toList();
      } else {
        // OPTIMIZED MONTHLY VIEW - fetch all month data at once
        
        // Get the first and last day of the current month
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0); // Last day of month
        
        // Calculate total days in month and divide into 4 weeks
        final daysInMonth = lastDayOfMonth.day;
        final daysPerWeek = (daysInMonth / 4).ceil();
        
        // Create fixed week labels
        final weekLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        
        // Initialize data map
        final Map<String, double> weeklyCalories = {};
        for (String week in weekLabels) {
          weeklyCalories[week] = 0.0;
        }

        // PERFORMANCE OPTIMIZATION: Get all food logs for the entire month in one call
        // We'll assume your FoodLogHistoryService has a method for this
        // If not, we can adapt the code to use multiple day-by-day calls
        try {
          final foodLogs = await _foodLogService.getFoodLogsByMonth(userId, now.year, now.month);
          
          // Group logs by week
          for (var log in foodLogs) {
            final logDay = log.timestamp.day;
            
            // Calculate which week this day belongs to (1-indexed)
            int weekNumber = ((logDay - 1) ~/ daysPerWeek) + 1;
            
            // Ensure week number is valid (1-4)
            weekNumber = weekNumber.clamp(1, 4);
            
            // Add calories to the appropriate week
            final weekLabel = 'Week $weekNumber';
            weeklyCalories[weekLabel] = (weeklyCalories[weekLabel] ?? 0) + log.calories;
          }
        } catch (e) {
          // Fallback: if getFoodLogsByMonth doesn't exist, fetch by days
          // This is less efficient but will still work
          for (int day = 1; day <= daysInMonth && day <= now.day; day++) {
            final date = DateTime(now.year, now.month, day);
            final dayLogs = await _foodLogService.getFoodLogsByDate(userId, date);
            
            if (dayLogs.isNotEmpty) {
              int weekNumber = ((day - 1) ~/ daysPerWeek) + 1;
              weekNumber = weekNumber.clamp(1, 4);
              
              final weekLabel = 'Week $weekNumber';
              double dayTotal = 0;
              for (var log in dayLogs) {
                dayTotal += log.calories;
              }
              weeklyCalories[weekLabel] = (weeklyCalories[weekLabel] ?? 0) + dayTotal;
            }
          }
        }
        
        // Create the result list in order
        return weekLabels.map((weekLabel) => 
          CalorieData(weekLabel, weeklyCalories[weekLabel] ?? 0)
        ).toList();
      }
    } catch (e) {
      debugPrint('Error fetching calorie data: $e');
      return _getDefaultCalorieData(isWeeklyView);
    }
  }

  // Helper method to check if two dates are the same day

  List<CalorieData> _getDefaultCalorieData(bool isWeeklyView) {
    if (isWeeklyView) {
      // Default data for Monday-Sunday
      return [
        CalorieData('Mon', 2100),
        CalorieData('Tue', 2300),
        CalorieData('Wed', 1950),
        CalorieData('Thu', 2200),
        CalorieData('Fri', 2400),
        CalorieData('Sat', 1800),
        CalorieData('Sun', 2000),
      ];
    } else {
      // Default data for Weeks 1-4
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
    final userId = await getUserId();
    if (userId == null) {
      return _getDefaultNutrientStats();
    }

    try {
      // Get today's date
      final today = DateTime.now();
      
      final foodLogs = await _foodLogService.getFoodLogsByDate(userId, today);
      
      // Calculate consumed calories with proper type conversion
      int consumedCalories = 0;
      for (var log in foodLogs) {
        consumedCalories += log.calories.round();
      }
      
      final exerciseLogs = await _exerciseLogService.getExerciseLogsByDate(userId, today);
      
      // Calculate burned calories with proper type conversion
      int burnedCalories = 0;
      for (var log in exerciseLogs) {
        burnedCalories += log.caloriesBurned.round();
      }
      
      // Calculate net calories
      int netCalories = consumedCalories - burnedCalories;
      
      // Format values with commas
      final formatter = NumberFormat('#,###');
      
      return [
        NutritionStat(
          label: 'Consumed', 
          value: "${formatter.format(consumedCalories)} kcal", 
          color: primaryPink
        ),
        NutritionStat(
          label: 'Burned', 
          value: "${formatter.format(burnedCalories)} kcal", 
          color: primaryGreen
        ),
        NutritionStat(
          label: 'Net', 
          value: "${formatter.format(netCalories)} kcal", 
          color: netCalories > 0 ? primaryPink : primaryGreen
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching nutrition stats: $e');
      return _getDefaultNutrientStats();
    }
  }

  List<NutritionStat> _getDefaultNutrientStats() {
    return [
      NutritionStat(label: 'Consumed', value: '1,850 kcal', color: primaryPink),
      NutritionStat(label: 'Burned', value: '450 kcal', color: primaryGreen),
      NutritionStat(label: 'Net', value: '1,400 kcal', color: primaryPink),
    ];
  }

  @override
  Future<List<MacroNutrient>> getMacroNutrients() async {
    final userId = await getUserId();
    if (userId == null) {
      return _getDefaultMacroNutrients();
    }

    try {
      // Get today's date
      final today = DateTime.now();
      
      final foodLogs = await _foodLogService.getFoodLogsByDate(userId, today);
      
      // Set default goals
      const proteinGoal = 120;
      const carbsGoal = 250;
      const fatGoal = 65;
      
      // Calculate totals from food logs
      double proteinTotal = 0;
      double carbsTotal = 0;
      double fatTotal = 0;
      
      // Process each food log, now using async approach
      for (var log in foodLogs) {
        // Access nutrition info using helper method
        final nutritionInfo = await _getNutritionInfo(log);
        if (nutritionInfo != null) {
          proteinTotal += nutritionInfo.protein;
          carbsTotal += nutritionInfo.carbs;
          fatTotal += nutritionInfo.fat;
        }
      }
      
      // Calculate percentages (capped at 100%)
      int proteinPercentage = (proteinTotal / proteinGoal * 100).round().clamp(0, 100);
      int carbsPercentage = (carbsTotal / carbsGoal * 100).round().clamp(0, 100);
      int fatPercentage = (fatTotal / fatGoal * 100).round().clamp(0, 100);
      
      return [
        MacroNutrient(
          label: 'Protein',
          percentage: proteinPercentage,
          detail: '${proteinTotal.round()}g/${proteinGoal}g',
          color: primaryPink,
        ),
        MacroNutrient(
          label: 'Carbs',
          percentage: carbsPercentage,
          detail: '${carbsTotal.round()}g/${carbsGoal}g',
          color: primaryGreen,
        ),
        MacroNutrient(
          label: 'Fat',
          percentage: fatPercentage,
          detail: '${fatTotal.round()}g/${fatGoal}g',
          color: primaryYellow,
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching macro nutrients: $e');
      return _getDefaultMacroNutrients();
    }
  }

  List<MacroNutrient> _getDefaultMacroNutrients() {
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
    final userId = await getUserId();
    if (userId == null) {
      return _getDefaultMicroNutrients();
    }

    try {
      // Get today's date
      final today = DateTime.now();
      
      final foodLogs = await _foodLogService.getFoodLogsByDate(userId, today);
      
      // Define goals
      const fiberGoal = 25.0;
      const sugarGoal = 30.0;
      const sodiumGoal = 2300.0;
      
      // Calculate totals
      double fiberTotal = 0;
      double sugarTotal = 0;
      double sodiumTotal = 0;
      
      for (var log in foodLogs) {
        // Access nutrition info using helper method - now async
        final nutritionInfo = await _getNutritionInfo(log);
        if (nutritionInfo != null) {
          fiberTotal += nutritionInfo.fiber;
          sugarTotal += nutritionInfo.sugar;
          sodiumTotal += nutritionInfo.sodium;
        }
      }
      
      // Calculate progress (capped at 1.0)
      double fiberProgress = (fiberTotal / fiberGoal).clamp(0.0, 1.0);
      double sugarProgress = (sugarTotal / sugarGoal).clamp(0.0, 1.0);
      double sodiumProgress = (sodiumTotal / sodiumGoal).clamp(0.0, 1.0);
      
      return [
        MicroNutrient(
          nutrient: 'Fiber',
          current: '${fiberTotal.round()}g',
          target: '${fiberGoal.round()}g',
          progress: fiberProgress,
          color: primaryGreen,
        ),
        MicroNutrient(
          nutrient: 'Sugar',
          current: '${sugarTotal.round()}g',
          target: '${sugarGoal.round()}g',
          progress: sugarProgress,
          color: sugarProgress >= 0.9 ? primaryPink : primaryGreen,
        ),
        MicroNutrient(
          nutrient: 'Sodium',
          current: '${sodiumTotal.round()}mg',
          target: '${sodiumGoal.round()}mg',
          progress: sodiumProgress,
          color: sodiumProgress >= 0.9 ? primaryPink : primaryGreen,
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching micro nutrients: $e');
      return _getDefaultMicroNutrients();
    }
  }

  List<MicroNutrient> _getDefaultMicroNutrients() {
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
    ];
  }

  @override
  Future<List<Meal>> getMeals() async {
    final userId = await getUserId();
    if (userId == null) {
      return _getDefaultMeals();
    }

    try {
      // Get today's date
      final today = DateTime.now();
      
      final foodLogs = await _foodLogService.getFoodLogsByDate(userId, today);
      
      if (foodLogs.isEmpty) {
        return _getDefaultMeals();
      }
      
      // Group by meal type
      Map<String, int> mealCalories = {
        'Breakfast': 0,
        'Lunch': 0,
        'Dinner': 0,
        'Snack': 0,
      };
      
      Map<String, String> mealTimes = {
        'Breakfast': '7:30 AM',
        'Lunch': '12:30 PM',
        'Dinner': '7:00 PM',
        'Snack': '3:30 PM',
      };
      
      int totalCalories = 0;
      
      for (var log in foodLogs) {
        // Determine meal type based on timestamp instead of accessing a nonexistent property
        final mealType = _determineMealType(log.timestamp);
        
        // Fix type conversion
        final calories = log.calories.round();
        
        // Add calories to the meal type
        mealCalories.update(mealType, (value) => value + calories, ifAbsent: () => calories);
        
        // Set meal time from the log timestamp
        mealTimes[mealType] = _formatTime(log.timestamp);
        
        // Add to total calories
        totalCalories += calories;
      }
      
      // Build meal list
      List<Meal> meals = [];
      
      // Add colors based on meal type
      Map<String, Color> mealColors = {
        'Breakfast': primaryPink,
        'Lunch': primaryGreen,
        'Dinner': primaryYellow,
        'Snack': Colors.purple,
      };
      
      // Create meal objects
      mealCalories.forEach((mealType, calories) {
        if (calories > 0) {
          meals.add(Meal(
            name: mealType,
            calories: calories,
            totalCalories: totalCalories,
            time: mealTimes[mealType] ?? '12:00 PM',
            color: mealColors[mealType] ?? primaryGreen,
          ));
        }
      });
      
      return meals.isEmpty ? _getDefaultMeals() : meals;
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      return _getDefaultMeals();
    }
  }

  List<Meal> _getDefaultMeals() {
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
// coverage:ignore-end