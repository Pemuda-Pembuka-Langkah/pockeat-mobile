import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/meal_row_widget.dart';

class MealPatternsWidget extends StatelessWidget {
  final List<Meal> meals;
  final Color primaryGreen;

  const MealPatternsWidget({
    Key? key,
    required this.meals,
    required this.primaryGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meal Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Well Balanced',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < meals.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                MealRowWidget(meal: meals[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}