// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';

/// Widget to display saved meal in card format
///
/// This widget shows the saved meal information in a card with an icon,
/// meal name, date, nutrition info, and health score
class SavedMealCard extends StatelessWidget {
  final SavedMeal savedMeal;
  final VoidCallback onTap;

  // Colors
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryOrange = const Color(0xFFFF9800);
  final Color primaryPink = const Color(0xFFFF6B6B);

  const SavedMealCard({
    super.key,
    required this.savedMeal,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final meal = savedMeal.foodAnalysis;
    // Use createdAt directly since it seems to be non-nullable in the model
    final date = savedMeal.createdAt;

    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal Icon with star badge
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      color: primaryGreen,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Meal Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            savedMeal.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            _getFormattedDate(date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Food description
                    Text(
                      meal.foodName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Macronutrients row
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
                    const SizedBox(height: 8),
                    // Bottom badges row
                    Row(
                      children: [
                        // Calories badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: primaryOrange,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${meal.nutritionInfo.calories.round()} cal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Health score badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getHealthScoreColor(meal.healthScore)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: _getHealthScoreColor(meal.healthScore),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Health: ${meal.healthScore.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getHealthScoreColor(meal.healthScore),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format date to show day and month
  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
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
    if (score >= 7) return primaryGreen;
    if (score >= 4) return primaryOrange;
    return primaryPink;
  }
}
