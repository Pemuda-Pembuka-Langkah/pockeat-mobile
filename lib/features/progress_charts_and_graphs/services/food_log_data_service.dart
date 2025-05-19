// Flutter imports:

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';

// coverage:ignore-start
class FoodLogDataService {
  final FoodLogHistoryService _foodLogService;

  FoodLogDataService({required FoodLogHistoryService foodLogService})
      : _foodLogService = foodLogService;

  // Get calorie data for a specific week (current week by default)
  Future<List<CalorieData>> getWeekCalorieData({int weeksAgo = 0}) async {
    try {
      // PERUBAHAN: Mengubah logika untuk dimulai dari hari Senin, bukan Minggu
      final now = DateTime.now();

      // Hitung Senin minggu ini: kurangi weekday-1 hari dari hari ini
      // weekday: 1=Senin, 2=Selasa, ..., 7=Minggu
      final int daysFromMonday = now.weekday - 1;
      final currentStartOfWeek = now.subtract(Duration(days: daysFromMonday));

      // Calculate start date for the requested week (going back weeksAgo weeks)
      final startDate = DateTime(currentStartOfWeek.year,
          currentStartOfWeek.month, currentStartOfWeek.day - (7 * weeksAgo));

      final endDate = startDate.add(const Duration(days: 7));

      // Get user ID from Firebase Auth
      final userId = await _getUserId();

      // Fetch food log entries (limit to 100 to ensure we have enough data)
      final foodLogs = await _foodLogService.getAllFoodLogs(userId, limit: 100);

      // Filter logs for the requested week
      final weekLogs = _filterLogsForSpecificWeek(foodLogs, startDate, endDate);

      // Group entries by day and calculate macronutrient totals
      return _processLogsToCalorieData(weekLogs, startDate);
    } catch (e) {
      return _getDefaultWeekData();
    }
  }

  // Filter logs for a specific week
  List<FoodLogHistoryItem> _filterLogsForSpecificWeek(
      List<FoodLogHistoryItem> logs, DateTime startDate, DateTime endDate) {
    return logs.where((log) {
      // Adjust timestamp by subtracting 7 hours to match local time zone
      final adjustedTimestamp =
          log.timestamp.subtract(const Duration(hours: 7));

      return adjustedTimestamp.isAfter(startDate) &&
          adjustedTimestamp.isBefore(endDate);
    }).toList();
  }

  // Get calorie data for current month (grouped by weeks)
  Future<List<CalorieData>> getMonthCalorieData() async {
    try {
      // Get the date range for current month
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final userId = await _getUserId();

      // Fetch food log entries (limit to 100 to ensure we have enough data)
      final foodLogs = await _foodLogService.getAllFoodLogs(userId, limit: 100);

      // Filter logs for current month
      final monthLogs = _filterLogsForCurrentMonth(foodLogs, firstDayOfMonth);

      // Process logs into weekly data
      return _processLogsToWeeklyCalorieData(monthLogs, firstDayOfMonth);
    } catch (e) {
      return _getDefaultMonthData();
    }
  }

  // Helper function to get the current user ID
  Future<String> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  // Process daily logs
  List<CalorieData> _processLogsToCalorieData(
      List<FoodLogHistoryItem> logs, DateTime startDate) {
    // Create map for each day
    Map<String, Map<String, double>> dailyMacros = {};
    Map<String, double> dailyCalories = {};

    // PERUBAHAN: Initialize all days of the week with zeros, Senin dulu
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var day in dayNames) {
      dailyMacros[day] = {'protein': 0, 'carbs': 0, 'fats': 0};
      dailyCalories[day] = 0;
    }

    // Process each log entry
    for (var log in logs) {
      // Adjust for timezone by subtracting 7 hours
      final logDateTime = log.timestamp.subtract(const Duration(hours: 7));

      // PERUBAHAN: Convert to Monday-Sunday format
      // weekday returns 1=Monday, 2=Tuesday, ..., 7=Sunday
      final int weekdayIndex =
          logDateTime.weekday - 1; // 0=Monday, 1=Tuesday, ..., 6=Sunday
      final dayOfWeek = dayNames[weekdayIndex];

      // Extract macronutrient values directly from FoodLogHistoryItem properties
      final protein = log.protein?.toDouble() ?? 0;
      final carbs = log.carbs?.toDouble() ?? 0;
      final fat = log.fat?.toDouble() ?? 0;

      // Extract calories directly from the log
      final calories = log.calories.toDouble();

      // Add macronutrient values
      dailyMacros[dayOfWeek]!['protein'] =
          (dailyMacros[dayOfWeek]!['protein'] ?? 0) + protein;
      dailyMacros[dayOfWeek]!['carbs'] =
          (dailyMacros[dayOfWeek]!['carbs'] ?? 0) + carbs;
      dailyMacros[dayOfWeek]!['fats'] =
          (dailyMacros[dayOfWeek]!['fats'] ?? 0) + fat;

      // Add calories
      dailyCalories[dayOfWeek] = (dailyCalories[dayOfWeek] ?? 0) + calories;
    }

