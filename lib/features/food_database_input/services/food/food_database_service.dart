import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/food_database_input/services/base/supabase.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/domain/repositories/nutrition_database_repository.dart';

//coverage: ignore-file
abstract class NutritionDatabaseServiceInterface {
  // Food data operations from Supabase
  Future<List<FoodAnalysisResult>> getAllFoods(
      {int limit = 20, int offset = 0});
  Future<List<FoodAnalysisResult>> searchFoods(String query);
  Future<FoodAnalysisResult?> getFoodById(int id);
  Future<FoodAnalysisResult> adjustPortion(int foodId, double grams);

  // Meal operations
  FoodAnalysisResult createLocalMeal(
      String name, List<FoodAnalysisResult> items,
      {Map<String, dynamic>? additionalInformation});
  FoodAnalysisResult updateLocalMeal(FoodAnalysisResult meal,
      {String? name, List<FoodAnalysisResult>? items});

  // Firebase operations - only called when explicitly saving
  Future<String> saveMealToFirebase(FoodAnalysisResult meal);
}

class NutritionDatabaseService implements NutritionDatabaseServiceInterface {
  final SupabaseService _supabase;
  final FirebaseAuth _auth;
  final NutritionDatabaseRepository _repository;

  NutritionDatabaseService(
    this._supabase, {
    FirebaseAuth? auth,
    NutritionDatabaseRepository? repository,
    required FirebaseFirestore firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _repository = repository ?? NutritionDatabaseRepository();

  @override
  Future<List<FoodAnalysisResult>> getAllFoods(
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase.fetchFromTable(
        'nutrition_data',
        limit: limit,
        offset: offset,
        orderBy: 'food',
      );

      return _convertToFoodAnalysisResults(response);
    } catch (e) {
      print('Error fetching foods: $e');
      return [];
    }
  }

  @override
  Future<List<FoodAnalysisResult>> searchFoods(String query) async {
    try {
      final response = await _supabase.client
          .from('nutrition_data')
          .select()
          .ilike('food', '%$query%')
          .limit(20);

      return _convertToFoodAnalysisResults(response);
    } catch (e) {
      print('Error searching foods: $e');
      return [];
    }
  }

  @override
  Future<FoodAnalysisResult?> getFoodById(int id) async {
    try {
      final response = await _supabase.getById('nutrition_data', 'id', id);
      if (response == null) return null;

      return _convertToFoodAnalysisResult(response);
    } catch (e) {
      print('Error getting food by ID: $e');
      return null;
    }
  }

  /// Adjusts portion by fetching fresh data from the database
  @override
  Future<FoodAnalysisResult> adjustPortion(int foodId, double grams) async {
    // Fetch the original food data directly from the database
    final originalFood = await getFoodById(foodId);

    if (originalFood == null) {
      throw Exception('Food with ID $foodId not found');
    }

    // Base values are per 100g, so calculate factor
    double factor = (grams / 100.0);

    // Just do the math without intermediate rounding
    NutritionInfo adjustedNutrition = NutritionInfo(
      calories: originalFood.nutritionInfo.calories * factor,
      protein: originalFood.nutritionInfo.protein * factor,
      carbs: originalFood.nutritionInfo.carbs * factor,
      fat: originalFood.nutritionInfo.fat * factor,
      saturatedFat: originalFood.nutritionInfo.saturatedFat * factor,
      sodium: originalFood.nutritionInfo.sodium * factor,
      fiber: originalFood.nutritionInfo.fiber * factor,
      sugar: originalFood.nutritionInfo.sugar * factor,
      cholesterol: originalFood.nutritionInfo.cholesterol * factor,
      nutritionDensity: originalFood.nutritionInfo.nutritionDensity,
      vitaminsAndMinerals: _scaleVitaminsAndMinerals(
          originalFood.nutritionInfo.vitaminsAndMinerals, factor),
    );

    // Use adjusted calories as servings
    Ingredient adjustedIngredient = Ingredient(
      name: originalFood.foodName,
      servings: adjustedNutrition.calories, // Use the adjusted calories
    );

    // Return a new food analysis result with adjusted values
    return originalFood.copyWith(
      id: 'portion_${originalFood.id}_${grams}g',
      nutritionInfo: adjustedNutrition,
      ingredients: [adjustedIngredient],
      additionalInformation: {
        ...originalFood.additionalInformation,
        'portion_adjusted': true,
        'original_food_id': originalFood.id,
        'original_portion': 100,
        'adjusted_portion': grams,
      },
    );
  }

  // LOCAL MEAL MANAGEMENT - NO DATABASE OPERATIONS

  @override
  FoodAnalysisResult createLocalMeal(
      String name, List<FoodAnalysisResult> items,
      {Map<String, dynamic>? additionalInformation}) {
    try {
      // Extract component counts from additionalInformation
      List<Map<String, dynamic>> componentInfo = [];
      if (additionalInformation != null &&
          additionalInformation.containsKey('components') &&
          additionalInformation['components'] is List) {
        componentInfo = List<Map<String, dynamic>>.from(
            additionalInformation['components']);
      }

      // Create ingredients list from items and account for count
      List<Ingredient> ingredients = [];
      // Prepare a list to store nutrition info that accounts for counts
      List<NutritionInfo> scaledNutritionInfos = [];

      for (int i = 0; i < items.length; i++) {
        final food = items[i];
        // Default count is 1
        int count = 1;

        // Try to get count from component info
        if (i < componentInfo.length && componentInfo[i].containsKey('count')) {
          count = int.tryParse(componentInfo[i]['count'].toString()) ?? 1;
          // Ensure minimum count of 1
          if (count < 1) count = 1;
        }

        // Get portion
        final portion = food.ingredients.isNotEmpty
            ? food.ingredients[0].servings.roundToDouble()
            : 100.0;

        // Add ingredient with count-adjusted servings
        ingredients.add(Ingredient(
          name: food.foodName,
          servings: portion * count, // Adjust servings based on count
        ));

        // Scale nutrition info by count and add to list for combining
        for (int j = 0; j < count; j++) {
          scaledNutritionInfos.add(food.nutritionInfo);
        }
      }

      // Calculate combined nutrition info using the scaled values
      NutritionInfo combinedNutrition =
          _combineNutritionInfo(scaledNutritionInfos);

      // Generate warnings based on thresholds
      Set<String> allWarnings = {};
      if (combinedNutrition.sodium > FoodAnalysisResult.highSodiumThreshold) {
        allWarnings.add(FoodAnalysisResult.highSodiumWarning);
      }
      if (combinedNutrition.sugar > FoodAnalysisResult.highSugarThreshold) {
        allWarnings.add(FoodAnalysisResult.highSugarWarning);
      }
      if (combinedNutrition.cholesterol >
          FoodAnalysisResult.highCholesterolThreshold) {
        allWarnings.add(FoodAnalysisResult.highCholesterolWarning);
      }
      if (combinedNutrition.saturatedFat >
          FoodAnalysisResult.highSaturatedFatThreshold) {
        allWarnings.add(FoodAnalysisResult.highSaturatedFatWarning);
      }

      // Get current user ID
      final userId = _auth.currentUser?.uid ?? '';

      // Merge provided additionalInformation with default information
      Map<String, dynamic> finalAdditionalInfo = {
        'is_meal': true,
        'component_count': ingredients.length,
        'saved_to_firebase': false, // Indicates this meal hasn't been saved yet
      };

      // Keep the original components information
      if (additionalInformation != null) {
        finalAdditionalInfo.addAll(additionalInformation);
      }

      // Create the meal as a FoodAnalysisResult
      return FoodAnalysisResult(
          foodName: name,
          ingredients: ingredients,
          nutritionInfo: combinedNutrition,
          warnings: allWarnings.toList(),
          id: 'meal_local_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          timestamp: DateTime.now(),
          additionalInformation: finalAdditionalInfo);
    } catch (e) {
      print('Error creating local meal: $e');
      throw Exception('Failed to create local meal: $e');
    }
  }

  @override
  FoodAnalysisResult updateLocalMeal(FoodAnalysisResult meal,
      {String? name, List<FoodAnalysisResult>? items}) {
    try {
      // If no changes, return original meal
      if (name == null && items == null) {
        return meal;
      }

      // Update name if provided
      final updatedName = name ?? meal.foodName;

      // Handle items update
      List<Ingredient> updatedIngredients = meal.ingredients;
      NutritionInfo updatedNutrition = meal.nutritionInfo;
      List<String> updatedWarnings = [...meal.warnings];
      Map<String, dynamic> updatedAdditionalInfo = {
        ...meal.additionalInformation
      };

      if (items != null) {
        // Get existing component info if available
        List<Map<String, dynamic>> componentInfo = [];
        if (updatedAdditionalInfo.containsKey('components') &&
            updatedAdditionalInfo['components'] is List) {
          componentInfo = List<Map<String, dynamic>>.from(
              updatedAdditionalInfo['components']);
        }

        // Create ingredients list from items and account for counts
        updatedIngredients = [];
        List<NutritionInfo> scaledNutritionInfos = [];

        // Store component IDs, names, portions and counts for reference
        List<Map<String, dynamic>> updatedComponents = [];

        for (int i = 0; i < items.length; i++) {
          final food = items[i];
          // Default count is 1
          int count = 1;

          // Try to get count from existing component info
          if (i < componentInfo.length &&
              componentInfo[i].containsKey('count')) {
            count = int.tryParse(componentInfo[i]['count'].toString()) ?? 1;
            if (count < 1) count = 1; // Ensure minimum count
          }

          // Get portion
          final portion = food.ingredients.isNotEmpty
              ? food.ingredients[0].servings.roundToDouble()
              : 100.0;

          // Add ingredient with count-adjusted servings
          updatedIngredients.add(Ingredient(
            name: food.foodName,
            servings: portion * count, // Adjust servings based on count
          ));

          // Scale nutrition info by count and add to list for combining
          for (int j = 0; j < count; j++) {
            scaledNutritionInfos.add(food.nutritionInfo);
          }

          // Add component info
          updatedComponents.add({
            'food_id': food.id.replaceAll('food_', ''),
            'name': food.foodName,
            'portion': portion,
            'count': count,
          });
        }

        // Calculate combined nutrition info using the scaled values
        updatedNutrition = _combineNutritionInfo(scaledNutritionInfos);

        // Generate warnings based on thresholds
        Set<String> allWarnings = {};
        if (updatedNutrition.sodium > FoodAnalysisResult.highSodiumThreshold) {
          allWarnings.add(FoodAnalysisResult.highSodiumWarning);
        }
        if (updatedNutrition.sugar > FoodAnalysisResult.highSugarThreshold) {
          allWarnings.add(FoodAnalysisResult.highSugarWarning);
        }
        if (updatedNutrition.cholesterol >
            FoodAnalysisResult.highCholesterolThreshold) {
          allWarnings.add(FoodAnalysisResult.highCholesterolWarning);
        }
        if (updatedNutrition.saturatedFat >
            FoodAnalysisResult.highSaturatedFatThreshold) {
          allWarnings.add(FoodAnalysisResult.highSaturatedFatWarning);
        }
        updatedWarnings = allWarnings.toList();

        updatedAdditionalInfo = {
          ...meal.additionalInformation,
          'component_count': updatedComponents.length,
          'components': updatedComponents,
          'modified_locally': true, // Mark as locally modified
        };
      }

      // Return updated meal
      return meal.copyWith(
        foodName: updatedName,
        ingredients: updatedIngredients,
        nutritionInfo: updatedNutrition,
        warnings: updatedWarnings,
        additionalInformation: updatedAdditionalInfo,
      );
    } catch (e) {
      print('Error updating local meal: $e');
      throw Exception('Failed to update local meal: $e');
    }
  }

  // FIREBASE OPERATIONS - Only called when explicitly requested

  @override
  Future<String> saveMealToFirebase(FoodAnalysisResult meal) async {
    try {
      // Get current user ID
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Ensure meal has current user ID
      final mealWithUserId = meal.copyWith(userId: userId);

      // Use the repository to save the meal
      return await _repository.save(mealWithUserId, mealWithUserId.id);
    } catch (e) {
      print('Error saving meal to Firebase: $e');
      throw Exception('Failed to save meal: $e');
    }
  }

  // HELPER METHODS

  List<FoodAnalysisResult> _convertToFoodAnalysisResults(List<dynamic> data) {
    return data
        .map<FoodAnalysisResult>((item) => _convertToFoodAnalysisResult(item))
        .toList();
  }

  FoodAnalysisResult _convertToFoodAnalysisResult(Map<String, dynamic> item) {
    // Map vitamins and minerals without rounding values
    final Map<String, double> vitaminsAndMinerals = {
      'vitamin_a': _parseDouble(item['vitamin_a']),
      'vitamin_b1': _parseDouble(item['vitamin_b1']),
      'vitamin_b11': _parseDouble(item['vitamin_b11']),
      'vitamin_b12': _parseDouble(item['vitamin_b12']),
      'vitamin_b2': _parseDouble(item['vitamin_b2']),
      'vitamin_b3': _parseDouble(item['vitamin_b3']),
      'vitamin_b5': _parseDouble(item['vitamin_b5']),
      'vitamin_b6': _parseDouble(item['vitamin_b6']),
      'vitamin_c': _parseDouble(item['vitamin_c']),
      'vitamin_d': _parseDouble(item['vitamin_d']),
      'vitamin_e': _parseDouble(item['vitamin_e']),
      'vitamin_k': _parseDouble(item['vitamin_k']),
      'calcium': _parseDouble(item['calcium']),
      'copper': _parseDouble(item['copper']),
      'iron': _parseDouble(item['iron']),
      'magnesium': _parseDouble(item['magnesium']),
      'manganese': _parseDouble(item['manganese']),
      'phosphorus': _parseDouble(item['phosphorus']),
      'potassium': _parseDouble(item['potassium']),
      'selenium': _parseDouble(item['selenium']),
      'zinc': _parseDouble(item['zinc']),
    };

    // Create nutrition info without rounding values
    final nutritionInfo = NutritionInfo(
      calories: _parseDouble(item['caloric_value']),
      protein: _parseDouble(item['protein']),
      carbs: _parseDouble(item['carbohydrates']),
      fat: _parseDouble(item['fat']),
      saturatedFat: _parseDouble(item['saturated_fats']),
      sodium: _parseDouble(item['sodium']) * 1000.0,
      fiber: _parseDouble(item['dietary_fiber']),
      sugar: _parseDouble(item['sugars']),
      cholesterol: _parseDouble(item['cholesterol']),
      nutritionDensity: _parseDouble(item['nutrition_density']),
      vitaminsAndMinerals: vitaminsAndMinerals,
    );

    final ingredient = Ingredient(
      name: item['food'] ?? 'Unknown Food',
      servings: _parseDouble(
          item['caloric_value']), // Use _parseDouble to safely convert calories
    );

    final warnings = <String>[];

    if (nutritionInfo.sodium > FoodAnalysisResult.highSodiumThreshold) {
      warnings.add(FoodAnalysisResult.highSodiumWarning);
    }
    if (nutritionInfo.sugar > FoodAnalysisResult.highSugarThreshold) {
      warnings.add(FoodAnalysisResult.highSugarWarning);
    }
    if (nutritionInfo.cholesterol >
        FoodAnalysisResult.highCholesterolThreshold) {
      warnings.add(FoodAnalysisResult.highCholesterolWarning);
    }
    if (nutritionInfo.saturatedFat >
        FoodAnalysisResult.highSaturatedFatThreshold) {
      warnings.add(FoodAnalysisResult.highSaturatedFatWarning);
    }

    // Additional information without rounding values
    final additionalInfo = {
      'database_id': item['id'],
      'source': 'nutrition_database',
      'water_content': _parseDouble(item['water']),
      'monounsaturated_fats': _parseDouble(item['monounsaturated_fats']),
      'polyunsaturated_fats': _parseDouble(item['polyunsaturated_fats']),
    };

    return FoodAnalysisResult(
      foodName: item['food'] ?? 'Unknown Food',
      ingredients: [ingredient],
      nutritionInfo: nutritionInfo,
      warnings: warnings,
      id: 'food_${item['id']}',
      additionalInformation: additionalInfo,
    );
  }

  Map<String, double> _scaleVitaminsAndMinerals(
      Map<String, double> original, double factor) {
    final Map<String, double> scaled = {};
    original.forEach((key, value) {
      scaled[key] = value * factor; // Remove rounding here
    });
    return scaled;
  }

  NutritionInfo _combineNutritionInfo(List<NutritionInfo> components) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalSaturatedFat = 0;
    double totalSodium = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalCholesterol = 0;

    final Map<String, double> totalVitaminsAndMinerals = {};

    // Sum all components without intermediate rounding
    for (final component in components) {
      totalCalories += component.calories;
      totalProtein += component.protein;
      totalCarbs += component.carbs;
      totalFat += component.fat;
      totalSaturatedFat += component.saturatedFat;
      totalSodium += component.sodium; // Remove the 1000 multiplier here
      totalFiber += component.fiber;
      totalSugar += component.sugar;
      totalCholesterol += component.cholesterol;

      component.vitaminsAndMinerals.forEach((key, value) {
        totalVitaminsAndMinerals[key] =
            (totalVitaminsAndMinerals[key] ?? 0) + value;
      });
    }

    // Calculate average nutrition density without intermediate rounding
    double avgNutritionDensity = 0;
    if (components.isNotEmpty) {
      avgNutritionDensity =
          components.fold(0.0, (sum, comp) => sum + comp.nutritionDensity) /
              components.length;
    }

    // Apply rounding only at the final step
    return NutritionInfo(
      calories: totalCalories.roundToDouble(),
      protein: totalProtein.roundToDouble(),
      carbs: totalCarbs.roundToDouble(),
      fat: totalFat.roundToDouble(),
      saturatedFat: totalSaturatedFat.roundToDouble(),
      sodium: totalSodium.roundToDouble(),
      fiber: totalFiber.roundToDouble(),
      sugar: totalSugar.roundToDouble(),
      cholesterol: totalCholesterol.roundToDouble(),
      nutritionDensity: avgNutritionDensity.roundToDouble(),
      vitaminsAndMinerals: totalVitaminsAndMinerals
          .map((key, value) => MapEntry(key, value.roundToDouble())),
    );
  }

  // Helper to parse double values
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// Extension to add roundToDouble functionality
extension DoubleRoundExtension on double {
  double roundToDouble([int places = 2]) {
    double mod = pow(10.0, places);
    // Use ceiling for very small values (less than the smallest decimal place we're showing)
    // This ensures values like 0.001 show up as 0.01 instead of 0
    if (this > 0 && this < 1 / mod) {
      return 1 /
          mod; // Return the smallest representable value for this precision
    }
    return ((this * mod).round().toDouble() / mod);
  }
}

// Helper function for pow since we're not importing dart:math
double pow(double x, int exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
