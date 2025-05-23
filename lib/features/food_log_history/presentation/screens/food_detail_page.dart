// Flutter imports:
//coverage: ignore-file

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_log_history/utils/food_sharing_extension.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/health_score_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/vitamins_and_minerals_section.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';

//coverage: ignore-file

/// A page that displays detailed information about a food item.
///
class FoodDetailPage extends StatefulWidget {
  final String foodId;
  final FoodScanRepository foodRepository;
  final FoodTextInputRepository foodTextInputRepository;
  final FoodTrackingClientController? foodTrackingController;

  const FoodDetailPage({
    super.key,
    required this.foodId,
    required this.foodRepository,
    required this.foodTextInputRepository,
    this.foodTrackingController,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late Future<FoodAnalysisResult?> _foodFuture;
  bool _isLoading = false;
  bool _isSaved = false;

  // Colors
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color primaryOrange = const Color(0xFFFF9800);
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color primaryRed = const Color(0xFFE57373);

  @override
  void initState() {
    super.initState();
    _loadFoodDetails();
  }

  void _loadFoodDetails() {
    setState(() {
      _foodFuture = _fetchFoodDetailsAndCheckSaved();
    });
  }

  Future<FoodAnalysisResult?> _fetchFoodDetailsAndCheckSaved() async {
    try {
      final result = await widget.foodRepository.getById(widget.foodId);

      if (result != null) {
        // Check if this meal is already saved
        await _checkIfMealIsSaved(result.id);
      }

      return result;
    } catch (e) {
      throw Exception('Failed to load food details: $e');
    }
  }

  Future<void> _checkIfMealIsSaved(String foodId) async {
    try {
      final savedMealService = GetIt.instance<SavedMealService>();
      final isSaved = await savedMealService.isMealSaved(foodId);

      if (mounted) {
        setState(() {
          _isSaved = isSaved;
        });
      }
    } catch (e) {
      // Silently handle the error - default to not saved
      debugPrint('Error checking if meal is saved: $e');
    }
  }

  Future<void> _deleteFood() async {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      setState(() {
        _isLoading = true;
      });

      // No need to show a separate loading dialog since we're already showing a loading state
      // in the UI with _isLoading = true

      bool success = await widget.foodRepository.deleteById(widget.foodId);

      if (!mounted) return;

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Food entry deleted successfully'),
              ],
            ),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Force update home screen widget if controller is available
        if (widget.foodTrackingController != null) {
          try {
            await widget.foodTrackingController!.forceUpdate();
          } catch (e) {
            // Silently log error but continue - don't block navigation for widget update failure
            debugPrint('Failed to update home screen widget: $e');
          }
        }

        // Return true to indicate deletion was successful
        navigator.pop(true);
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to delete food entry'),
              ],
            ),
            backgroundColor: primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Error: ${e.toString()}'),
            ],
          ),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.delete, color: primaryRed),
            const SizedBox(width: 8),
            const Text('Delete Food Entry'),
          ],
        ),
        content: const Text(
            'Are you sure you want to delete this food entry? This action cannot be undone.'),
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
              _deleteFood();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(date);
  }