    // Convert to CalorieData list
    List<CalorieData> result = [];
    for (var dayName in dayNames) {
      result.add(CalorieData(
        dayName,
        dailyMacros[dayName]!['protein'] ?? 0,
        dailyMacros[dayName]!['carbs'] ?? 0,
        dailyMacros[dayName]!['fats'] ?? 0,
        dailyCalories[dayName] ?? 0,
      ));
    }

    return result;
  }

  // Process logs into weekly data
  List<CalorieData> _processLogsToWeeklyCalorieData(
      List<FoodLogHistoryItem> logs, DateTime startDate) {
    // Create map for each week
    Map<int, Map<String, double>> weeklyMacros = {
      1: {'protein': 0, 'carbs': 0, 'fats': 0},
      2: {'protein': 0, 'carbs': 0, 'fats': 0},
      3: {'protein': 0, 'carbs': 0, 'fats': 0},
      4: {'protein': 0, 'carbs': 0, 'fats': 0},
    };

    Map<int, double> weeklyCalories = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
    };

    // Process each log entry
    for (var log in logs) {
      // Use timestamp with timezone adjustment
      final logDateTime = log.timestamp.subtract(const Duration(hours: 7));

      // Calculate week number (1-4)
      final weekOfMonth = ((logDateTime.day - 1) / 7).floor() + 1;
      final weekNumber = weekOfMonth.clamp(1, 4);

      // Extract macronutrient values
      final protein = log.protein?.toDouble() ?? 0;
      final carbs = log.carbs?.toDouble() ?? 0;
      final fat = log.fat?.toDouble() ?? 0;

      // Extract calories directly from log
      final calories = log.calories.toDouble();

      // Add macronutrient values for this week
      weeklyMacros[weekNumber]!['protein'] =
          (weeklyMacros[weekNumber]!['protein'] ?? 0) + protein;
      weeklyMacros[weekNumber]!['carbs'] =
          (weeklyMacros[weekNumber]!['carbs'] ?? 0) + carbs;
      weeklyMacros[weekNumber]!['fats'] =
          (weeklyMacros[weekNumber]!['fats'] ?? 0) + fat;

      // Add calories for this week
      weeklyCalories[weekNumber] = (weeklyCalories[weekNumber] ?? 0) + calories;
    }

    // Convert to CalorieData list
    List<CalorieData> result = [];
    for (int i = 1; i <= 4; i++) {
      result.add(CalorieData(
        'Week $i',
        weeklyMacros[i]!['protein'] ?? 0,
        weeklyMacros[i]!['carbs'] ?? 0,
        weeklyMacros[i]!['fats'] ?? 0,
        weeklyCalories[i] ?? 0,
      ));
    }

    return result;
  }

  // Default week data if fetch fails
  List<CalorieData> _getDefaultWeekData() {
    return [
      // PERUBAHAN: Default data Monday-Sunday
      CalorieData('Mon', 0, 0, 0),
      CalorieData('Tue', 0, 0, 0),
      CalorieData('Wed', 0, 0, 0),
      CalorieData('Thu', 0, 0, 0),
      CalorieData('Fri', 0, 0, 0),
      CalorieData('Sat', 0, 0, 0),
      CalorieData('Sun', 0, 0, 0),
    ];
  }

  // Default month data if fetch fails
  List<CalorieData> _getDefaultMonthData() {
    return [
      CalorieData('Week 1', 0, 0, 0),
      CalorieData('Week 2', 0, 0, 0),
      CalorieData('Week 3', 0, 0, 0),
      CalorieData('Week 4', 0, 0, 0),
    ];
  }

  // Calculate total calories directly from CalorieData objects
  double calculateTotalCalories(List<CalorieData> calorieData) {
    double total = 0;
    for (var data in calorieData) {
      total += data.calories;
    }
    return total;
  }

  // Filter logs for the current month
  List<FoodLogHistoryItem> _filterLogsForCurrentMonth(
      List<FoodLogHistoryItem> logs, DateTime firstDayOfMonth) {
    final lastDayOfMonth = DateTime(
        firstDayOfMonth.year,
        firstDayOfMonth.month + 1,
        0, // Last day of month
        23,
        59,
        59);

    return logs.where((log) {
      // Adjust timestamp by subtracting 7 hours to match local time zone
      final adjustedTimestamp =
          log.timestamp.subtract(const Duration(hours: 7));

      return adjustedTimestamp.isAfter(firstDayOfMonth) &&
          adjustedTimestamp.isBefore(lastDayOfMonth);
    }).toList();
  }
}
// coverage:ignore-end
