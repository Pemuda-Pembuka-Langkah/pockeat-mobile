// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class FoodConsumptionItem extends StatelessWidget {
  final FoodAnalysisResult food;
  final double totalCalories;

  const FoodConsumptionItem({
    super.key,
    required this.food,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    double percentOfTotal = 0;
    if (totalCalories > 0) {
      percentOfTotal =
          (food.nutritionInfo.calories / totalCalories * 100).clamp(0.0, 100.0);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Food icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.blue[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Food Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.foodName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${food.ingredients.isNotEmpty ? food.ingredients[0].servings.toStringAsFixed(1) : '100'}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Total Calories
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${food.nutritionInfo.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${percentOfTotal.toStringAsFixed(1)}% of total',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Visual percentage
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '${percentOfTotal.round()}%',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
