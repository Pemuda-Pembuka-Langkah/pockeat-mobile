import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';

// coverage:ignore-start
class MacroCardWidget extends StatelessWidget {
  final MacroNutrient macro;

  // ignore: use_super_parameters
  const MacroCardWidget({
    Key? key,
    required this.macro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('macro_card_widget'),
      padding: const EdgeInsets.all(16),
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
        children: [
          Text(
            macro.label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${macro.percentage}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: macro.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            macro.detail,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: macro.percentage / 100,
              backgroundColor: macro.color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(macro.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
// coverage:ignore-end
