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
    return GestureDetector(
      onTap: () => _showHealthScoreExplanationDialog(context),
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

  // Health score explanation dialog
  void _showHealthScoreExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Health Score Calculation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Base Score:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Text('• Starts at 7.5 out of 10'),
                    const SizedBox(height: 12),
                    const Text(
                      'Deductions:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Text('• High sodium (>500mg): up to -3.0 points'),
                    const Text('• High sugar (>20g): up to -2.5 points'),
                    const Text('• High fat (>15g): up to -1.5 points'),
                    const Text('• High saturated fat ratio: up to -1.0 point'),
                    const Text('• High cholesterol (>200mg): up to -1.0 point'),
                    const SizedBox(height: 12),
                    const Text(
                      'Bonuses:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Text('• Protein content: up to +1.5 points'),
                    const Text('• Fiber content: up to +1.0 point'),
                    const Text('• Nutrition density: up to +1.0 point'),
                    const SizedBox(height: 12),
                    const Text(
                      'Note: Final score is rounded to nearest 0.5 and clamped between 1.0 and 10.0',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          'Got it',
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
//coverage:ignore-end
