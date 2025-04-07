import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';

// coverage:ignore-start
class WorkoutItemWidget extends StatelessWidget {
  final WorkoutItem workoutItem;
  
  const WorkoutItemWidget({
    Key? key,
    required this.workoutItem,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Exercise icon with background
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(workoutItem.colorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              workoutItem.icon,  // Use the icon from the workout item
              color: Color(workoutItem.colorValue),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Workout details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutItem.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workoutItem.stats,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          // Type and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(workoutItem.colorValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  workoutItem.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(workoutItem.colorValue),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                workoutItem.time,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// coverage:ignore-end