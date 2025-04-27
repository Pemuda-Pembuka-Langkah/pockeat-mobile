import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/services/food/food_database_service.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/search_tab.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/selected_foods_tab.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/meal_details_tab.dart';

class NutritionDatabasePage extends StatefulWidget {
  const NutritionDatabasePage({Key? key}) : super(key: key);

  @override
  State<NutritionDatabasePage> createState() => _NutritionDatabasePageState();
}

class _NutritionDatabasePageState extends State<NutritionDatabasePage>
    with SingleTickerProviderStateMixin {
  final NutritionDatabaseServiceInterface _nutritionService =
      GetIt.instance<NutritionDatabaseServiceInterface>();

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  // State variables
  List<FoodAnalysisResult> _searchResults = [];
  List<FoodAnalysisResult> _selectedFoods = [];
  FoodAnalysisResult? _currentMeal;
  bool _isLoading = false;
  bool _isSearching = false;
  String _statusMessage = '';

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _mealNameController = TextEditingController();
  final List<TextEditingController> _componentCountControllers = [];
  final _formKey = GlobalKey<FormState>();

  // Map to store current portion values for selected foods
  final Map<int, double> _portionValues = {};

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }


  void _searchFoods() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _statusMessage = 'Searching for "${_searchController.text}"...';
    });

    try {
      final results =
          await _nutritionService.searchFoods(_searchController.text.trim());
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _statusMessage = 'Found ${results.length} results';
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _statusMessage = 'Search error: $e';
      });
    }
  }

  void _addFoodToSelection(FoodAnalysisResult food) {
    setState(() {
      _selectedFoods.add(food);

      // Initialize portion value for the new food
      final index = _selectedFoods.length - 1;
      final initialPortion =
          food.ingredients.isNotEmpty ? food.ingredients[0].servings : 100.0;
      _portionValues[index] = initialPortion;

      // Add a new component count controller
      _componentCountControllers.add(TextEditingController(text: "1"));

      _statusMessage = 'Added ${food.foodName} to meal';

      // Switch to the "Selected" tab after adding a food
      _tabController.animateTo(1);
    });
  }

  void _adjustPortion(int index, double grams) async {
    if (index < 0 || index >= _selectedFoods.length) return;

    final selectedFood = _selectedFoods[index];

    try {
      int foodId;

      // Handle different ID formats:
      // 1. Regular food item: "food_123"
      // 2. Portion-adjusted food: "portion_food_123_100g"
      if (selectedFood.id.startsWith('food_')) {
        // Extract the database ID by removing the 'food_' prefix
        String idString = selectedFood.id.replaceAll('food_', '');
        foodId = int.parse(idString);
      } else if (selectedFood.id.startsWith('portion_')) {
        // Extract the original food ID from additional information
        if (selectedFood.additionalInformation
            .containsKey('original_food_id')) {
          String originalId =
              selectedFood.additionalInformation['original_food_id'];
          originalId = originalId.replaceAll('food_', '');
          foodId = int.parse(originalId);
        } else {
          // Try to extract from portion ID format: "portion_food_123_100g"
          final parts = selectedFood.id.split('_');
          if (parts.length >= 3) {
            foodId = int.parse(parts[2]); // Extract the numeric ID
          } else {
            throw Exception('Cannot determine food ID from ${selectedFood.id}');
          }
        }
      } else {
        throw Exception('Unsupported food ID format: ${selectedFood.id}');
      }

      // Store the new portion value in the map
      _portionValues[index] = grams;

      setState(() {
        _statusMessage = 'Adjusting portion...';
      });

      // Call the service method with the correct parameters
      final adjustedFood = await _nutritionService.adjustPortion(foodId, grams);

      if (mounted) {
        setState(() {
          _selectedFoods[index] = adjustedFood;
          _statusMessage = 'Adjusted portion to ${grams.toStringAsFixed(1)}g';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error adjusting portion: $e';
        });
      }
    }
  }

  void _removeFood(int index) {
    if (index < 0 || index >= _selectedFoods.length) return;

    setState(() {
      final removedFood = _selectedFoods.removeAt(index);
      // Also remove the controller and portion value
      _componentCountControllers.removeAt(index);
      _portionValues.remove(index);
      // Re-index the portion values
      final newPortionValues = <int, double>{};
      _portionValues.forEach((oldIndex, value) {
        if (oldIndex > index) {
          newPortionValues[oldIndex - 1] = value;
        } else if (oldIndex < index) {
          newPortionValues[oldIndex] = value;
        }
      });
      _portionValues.clear();
      _portionValues.addAll(newPortionValues);

      _statusMessage = 'Removed ${removedFood.foodName}';
    });
  }

  void _createMeal() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFoods.isEmpty) {
      setState(() {
        _statusMessage = 'Please add at least one food to create a meal';
      });
      return;
    }

    // Create a map of component counts from the controller values
    Map<String, dynamic> componentInfo = {};
    List<Map<String, dynamic>> components = [];

    // Process each food item with its component count and portion
    for (int i = 0; i < _selectedFoods.length; i++) {
      final food = _selectedFoods[i];
      final countText = _componentCountControllers[i].text;

      // Parse component count (default to 1 if invalid)
      int count = 1;
      try {
        count = int.parse(countText);
        if (count < 1) count = 1; // Ensure minimum count of 1
      } catch (e) {
        print('Invalid component count for ${food.foodName}: $e');
      }

      // Get the adjusted portion for this food
      final portion = _portionValues[i] ??
          (food.ingredients.isNotEmpty ? food.ingredients[0].servings : 100.0);

      // Add to components list
      components.add({
        'id': food.id,
        'name': food.foodName,
        'count': count,
        'portion': portion,
      });
    }

    // Add component info to meal metadata
    componentInfo['components'] = components;
    componentInfo['component_count'] = components.length;

    setState(() {
      // Create meal with additional component information
      _currentMeal = _nutritionService.createLocalMeal(
          _mealNameController.text.trim(), _selectedFoods,
          additionalInformation: componentInfo);
      _statusMessage =
          'Created meal "${_mealNameController.text}" with ${components.length} components';

      // Switch to "Meal" tab
      _tabController.animateTo(2);
    });
  }

  void _saveMealToFirebase() async {
    if (_currentMeal == null) {
      setState(() {
        _statusMessage = 'Please create a meal first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Saving meal...';
    });

    try {
      final mealId = await _nutritionService.saveMealToFirebase(_currentMeal!);
      setState(() {
        _isLoading = false;
        _statusMessage = 'Meal saved with ID: $mealId';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error saving meal: $e';
      });
    }
  }

  void _clearMeal() {
    setState(() {
      _currentMeal = null;
      _selectedFoods.clear();
      _mealNameController.clear();
      _componentCountControllers.clear();
      _portionValues.clear();
      _statusMessage = 'Cleared current meal';

      // Return to the search tab
      _tabController.animateTo(0);
    });
  }

  // Helper methods for formatting
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatNutrientName(String name) {
    // Replace underscores with spaces
    String formattedName = name.replaceAll('_', ' ');

    // Capitalize first letter of each word
    formattedName = formattedName.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');

    return formattedName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Database'),
        elevation: 0,
        backgroundColor: primaryYellow,
        foregroundColor: Colors.black87,
        actions: [
      
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryPink,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
              text: 'Search',
            ),
            Tab(
              icon: Icon(Icons.food_bank),
              text: 'Selected',
            ),
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Meal',
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar for messages
            if (_statusMessage.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                color: _statusMessage.contains('Error')
                    ? primaryPink.withOpacity(0.1)
                    : primaryGreen.withOpacity(0.1),
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(
                      _statusMessage.contains('Error')
                          ? Icons.error_outline
                          : Icons.info_outline,
                      size: 16,
                      color: _statusMessage.contains('Error')
                          ? primaryPink
                          : primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: _statusMessage.contains('Error')
                              ? primaryPink
                              : Colors.black87,
                        ),
                      ),
                    ),
                    if (_isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryGreen),
                        ),
                      ),
                  ],
                ),
              ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Search Tab
                  SearchTab(
                    searchController: _searchController,
                    onSearch: _searchFoods,
                    searchResults: _searchResults,
                    isSearching: _isSearching,
                    onFoodSelected: _addFoodToSelection,
                    primaryYellow: primaryYellow,
                    primaryPink: primaryPink,
                    primaryGreen: primaryGreen,
                  ),

                  // Selected Foods Tab
                  SelectedFoodsTab(
                    mealNameController: _mealNameController,
                    selectedFoods: _selectedFoods,
                    componentCountControllers: _componentCountControllers,
                    portionValues: _portionValues,
                    formKey: _formKey,
                    onCreateMeal: _createMeal,
                    onClearAll: _clearMeal,
                    onRemoveFood: _removeFood,
                    onAdjustPortion: _adjustPortion,
                    onGoToSearchTab: () => _tabController.animateTo(0),
                    primaryYellow: primaryYellow,
                    primaryPink: primaryPink,
                    primaryGreen: primaryGreen,
                  ),

                  // Meal Details Tab
                  MealDetailsTab(
                    currentMeal: _currentMeal,
                    selectedFoods: _selectedFoods,
                    isLoading: _isLoading,
                    onSaveMeal: _saveMealToFirebase,
                    onClearMeal: _clearMeal,
                    onGoToCreateMeal: () => _tabController.animateTo(1),
                    formatDate: (date) => _formatDate(date),
                    formatNutrientName: _formatNutrientName,
                    primaryYellow: primaryYellow,
                    primaryPink: primaryPink,
                    primaryGreen: primaryGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mealNameController.dispose();
    for (var controller in _componentCountControllers) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }
}
