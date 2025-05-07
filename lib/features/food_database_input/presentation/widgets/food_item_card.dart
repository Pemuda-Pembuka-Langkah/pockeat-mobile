// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class FoodItemCard extends StatelessWidget {
  final FoodAnalysisResult food;
  final int index;
  final double portion;
  final TextEditingController countController;
  final Function(int, double) onPortionChanged;
  final Function(int) onRemove;
  final Color primaryGreen;
  final Color primaryPink;

  const FoodItemCard({
    super.key,
    required this.food,
    required this.index,
    required this.portion,
    required this.countController,
    required this.onPortionChanged,
    required this.onRemove,
    required this.primaryGreen,
    required this.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food header with name and delete button
            Row(
              children: [
                Icon(Icons.restaurant, size: 16, color: primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    food.foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: primaryPink),
                  onPressed: () => onRemove(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              ],
            ),

            const Divider(),

            // Nutrition summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text:
                            '${food.nutritionInfo.calories.toStringAsFixed(0)} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: 'kcal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'P: ${food.nutritionInfo.protein.toStringAsFixed(1)}g • '
                  'C: ${food.nutritionInfo.carbs.toStringAsFixed(1)}g • '
                  'F: ${food.nutritionInfo.fat.toStringAsFixed(1)}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Portion row with count input
            Row(
              children: [
                Text(
                  'Portion:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${portion.toStringAsFixed(1)}g',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Count:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 50,
                  height: 32,
                  child: TextFormField(
                    controller: countController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: primaryGreen),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: primaryGreen, width: 2),
                      ),
                      counter: const SizedBox.shrink(),
                    ),
                    maxLength: 2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Portion slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primaryGreen,
                inactiveTrackColor: primaryGreen.withOpacity(0.2),
                thumbColor: primaryGreen,
                overlayColor: primaryGreen.withOpacity(0.3),
                trackHeight: 4.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                min: 10,
                max: 500,
                divisions: 49,
                value: portion,
                onChanged: (value) => onPortionChanged(index, value),
              ),
            ),

            // Portion size indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '10g',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  '100g',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: portion <= 150 && portion >= 50
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  '250g',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: portion <= 300 && portion >= 200
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  '500g',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
