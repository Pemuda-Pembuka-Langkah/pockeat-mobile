import 'package:flutter/material.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/macro_item.dart';

class NutritionalInfoSection extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic> nutritionData;
  final Color primaryPink;
  final Color primaryGreen;
  final Color warningYellow;

  const NutritionalInfoSection({
    Key? key,
    required this.isLoading,
    required this.nutritionData,
    required this.primaryPink,
    required this.primaryGreen,
    required this.warningYellow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutritional Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                MacroItem(
                  label: 'Protein',
                  value: isLoading ? 0 : (nutritionData['protein'] ?? 0),
                  total: 120,
                  color: primaryPink,
                  subtitle: isLoading
                      ? 'Loading...'
                      : '${(nutritionData['protein'] ?? 0) * 100 ~/ 120}% of daily goal',
                ),
                const Divider(height: 1),
                MacroItem(
                  label: 'Carbs',
                  value: isLoading ? 0 : (nutritionData['carbs'] ?? 0),
                  total: 250,
                  color: primaryGreen,
                  subtitle: isLoading
                      ? 'Loading...'
                      : '${(nutritionData['carbs'] ?? 0) * 100 ~/ 250}% of daily goal',
                ),
                const Divider(height: 1),
                MacroItem(
                  label: 'Fat',
                  value: isLoading ? 0 : (nutritionData['fat'] ?? 0),
                  total: 65,
                  color: warningYellow,
                  subtitle: isLoading
                      ? 'Loading...'
                      : '${(nutritionData['fat'] ?? 0) * 100 ~/ 65}% of daily goal',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 