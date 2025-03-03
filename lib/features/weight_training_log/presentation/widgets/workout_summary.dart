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
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}