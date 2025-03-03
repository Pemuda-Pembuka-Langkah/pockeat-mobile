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
    return Row(
      children: [
        Text('$setNumber'),
        Text('${set.weight} kg × ${set.reps} reps (${set.duration} min)'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(exercise.name),
        Text('$volume kg'),
        Text('${calculateExerciseCalories(exercise).toStringAsFixed(2)} kcal'),
        ListView.builder(
          shrinkWrap: true,
          itemCount: exercise.sets.length,
          itemBuilder: (context, index) {
            return _buildSetRow(index + 1, exercise.sets[index]);
          },
        ),
        ElevatedButton(onPressed: onAddSet, child: const Text('Add Set')),
      ],
    );
  }
}
