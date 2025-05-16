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

  /// Check if sync fitness tracker is enabled
  Future<bool> isSyncFitnessTrackerEnabled(String userId);

  /// Set sync fitness tracker setting
  Future<void> setSyncFitnessTrackerEnabled(String userId, bool enabled);
}

/// Implementation of UserPreferencesRepository using Firebase and SharedPreferences
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final FirebaseFirestore _firestore;

  // Key for the exercise calorie compensation setting
  static const String _exerciseCalorieCompensationKey =
      'exercise_calorie_compensation_enabled';

  // Key for the rollover calories setting
  static const String _rolloverCaloriesKey = 'rollover_calories_enabled';

  // Key for the sync fitness tracker setting
  static const String _syncFitnessTrackerKey = 'sync_fitness_tracker_enabled';

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

      // Get all stats documents for this user, sorted by date
      final statsAllDocs = await _firestore
          .collection('calorie_stats')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(10) // Get more docs to ensure yesterday is included
          .get(); // Calculate yesterday's date
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      debugPrint(
          'Looking for stats from yesterday: ${yesterday.toIso8601String()}'); // Find all documents that match yesterday's date
      List<DocumentSnapshot> yesterdayDocs = [];
      for (var doc in statsAllDocs.docs) {
        DateTime docDate;
        final dateField = doc.data()['date'];

        // Handle both Timestamp and String date formats
        if (dateField is Timestamp) {
          docDate = dateField.toDate();
        } else if (dateField is String) {
          // Parse date string in the format YYYY-MM-DD
          final parts = dateField.split('-');
          if (parts.length == 3) {
            try {
              docDate = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
            } catch (e) {
              debugPrint('Error parsing date string: $e');
              continue;
            }
          } else {
            continue;
          }
        } else {
          debugPrint('Unsupported date format: ${dateField.runtimeType}');
          continue;
        }

        debugPrint('Comparing with doc date: ${docDate.toIso8601String()}');

        // Compare only year, month, and day
        if (docDate.year == yesterday.year &&
            docDate.month == yesterday.month &&
            docDate.day == yesterday.day) {
          yesterdayDocs.add(doc);
          debugPrint('Found yesterday\'s document: ${doc.id}');
        }
      }

      // If no document found for yesterday, return default value
      if (yesterdayDocs.isEmpty) {
        debugPrint('No stats document found for yesterday');
        return 0; // Default rollover calories when no data exists
      }

      // If multiple documents found for yesterday, select the most relevant one
      DocumentSnapshot yesterdayDoc;
      if (yesterdayDocs.length > 1) {
        debugPrint(
            'Found ${yesterdayDocs.length} documents for yesterday, selecting most relevant');

        // Look for document with non-zero values
        DocumentSnapshot? nonZeroDoc;
        for (var doc in yesterdayDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final caloriesConsumed = data['caloriesConsumed'] as int? ?? 0;
          final caloriesBurned = data['caloriesBurned'] as int? ?? 0;

          if (caloriesConsumed > 0 || caloriesBurned > 0) {
            nonZeroDoc = doc;
            debugPrint(
                'Selected document with non-zero values: calories consumed=$caloriesConsumed, calories burned=$caloriesBurned');
            break;
          }
        }

        // Use the document with non-zero values if found, otherwise use the first one
        yesterdayDoc = nonZeroDoc ?? yesterdayDocs.first;
      } else {
        yesterdayDoc = yesterdayDocs.first;
      }

      // Get calories consumed from yesterday's document
      final caloriesConsumed = (yesterdayDoc.data()
              as Map<String, dynamic>)['caloriesConsumed'] as int? ??
          0;
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

  @override
  Future<bool> isSyncFitnessTrackerEnabled(String userId) async {
    if (userId.isEmpty) return false;

    try {
      // Try getting setting from local storage first for fast access
      final prefs = await SharedPreferences.getInstance();
      final localSetting = prefs.getBool('${_syncFitnessTrackerKey}_$userId');

      if (localSetting != null) return localSetting;

      // If not in local storage, get from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();

      final setting =
          doc.data()?['preferences']?[_syncFitnessTrackerKey] as bool? ?? false;

      // Cache in local storage for faster access next time
      await prefs.setBool('${_syncFitnessTrackerKey}_$userId', setting);

      return setting;
    } catch (e) {
      debugPrint('Error fetching sync fitness tracker setting: $e');
      return false;
    }
  }

  @override
  Future<void> setSyncFitnessTrackerEnabled(String userId, bool enabled) async {
    if (userId.isEmpty) return;

    try {
      // Update Firestore
      await _firestore.collection('users').doc(userId).set({
        'preferences': {_syncFitnessTrackerKey: enabled}
      }, SetOptions(merge: true));

      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_syncFitnessTrackerKey}_$userId', enabled);
    } catch (e) {
      debugPrint('Error saving sync fitness tracker setting: $e');
      throw Exception('Failed to save preference: $e');
    }
  }
}
