import 'package:flutter/material.dart';

class HealthScoreIndicator extends StatelessWidget {
  final double score;
  final Color primaryGreen;
  final Color primaryPink;

  const HealthScoreIndicator({
    Key? key,
    required this.score,
    required this.primaryGreen,
    required this.primaryPink,
  }) : super(key: key);

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

    return Container(
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
        ],
      ),
    );
  }
}
