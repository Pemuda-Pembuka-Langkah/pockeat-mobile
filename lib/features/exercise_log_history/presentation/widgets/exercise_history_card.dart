import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';

/// A reusable widget that displays an exercise history item in a card format.
///
/// This widget is extracted from the RecentExerciseSection's buildExerciseCard
/// but uses the ExerciseLogHistoryItem model instead of a Map.
class ExerciseHistoryCard extends StatelessWidget {
  final ExerciseLogHistoryItem exercise;
  final VoidCallback? onTap;

  // Colors
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color purpleColor = const Color(0xFF9B6BFF);

  const ExerciseHistoryCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  /// Get the appropriate icon based on activity type
  IconData _getIconForActivityType(String activityType) {
    switch (activityType) {
      case ExerciseLogHistoryItem.typeCardio:
        return Icons.directions_run;
      case ExerciseLogHistoryItem.typeWeightlifting:
        return CupertinoIcons.arrow_up_circle_fill;
      case ExerciseLogHistoryItem.typeSmartExercise:
        return CupertinoIcons.text_badge_checkmark;
      default:
        return Icons.fitness_center;
    }
  }

  /// Get the appropriate color based on activity type
  Color _getColorForActivityType(String activityType) {
    switch (activityType) {
      case ExerciseLogHistoryItem.typeCardio:
        return primaryPink;
      case ExerciseLogHistoryItem.typeWeightlifting:
        return primaryGreen;
      case ExerciseLogHistoryItem.typeSmartExercise:
        return purpleColor;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityColor = _getColorForActivityType(exercise.activityType);
    final activityIcon = _getIconForActivityType(exercise.activityType);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  activityIcon,
                  color: activityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Exercise Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          exercise.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          exercise.timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
