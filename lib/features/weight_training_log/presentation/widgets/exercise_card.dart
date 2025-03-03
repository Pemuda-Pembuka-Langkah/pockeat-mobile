import 'package:flutter/material.dart';
import 'package:pockeat/features/weight_training_log/domain/models/exercise.dart';
import 'package:pockeat/features/weight_training_log/services/workout_service.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final Color primaryGreen;
  final double volume;
  final VoidCallback onAddSet;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.primaryGreen,
    required this.volume,
    required this.onAddSet,
  }) : super(key: key);

  Widget _buildSetRow(int setNumber, ExerciseSet set) {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
