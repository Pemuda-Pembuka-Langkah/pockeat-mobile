// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';

// Package imports:

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
    
    // Round down values to ensure consistent display
    adjustedTargetCalories = (adjustedTargetCalories ~/ 5) * 5; // Round to nearest multiple of 5 down
    caloriesConsumed = (caloriesConsumed ~/ 5) * 5; // Round to nearest multiple of 5 down

    // Calculate calories difference (can be positive for remaining or negative for exceeded)
    int caloriesDifference = adjustedTargetCalories - caloriesConsumed;

    // Check if calories are exceeded and calculate exceeded amount if needed
    bool isExceeded = caloriesDifference < 0;
    int exceededCalories = isExceeded
        ? -caloriesDifference
        : 0; // Convert negative difference to positive number
    int remainingCalories = isExceeded ? 0 : caloriesDifference;

    // Calculate percentage without clamping to determine if exceeded
    double completionPercentage = adjustedTargetCalories > 0
        ? caloriesConsumed / adjustedTargetCalories
        : 0.0;

    // For display, clamp the percentage to 1.0 max for the circular indicator
    double displayPercentage =
        completionPercentage > 1.0 ? 1.0 : completionPercentage;

    // Ensure values are within reasonable bounds
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
                    isExceeded ? '$exceededCalories' : '$remainingCalories',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    isExceeded ? 'Exceeded Calories' : 'Remaining Calories',
                    style: const TextStyle(
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
                            Icons.update, // Icon for rollover calories
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
                      value: displayPercentage,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isExceeded ? Colors.amber : Colors.white),
                      strokeWidth: 12,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Show double exclamation mark or percentage based on whether calories are exceeded
                      Text(
                        isExceeded
                            ? '!!'
                            : '${(completionPercentage * 100).floor()}%', // Use floor instead of round for consistent percentages
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isExceeded
                              ? 40
                              : 32, // Larger font for exclamation marks
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isExceeded ? 'Exceeded' : 'Completed',
                        style: const TextStyle(
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
