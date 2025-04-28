// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';

//coverage:ignore-file

class SavedMealCard extends StatelessWidget {
  final SavedMeal savedMeal;
  final VoidCallback onTap;

  const SavedMealCard({
    Key? key,
    required this.savedMeal,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meal = savedMeal.foodAnalysis;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          savedMeal.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          meal.foodName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildNutrientIndicator(
                              'P',
                              meal.nutritionInfo.protein,
                              Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            _buildNutrientIndicator(
                              'C',
                              meal.nutritionInfo.carbs,
                              Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            _buildNutrientIndicator(
                              'F',
                              meal.nutritionInfo.fat,
                              Colors.orange.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getHealthScoreColor(meal.healthScore),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${meal.healthScore.round()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${meal.nutritionInfo.calories.round()} Cal',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (meal.ingredients.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 4),
                Text(
                  'Ingredients: ${meal.ingredients.take(3).map((e) => e.name).join(", ")}${meal.ingredients.length > 3 ? "..." : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientIndicator(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${value.round()}g',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 75) return const Color(0xFF4ECDC4); // Primary Green
    if (score >= 50) return Colors.amber;
    return const Color(0xFFFF6B6B); // Primary Pink
  }
}
