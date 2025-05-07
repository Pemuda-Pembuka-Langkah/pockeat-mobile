// lib/features/saved_meals/services/saved_meal_service.dart
//

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/repositories/saved_meals_repository.dart';

class SavedMealService {
  final SavedMealsRepository _repository;
  final FoodTextAnalysisService _textAnalysisService;

  SavedMealService({
    required SavedMealsRepository repository,
    required FoodTextAnalysisService textAnalysisService,
  })  : _repository = repository,
        _textAnalysisService = textAnalysisService;

  // Get all saved meals
  Stream<List<SavedMeal>> getSavedMeals() {
    //print("SavedMealService: Getting all saved meals");
    try {
      return _repository.getSavedMeals();
    } catch (e) {
      //print("SavedMealService: Error getting saved meals - $e");
      //print("SavedMealService: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Get a specific saved meal
  Future<SavedMeal?> getSavedMeal(String id) async {
    //print("SavedMealService: Getting saved meal with ID - $id");
    try {
      final result = await _repository.getSavedMeal(id);
      if (result == null) {
        //print("SavedMealService: Meal not found - $id");
      } else {
        //print("SavedMealService: Meal found - $id");
      }
      return result;
    } catch (e) {
      //print("SavedMealService: Error getting saved meal - $e");
      //print("SavedMealService: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Save a meal
  Future<SavedMeal> saveMeal(FoodAnalysisResult foodAnalysis,
      {String? name}) async {
    //print("SavedMealService: Saving meal - ${foodAnalysis.foodName}");
    try {
      final result = await _repository.saveMeal(foodAnalysis, name: name);
      //print("SavedMealService: Meal saved successfully with ID - ${result.id}");
      return result;
    } catch (e) {
      //print("SavedMealService: Error saving meal - $e");
      //print("SavedMealService: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Correct a saved meal's analysis - don't save to firebase, just return the corrected analysis
  Future<FoodAnalysisResult> correctSavedMealAnalysis(
      SavedMeal savedMeal, String userComment) async {
    //print("SavedMealService: Correcting saved meal analysis - ${savedMeal.id}");
    try {
      // Only pass the food analysis to the correction service, not the whole saved meal
      // This avoids the Timestamp serialization issue
      final correctedAnalysis = await _textAnalysisService.correctAnalysis(
          savedMeal.foodAnalysis, userComment);
      //print("SavedMealService: Meal correction completed successfully");
      //print(correctedAnalysis
      // .toJson()); // Print the corrected analysis for debugging

      return correctedAnalysis;
    } catch (e) {
      //print("SavedMealService: Error correcting saved meal analysis - $e");
      //print("SavedMealService: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Single method to log a food analysis to Firebase
  Future<String> logFoodAnalysis(FoodAnalysisResult foodAnalysis) async {
    //print("SavedMealService: Logging food analysis - ${foodAnalysis.foodName}");
    try {
      final savedId = await _repository.logFoodAnalysis(foodAnalysis);
      //print(
      // "SavedMealService: Food analysis logged successfully with ID - $savedId");
      return savedId;
    } catch (e) {
      //print("SavedMealService: Error logging food analysis - $e");
      //print("SavedMealService: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Delete a saved meal
  Future<void> deleteSavedMeal(String id) async {
    //print("SavedMealService: Deleting saved meal - $id");
    try {
      await _repository.deleteSavedMeal(id);
      //print("SavedMealService: Meal deleted successfully - $id");
    } catch (e) {
      //print("SavedMealService: Error deleting saved meal - $e");
      //print("SavedMealService: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Check if a meal is already saved
  Future<bool> isMealSaved(String foodAnalysisId) async {
    //print("SavedMealService: Checking if meal is saved - $foodAnalysisId");
    try {
      final result = await _repository.isMealSaved(foodAnalysisId);
      //print("SavedMealService: Meal saved check result - $result");
      return result;
    } catch (e) {
      //print("SavedMealService: Error checking if meal is saved - $e");
      //print("SavedMealService: Stack trace - $stackTrace");
      rethrow;
    }
  }
}
