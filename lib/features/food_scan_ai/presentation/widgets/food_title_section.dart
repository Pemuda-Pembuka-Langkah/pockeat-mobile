// Flutter imports:
import 'package:flutter/material.dart';

class FoodTitleSection extends StatelessWidget {
  final bool isLoading;
  final String foodName;
  final Color primaryGreen;
  final double? healthScore; // Add healthScore parameter
  final String? healthCategory; // Add health category parameter

  const FoodTitleSection({
    super.key,
    required this.isLoading,
    required this.foodName,
    required this.primaryGreen,
    this.healthScore, // Optional parameter
    this.healthCategory, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? 'Analyzing...' : foodName,
                      key: const Key('food_title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                      softWrap: true,
                    ),

                    // Only show health score if available and not loading
                    if (!isLoading && healthScore != null) ...[
                      const SizedBox(height: 8),
                      _buildHealthScoreChip(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Create a separate widget for the health score display
  Widget _buildHealthScoreChip() {
    // Choose color based on health score
    Color scoreColor;
    if (healthScore! >= 7.0) {
      scoreColor = primaryGreen;
    } else if (healthScore! >= 4.0) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scoreColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite,
            color: scoreColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${healthScore!.toStringAsFixed(1)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
          if (healthCategory != null) ...[
            const SizedBox(width: 4),
            Text(
              '($healthCategory)',
              style: TextStyle(
                fontSize: 12,
                color: scoreColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
