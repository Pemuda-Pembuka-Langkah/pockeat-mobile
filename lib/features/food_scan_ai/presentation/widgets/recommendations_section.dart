// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecommendationsSection extends StatelessWidget {
  final Color primaryYellow;
  final Color primaryPink;

  const RecommendationsSection({
    super.key,
    required this.primaryYellow,
    required this.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.lightbulb_fill,
                  color: primaryPink,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add a side of vegetables to increase your fiber intake and reach your daily nutrition goals.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
