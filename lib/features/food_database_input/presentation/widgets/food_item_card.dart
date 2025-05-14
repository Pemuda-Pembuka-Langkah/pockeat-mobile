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
  // Helper method to build marker labels
  Widget _buildMarker(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[600],
        fontWeight: text == '10g' || text == '500g'
            ? FontWeight.bold
            : FontWeight.normal,
      ),
    );
  }

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

            const SizedBox(
                height:
                    12), // Centered slider (improved touch target with fixed center thumb)
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  // Slider usage hint
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Hold and Drag slider to adjust portion',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ), // Standard Flutter Slider with enhanced appearance
                  SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 4.0,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 12.0,
                        pressedElevation: 8.0,
                      ),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: 24.0,
                      ),
                      tickMarkShape: RoundSliderTickMarkShape(
                        tickMarkRadius: 2.0,
                      ),
                      showValueIndicator: ShowValueIndicator.always,
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      valueIndicatorTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Slider(
                      min: 10,
                      max: 500,
                      value: portion,
                      divisions: 49,
                      activeColor: primaryGreen,
                      inactiveColor: primaryGreen.withOpacity(0.2),
                      label: '${portion.toStringAsFixed(0)}g',
                      onChanged: (value) => onPortionChanged(index, value),
                    ),
                  ),

                  // Key markers for better understanding of the scale
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, left: 12.0, right: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMarker('10g'),
                        _buildMarker('100g'),
                        _buildMarker('250g'),
                        _buildMarker('400g'),
                        _buildMarker('500g'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
