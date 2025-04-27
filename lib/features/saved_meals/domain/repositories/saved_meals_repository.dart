import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';

class SavedMealsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SavedMealsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _savedMealsCollection =>
      _firestore.collection('saved_meals');

  // Get current user ID
  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Save a meal
  Future<SavedMeal> saveMeal(FoodAnalysisResult foodAnalysis,
      {String? name}) async {
    try {
      debugPrint(
          "SavedMealsRepository: Saving meal - ${foodAnalysis.foodName}");
      final now = DateTime.now();

      // Store the foodAnalysisId directly in the document
      final data = {
        'userId': _currentUserId,
        'name': name ?? foodAnalysis.foodName,
        'foodAnalysis': foodAnalysis.toJson(),
        'foodAnalysisId':
            foodAnalysis.id, // Store the ID directly for easier queries
        'createdAt': now,
        'updatedAt': now,
      };

      final docRef = await _savedMealsCollection.add(data);
      debugPrint(
          "SavedMealsRepository: Meal saved successfully with ID - ${docRef.id}");

      return SavedMeal(
        id: docRef.id,
        userId: _currentUserId,
        name: name ?? foodAnalysis.foodName,
        foodAnalysis: foodAnalysis,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e, stackTrace) {
      debugPrint("SavedMealsRepository: Error saving meal - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Get all saved meals for current user - simplified query without needing composite index
  Stream<List<SavedMeal>> getSavedMeals() {
    try {
      debugPrint(
          "SavedMealsRepository: Getting saved meals for user - $_currentUserId");
      return _savedMealsCollection
          .where('userId', isEqualTo: _currentUserId)
          .snapshots()
          .map((snapshot) {
        final meals =
            snapshot.docs.map((doc) => SavedMeal.fromFirestore(doc)).toList();
        // Sort in memory instead of using orderBy to avoid needing a composite index
        meals.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        debugPrint(
            "SavedMealsRepository: Received ${meals.length} saved meals");
        return meals;
      });
    } catch (e, stackTrace) {
      debugPrint("SavedMealsRepository: Error getting saved meals - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Get a specific saved meal
  Future<SavedMeal?> getSavedMeal(String id) async {
    try {
      debugPrint("SavedMealsRepository: Getting saved meal - $id");
      final doc = await _savedMealsCollection.doc(id).get();
      if (!doc.exists) {
        debugPrint("SavedMealsRepository: Meal not found - $id");
        return null;
      }
      debugPrint("SavedMealsRepository: Meal found - $id");
      return SavedMeal.fromFirestore(doc);
    } catch (e, stackTrace) {
      debugPrint("SavedMealsRepository: Error getting saved meal - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Delete a saved meal
  Future<void> deleteSavedMeal(String id) async {
    try {
      debugPrint("SavedMealsRepository: Deleting saved meal - $id");
      await _savedMealsCollection.doc(id).delete();
      debugPrint("SavedMealsRepository: Meal deleted successfully - $id");
    } catch (e, stackTrace) {
      debugPrint("SavedMealsRepository: Error deleting saved meal - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Log a saved meal to food_analysis collection without updating the saved meal
  Future<void> logSavedMealAsNew(SavedMeal savedMeal) async {
    try {
      debugPrint(
          "SavedMealsRepository: Logging saved meal as new - ${savedMeal.id}");
      // Reference to the food_analysis collection
      final foodAnalysisCollection = _firestore.collection('food_analysis');

      final now = DateTime.now();

      // Add a new entry to food_analysis collection
      final docRef = await foodAnalysisCollection.add({
        'foodAnalysis': savedMeal.foodAnalysis.toJson(),
      });
      debugPrint(
          "SavedMealsRepository: Meal logged successfully with ID - ${docRef.id}");
    } catch (e, stackTrace) {
      debugPrint("SavedMealsRepository: Error logging saved meal - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      rethrow;
    }
  }

  // Check if a meal is already saved by its original food analysis ID
  Future<bool> isMealSaved(String foodAnalysisId) async {
    try {
      debugPrint(
          "SavedMealsRepository: Checking if meal is saved - $foodAnalysisId");
      // Use the direct foodAnalysisId field instead of nested path
      final snapshot = await _savedMealsCollection
          .where('userId', isEqualTo: _currentUserId)
          .where('foodAnalysisId', isEqualTo: foodAnalysisId)
          .limit(1)
          .get();

      debugPrint(
          "SavedMealsRepository: Meal saved check result - ${snapshot.docs.isNotEmpty}");
      return snapshot.docs.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint("SavedMealsRepository: Error checking if meal is saved - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      rethrow;
    }
  }
}
