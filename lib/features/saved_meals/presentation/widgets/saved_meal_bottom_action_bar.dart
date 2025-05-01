// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';

class SavedMealBottomActionBar extends StatelessWidget {
  final bool isLoading;
  final SavedMeal? savedMeal;
  final SavedMealService savedMealService;
  final Color primaryYellow;
  final Color primaryPink;
  final Color primaryGreen;
  final Color primaryBlue;
  final Function(FoodAnalysisResult)? onAnalysisCorrected;
  final Function(bool)? onSavingStateChange;
  final Function()? onDelete;

  const SavedMealBottomActionBar({
    super.key,
    required this.isLoading,
    required this.savedMeal,
    required this.savedMealService,
    required this.primaryYellow,
    required this.primaryPink,
    this.primaryGreen = const Color(0xFF4ECDC4),
    this.primaryBlue = const Color(0xFF2196F3),
    this.onAnalysisCorrected,
    this.onSavingStateChange,
    this.onDelete,
  });

  void showSnackBarMessage(BuildContext context, String message,
      {Color? backgroundColor}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Correction Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isLoading ? null : () => _showCorrectionDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryBlue.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.wand_stars,
                        color: primaryBlue.withOpacity(0.8), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'AI Correction',
                      style: TextStyle(
                        color: primaryBlue.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Log This Meal Button
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isLoading || savedMeal == null
                  ? null
                  : () => _logMeal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryGreen.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add,
                        color: primaryGreen.withOpacity(0.8), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Log This Meal',
                      style: TextStyle(
                        color: primaryGreen.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCorrectionDialog(BuildContext context) {
    if (savedMeal == null) return;

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
              _applyAICorrection(context, correctionController.text.trim());
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

  Future<void> _applyAICorrection(
      BuildContext context, String correction) async {
    if (correction.isEmpty || savedMeal == null) return;

    // Capture scaffold messenger before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Signal loading state
    onSavingStateChange?.call(true);

    // Show a non-blocking snackbar instead of a modal dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Processing correction...'),
            ],
          ),
          backgroundColor: primaryBlue,
          duration:
              const Duration(seconds: 30), // Long duration, will be dismissed
        ),
      );
    });

    try {
      // Use the service to correct the analysis
      final correctedAnalysis = await savedMealService.correctSavedMealAnalysis(
          savedMeal!, correction);

      // Clear any existing snackbars
      scaffoldMessenger.hideCurrentSnackBar();

      // Update the parent with corrected analysis
      if (onAnalysisCorrected != null) {
        onAnalysisCorrected!(correctedAnalysis);
      }

      // Show success message with the captured scaffoldMessenger
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Meal corrected successfully!',
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
          duration: const Duration(seconds: 3),
        ),
      );

      // Use a boolean flag to track if we should show the comparison dialog
      bool shouldShowComparisonDialog = true;

      // Show the comparison dialog after ensuring the UI has been updated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (shouldShowComparisonDialog) {
          // We use a new context for the dialog to avoid deactivated widget errors
          _showCorrectionResultsDialogSafely(scaffoldMessenger.context,
              savedMeal!.foodAnalysis, correctedAnalysis);
        }
      });
    } catch (e) {
      //print("Error correcting meal: $e");

      // Clear any existing snackbars
      scaffoldMessenger.hideCurrentSnackBar();

      // Show error message with the captured scaffoldMessenger
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
    } finally {
      // Always signal that loading is complete
      onSavingStateChange?.call(false);
    }
  }

  // A safer version of showing the correction results dialog
  void _showCorrectionResultsDialogSafely(BuildContext context,
      FoodAnalysisResult original, FoodAnalysisResult corrected) {
    // Only show if context is still valid
    if (context is Element && context.mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
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

                // Original vs corrected ingredients comparison
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Original:',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700])),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              original.ingredients.isEmpty
                                  ? 'No ingredients'
                                  : original.ingredients
                                      .map((i) => i.name)
                                      .join(', '),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Corrected:',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700])),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              corrected.ingredients.isEmpty
                                  ? 'No ingredients'
                                  : corrected.ingredients
                                      .map((i) => i.name)
                                      .join(', '),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildComparisonRow(String label, String original, String corrected) {
    final bool hasChanged = original != corrected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              original,
              style: TextStyle(
                decoration: hasChanged ? TextDecoration.lineThrough : null,
                color: hasChanged ? Colors.grey : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (hasChanged)
            const Icon(Icons.arrow_forward, size: 14, color: Colors.grey)
          else
            const SizedBox(width: 14),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              corrected,
              style: TextStyle(
                fontWeight: hasChanged ? FontWeight.bold : FontWeight.normal,
                color: hasChanged ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    if (savedMeal == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: primaryPink),
            const SizedBox(width: 8),
            const Text('Confirm Delete'),
          ],
        ),
        content: Text(
            'Are you sure you want to delete "${savedMeal!.foodAnalysis.foodName}"?'),
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
              _deleteMeal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMeal(BuildContext context) async {
    if (savedMeal == null) return;

    onSavingStateChange?.call(true);

    try {
      showSnackBarMessage(context, 'Deleting meal...',
          backgroundColor: Colors.orange);

      await savedMealService.deleteSavedMeal(savedMeal!.id);

      if (!context.mounted) return;

      showSnackBarMessage(context, 'Meal deleted successfully!',
          backgroundColor: primaryGreen);

      // Call the onDelete callback if provided
      onDelete?.call();

      // Navigate back after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      if (!context.mounted) return;
      showSnackBarMessage(context, 'Failed to delete meal: ${e.toString()}',
          backgroundColor: Colors.red);
    } finally {
      onSavingStateChange?.call(false);
    }
  }

  Future<void> _logMeal(BuildContext context) async {
    if (savedMeal == null) return;

    onSavingStateChange?.call(true);

    try {
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
                'Logging meal...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );

      // Use the service to log the food analysis
      await savedMealService.logFoodAnalysis(savedMeal!.foodAnalysis);

      // Close the loading dialog
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Meal logged successfully!',
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

      // Navigate to food history page after successful logging
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          // Pop current screen
          Navigator.of(context).pop();

          // Navigate to analytics page with food history tab (index 1) open
          Navigator.of(context)
              .pushNamed('/analytic', arguments: {'initialTabIndex': 1});
        }
      });
    } catch (e) {
      // Close the loading dialog if it's still showing
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to log meal: ${e.toString()}',
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
    } finally {
      onSavingStateChange?.call(false);
    }
  }
}
