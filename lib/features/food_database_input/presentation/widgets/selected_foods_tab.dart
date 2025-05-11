// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/food_item_card.dart';

class SelectedFoodsTab extends StatelessWidget {
  final TextEditingController mealNameController;
  final List<FoodAnalysisResult> selectedFoods;
  final List<TextEditingController> componentCountControllers;
  final Map<int, double> portionValues;
  final GlobalKey<FormState> formKey;
  final Function() onCreateMeal;
  final Function() onClearAll;
  final Function(int) onRemoveFood;
  final Function(int, double) onAdjustPortion;
  final Function() onGoToSearchTab;
  final Color primaryYellow;
  final Color primaryPink;
  final Color primaryGreen;

  const SelectedFoodsTab({
    super.key,
    required this.mealNameController,
    required this.selectedFoods,
    required this.componentCountControllers,
    required this.portionValues,
    required this.formKey,
    required this.onCreateMeal,
    required this.onClearAll,
    required this.onRemoveFood,
    required this.onAdjustPortion,
    required this.onGoToSearchTab,
    required this.primaryYellow,
    required this.primaryPink,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal name input
          Form(
            key: formKey,
            child: TextFormField(
              controller: mealNameController,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                hintText: 'Enter a name for your meal',
                prefixIcon: Icon(Icons.restaurant_menu, color: primaryGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              // coverage:ignore-line
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a meal name';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 16),

          // Selected foods header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Foods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${selectedFoods.length} items selected',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Selected foods list
          Expanded(
            child: selectedFoods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.no_food,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No foods selected yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: onGoToSearchTab,
                          icon: const Icon(Icons.search),
                          label: const Text('Search Foods'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedFoods.length,
                    itemBuilder: (context, index) {
                      final food = selectedFoods[index];
                      // coverage:ignore-line
                      final portion = portionValues[index] ??
                          (food.ingredients.isNotEmpty
                              ? food.ingredients[0].servings
                              : 100.0);

                      return FoodItemCard(
                        food: food,
                        index: index,
                        portion: portion,
                        countController: componentCountControllers[index],
                        onPortionChanged: onAdjustPortion,
                        onRemove: onRemoveFood,
                        primaryGreen: primaryGreen,
                        primaryPink: primaryPink,
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectedFoods.isEmpty ? null : onCreateMeal,
                  icon: const Icon(Icons.create),
                  label: const Text('Create Meal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onClearAll,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryPink,
                  side: BorderSide(color: primaryPink),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
