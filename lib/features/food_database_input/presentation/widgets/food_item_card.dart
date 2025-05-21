// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class FoodItemCard extends StatefulWidget {
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
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  // Controller for the portion input
  late TextEditingController _portionController;

  @override
  void initState() {
    super.initState();
    _portionController =
        TextEditingController(text: widget.portion.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(FoodItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.portion != widget.portion) {
      _portionController.text = widget.portion.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  // Helper method to update the portion value
  void _updatePortionValue() {
    if (_portionController.text.isNotEmpty) {
      int? intValue = int.tryParse(_portionController.text);
      if (intValue != null && intValue >= 1 && intValue <= 1000) {
        widget.onPortionChanged(widget.index, intValue.toDouble());
      } else {
        // Reset to valid value if entered value is invalid
        _portionController.text = widget.portion.toStringAsFixed(0);
      }
    }
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
                Icon(Icons.restaurant, size: 16, color: widget.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.food.foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: widget.primaryPink),
                  onPressed: () => widget.onRemove(widget.index),
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
                            '${widget.food.nutritionInfo.calories.toStringAsFixed(0)} ',
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
                  'P: ${widget.food.nutritionInfo.protein.toStringAsFixed(1)}g • '
                  'C: ${widget.food.nutritionInfo.carbs.toStringAsFixed(1)}g • '
                  'F: ${widget.food.nutritionInfo.fat.toStringAsFixed(1)}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16), // Portion and count inputs in a row
            Row(
              children: [
                // Count input
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Count:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          controller: widget.countController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: widget.primaryGreen),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: widget.primaryGreen, width: 2),
                            ),
                            counter: const SizedBox.shrink(),
                          ),
                          maxLength: 2,
                          // No real-time updates - only update when editing is complete
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            // Calculation will happen when the focus is lost
                          },
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Portion input
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portion (grams):',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          controller: _portionController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            isDense: true,
                            suffixText: 'g',
                            suffixStyle: TextStyle(
                              color: widget.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: widget.primaryGreen),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: widget.primaryGreen, width: 2),
                            ),
                            counter: const SizedBox.shrink(),
                          ),
                          maxLength: 4,
                          // Update only when user is done editing
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            _updatePortionValue();
                          },
                          onFieldSubmitted: (_) {
                            _updatePortionValue();
                          },
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Helper text
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Enter portion size (1-1000 grams)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
