// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

class CaloriesTodayWidget extends StatefulWidget {
  final int targetCalories;

  const CaloriesTodayWidget({
    super.key,
    this.targetCalories = 2000,
  });

  @override
  State<CaloriesTodayWidget> createState() => _CaloriesTodayWidgetState();
}

class _CaloriesTodayWidgetState extends State<CaloriesTodayWidget> {
  final Color primaryPink = const Color(0xFFFF6B6B);
  late Future<DailyCalorieStats> _statsFuture;
  late Future<bool> _isCalorieCompensationEnabledFuture;

  @override
  void initState() {
    super.initState();
    _loadCalorieStats();
    _loadCalorieCompensationSetting();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when dependencies change
    _loadCalorieStats();
    _loadCalorieCompensationSetting();
  }

  void _loadCalorieCompensationSetting() {
    final preferencesService = GetIt.instance<UserPreferencesService>();
    _isCalorieCompensationEnabledFuture =
        preferencesService.isExerciseCalorieCompensationEnabled();
  }

  void _loadCalorieStats() {
    final calorieService = GetIt.instance<CalorieStatsService>();
    final userId = GetIt.instance<FirebaseAuth>().currentUser?.uid ?? '';

    // Add cache-busting by forcing recalculation
    setState(() {
      _statsFuture =
          calorieService.calculateStatsForDate(userId, DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_statsFuture, _isCalorieCompensationEnabledFuture]),
      builder: (context, snapshot) {
        // Default values if data is loading or failed
        int caloriesConsumed = 0;
        int caloriesBurned = 0;
        bool isCalorieCompensationEnabled = false;
        double completionPercentage = 0.0;
        int remainingCalories = widget.targetCalories;

        // If we have data, calculate actual values
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            !snapshot.hasError) {
          final stats = snapshot.data![0] as DailyCalorieStats;
          isCalorieCompensationEnabled = snapshot.data![1] as bool;

          caloriesConsumed = stats.caloriesConsumed;
          caloriesBurned = stats.caloriesBurned;

          // Calculate remaining calories based on exercise calorie compensation preference
          if (isCalorieCompensationEnabled) {
            // If enabled, add burned calories to target
            remainingCalories =
                widget.targetCalories + caloriesBurned - caloriesConsumed;
            completionPercentage =
                caloriesConsumed / (widget.targetCalories + caloriesBurned);
          } else {
            // Standard calculation without considering burned calories
            remainingCalories = widget.targetCalories - caloriesConsumed;
            completionPercentage = caloriesConsumed / widget.targetCalories;
          }

          // Ensure values are within reasonable bounds
          if (remainingCalories < 0) remainingCalories = 0;
          if (completionPercentage > 1.0) completionPercentage = 1.0;
          if (completionPercentage < 0.0) completionPercentage = 0.0;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryPink,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: snapshot.connectionState == ConnectionState.waiting
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$remainingCalories',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                            const Text(
                              'Remaining Calories',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        if (isCalorieCompensationEnabled && caloriesBurned > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+$caloriesBurned',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CircularProgressIndicator(
                                value: completionPercentage,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                strokeWidth: 12,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(completionPercentage * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
