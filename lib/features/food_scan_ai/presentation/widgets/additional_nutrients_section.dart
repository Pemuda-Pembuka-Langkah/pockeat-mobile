// Flutter imports:
import 'package:flutter/material.dart';

class AdditionalNutrientsSection extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic> nutritionData;
  final double calories; // Changed from int to double
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Nutrients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildNutrientChip(
                    icon: Icons.water_drop,
                    label: 'Sodium',
                    value: isLoading
                        ? '0'
                        : '${(nutritionData['sodium'] ?? 0).toStringAsFixed(0)}',
                    unit: 'mg',
                    color: Colors.blue,
                  ),
                  _buildNutrientChip(
                    icon: Icons.grass,
                    label: 'Fiber',
                    value: isLoading
                        ? '0'
                        : '${(nutritionData['fiber'] ?? 0).toStringAsFixed(1)}',
                    unit: 'g',
                    color: Colors.green,
                  ),
                  _buildNutrientChip(
                    icon: Icons.icecream,
                    label: 'Sugar',
                    value: isLoading
                        ? '0'
                        : '${(nutritionData['sugar'] ?? 0).toStringAsFixed(1)}',
                    unit: 'g',
                    color: Colors.pink,
                  ),
                  _buildNutrientChip(
                    icon: Icons.opacity,
                    label: 'Saturated Fat',
                    value: isLoading
                        ? '0'
                        : '${(nutritionData['saturatedFat'] ?? 0).toStringAsFixed(1)}',
                    unit: 'g',
                    color: Colors.orange,
                  ),
                  _buildNutrientChip(
                    icon: Icons.medical_information,
                    label: 'Cholesterol',
                    value: isLoading
                        ? '0'
                        : '${(nutritionData['cholesterol'] ?? 0).toStringAsFixed(0)}',
                    unit: 'mg',
                    color: Colors.purple,
                  ),
                  _buildNutrientChip(
                    icon: Icons.star,
                    label: 'Nutrition Density',
                    value: isLoading
                        ? '0'
                        : '${(nutritionData['nutritionDensity'] ?? 0).toStringAsFixed(1)}',
                    unit: '',
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: $value$unit',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
