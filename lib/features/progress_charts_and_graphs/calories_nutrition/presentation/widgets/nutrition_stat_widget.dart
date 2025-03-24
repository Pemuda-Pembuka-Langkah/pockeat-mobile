import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';

class NutritionStatWidget extends StatelessWidget {
  final NutritionStat stat;

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
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (stat.label == 'Burned') const Text('-'),
            Text(
              stat.value,
              style: TextStyle(
                color: stat.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Text(
          'kcal',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}