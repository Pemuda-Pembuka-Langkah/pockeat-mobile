// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Constants
const String _collectionName = 'third_party_tracker';
const String _dateFormat = 'yyyy-MM-dd';

/// Service to manage data from third-party fitness trackers
///
/// Handles storing and retrieving health data from third-party sources
/// like Health Connect, Google Fit, or Apple Health. This service
/// maintains a separate collection in Firebase to store this data.
class ThirdPartyTrackerService {
  /// Firestore instance for database operations
  final FirebaseFirestore _firestore;

  /// Creates a new ThirdPartyTrackerService
  ///
  /// @param firestore Optional Firestore instance for dependency injection
  ThirdPartyTrackerService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Helper method to handle errors
  void _handleError(String operation, dynamic error) {
    debugPrint('Error $operation: $error');
  }

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return DateFormat(_dateFormat).format(date);
  }

  /// Save tracker data for the current day
  Future<void> saveTrackerData({
    required String userId,
    required int steps,
    required double caloriesBurned,
  }) async {
    if (userId.isEmpty) return;

    try {
      // Format today's date as YYYY-MM-DD
      final today = DateTime.now();
      final dateString = _formatDate(today);

      // Check if a document already exists for this user and date
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: dateString)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update existing document
        await _firestore
            .collection(_collectionName)
            .doc(querySnapshot.docs.first.id)
            .update({
          'steps': steps,
          'caloriesBurned': caloriesBurned,
          'timestamp': FieldValue.serverTimestamp(),
        });
        debugPrint('Updated tracker data for user: $userId');
      } else {
        // Create new document
        await _firestore.collection(_collectionName).add({
          'userId': userId,
          'date': dateString,
          'steps': steps,
          'caloriesBurned': caloriesBurned,
          'timestamp': FieldValue.serverTimestamp(),
        });
        debugPrint('Saved new tracker data for user: $userId');
      }
    } catch (e) {
      _handleError('saving tracker data', e);
    }
  }

  /// Reset tracker data when disconnected
  Future<void> resetTrackerData(String userId) async {
    if (userId.isEmpty) return;

    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      // Create a batch to perform all operations at once
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        // Update each document to reset values
        batch.update(doc.reference, {
          'steps': 0,
          'caloriesBurned': 0,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();
      debugPrint('Reset tracker data for user: $userId');
    } catch (e) {
      _handleError('resetting tracker data', e);
    }
  }

  /// Get tracker data for a specific date
  Future<Map<String, dynamic>> getTrackerDataForDate(
      String userId, DateTime date) async {
    if (userId.isEmpty) {
      return {'steps': 0, 'caloriesBurned': 0};
    }

    try {
      // Format date as YYYY-MM-DD
      final dateString = _formatDate(date);

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: dateString)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return {
          'steps': data['steps'] ?? 0,
          'caloriesBurned': (data['caloriesBurned'] ?? 0.0).toDouble(),
        };
      }
    } catch (e) {
      _handleError('getting tracker data', e);
    }

    // Return default values if no data or error
    return {'steps': 0, 'caloriesBurned': 0.0};
  }
}
