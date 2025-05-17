// Flutter imports:
import 'package:flutter/material.dart';

class CalorieSummaryCard extends StatelessWidget {
  final bool isLoading;
  final double calories; // Changed from int to double
  final Color primaryYellow;
  final Color primaryPink;

  const CalorieSummaryCard({
    super.key,
    required this.isLoading,
    required this.calories,
    required this.primaryYellow,
    required this.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
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
                      isLoading
                          ? '--'
                          : '${calories.round()}', // Round to nearest integer for display
                      key: const Key('food_calories'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Calories',
                      key: Key('food_calories_text'),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