// coverage:ignore-start
  void _shareFood(FoodAnalysisResult food) async {
    await context.shareFoodSummary(food);
  }
  // coverage:ignore-end

  void _showSaveMealDialog(FoodAnalysisResult food) {
    final TextEditingController nameController =
        TextEditingController(text: food.foodName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.bookmark, color: primaryGreen),
            const SizedBox(width: 8),
            const Text('Save Meal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save this meal to your collection for quick access later.',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Enter a name for this saved meal',
              ),
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
              _saveMeal(food, name: nameController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMeal(FoodAnalysisResult food, {String? name}) async {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint("FoodDetailPage: Getting SavedMealService from GetIt");
      try {
        // Get the saved meal service from GetIt
        final savedMealService = GetIt.instance<SavedMealService>();
        debugPrint(
            "FoodDetailPage: Successfully got SavedMealService from GetIt");

        debugPrint(
            "FoodDetailPage: Calling saveMeal with food ID ${food.id} and name $name");
        // Save the meal with the provided name or default to food name
        final savedMeal = await savedMealService.saveMeal(food, name: name);
        debugPrint("FoodDetailPage: Meal saved with ID: ${savedMeal.id}");

        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isSaved = true;
        });

        // Show success message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Meal saved successfully'),
              ],
            ),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (getItError) {
        debugPrint(
            "FoodDetailPage: Error getting SavedMealService from GetIt - $getItError");
        throw Exception("Error accessing SavedMealService: $getItError");
      }
    } catch (e, stackTrace) {
      debugPrint("FoodDetailPage: Error saving meal - $e");
      debugPrint("FoodDetailPage: Stack trace - $stackTrace");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show detailed error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to save meal: ${e.toString()}')),
            ],
          ),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  void _showUnsaveMealDialog(FoodAnalysisResult food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.bookmark_remove, color: primaryRed),
            const SizedBox(width: 8),
            const Text('Remove Saved Meal'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove this meal from your saved collection?',
              style: TextStyle(color: Colors.black87),
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
              _unsaveMeal(food);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _unsaveMeal(FoodAnalysisResult food) async {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      setState(() {
        _isLoading = true;
      });

      // Get the saved meal service from GetIt
      final savedMealService = GetIt.instance<SavedMealService>();

      // Find the saved meal with this food analysis ID
      final snapshot = await FirebaseFirestore.instance
          .collection('saved_meals')
          .where('foodAnalysis.id', isEqualTo: food.id)
          .where('userId',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Saved meal not found');
      }

      final savedMealId = snapshot.docs.first.id;

      // Delete the saved meal
      await savedMealService.deleteSavedMeal(savedMealId);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSaved = false;
      });

      // Show success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Meal removed from saved collection'),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to remove meal: ${e.toString()}')),
            ],
          ),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        //coverage:ignore-start
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Colors.black87,
            ),
            onPressed: () {
              _foodFuture.then((food) {
                if (food != null) {
                  _shareFood(food);
                }
              });
            },
            tooltip: 'Share',
          ),
          //coverage:ignore-end
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () => _showDeleteConfirmation(),
            tooltip: 'Delete',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<FoodAnalysisResult?>(
              future: _foodFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: primaryRed,
                            size: 64.0,
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'Error loading data',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.no_food,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Food entry not found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                final food = snapshot.data!;
                return _buildFoodDetailContent(food);
              },
            ),
    );
  }

  Widget _buildFoodDetailContent(FoodAnalysisResult food) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with food image (if available)
          _buildFoodHeader(food),

          // Food info section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food name and save button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        food.foodName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: _isSaved ? primaryGreen : Colors.black87,
                      ),
                      onPressed: () => _isSaved
                          ? _showUnsaveMealDialog(food)
                          : _showSaveMealDialog(food),
                      tooltip: _isSaved ? 'Saved Meal' : 'Save Meal',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            primaryGreen.withOpacity(_isSaved ? 0.2 : 0.1),
                        foregroundColor:
                            _isSaved ? primaryGreen : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(CupertinoIcons.calendar,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(food.timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nutrition section
                _buildNutritionSection(food),

                // Ingredients section
                _buildIngredientsSection(food),

                // Warnings section (if any)
                if (food.warnings.isNotEmpty) _buildWarningsSection(food),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodHeader(FoodAnalysisResult food) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.1),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Food image or placeholder
          if (food.foodImageUrl != null && food.foodImageUrl!.isNotEmpty)
            Image.network(
              food.foodImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFoodImagePlaceholder();
              },
            )
          else
            _buildFoodImagePlaceholder(),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                stops: const [0.7, 1.0],
              ),
            ),
          ),

          // Calories indicator
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.flame_fill,
                    color: primaryOrange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${food.nutritionInfo.calories.toInt()} calories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImagePlaceholder() {
    return Container(
      color: primaryGreen.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 64,
          color: primaryGreen.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildNutritionSection(FoodAnalysisResult food) {
    // Calculate macronutrient percentages
    final totalCarbs = food.nutritionInfo.carbs.toInt();
    final totalProtein = food.nutritionInfo.protein.toInt();
    final totalFat = food.nutritionInfo.fat.toInt();
    final totalMacros = totalCarbs + totalProtein + totalFat;

    final carbPercentage =
        totalMacros > 0 ? (totalCarbs / totalMacros) * 100 : 0;
    final proteinPercentage =
        totalMacros > 0 ? (totalProtein / totalMacros) * 100 : 0;
    final fatPercentage = totalMacros > 0 ? (totalFat / totalMacros) * 100 : 0;

    // Convert nutrition info to a map for HealthScoreSection
    final Map<String, dynamic> nutritionMap = {
      'healthScore': food.healthScore,
      'healthScoreCategory': food.getHealthScoreCategory(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Health Score Section
        HealthScoreSection(
          isLoading: false,
          nutritionData: nutritionMap,
          primaryGreen: primaryGreen,
          primaryPink: primaryRed,
        ),
        const SizedBox(height: 16),

        _buildSectionHeader('Nutrition Information',
            CupertinoIcons.chart_pie_fill, primaryBlue),
        const SizedBox(height: 16),

        // Macronutrient breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Macronutrients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Macronutrient bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 16,
                  child: Row(
                    children: [
                      Expanded(
                        flex: carbPercentage.toInt(),
                        child: Container(color: Colors.amber),
                      ),
                      Expanded(
                        flex: proteinPercentage.toInt(),
                        child: Container(color: primaryBlue),
                      ),
                      Expanded(
                        flex: fatPercentage.toInt(),
                        child: Container(color: primaryRed),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Macronutrient details
              Row(
                children: [
                  _buildMacronutrientItem('Carbs', '$totalCarbs g',
                      '${carbPercentage.toStringAsFixed(0)}%', Colors.amber),
                  const SizedBox(width: 16),
                  _buildMacronutrientItem('Protein', '$totalProtein g',
                      '${proteinPercentage.toStringAsFixed(0)}%', primaryBlue),
                  const SizedBox(width: 16),
                  _buildMacronutrientItem('Fat', '$totalFat g',
                      '${fatPercentage.toStringAsFixed(0)}%', primaryRed),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Detailed nutrition
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detailed Nutrition',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildNutritionRow('Calories',
                  '${food.nutritionInfo.calories.toInt()} cal', primaryOrange),
              _buildNutritionRow('Protein',
                  '${food.nutritionInfo.protein.toInt()} g', primaryBlue),
              _buildNutritionRow('Carbs',
                  '${food.nutritionInfo.carbs.toInt()} g', Colors.amber),
              _buildNutritionRow(
                  'Fat', '${food.nutritionInfo.fat.toInt()} g', primaryRed),
              _buildNutritionRow('Sodium',
                  '${food.nutritionInfo.sodium.toInt()} mg', Colors.grey),
              _buildNutritionRow('Fiber',
                  '${food.nutritionInfo.fiber.toInt()} g', primaryGreen),
              _buildNutritionRow('Sugar',
                  '${food.nutritionInfo.sugar.toInt()} g', Colors.pink),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMacronutrientItem(
      String name, String value, String percentage, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                percentage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(FoodAnalysisResult food) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Ingredients', CupertinoIcons.list_bullet, primaryGreen),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: food.ingredients.isEmpty
              ? _buildEmptyStateMessage('No ingredients information available',
                  CupertinoIcons.info_circle)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: food.ingredients.map((ingredient) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ingredient.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (ingredient.servings > 0)
                                  Text(
                                    '${ingredient.servings} kcal',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 24),

        // Vitamins and Minerals Section
        VitaminsAndMineralsSection(
          isLoading: false,
          food: food,
          primaryColor: primaryBlue,
        ),
      ],
    );
  }

  Widget _buildWarningsSection(FoodAnalysisResult food) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Warnings',
            CupertinoIcons.exclamationmark_triangle_fill, Colors.amber),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: food.warnings.map((warning) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_circle,
                        color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateMessage(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
