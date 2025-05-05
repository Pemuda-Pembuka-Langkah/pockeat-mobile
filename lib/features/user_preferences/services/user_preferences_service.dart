// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
/// Service for managing user preferences
class UserPreferencesService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Key for the exercise calorie compensation setting
  static const String _exerciseCalorieCompensationKey =
      'exercise_calorie_compensation_enabled';

  UserPreferencesService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Check if exercise calorie compensation is enabled
  Future<bool> isExerciseCalorieCompensationEnabled() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

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

  /// Set exercise calorie compensation setting
  Future<void> setExerciseCalorieCompensationEnabled(bool enabled) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

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
    }
  }
}
