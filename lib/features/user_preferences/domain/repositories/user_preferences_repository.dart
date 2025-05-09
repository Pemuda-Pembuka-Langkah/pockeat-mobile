// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
/// Repository for managing user preferences
abstract class UserPreferencesRepository {
  /// Check if exercise calorie compensation is enabled
  Future<bool> isExerciseCalorieCompensationEnabled(String userId);

  /// Set exercise calorie compensation setting
  Future<void> setExerciseCalorieCompensationEnabled(
      String userId, bool enabled);
}

/// Implementation of UserPreferencesRepository using Firebase and SharedPreferences
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final FirebaseFirestore _firestore;

  // Key for the exercise calorie compensation setting
  static const String _exerciseCalorieCompensationKey =
      'exercise_calorie_compensation_enabled';

  UserPreferencesRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<bool> isExerciseCalorieCompensationEnabled(String userId) async {
    if (userId.isEmpty) return false;

    try {
      // Try getting setting from local storage first for fast access
      final prefs = await SharedPreferences.getInstance();
      final localSetting =
          prefs.getBool('${_exerciseCalorieCompensationKey}_$userId');

      if (localSetting != null) return localSetting;

      // If not in local storage, get from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();

      final setting = doc.data()?['preferences']
              ?[_exerciseCalorieCompensationKey] as bool? ??
          false;

      // Cache in local storage for faster access next time
      await prefs.setBool(
          '${_exerciseCalorieCompensationKey}_$userId', setting);

      return setting;
    } catch (e) {
      debugPrint('Error fetching exercise calorie compensation setting: $e');
      return false;
    }
  }

  @override
  Future<void> setExerciseCalorieCompensationEnabled(
      String userId, bool enabled) async {
    if (userId.isEmpty) return;

    try {
      // Update Firestore
      await _firestore.collection('users').doc(userId).set({
        'preferences': {_exerciseCalorieCompensationKey: enabled}
      }, SetOptions(merge: true));

      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          '${_exerciseCalorieCompensationKey}_$userId', enabled);
    } catch (e) {
      debugPrint('Error saving exercise calorie compensation setting: $e');
      throw Exception('Failed to save preference: $e');
  }
  }
}
