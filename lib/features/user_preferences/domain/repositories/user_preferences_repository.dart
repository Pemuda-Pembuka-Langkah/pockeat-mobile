// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing user preferences
abstract class UserPreferencesRepository {
  /// Check if exercise calorie compensation is enabled
  Future<bool> isExerciseCalorieCompensationEnabled(String userId);

  /// Set exercise calorie compensation setting
  Future<void> setExerciseCalorieCompensationEnabled(
      String userId, bool enabled);

  /// Check if rollover calories feature is enabled
  Future<bool> isRolloverCaloriesEnabled(String userId);

  /// Set rollover calories setting
  Future<void> setRolloverCaloriesEnabled(String userId, bool enabled);

  /// Calculate rollover calories from previous day
  Future<int> calculateRolloverCalories(String userId);
}

/// Implementation of UserPreferencesRepository using Firebase and SharedPreferences
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final FirebaseFirestore _firestore;

  // Key for the exercise calorie compensation setting
  static const String _exerciseCalorieCompensationKey =
      'exercise_calorie_compensation_enabled';

  // Key for the rollover calories setting
  static const String _rolloverCaloriesKey = 'rollover_calories_enabled';

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

  @override
  Future<bool> isRolloverCaloriesEnabled(String userId) async {
    if (userId.isEmpty) return false;

    try {
      // Try getting setting from local storage first for fast access
      final prefs = await SharedPreferences.getInstance();
      final localSetting = prefs.getBool('${_rolloverCaloriesKey}_$userId');

      if (localSetting != null) return localSetting;

      // If not in local storage, get from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();

      final setting =
          doc.data()?['preferences']?[_rolloverCaloriesKey] as bool? ?? false;

      // Cache in local storage for faster access next time
      await prefs.setBool('${_rolloverCaloriesKey}_$userId', setting);

      return setting;
    } catch (e) {
      debugPrint('Error fetching rollover calories setting: $e');
      return false;
    }
  }

  @override
  Future<void> setRolloverCaloriesEnabled(String userId, bool enabled) async {
    if (userId.isEmpty) return;

    try {
      // Update Firestore
      await _firestore.collection('users').doc(userId).set({
        'preferences': {_rolloverCaloriesKey: enabled}
      }, SetOptions(merge: true));

      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_rolloverCaloriesKey}_$userId', enabled);
    } catch (e) {
      debugPrint('Error saving rollover calories setting: $e');
      throw Exception('Failed to save preference: $e');
    }
  }

  @override
  Future<int> calculateRolloverCalories(String userId) async {
    debugPrint('Calculating rollover calories for user: $userId');
    if (userId.isEmpty) return 0;

    try {
      // Check if the feature is enabled first
      final isEnabled = await isRolloverCaloriesEnabled(userId);
      debugPrint('Rollover calories feature enabled: $isEnabled');
      if (!isEnabled) return 0;

      // Get user's TDE (Total Daily Energy) from caloric_requirements collection
      final requirementsDoc = await _firestore
          .collection('caloric_requirements')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      debugPrint('Requirements Document: ${requirementsDoc.docs}');
      if (requirementsDoc.docs.isEmpty) return 0;

      // Get the TDE value and round up if decimal part >= 0.5
      // Check both 'tdee' and 'tde' fields for backward compatibility
      final Map<String, dynamic> data = requirementsDoc.docs.first.data();
      final double? tdeeValue =
          data['tdee'] as double? ?? data['tde'] as double?;
      final double tdeValue = tdeeValue ?? 0.0;
      final int tde =
          (tdeValue % 1 >= 0.5) ? tdeValue.ceil() : tdeValue.floor();
      debugPrint('TDE: $tde');

      // Get yesterday's date as a string in format YYYY-MM-DD
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final dateString =
          "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

      debugPrint(
          'Looking for stats between: $dateString and ${DateTime.now()}');

      // Query documents by date string
      final statsDoc = await _firestore
          .collection('calorie_stats')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: dateString)
          .limit(1)
          .get();

      debugPrint('Stats Document: ${statsDoc.docs}');
      if (statsDoc.docs.isEmpty) return 0;

      final caloriesConsumed =
          statsDoc.docs.first.data()['caloriesConsumed'] as int? ?? 0;
      debugPrint('Calories Consumed: $caloriesConsumed');

      // Calculate rollover calories: TDE - caloriesConsumed
      // Ensure it's not negative and cap at 1000
      int rolloverCalories = tde - caloriesConsumed;
      rolloverCalories = (rolloverCalories < 0) ? 0 : rolloverCalories;
      rolloverCalories = (rolloverCalories > 1000) ? 1000 : rolloverCalories;
      debugPrint('Rollover Calories: $rolloverCalories');
      return rolloverCalories;
    } catch (e) {
      debugPrint('Error calculating rollover calories: $e');
      return 0;
    }
  }
}
