import 'package:flutter/material.dart';

class AdditionalNutrientsSection extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic> nutritionData;
  final int calories;
  final Color primaryYellow;

  const AdditionalNutrientsSection({
    super.key,
    required this.isLoading,
    required this.nutritionData,
    required this.calories,
    required this.primaryYellow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: _buildNutrientsGrid(),
    );
  }

  Widget _buildNutrientsGrid() {
    final nutrients = [
      {
        'name': 'Fiber',
        'value': isLoading ? '0g' : '${nutritionData['fiber'] ?? 0}g',
        'goal': '25g'
      },
      {
        'name': 'Sugar',
        'value': isLoading ? '0g' : '${nutritionData['sugar'] ?? 0}g',
        'goal': '25g'
      },
      {
        'name': 'Sodium',
        'value': isLoading ? '0mg' : '${nutritionData['sodium'] ?? 0}mg',
        'goal': '2300mg'
      },
      {
        'name': 'Calories',
        'value': isLoading ? '0' : '$calories',
        'goal': '2000'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: nutrients.length,
      itemBuilder: (context, index) {
        final nutrient = nutrients[index];
        return _buildNutrientItem(nutrient);
      },
    );
  }

  Widget _buildNutrientItem(Map<String, String> nutrient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryYellow.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            nutrient['name']!,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nutrient['value']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
