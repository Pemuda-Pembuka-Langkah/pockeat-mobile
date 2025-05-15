// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';

// Package imports:

class CaloriesTodayWidget extends StatefulWidget {
  final int targetCalories;
  final DailyCalorieStats? stats;
  final bool isCalorieCompensationEnabled;
  final bool isRolloverCaloriesEnabled;
  final int rolloverCalories;

  const CaloriesTodayWidget({
    super.key,
    required this.targetCalories,
    required this.stats,
    required this.isCalorieCompensationEnabled,
    required this.isRolloverCaloriesEnabled,
    required this.rolloverCalories,
  });

  @override
  State<CaloriesTodayWidget> createState() => _CaloriesTodayWidgetState();
}

class _CaloriesTodayWidgetState extends State<CaloriesTodayWidget> {
  final Color primaryPink = const Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    // Default values if data is not provided
    int adjustedTargetCalories = 0;
    int caloriesConsumed = widget.stats?.caloriesConsumed ?? 0;
    int caloriesBurned = widget.stats?.caloriesBurned ?? 0;

    adjustedTargetCalories = widget.targetCalories;

    if (widget.isCalorieCompensationEnabled) {
      adjustedTargetCalories += caloriesBurned;
    }

    if (widget.isRolloverCaloriesEnabled) {
      adjustedTargetCalories += widget.rolloverCalories;
    }

    int remainingCalories = adjustedTargetCalories - caloriesConsumed;

    double completionPercentage = adjustedTargetCalories > 0
        ? caloriesConsumed / adjustedTargetCalories
        : 0.0;

    // Ensure values are within reasonable bounds
    if (remainingCalories < 0) remainingCalories = 0;
    if (completionPercentage > 1.0) completionPercentage = 1.0;
    if (completionPercentage < 0.0) completionPercentage = 0.0;

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
      child: Column(
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
              Row(
                children: [
                  // Show exercise compensation bonus if enabled
                  if (widget.isCalorieCompensationEnabled && caloriesBurned > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
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
                  // Show rollover calories bonus if enabled
                  if (widget.isRolloverCaloriesEnabled &&
                      widget.rolloverCalories > 0)
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
                            Icons.update, // Different icon for rollover
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${widget.rolloverCalories}',
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
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
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
  }
}
