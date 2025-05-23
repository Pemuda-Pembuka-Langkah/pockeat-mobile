// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';

class SmartExerciseLogRepositoryImpl implements SmartExerciseLogRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'exerciseAnalysis';

  SmartExerciseLogRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<String> saveAnalysisResult(ExerciseAnalysisResult result) async {
    try {
      // Validate that userId is not empty
      if (result.userId.isEmpty) {
        throw Exception('User ID cannot be empty when saving analysis result');
      }

      final docRef = _firestore.collection(_collection).doc(result.id);
      await docRef.set(result.toMap());
      return result.id;
    } catch (e) {
      throw Exception('Failed to save analysis result: $e');
    }
  }

  @override
  Future<ExerciseAnalysisResult?> getAnalysisResultFromId(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(id).get();
      if (!docSnapshot.exists) return null;

      return ExerciseAnalysisResult.fromDbMap(
          docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
    } catch (e) {
      throw Exception('Failed to retrieve analysis result: $e');
    }
  }

  @override
  Future<List<ExerciseAnalysisResult>> getAllAnalysisResults(
      {int? limit}) async {
    try {
      var query = _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true);

      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnalysisResult.fromDbMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve analysis results: $e');
    }
  }

  @override
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByDate(DateTime date,
      {int? limit}) async {
    try {
      // Create timestamp for the start of the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final startTimestamp = startOfDay.millisecondsSinceEpoch;

      // Create timestamp for the end of the day
      final endOfDay =
          DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      final endTimestamp = endOfDay.millisecondsSinceEpoch;

      var query = _firestore
          .collection(_collection)
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .orderBy('timestamp', descending: true);

      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnalysisResult.fromDbMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve analysis results by date: $e');
    }
  }

  @override
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByMonth(
      int month, int year,
      {int? limit}) async {
    try {
      // Validate month
      if (month < 1 || month > 12) {
        throw ArgumentError('Month must be between 1 and 12');
      }

      // Create timestamp for the start of the month
      final startOfMonth = DateTime(year, month, 1);
      final startTimestamp = startOfMonth.millisecondsSinceEpoch;

      // Create timestamp for the end of the month
      final endOfMonth = month < 12
          ? DateTime(year, month + 1, 1)
              .subtract(const Duration(milliseconds: 1))
          : DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      final endTimestamp = endOfMonth.millisecondsSinceEpoch;

      var query = _firestore
          .collection(_collection)
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .orderBy('timestamp', descending: true);

      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnalysisResult.fromDbMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve analysis results by month: $e');
    }
  }

  @override
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByYear(int year,
      {int? limit}) async {
    try {
      // Create timestamp for the start of the year
      final startOfYear = DateTime(year, 1, 1);
      final startTimestamp = startOfYear.millisecondsSinceEpoch;

      // Create timestamp for the end of the year
      final endOfYear =
          DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      final endTimestamp = endOfYear.millisecondsSinceEpoch;

      var query = _firestore
          .collection(_collection)
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .orderBy('timestamp', descending: true);

      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnalysisResult.fromDbMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve analysis results by year: $e');
    }
  }

  @override
  Future<bool> deleteById(String id) async {
    try {
      // Check if document exists first
      final docRef = _firestore.collection(_collection).doc(id);
      final docSnapshot = await docRef.get();

      // If document doesn't exist, return false
      if (!docSnapshot.exists) {
        return false;
      }

      // Delete the document and return true
      await docRef.delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete analysis result: $e');
    }
  }

  @override
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByUser(String userId,
      {int? limit}) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      var query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnalysisResult.fromDbMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve analysis results by user: $e');
    }
  }

  @override
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByUserAndDate(
      String userId, DateTime date,
      {int? limit}) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      // Create timestamp for the start of the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final startTimestamp = startOfDay.millisecondsSinceEpoch;

      // Create timestamp for the end of the day
      final endOfDay =
          DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      final endTimestamp = endOfDay.millisecondsSinceEpoch;

      var query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .orderBy('timestamp', descending: true);

      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnalysisResult.fromDbMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception(
          'Failed to retrieve analysis results by user and date: $e');
    }
  }

  @override
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByUserAndMonth(
      String userId, int month, int year,
      {int? limit}) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      // Validate month
      if (month < 1 || month > 12) {
        throw ArgumentError('Month must be between 1 and 12');
      }

      // Create timestamp for the start of the month
      final startOfMonth = DateTime(year, month, 1);
      final startTimestamp = startOfMonth.millisecondsSinceEpoch;

      // Create timestamp for the end of the month
      final endOfMonth = month < 12
          ? DateTime(year, month + 1, 1)
              .subtract(const Duration(milliseconds: 1))
          : DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      final endTimestamp = endOfMonth.millisecondsSinceEpoch;

      var query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .orderBy('timestamp', descending: true);

      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnalysisResult.fromDbMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception(
          'Failed to retrieve analysis results by user and month: $e');
    }
  }
}
