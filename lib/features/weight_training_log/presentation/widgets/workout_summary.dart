// Flutter imports:
import 'package:flutter/material.dart';

class WorkoutSummary extends StatelessWidget {
  final int exerciseCount;
  final int totalSets;
  final int totalReps;
  final double totalVolume;
  final double totalDuration;
  final double estimatedCalories;
  final Color primaryGreen;

  const WorkoutSummary({
    super.key,
    required this.exerciseCount,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.totalDuration,
    required this.estimatedCalories,
    required this.primaryGreen,
  });

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed size container for icon
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          // Value text with flexible height
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          // Label text
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryItem(
                  'Exercises', exerciseCount.toString(), Icons.fitness_center),
              _buildSummaryItem('Sets', totalSets.toString(), Icons.repeat),
              _buildSummaryItem('Volume',
                  '${totalVolume.toStringAsFixed(1)}\nkg', Icons.bar_chart),
              _buildSummaryItem(
                  'Duration',
                  '${totalDuration.toStringAsFixed(1)}\nminutes',
                  Icons.access_time_rounded),
              _buildSummaryItem(
                  'Estimated\nCalories',
                  '${estimatedCalories.toStringAsFixed(2)}\nkcal',
                  Icons.local_fire_department),
            ],
          ),
        ],
      ),
    );
  }
}
