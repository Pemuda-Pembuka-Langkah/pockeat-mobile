import 'package:flutter/material.dart';

class CalorieSummaryCard extends StatelessWidget {
  final bool isLoading;
  final double calories;
  final Color primaryYellow;
  final Color primaryPink;

  const CalorieSummaryCard({
    Key? key,
    required this.isLoading,
    required this.calories,
    required this.primaryYellow,
    required this.primaryPink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryYellow.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? '--' : '$calories',
                      key: const Key('food_calories'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'calories',
                      key: Key('food_calories_text'),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '22% of daily goal',
                    key: Key('food_calories_goal'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.22,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(primaryPink),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 