// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class FoodSummaryCard extends StatelessWidget {
  final FoodAnalysisResult food;
  final GlobalKey cardKey;

  const FoodSummaryCard({
    super.key,
    required this.food,
    required this.cardKey,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate macronutrient percentages
    final totalCarbs = food.nutritionInfo.carbs.toInt();
    final totalProtein = food.nutritionInfo.protein.toInt();
    final totalFat = food.nutritionInfo.fat.toInt();
    final totalMacros = totalCarbs + totalProtein + totalFat;

    final carbPercentage =
        totalMacros > 0 ? (totalCarbs / totalMacros) * 100 : 0;
    final proteinPercentage =
        totalMacros > 0 ? (totalProtein / totalMacros) * 100 : 0;
    final fatPercentage = totalMacros > 0 ? (totalFat / totalMacros) * 100 : 0;

    // Make flexes at least 1 to avoid zero-sized divisions
    final carbFlex = carbPercentage.toInt() < 1 ? 1 : carbPercentage.toInt();
    final proteinFlex =
        proteinPercentage.toInt() < 1 ? 1 : proteinPercentage.toInt();
    final fatFlex = fatPercentage.toInt() < 1 ? 1 : fatPercentage.toInt();

    return RepaintBoundary(
      key: cardKey,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PockEat branding
            Row(
              children: [
                Image.asset(
                  'assets/icons/Logo_PockEat_draft_transparent.png',
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'PockEat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Color(0xFFFF9800),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${food.nutritionInfo.calories.toInt()} cal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Food name
            Text(
              food.foodName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Macronutrient bar
            const Text(
              'Macronutrients',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    Expanded(
                      flex: carbFlex,
                      child: Container(color: Colors.amber),
                    ),
                    Expanded(
                      flex: proteinFlex,
                      child: Container(color: const Color(0xFF2196F3)),
                    ),
                    Expanded(
                      flex: fatFlex,
                      child: Container(color: const Color(0xFFE57373)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Macronutrient details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacronutrientItem('Carbs', '$totalCarbs g', Colors.amber),
                _buildMacronutrientItem(
                    'Protein', '$totalProtein g', const Color(0xFF2196F3)),
                _buildMacronutrientItem(
                    'Fat', '$totalFat g', const Color(0xFFE57373)),
              ],
            ),
            const SizedBox(height: 16),

            // Additional details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNutrientItem(
                    'Sodium', '${food.nutritionInfo.sodium.toInt()} mg'),
                _buildNutrientItem(
                    'Fiber', '${food.nutritionInfo.fiber.toInt()} g'),
                _buildNutrientItem(
                    'Sugar', '${food.nutritionInfo.sugar.toInt()} g'),
              ],
            ),

            // Warning section (if any)
            if (food.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        food.warnings.first,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Footer branding
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'tracked with PockEat',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacronutrientItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label[0],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
