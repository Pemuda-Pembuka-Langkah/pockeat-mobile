// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/additional_nutrients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/calorie_summary_card.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_loading.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_title_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/health_score_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/ingredients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutritional_info_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/vitamins_and_minerals_section.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';

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

  void _updateFoodData(FoodAnalysisResult result, {bool isCorrection = false}) {
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
  }

  // Method to show AI correction dialog
  void _showAICorrectionDialog() {
    if (_savedMeal == null) return;

    final TextEditingController correctionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: primaryBlue),
            const SizedBox(width: 8),
            const Text('AI Correction'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe what you want to correct about this meal. For example:',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              '• "This has 300 calories, not 400"\n• "It contains less sugar, about 5g"\n• "Add broccoli as an ingredient"',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: correctionController,
              decoration: InputDecoration(
                labelText: 'Your correction',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Enter your correction...',
              ),
              minLines: 3,
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyAICorrection(correctionController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Apply Correction'),
          ),
        ],
      ),
    );
  }

  // Apply AI Correction using existing methods
  Future<void> _applyAICorrection(String correction) async {
    if (correction.isEmpty || _savedMeal == null) return;
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      setState(() {
        _isSaving = true;
      });

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Processing data...\nThis may take a moment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );

      // Use the existing method to correct the analysis
      final correctedAnalysis = await widget.savedMealService
          .correctSavedMealAnalysis(_savedMeal!, correction);

      // Close the loading dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      // Log the corrected meal as a new food analysis entry using existing method
      await widget.savedMealService.logCorrectedMealAsNew(
        _savedMeal!,
        correctedAnalysis,
      );

      setState(() {
        _isSaving = false;
      });

      // Show success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Meal corrected and logged successfully!',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Show the correction results
      _showCorrectionResultsDialog(_savedMeal!.foodAnalysis, correctedAnalysis);
    } catch (e) {
      // Close the loading dialog if it's still showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to correct meal: ${e.toString()}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Show the results of the correction
  void _showCorrectionResultsDialog(
      FoodAnalysisResult original, FoodAnalysisResult corrected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.compare_arrows, color: primaryBlue),
            const SizedBox(width: 8),
            const Text('Correction Results'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Here\'s what changed:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildComparisonRow(
                  'Calories',
                  '${original.nutritionInfo.calories.toInt()} cal',
                  '${corrected.nutritionInfo.calories.toInt()} cal'),
              _buildComparisonRow(
                  'Protein',
                  '${original.nutritionInfo.protein.toInt()} g',
                  '${corrected.nutritionInfo.protein.toInt()} g'),
              _buildComparisonRow(
                  'Carbs',
                  '${original.nutritionInfo.carbs.toInt()} g',
                  '${corrected.nutritionInfo.carbs.toInt()} g'),
              _buildComparisonRow(
                  'Fat',
                  '${original.nutritionInfo.fat.toInt()} g',
                  '${corrected.nutritionInfo.fat.toInt()} g'),
              _buildComparisonRow(
                  'Sugar',
                  '${original.nutritionInfo.sugar.toInt()} g',
                  '${corrected.nutritionInfo.sugar.toInt()} g'),

              const SizedBox(height: 12),
              const Text('Ingredients:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Original ingredients
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Original:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(original.ingredients.isEmpty
                        ? 'None'
                        : original.ingredients.map((i) => i.name).join(", ")),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Corrected ingredients
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Corrected:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(corrected.ingredients.isEmpty
                        ? 'None'
                        : corrected.ingredients.map((i) => i.name).join(", ")),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String original, String corrected) {
    final bool hasChanged = original != corrected;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            width: 80,
            child: Text(original,
                style: hasChanged
                    ? const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey)
                    : null),
          ),
          if (hasChanged)
            Icon(Icons.arrow_forward, size: 16, color: primaryBlue),
          if (hasChanged) const SizedBox(width: 4),
          Text(
            corrected,
            style: hasChanged
                ? TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Meal Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showAICorrectionDialog,
          ),
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
    );
  }

  // Method to show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Saved Meal'),
          content: const Text(
              'Are you sure you want to delete this meal? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _isLoading = true;
                });

                try {
                  await widget.savedMealService.deleteSavedMeal(widget.savedMealId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Meal deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context)
                        .pop(); // Return to the previous screen
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete meal: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
