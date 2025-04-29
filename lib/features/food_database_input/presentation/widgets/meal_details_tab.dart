import 'package:flutter/material.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/food_consumption_item.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/health_score_indicator.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/macro_distribution_bar.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/nutrient_item.dart';

class MealDetailsTab extends StatelessWidget {
  final FoodAnalysisResult? currentMeal;
  final List<FoodAnalysisResult> selectedFoods;
  final bool isLoading;
  final Function() onSaveMeal;
  final Function() onClearMeal;
  final Function() onGoToCreateMeal;
  final Function(DateTime) formatDate;
  final Function(String) formatNutrientName;
  final Color primaryYellow;
  final Color primaryPink;
  final Color primaryGreen;

  const MealDetailsTab({
    Key? key,
    required this.currentMeal,
    required this.selectedFoods,
    required this.isLoading,
    required this.onSaveMeal,
    required this.onClearMeal,
    required this.onGoToCreateMeal,
    required this.formatDate,
    required this.formatNutrientName,
    required this.primaryYellow,
    required this.primaryPink,
    required this.primaryGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentMeal == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_meals,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No meal created yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select foods and create a meal first',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onGoToCreateMeal,
              icon: const Icon(Icons.add),
              label: const Text('Create New Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Handle the navigation to food history
    void handleSaveMeal() {
      onSaveMeal();
      // After successful meal logging, navigate to analytics with food history tab
      Navigator.of(context).popAndPushNamed('/analytic', 
          arguments: {'initialTabIndex': 1});
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header with name and health score
          Row(
            children: [
              Expanded(
                child: Text(
                  currentMeal!.foodName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              HealthScoreIndicator(
                score: currentMeal!.healthScore,
                primaryGreen: primaryGreen,
                primaryPink: primaryPink,
              ),
            ],
          ),

          Text(
            'Created ${formatDate(currentMeal!.timestamp)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 24),

          // Macronutrient distribution
          MacroDistributionBar(
            nutrition: currentMeal!.nutritionInfo,
            primaryGreen: primaryGreen,
            primaryPink: primaryPink,
          ),

          const SizedBox(height: 20),

          // Nutrition summary cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutritional Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NutrientItem(
                            label: 'Calories',
                            value:
                                '${currentMeal!.nutritionInfo.calories.toStringAsFixed(0)} kcal',
                            icon: Icons.local_fire_department,
                            color: Colors.red,
                          ),
                          NutrientItem(
                            label: 'Protein',
                            value:
                                '${currentMeal!.nutritionInfo.protein.toStringAsFixed(2)}g',
                            icon: Icons.fitness_center,
                            color: Colors.blue,
                          ),
                          NutrientItem(
                            label: 'Carbs',
                            value:
                                '${currentMeal!.nutritionInfo.carbs.toStringAsFixed(2)}g',
                            icon: Icons.grain,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NutrientItem(
                            label: 'Fat',
                            value:
                                '${currentMeal!.nutritionInfo.fat.toStringAsFixed(2)}g',
                            icon: Icons.opacity,
                            color: Colors.orange,
                          ),
                          NutrientItem(
                            label: 'Fiber',
                            value:
                                '${currentMeal!.nutritionInfo.fiber.toStringAsFixed(2)}g',
                            icon: Icons.grass,
                            color: Colors.lightGreen,
                          ),
                          NutrientItem(
                            label: 'Sugar',
                            value:
                                '${currentMeal!.nutritionInfo.sugar.toStringAsFixed(2)}g',
                            icon: Icons.icecream,
                            color: Colors.purple,
                          ),
                          NutrientItem(
                            label: 'Sodium',
                            value:
                                '${currentMeal!.nutritionInfo.sodium.toStringAsFixed(2)}mg',
                            icon: Icons.water_drop,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Warnings section
          if (currentMeal!.warnings.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryPink.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: primaryPink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nutrition Warnings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...currentMeal!.warnings.map((warning) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryPink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                warning,
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Foods in this meal section
          Text(
            'Foods in this Meal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                ...currentMeal!.ingredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  // Find the matching selected food for more details
                  FoodAnalysisResult? food;
                  if (index < selectedFoods.length) {
                    food = selectedFoods[index];
                  }

                  return Column(
                    children: [
                      FoodConsumptionItem(
                        food: food ??
                            FoodAnalysisResult(
                              foodName: ingredient.name,
                              ingredients: [ingredient],
                              nutritionInfo: NutritionInfo(
                                calories: 0,
                                protein: 0,
                                carbs: 0,
                                fat: 0,
                                saturatedFat: 0,
                                sodium: 0,
                                fiber: 0,
                                sugar: 0,
                                cholesterol: 0,
                                nutritionDensity: 0,
                                vitaminsAndMinerals: {},
                              ),
                              warnings: [],
                              id: '',
                              userId: '',
                              timestamp: DateTime.now(),
                              additionalInformation: {},
                            ),
                        totalCalories: currentMeal!.nutritionInfo.calories,
                      ),
                      if (index < currentMeal!.ingredients.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Additional nutrient details expandable card
          ExpansionTile(
            title: Text(
              'Vitamins & Minerals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            backgroundColor: Colors.grey[50],
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      currentMeal!.nutritionInfo.vitaminsAndMinerals.entries
                          .where((entry) => entry.value > 0)
                          .map((entry) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '${formatNutrientName(entry.key)}: ${entry.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ))
                          .toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : handleSaveMeal, // Use the new handler instead of onSaveMeal
                  icon: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(isLoading ? 'Saving...' : 'Log Meal'),
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
                onPressed: onClearMeal,
                icon: const Icon(Icons.refresh),
                label: const Text('Start Over'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryPink,
                  side: BorderSide(color: primaryPink),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
