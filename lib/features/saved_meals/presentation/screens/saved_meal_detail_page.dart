// Flutter imports:
//coverage:ignore-file
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/additional_nutrients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/calorie_summary_card.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_title_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/health_score_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/ingredients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutritional_info_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/vitamins_and_minerals_section.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';
import 'package:pockeat/features/saved_meals/presentation/widgets/saved_meal_bottom_action_bar.dart';


class SavedMealDetailPage extends StatefulWidget {
  final String savedMealId;
  final SavedMealService savedMealService;

  const SavedMealDetailPage({
    Key? key,
    required this.savedMealId,
    required this.savedMealService,
  }) : super(key: key);

  @override
  _SavedMealDetailPageState createState() => _SavedMealDetailPageState();
}

class _SavedMealDetailPageState extends State<SavedMealDetailPage> {
  bool _isScrolledToTop = true;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isSaving = false;
  String _foodName = 'Loading...';
  double _calories = 0;
  Map<String, dynamic> _nutritionData = {};
  List<String> _warnings = [];
  List<Ingredient> _ingredients = [];
  FoodAnalysisResult? food;
  SavedMeal? _savedMeal;

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color warningYellow = const Color(0xFFF4D03F);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadMealDetails());
  }

  Future<void> _loadMealDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final result =
          await widget.savedMealService.getSavedMeal(widget.savedMealId);

      if (result == null) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      setState(() {
        _savedMeal = result;
        _updateFoodData(result.foodAnalysis);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Meal Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmationDialog,
            tooltip: 'Delete meal',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  FoodTitleSection(
                    isLoading: _isLoading,
                    foodName: _foodName,
                    primaryGreen: primaryGreen,
                    healthScore: _nutritionData['healthScore'] as double?,
                    healthCategory:
                        _nutritionData['healthScoreCategory'] as String?,
                  ),
                  CalorieSummaryCard(
                    isLoading: _isLoading,
                    calories: _calories,
                    primaryYellow: primaryYellow,
                    primaryPink: primaryPink,
                  ),
                  HealthScoreSection(
                    isLoading: _isLoading,
                    nutritionData: _nutritionData,
                    primaryGreen: primaryGreen,
                    primaryPink: primaryPink,
                  ),
                  NutritionalInfoSection(
                    isLoading: _isLoading,
                    nutritionData: _nutritionData,
                    primaryPink: primaryPink,
                    primaryGreen: primaryGreen,
                    warningYellow: warningYellow,
                  ),
                  AdditionalNutrientsSection(
                    isLoading: _isLoading,
                    nutritionData: _nutritionData,
                    calories: _calories,
                    primaryYellow: primaryYellow,
                  ),
                  IngredientsSection(
                    ingredients: _ingredients,
                    primaryGreen: primaryGreen,
                    isLoading: _isLoading,
                  ),
                  VitaminsAndMineralsSection(
                    isLoading: _isLoading,
                    food: food,
                    primaryColor: primaryGreen,
                  ),
                  DietTagsSection(
                    warnings: _warnings,
                    primaryGreen: primaryGreen,
                    warningYellow: warningYellow,
                  ),
                  const SizedBox(height: 100),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _savedMeal == null || _isLoading
          ? null
          : SavedMealBottomActionBar(
              isLoading: _isSaving,
              savedMeal: _savedMeal,
              savedMealService: widget.savedMealService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: primaryGreen,
              primaryBlue: primaryBlue,
              // Simplified callback handling like in NutritionPage
              onAnalysisCorrected: (correctedAnalysis) {
                setState(() {
                  // Update saved meal with corrected analysis
                  _savedMeal =
                      _savedMeal!.copyWith(foodAnalysis: correctedAnalysis);
                  // Update all UI data
                  _updateFoodData(correctedAnalysis, isCorrection: true);
                });
              },
              onSavingStateChange: (isSaving) {
                setState(() {
                  _isSaving = isSaving;
                });
              },
              onDelete: () {
                Navigator.of(context).pop();
              },
            ),
    );
  }

  // Method to show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a separate BuildContext for the dialog
        return AlertDialog(
          title: const Text('Delete Saved Meal'),
          content: const Text(
              'Are you sure you want to delete this meal? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Close the dialog first
                Navigator.of(dialogContext).pop();

                // Then perform the deletion
                _deleteMealAndNavigateBack(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Separate method to delete meal and navigate back
  Future<void> _deleteMealAndNavigateBack(BuildContext outerContext) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.savedMealService.deleteSavedMeal(widget.savedMealId);

      // Use the provided context for navigation
      if (outerContext.mounted) {
        ScaffoldMessenger.of(outerContext).showSnackBar(
          const SnackBar(
            content: Text('Meal deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to the saved meals page
        Navigator.of(outerContext).pushNamedAndRemoveUntil(
          '/saved-meals',
          (route) => false,
        );
      }
    } catch (e) {
      // Only show error if we're still mounted
      if (outerContext.mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(outerContext).showSnackBar(
          SnackBar(
            content: Text('Failed to delete meal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateFoodData(FoodAnalysisResult result, {bool isCorrection = false}) {
    setState(() {
      _foodName = result.foodName;
      _calories = result.nutritionInfo.calories;
      _nutritionData = {
        'protein': result.nutritionInfo.protein,
        'carbs': result.nutritionInfo.carbs,
        'fat': result.nutritionInfo.fat,
        'fiber': result.nutritionInfo.fiber,
        'sugar': result.nutritionInfo.sugar,
        'sodium': result.nutritionInfo.sodium,
        'saturatedFat': result.nutritionInfo.saturatedFat,
        'cholesterol': result.nutritionInfo.cholesterol,
        'nutritionDensity': result.nutritionInfo.nutritionDensity,
        'healthScore': result.healthScore,
        'healthScoreCategory': result.getHealthScoreCategory(),
      };
      _ingredients = result.ingredients;
      _warnings = result.warnings;
      food = result;

      if (!isCorrection) {
        _isLoading = false;
      }
    });
  }
}
