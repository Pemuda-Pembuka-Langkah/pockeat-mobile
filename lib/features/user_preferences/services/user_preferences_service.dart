// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    if (userId.isEmpty) {
      return false;
    }

    try {
      return await _repository.isExerciseCalorieCompensationEnabled(userId);
    } catch (e) {
      debugPrint('Error checking exercise calorie compensation setting: $e');
      return false;
    }
  }

  /// Set exercise calorie compensation setting
  Future<void> setExerciseCalorieCompensationEnabled(bool enabled) async {
    final userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return;
    }

    try {
      await _repository.setExerciseCalorieCompensationEnabled(userId, enabled);
    } catch (e) {
      debugPrint('Error setting exercise calorie compensation setting: $e');
      throw Exception('Failed to update setting: $e');
    }
  }

  /// Check if rollover calories feature is enabled
  Future<bool> isRolloverCaloriesEnabled() async {
    final userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return false;
    }

    try {
      return await _repository.isRolloverCaloriesEnabled(userId);
    } catch (e) {
      debugPrint('Error checking rollover calories setting: $e');
      return false;
    }
  }

  /// Set rollover calories setting
  Future<void> setRolloverCaloriesEnabled(bool enabled) async {
    final userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return;
    }

    try {
      await _repository.setRolloverCaloriesEnabled(userId, enabled);

      // If the feature is being enabled, immediately calculate rollover
      // to ensure data is available in the UI
      if (enabled) {
        await getRolloverCalories();
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
}
