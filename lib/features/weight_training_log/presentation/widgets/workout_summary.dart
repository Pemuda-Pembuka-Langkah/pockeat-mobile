import 'package:flutter/material.dart';
import 'package:pockeat/features/weight_training_log/services/workout_service.dart';

class WorkoutSummary extends StatelessWidget {
  final int exerciseCount;
  final int totalSets;
  final int totalReps;
  final double totalVolume;
  final double totalDuration;
  final double estimatedCalories;
  final Color primaryGreen;

  const WorkoutSummary({
    Key? key,
    required this.exerciseCount,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.totalDuration,
    required this.estimatedCalories,
    required this.primaryGreen,
  }) : super(key: key);

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Exercises', exerciseCount.toString(), Icons.fitness_center),
              _buildSummaryItem('Sets', totalSets.toString(), Icons.repeat),
              _buildSummaryItem('Volume', '${totalVolume.toStringAsFixed(1)} kg', Icons.bar_chart),
              _buildSummaryItem('Duration', '${totalDuration.toString()} minutes', Icons.access_time_rounded),
              _buildSummaryItem('Calories', 'Est. ${estimatedCalories.toStringAsFixed(2)} kcal', Icons.local_fire_department),
            ],
          ),
        ],
      ),
    );
  }
}