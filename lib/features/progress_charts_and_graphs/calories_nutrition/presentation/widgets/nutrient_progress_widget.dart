import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'macro_card_widget.dart';
import 'nutrient_row_widget.dart';

// coverage:ignore-start
class NutrientProgressWidget extends StatelessWidget {
  final List<MacroNutrient> macroNutrients;
  final List<MicroNutrient> microNutrients;

  const NutrientProgressWidget({
    Key? key,
    required this.macroNutrients,
    required this.microNutrients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrient Balance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (int i = 0; i < macroNutrients.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: MacroCardWidget(macro: macroNutrients[i]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Container(
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
            children: microNutrients.map((nutrient) => 
              NutrientRowWidget(nutrient: nutrient)
            ).toList(),
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end