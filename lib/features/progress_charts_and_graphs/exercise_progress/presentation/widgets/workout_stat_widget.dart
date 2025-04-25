// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';

// coverage:ignore-start
class WorkoutStatWidget extends StatelessWidget {
  final WorkoutStat stat;

  const WorkoutStatWidget({
    super.key,
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          stat.label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.value,
          style: TextStyle(
            color: Color(stat.colorValue),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end
