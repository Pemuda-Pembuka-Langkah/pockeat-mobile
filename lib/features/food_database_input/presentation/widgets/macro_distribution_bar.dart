// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class MacroDistributionBar extends StatelessWidget {
  final NutritionInfo nutrition;
  final Color primaryGreen;
  final Color primaryPink;

  const MacroDistributionBar({
    super.key,
    required this.nutrition,
    required this.primaryGreen,
    required this.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    final double totalCals = nutrition.calories;
    double proteinPercent = 0;
    double carbsPercent = 0;
    double fatPercent = 0;

    if (totalCals > 0) {
      proteinPercent =
          (nutrition.protein * 4 / totalCals * 100).clamp(0.0, 100.0);
      carbsPercent = (nutrition.carbs * 4 / totalCals * 100).clamp(0.0, 100.0);
      fatPercent = (nutrition.fat * 9 / totalCals * 100).clamp(0.0, 100.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Macronutrient Distribution',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${nutrition.calories.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                // Protein bar
                Expanded(
                  flex: proteinPercent.round(),
                  child: Container(
                    color: Colors.blue[400],
                    child: Center(
                      child: proteinPercent >= 10
                          // coverage:ignore-line
                          ? Text(
                              'P: ${proteinPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Container(),
                    ),
                  ),
                ),
                // Carbs bar
                Expanded(
                  flex: carbsPercent.round(),
                  child: Container(
                    color: primaryGreen,
                    child: Center(
                      child: carbsPercent >= 10
                          ? Text(
                              'C: ${carbsPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          // coverage:ignore-line
                          : Container(),
                    ),
                  ),
                ),
                // Fat bar
                Expanded(
                  flex: fatPercent.round(),
                  child: Container(
                    color: primaryPink,
                    child: Center(
                      child: fatPercent >= 10
                          // coverage:ignore-line
                          ? Text(
                              'F: ${fatPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Protein: ${nutrition.protein.toStringAsFixed(1)}g',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Carbs: ${nutrition.carbs.toStringAsFixed(1)}g',
              style: TextStyle(
                fontSize: 12,
                color: primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Fat: ${nutrition.fat.toStringAsFixed(1)}g',
              style: TextStyle(
                fontSize: 12,
                color: primaryPink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
