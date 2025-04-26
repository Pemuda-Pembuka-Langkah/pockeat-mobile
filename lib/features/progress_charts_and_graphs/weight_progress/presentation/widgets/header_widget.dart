// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';

class HeaderWidget extends StatelessWidget {
  final WeightStatus weightStatus;
  final Color primaryPink;

  const HeaderWidget({
    super.key,
    required this.weightStatus,
    required this.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Weight Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                _buildAchievementBadge(),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Last 30 days',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        _buildBMIIndicator(weightStatus.bmiValue, weightStatus.bmiCategory),
      ],
    );
  }

  Widget _buildAchievementBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: primaryPink, size: 14),
          const SizedBox(width: 4),
          Text(
            'Consistent',
            style: TextStyle(
              color: primaryPink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIIndicator(double bmi, String category) {
    Color color;

    if (category == 'Underweight') {
      color = const Color(0xFFFFB946);
    } else if (category == 'Healthy') {
      color = const Color(0xFF4ECDC4);
    } else if (category == 'Overweight') {
      color = const Color(0xFFFFB946);
    } else {
      color = primaryPink;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            category,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
