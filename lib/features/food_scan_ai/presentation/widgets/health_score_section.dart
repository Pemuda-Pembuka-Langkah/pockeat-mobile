// Flutter imports:
import 'package:flutter/material.dart';

class HealthScoreSection extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic> nutritionData;
  final Color primaryGreen;
  final Color primaryPink;

  const HealthScoreSection({
    super.key,
    required this.isLoading,
    required this.nutritionData,
    required this.primaryGreen,
    required this.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || !nutritionData.containsKey('healthScore')) {
      return const SizedBox.shrink(); // Don't show if loading or data not available
    }

    final double healthScore = nutritionData['healthScore'] ?? 0.0;
    final String category = nutritionData['healthScoreCategory'] ?? 'Unknown';

    // Determine color based on score
    Color scoreColor;
    if (healthScore >= 7) {
      scoreColor = primaryGreen;
    } else if (healthScore >= 4) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = primaryPink;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Score',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: scoreColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${healthScore.toStringAsFixed(1)}/10',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getHealthScoreDescription(category),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHealthScoreDescription(String category) {
    switch (category) {
      case "Excellent":
        return "This food has excellent nutritional value with a great balance of nutrients.";
      case "Good":
        return "This food has good nutritional value and fits well into a balanced diet.";
      case "Fair":
        return "This food has acceptable nutritional value but should be consumed in moderation.";
      case "Poor":
        return "This food has limited nutritional value. Consider balancing with healthier options.";
      case "Very Poor":
        return "This food has very low nutritional value. Best consumed occasionally and in small amounts.";
      default:
        return "No health score information available for this food.";
    }
  }
}