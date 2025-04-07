import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ExerciseProgressRepositoryImpl implements ExerciseProgressRepository {
  bool _isWeeklyView = true;
  final int _primaryPink = 0xFFFF6B6B;
  final int _primaryGreen = 0xFF4ECDC4;
  final int _primaryYellow = 0xFFFFB946;
  final int _purpleColor = 0xFF9B6BFF;
  
  final ExerciseLogHistoryService _exerciseLogHistoryService;
  final FirebaseAuth _auth;
  
  ExerciseProgressRepositoryImpl({
    required ExerciseLogHistoryService exerciseLogHistoryService,
    FirebaseAuth? auth,
  }) : _exerciseLogHistoryService = exerciseLogHistoryService,
       _auth = auth ?? FirebaseAuth.instance;

  // Helper method to get logs with current userId for consistency
  Future<List<ExerciseLogHistoryItem>> _getExerciseLogs() async {
    try {
      // Get the current user ID or use a test ID if no user is logged in
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid ?? 'test_user_123';
      
      final logs = await _exerciseLogHistoryService.getAllExerciseLogs(userId);
      return logs;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  @override
  Future<List<ExerciseData>> getExerciseData(bool isWeeklyView) async {
    // Set the view mode for other methods to use
    _isWeeklyView = isWeeklyView;
    
    // Get all exercise logs
    final allLogs = await _getExerciseLogs();
    
    final now = DateTime.now();
    
    if (isWeeklyView) {
      // For weekly view, show current calendar week (Monday to Sunday)
      
      // Get the current year and month
      final currentYear = now.year;
      final currentMonth = now.month;
      
      // Calculate current week's Monday (start of week)
      // Normalize times to start of day to ensure proper week boundary comparison
      final currentWeekday = now.weekday;
      final monday = DateTime(
        now.year, 
        now.month, 
        now.day - (currentWeekday - 1)
      );
      
      // Calculate end of current week (Sunday)
      final sunday = DateTime(
        monday.year,
        monday.month,
        monday.day + 6,
        23, 59, 59, 999
      );
      
      // Create list for days of the week (Mon-Sun)
      final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      // Initialize map with all days of the week
      final Map<String, double> dailyData = {};
      for (String day in dayNames) {
        dailyData[day] = 0.0; // Initialize with zero values
      }
      
      // Aggregate calories burned by day of week
      for (var log in allLogs) {
        final logDate = log.timestamp;
        
        // Normalize the log date to start of day for consistent comparison
        final normalizedLogDate = DateTime(logDate.year, logDate.month, logDate.day);
        
        // Only include logs from current week (Monday to Sunday)
        if ((normalizedLogDate.isAfter(monday) || 
             _isSameDay(normalizedLogDate, monday)) && 
            (normalizedLogDate.isBefore(sunday) || 
             _isSameDay(normalizedLogDate, sunday))) {
          
          // Get day name (Mon, Tue, etc.)
          final dayName = dayNames[logDate.weekday - 1];
          
          // Add calories to the appropriate day
          dailyData[dayName] = (dailyData[dayName] ?? 0) + log.caloriesBurned.toDouble();
        }
      }
      
      // Convert to list of ExerciseData with proper day order
      final result = dayNames.map((dayName) => 
        ExerciseData(dayName, dailyData[dayName] ?? 0)
      ).toList();
      
      return result;
    } else {
      // Monthly view - Show exactly 4 weeks of data for the current month
      
      // Get the first and last day of the current month
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      
      // Calculate the total days in the month
      final daysInMonth = lastDayOfMonth.day;
      
      // Create fixed 4 week divisions (regardless of actual calendar weeks)
      final weekLength = (daysInMonth / 4).ceil();
      
      // Create week labels - always exactly 4 weeks
      final weekLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      
      // Map to store data for each week
      final Map<String, double> weeklyData = {};
      for (String week in weekLabels) {
        weeklyData[week] = 0.0; // Initialize with zero values
      }
      
      // Filter logs to include only those from current month
      final currentMonthLogs = allLogs.where((log) => 
        log.timestamp.year == now.year && 
        log.timestamp.month == now.month
      ).toList();
      
      // Group logs into fixed 4-week periods
      for (var log in currentMonthLogs) {
        final dayOfMonth = log.timestamp.day;
        
        // Calculate which week this log belongs to (1-indexed)
        int weekNumber = ((dayOfMonth - 1) ~/ weekLength) + 1;
        
        // Ensure week number is valid (1-4)
        weekNumber = weekNumber.clamp(1, 4);
        
        // Add calories to the appropriate week
        final weekLabel = 'Week $weekNumber';
        weeklyData[weekLabel] = (weeklyData[weekLabel] ?? 0) + log.caloriesBurned.toDouble();
      }
      
      // Create result list in order
      return weekLabels.map((week) => 
        ExerciseData(week, weeklyData[week] ?? 0)
      ).toList();
    }
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  @override
  Future<List<WorkoutStat>> getWorkoutStats() async {
    final allLogs = await _getExerciseLogs();
    
    // Filter logs to only include today's workouts
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    
    final todaysLogs = allLogs.where((log) => 
      log.timestamp.isAfter(startOfToday) || 
      log.timestamp.isAtSameMomentAs(startOfToday)
    ).toList();
    
    if (todaysLogs.isEmpty) {
      return [
        WorkoutStat(
          label: 'Duration',
          value: '0 min',
          colorValue: _primaryGreen,
        ),
        WorkoutStat(
          label: 'Calories',
          value: '0 kcal',
          colorValue: _primaryPink,
        ),
        WorkoutStat(
          label: 'Intensity',
          value: 'Low',
          colorValue: _primaryYellow,
        ),
      ];
    }
    
    // Calculate total duration from today's workouts
    double totalDuration = 0;
    
    for (var log in todaysLogs) {
      // Parse duration from subtitle (e.g., "45 minutes • 280 cal")
      final durationMatch = RegExp(r'(\d+) minute').firstMatch(log.subtitle);
      if (durationMatch != null) {
        totalDuration += double.parse(durationMatch.group(1)!);
      }
    }
    
    // Calculate total calories burned today
    double totalCalories = 0;
    for (var log in todaysLogs) {
      totalCalories += log.caloriesBurned.toDouble();
    }
    
    // Determine intensity level based on today's total calories
    String intensityLevel = 'Low';
    if (totalCalories > 500) {
      intensityLevel = 'High';
    } else if (totalCalories > 300) {
      intensityLevel = 'Medium';
    }
    
    return [
      WorkoutStat(
        label: 'Duration',
        value: '${totalDuration.round()} min',
        colorValue: _primaryGreen,
      ),
      WorkoutStat(
        label: 'Calories',
        value: '${totalCalories.round().toString()} kcal',
        colorValue: _primaryPink,
      ),
      WorkoutStat(
        label: 'Intensity',
        value: intensityLevel,
        colorValue: _primaryYellow,
      ),
    ];
  }

  @override
  Future<List<ExerciseType>> getExerciseTypes() async {
    final allLogs = await _getExerciseLogs();
    
    // Filter logs by time period based on the current view
    final now = DateTime.now();
    final DateTime cutoffDate;
    
    if (_isWeeklyView) {
      // Weekly view - past 7 days
      cutoffDate = now.subtract(const Duration(days: 7));
    } else {
      // Monthly view - past 30 days
      cutoffDate = now.subtract(const Duration(days: 30));
    }
    
    // Filter logs based on selected time period
    final filteredLogs = allLogs.where((log) => 
      log.timestamp.isAfter(cutoffDate) || 
      log.timestamp.isAtSameMomentAs(cutoffDate)
    ).toList();
    
    if (filteredLogs.isEmpty) {
      // Return default values if no logs exist in the selected period
      return [
        ExerciseType(
          name: 'Cardio',
          percentage: 33,
          colorValue: _primaryPink,
        ),
        ExerciseType(
          name: 'Weightlifting',
          percentage: 33,
          colorValue: _primaryGreen,
        ),
        ExerciseType(
          name: 'Smart Exercise',
          percentage: 34,
          colorValue: _purpleColor,
        ),
      ];
    }
    
    // Count by activity type
    int cardioCount = 0;
    int weightliftingCount = 0;
    int smartExerciseCount = 0;
    
    for (var log in filteredLogs) {
      switch (log.activityType) {
        case ExerciseLogHistoryItem.typeCardio:
          cardioCount++;
          break;
        case ExerciseLogHistoryItem.typeWeightlifting:
          weightliftingCount++;
          break;
        case ExerciseLogHistoryItem.typeSmartExercise:
          smartExerciseCount++;
          break;
      }
    }
    
    final totalCount = cardioCount + weightliftingCount + smartExerciseCount;
    
    // Calculate percentages
    int cardioPercentage = totalCount > 0 ? ((cardioCount / totalCount) * 100).round() : 33;
    int weightliftingPercentage = totalCount > 0 ? ((weightliftingCount / totalCount) * 100).round() : 33;
    int smartExercisePercentage = totalCount > 0 ? ((smartExerciseCount / totalCount) * 100).round() : 34;
    
    // Ensure percentages add up to 100%
    final sum = cardioPercentage + weightliftingPercentage + smartExercisePercentage;
    if (sum != 100 && totalCount > 0) {
      final diff = 100 - sum;
      // Add the difference to the largest category
      if (cardioCount >= weightliftingCount && cardioCount >= smartExerciseCount) {
        cardioPercentage += diff;
      } else if (weightliftingCount >= cardioCount && weightliftingCount >= smartExerciseCount) {
        weightliftingPercentage += diff;
      } else {
        smartExercisePercentage += diff;
      }
    }
    
    return [
      ExerciseType(
        name: 'Cardio',
        percentage: cardioPercentage,
        colorValue: _primaryPink,
      ),
      ExerciseType(
        name: 'Weightlifting',
        percentage: weightliftingPercentage,
        colorValue: _primaryGreen,
      ),
      ExerciseType(
        name: 'Smart Exercise',
        percentage: smartExercisePercentage,
        colorValue: _purpleColor,
      ),
    ];
  }

  @override
  Future<List<PerformanceMetric>> getPerformanceMetrics() async {
    final allLogs = await _getExerciseLogs();
    
    // Calculate consistency (workout days in the last week)
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    
    // Count unique workout days in the last week and two weeks ago
    final Set<int> workoutDaysLastWeek = {};
    final Set<int> workoutDaysTwoWeeksAgo = {};
    
    for (var log in allLogs) {
      final logDate = log.timestamp;
      if (logDate.isAfter(lastWeek)) {
        // Replace DateUtils.getDayOfYear with our own calculation
        workoutDaysLastWeek.add(_getDayOfYear(logDate));
      } else if (logDate.isAfter(twoWeeksAgo) && logDate.isBefore(lastWeek)) {
        workoutDaysTwoWeeksAgo.add(_getDayOfYear(logDate));
      }
    }
    
    final consistencyPercentage = min(100, (workoutDaysLastWeek.length / 7 * 100).round());
    final previousConsistencyPercentage = min(100, (workoutDaysTwoWeeksAgo.length / 7 * 100).round());
    
    // Calculate current streak (consecutive days with workouts)
    int currentStreak = 0;
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    // Create a set of dates with workouts
    final Set<String> workoutDates = allLogs
        .map((log) => dateFormat.format(log.timestamp))
        .toSet();
    
    // Calculate streak from today backwards
    for (int i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final dateString = dateFormat.format(checkDate);
      
      if (workoutDates.contains(dateString)) {
        currentStreak++;
      } else if (i > 0) { // Allow for today not having a workout yet
        break;
      }
    }
    
    // Calculate intensity (average calories per workout in the last week)
    double totalCaloriesLastWeek = 0;
    int workoutsLastWeek = 0;
    
    for (var log in allLogs) {
      if (log.timestamp.isAfter(lastWeek)) {
        totalCaloriesLastWeek += log.caloriesBurned.toDouble();
        workoutsLastWeek++;
      }
    }
    
    final intensity = workoutsLastWeek > 0 ? (totalCaloriesLastWeek / workoutsLastWeek / 100).toStringAsFixed(1) : '0.0';
    
    // Recovery is more subjective, but we'll base it on workout frequency
    String recoveryPercentage = '95%';
    String recoveryStatus = 'Optimal';
    
    // If very frequent workouts without rest days, recovery might not be optimal
    if (workoutDaysLastWeek.length >= 6) {
      recoveryPercentage = '80%';
      recoveryStatus = 'Needs rest';
    }
    
    return [
      PerformanceMetric(
        label: 'Consistency',
        value: '$consistencyPercentage%',
        subtext: 'Last week: $previousConsistencyPercentage%',
        colorValue: _primaryPink,
        icon: Icons.trending_up,
      ),
      PerformanceMetric(
        label: 'Intensity',
        value: intensity,
        subtext: workoutsLastWeek > 0 ? 'Above average' : 'No data',
        colorValue: _purpleColor,
        icon: Icons.speed,
      ),
      PerformanceMetric(
        label: 'Streak',
        value: currentStreak.toString(),
        subtext: currentStreak > 0 ? 'days in a row' : 'No active streak',
        colorValue: _primaryYellow,
        icon: Icons.local_fire_department,
      ),
      PerformanceMetric(
        label: 'Recovery',
        value: recoveryPercentage,
        subtext: recoveryStatus,
        colorValue: _primaryGreen,
        icon: Icons.battery_charging_full,
      ),
    ];
  }

  // Helper method to calculate day of year (replacement for DateUtils.getDayOfYear)
  int _getDayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final diffDays = date.difference(startOfYear).inDays;
    return diffDays + 1; // +1 because days are 1-indexed (Jan 1 is day 1, not day 0)
  }

  @override
  Future<List<WorkoutItem>> getWorkoutHistory() async {
    // Use our helper method to get logs
    final allLogs = await _getExerciseLogs();
    
    // Get the most recent logs (limit to 5)
    final recentLogs = allLogs
        .where((log) => log.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 14))))
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    final limitedRecentLogs = recentLogs.take(5).toList();
    
    if (limitedRecentLogs.isEmpty) {
      // Return placeholder if no logs exist
      return [
        WorkoutItem(
          title: 'No workouts yet',
          type: 'Get Started',
          stats: '0 min • 0 cal',
          time: 'Now',
          colorValue: _primaryGreen,
          icon: Icons.add_circle_outline,
        ),
      ];
    }
    
    return limitedRecentLogs.map((log) {
      // Determine color based on activity type
      int colorValue;
      String type;
      IconData icon;
      
      switch (log.activityType) {
        case ExerciseLogHistoryItem.typeCardio:
          colorValue = _primaryPink;
          type = 'Cardio';
          icon = Icons.directions_run;
          break;
        case ExerciseLogHistoryItem.typeWeightlifting:
          colorValue = _primaryGreen;
          type = 'Weightlifting';
          icon = CupertinoIcons.arrow_up_circle_fill;
          break;
        case ExerciseLogHistoryItem.typeSmartExercise:
          colorValue = _purpleColor;
          type = 'Smart Exercise';
          icon = CupertinoIcons.text_badge_checkmark;
          break;
        default:
          colorValue = _primaryGreen;
          type = 'Exercise';
          icon = Icons.fitness_center;
      }
      
      return WorkoutItem(
        title: log.title,
        type: type,
        stats: log.subtitle,
        time: log.timeAgo,
        colorValue: colorValue,
        icon: icon,
      );
    }).toList();
  }

  @override
  Future<bool> getSelectedViewPeriod() async {
    return _isWeeklyView;
  }

  @override
  Future<void> setSelectedViewPeriod(bool isWeeklyView) async {
    _isWeeklyView = isWeeklyView;
  }

  @override
  Future<String> getCompletionPercentage() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final allLogs = await _getExerciseLogs();
    
    // Count unique workout days this week
    final Set<int> workoutDaysThisWeek = {};
    
    for (var log in allLogs) {
      if (log.timestamp.isAfter(startOfWeek)) {
        workoutDaysThisWeek.add(_getDayOfYear(log.timestamp));
      }
    }
    
    // Assume a goal of 5 workout days per week
    final targetWorkoutDays = 5;
    final completionPercentage = min(100, (workoutDaysThisWeek.length / targetWorkoutDays * 100).round());
    
    return '$completionPercentage% completed';
  }
}