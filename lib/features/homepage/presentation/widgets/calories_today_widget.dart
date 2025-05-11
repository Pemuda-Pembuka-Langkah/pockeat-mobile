// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';

class CaloriesTodayWidget extends StatefulWidget {
  final int targetCalories;
  final DailyCalorieStats? stats;

  const CaloriesTodayWidget({
    super.key,
    required this.targetCalories,
    required this.stats,
  });

  @override
  State<CaloriesTodayWidget> createState() => _CaloriesTodayWidgetState();
}

class _CaloriesTodayWidgetState extends State<CaloriesTodayWidget> {
  final Color primaryPink = const Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    // Default values if data is not provided
    int caloriesConsumed = widget.stats?.caloriesConsumed ?? 0;
    int remainingCalories = widget.targetCalories - caloriesConsumed;
    double completionPercentage = widget.targetCalories > 0
        ? caloriesConsumed / widget.targetCalories
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
              const SizedBox(width: 8),
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
