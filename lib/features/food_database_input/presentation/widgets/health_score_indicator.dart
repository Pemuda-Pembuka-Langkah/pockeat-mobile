// Flutter imports:
import 'package:flutter/material.dart';

class HealthScoreIndicator extends StatelessWidget {
  final double score;
  final Color primaryGreen;
  final Color primaryPink;

  const HealthScoreIndicator({
    super.key,
    required this.score,
    required this.primaryGreen,
    required this.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    String category;

    if (score >= 7) {
      scoreColor = primaryGreen;
      category = 'Good';
      // coverage:ignore-line
    } else if (score >= 4) {
      scoreColor = Colors.orange;
      category = 'Moderate';
    } else {
      // coverage:ignore-line
      scoreColor = primaryPink;
      category = 'Poor';
    }
//coverage:ignore-start
    return Tooltip(
      message: _getHealthScoreCalculationExplanation(),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 14),
      padding: const EdgeInsets.all(12),
      preferBelow: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scoreColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scoreColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, size: 18, color: scoreColor),
            const SizedBox(width: 6),
            Text(
              'Health: ${score.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($category)',
              style: TextStyle(
                fontSize: 12,
                color: scoreColor,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.info_outline,
              size: 14,
              color: scoreColor,
            ),
          ],
        ),
      ),
    );
  }

  // Health score calculation explanation
  String _getHealthScoreCalculationExplanation() {
    return 'How the Health Score is Calculated:\n\n'
        '• Base score starts at 7.5 out of 10\n\n'
        'Deductions:\n'
        '• High sodium (>500mg): up to -3.0 points\n'
        '• High sugar (>20g): up to -2.5 points\n'
        '• High fat (>15g): up to -1.5 points\n'
        '• High saturated fat ratio: up to -1.0 point\n'
        '• High cholesterol (>200mg): up to -1.0 point\n\n'
        'Bonuses:\n'
        '• Protein content: up to +1.5 points\n'
        '• Fiber content: up to +1.0 point\n'
        '• Nutrition density: up to +1.0 point\n\n'
        'Final score is rounded to nearest 0.5 and clamped between 1.0 and 10.0';
  }
}
//coverage:ignore-end