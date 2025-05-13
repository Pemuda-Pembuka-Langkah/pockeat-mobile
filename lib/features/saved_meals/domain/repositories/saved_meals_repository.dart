//

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/firebase/firebase_repository.dart';

// Concrete implementation for food analysis repository - matching FoodScanRepository structure
class FoodAnalysisRepository
    extends BaseFirestoreRepository<FoodAnalysisResult> {
  static const String _timestampField = 'timestamp';

  FoodAnalysisRepository({FirebaseFirestore? firestore})
      : super(
          collectionName: 'food_analysis',
          toMap: (item) =>
              item.toJson(), // Direct serialization without nesting
          fromMap: (map, id) => FoodAnalysisResult.fromJson(map),
          firestore: firestore,
        );

  // Get food analysis results for a specific date
  Future<List<FoodAnalysisResult>> getAnalysisResultsByDate(DateTime date,
      {int? limit}) async {
    return super.getByDate(
      date: date,
      timestampField: _timestampField,
      limit: limit,
      descending: true,
    );
  }
}

// SavedMealsRepository implementation
class SavedMealsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FoodAnalysisRepository _foodAnalysisRepository;

  SavedMealsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    //coverage:ignore-start
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _foodAnalysisRepository = FoodAnalysisRepository(
          firestore: firestore,
        );
  //coverage:ignore-end

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
      //coverage:ignore-start
      debugPrint("SavedMealsRepository: Error saving meal - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      //coverage:ignore-end
      rethrow;
    }
  }

  // Get all saved meals for current user
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
      //coverage:ignore-start
      debugPrint("SavedMealsRepository: Error getting saved meals - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      //coverage:ignore-end
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
      //coverage:ignore-start
      debugPrint("SavedMealsRepository: Error getting saved meal - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      //coverage:ignore-end
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

  // Log a food analysis to food_analysis collection
  Future<String> logFoodAnalysis(FoodAnalysisResult foodAnalysis) async {
    try {
      debugPrint(
          "SavedMealsRepository: Logging food analysis - ${foodAnalysis.foodName}");

      // Create a more robust unique ID using UUID
      final String uniqueId = const Uuid().v4();
      final now = DateTime.now();

      // Create a copy of the food analysis with the new ID, userId and timestamp
      final updatedFoodAnalysis = foodAnalysis.copyWith(
        id: uniqueId,
        userId: _currentUserId,
        timestamp: now,
      );

      // Use the repository's save method - this will use the toMap method that serializes directly
      final savedId =
          await _foodAnalysisRepository.save(updatedFoodAnalysis, uniqueId);

      debugPrint(
          "SavedMealsRepository: Food analysis logged successfully with ID - $savedId");

      return savedId;
    } catch (e, stackTrace) {
      //coverage:ignore-start
      debugPrint("SavedMealsRepository: Error logging food analysis - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      //coverage:ignore-end
      rethrow;
    }
  }

  // Get food logs for the current user by date
  Future<List<FoodAnalysisResult>> getFoodLogsByDate(DateTime date) async {
    try {
      debugPrint("SavedMealsRepository: Getting food logs for date - $date");

      return await _foodAnalysisRepository.getAnalysisResultsByDate(date);
    } catch (e, stackTrace) {
      //coverage:ignore-start
      debugPrint("SavedMealsRepository: Error getting food logs - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      //coverage:ignore-end
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
      ////coverage:ignore-start
      debugPrint("SavedMealsRepository: Error checking if meal is saved - $e");
      debugPrint("SavedMealsRepository: Stack trace - $stackTrace");
      //coverage:ignore-end
      rethrow;
    }
  }
}
