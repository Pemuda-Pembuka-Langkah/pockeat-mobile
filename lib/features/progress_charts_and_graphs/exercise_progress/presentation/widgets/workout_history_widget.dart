import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_item_widget.dart';

// coverage:ignore-start
class WorkoutHistoryWidget extends StatelessWidget {
  final List<WorkoutItem> workoutHistory;

  // ignore: use_super_parameters
  const WorkoutHistoryWidget({
    Key? key,
    required this.workoutHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Workouts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < workoutHistory.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            WorkoutItemWidget(workoutItem: workoutHistory[i]), // Changed parameter name from 'workout' to 'workoutItem'
          ],
        ],
      ),
    );
  }
}
// coverage:ignore-end