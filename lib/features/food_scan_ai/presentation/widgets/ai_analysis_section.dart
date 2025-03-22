import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AIAnalysisSection extends StatelessWidget {
  final Color primaryGreen;

  const AIAnalysisSection({
    super.key,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.sparkles, color: primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'AI Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• High protein content aligns well with your fitness goals\n'
              '• Consider adding vegetables to increase fiber intake\n'
              '• Sodium content is within your daily limit\n'
              '• Good pre-workout meal option',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 