import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';

// coverage:ignore-start
class NutritionStatWidget extends StatelessWidget {
  final NutritionStat stat;

  // ignore: use_super_parameters
  const NutritionStatWidget({
    Key? key,
    required this.stat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          stat.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: stat.color,
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end
