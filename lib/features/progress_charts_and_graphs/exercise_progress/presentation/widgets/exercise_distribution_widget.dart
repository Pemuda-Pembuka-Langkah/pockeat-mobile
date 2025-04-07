import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/exercise_type_row_widget.dart';

// coverage:ignore-start
class ExerciseDistributionWidget extends StatelessWidget {
  final List<ExerciseType> exerciseTypes;

  // ignore: use_super_parameters
  const ExerciseDistributionWidget({
    Key? key,
    required this.exerciseTypes,
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
            'Exercise Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < exerciseTypes.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            ExerciseTypeRowWidget(exerciseType: exerciseTypes[i]),
          ],
        ],
      ),
    );
  }
}
// coverage:ignore-end