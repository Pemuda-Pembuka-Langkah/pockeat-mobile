// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';

// coverage:ignore-start
class NutrientRowWidget extends StatelessWidget {
  final MicroNutrient nutrient;

  // ignore: use_super_parameters
  const NutrientRowWidget({
    Key? key,
    required this.nutrient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              nutrient.nutrient,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${nutrient.current} / ${nutrient.target}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: nutrient.progress,
                backgroundColor: nutrient.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(nutrient.color),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// coverage:ignore-end
