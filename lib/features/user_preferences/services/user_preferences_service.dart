// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/user_preferences/domain/repositories/user_preferences_repository.dart';

/// Service for managing user preferences
class UserPreferencesService {
  final FirebaseAuth _auth;
  final UserPreferencesRepository _repository;

  UserPreferencesService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _repository = UserPreferencesRepositoryImpl(
          firestore: firestore ?? FirebaseFirestore.instance,
        );

  /// Check if exercise calorie compensation is enabled
  Future<bool> isExerciseCalorieCompensationEnabled() async {
    final userId = _auth.currentUser?.uid ?? '';

    try {
      // If user is logged in, use repository to get the setting
      if (userId.isNotEmpty) {
        return await _repository.isExerciseCalorieCompensationEnabled(userId);
      }
      // If not logged in, check the onboarding preference directly
      else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool('exercise_calorie_compensation_enabled') ?? false;
      }
    } catch (e) {
      debugPrint('Error checking exercise calorie compensation setting: $e');
      return false;
    }
  }

  /// Set exercise calorie compensation setting
  Future<void> setExerciseCalorieCompensationEnabled(bool enabled) async {
    final userId = _auth.currentUser?.uid ?? '';

    try {
      // Always update local preferences for consistent access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('exercise_calorie_compensation_enabled', enabled);

      // Only update Firebase if user is logged in
      if (userId.isNotEmpty) {
        await _repository.setExerciseCalorieCompensationEnabled(
            userId, enabled);
      }
    } catch (e) {
      debugPrint('Error setting exercise calorie compensation setting: $e');
      throw Exception('Failed to update setting: $e');
    }
  }

  /// Check if rollover calories feature is enabled
  Future<bool> isRolloverCaloriesEnabled() async {
    final userId = _auth.currentUser?.uid ?? '';

    try {
      // If user is logged in, use repository to get the setting
      if (userId.isNotEmpty) {
        return await _repository.isRolloverCaloriesEnabled(userId);
      }
      // If not logged in, check the onboarding preference directly
      else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool('rollover_calories_enabled') ?? false;
      }
    } catch (e) {
      debugPrint('Error checking rollover calories setting: $e');
      return false;
    }
  }

  /// Set rollover calories setting
  Future<void> setRolloverCaloriesEnabled(bool enabled) async {
    final userId = _auth.currentUser?.uid ?? '';

    try {
      // Always update local preferences for consistent access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rollover_calories_enabled', enabled);

      // Only update Firebase if user is logged in
      if (userId.isNotEmpty) {
        await _repository.setRolloverCaloriesEnabled(userId, enabled);

        // If the feature is being enabled, immediately calculate rollover
        // to ensure data is available in the UI
        if (enabled) {
          await getRolloverCalories();
        }
      }
    } catch (e) {
      debugPrint('Error setting rollover calories setting: $e');
      throw Exception('Failed to update setting: $e');
    }
  }

  /// Get rollover calories from previous day
  Future<int> getRolloverCalories() async {
    final userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return 0;
    }

    try {
      // First check if feature is enabled
      final isEnabled = await _repository.isRolloverCaloriesEnabled(userId);
      if (!isEnabled) {
        return 0;
      }

      // Calculate rollover calories
      return await _repository.calculateRolloverCalories(userId);
    } catch (e) {
      debugPrint('Error calculating rollover calories: $e');
      return 0;
    }
  }

  /// Get the user's pet name
  /// Returns a default name 'Panda' if no pet name is set or user is not logged in
  Future<String> getPetName() async {
    final userId = _auth.currentUser?.uid ?? '';

    try {
      // If user is logged in, use repository to get the pet name
      if (userId.isNotEmpty) {
        return await _repository.getPetName(userId);
      }
      // If not logged in, check the local preference
      else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('pet_name') ?? 'Panda';
      }
    } catch (e) {
      debugPrint('Error fetching pet name: $e');
      return 'Panda'; // Default name
    }
  }

  /// Set the user's pet name
  /// Falls back to default name 'Panda' if an empty name is provided
  Future<void> setPetName(String petName) async {
    final userId = _auth.currentUser?.uid ?? '';
    final validPetName = petName.trim().isEmpty ? 'Panda' : petName.trim();

    try {
      // Always update local preferences for consistent access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pet_name', validPetName);

      // If user is logged in, also update in repository
      if (userId.isNotEmpty) {
        await _repository.setPetName(userId, validPetName);
      }

      debugPrint('Pet name set to: $validPetName');
    } catch (e) {
      debugPrint('Error setting pet name: $e');
      throw Exception('Failed to set pet name: $e');
    }
  }

  /// Check if sync fitness tracker is enabled
  /// This preference is only stored locally, not in Firebase
  Future<bool> isSyncFitnessTrackerEnabled() async {
    try {
      // Always check the local preference directly
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('sync_fitness_tracker_enabled') ?? false;
    } catch (e) {
      debugPrint('Error checking sync fitness tracker setting: $e');
      return false;
    }
  }

  /// Set sync fitness tracker setting
  /// This preference is only stored locally, not in Firebase
  Future<void> setSyncFitnessTrackerEnabled(bool enabled) async {
    try {
      // Only update local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sync_fitness_tracker_enabled', enabled);
      debugPrint('Saved sync fitness tracker setting locally: $enabled');
    } catch (e) {
      debugPrint('Error setting sync fitness tracker setting: $e');
      throw Exception('Failed to update setting: $e');
    }
  }

  /// Synchronize user preferences from SharedPreferences to Firebase after login
  /// Call this method when a user logs in to ensure their preferences are synced
  Future<void> synchronizePreferencesAfterLogin() async {
    final userId = _auth.currentUser?.uid;

    // Only proceed if user is logged in
    if (userId == null || userId.isEmpty) {
      debugPrint('Cannot synchronize preferences: No user logged in');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Sync exercise calorie compensation preference
      final exerciseCalorieCompensation =
          prefs.getBool('exercise_calorie_compensation_enabled');
      if (exerciseCalorieCompensation != null) {
        debugPrint(
            'Syncing exercise calorie compensation: $exerciseCalorieCompensation');
        await _repository.setExerciseCalorieCompensationEnabled(
            userId, exerciseCalorieCompensation);
      }
      
      // Sync rollover calories preference
      final rolloverCalories = prefs.getBool('rollover_calories_enabled');
      if (rolloverCalories != null) {
        debugPrint('Syncing rollover calories: $rolloverCalories');
        await _repository.setRolloverCaloriesEnabled(userId, rolloverCalories);
      }
      
      // Sync pet name preference
      final petName = prefs.getString('pet_name');
      if (petName != null) {
        debugPrint('Syncing pet name: $petName');
        await _repository.setPetName(userId, petName);
      }
      
      // No need to sync fitness tracker preference to Firebase - handled locally only

      debugPrint('Successfully synchronized user preferences after login');
    } catch (e) {
      debugPrint('Error synchronizing preferences after login: $e');
    }
  }
}
