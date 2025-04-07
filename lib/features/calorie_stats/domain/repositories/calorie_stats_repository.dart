import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
// coverage:ignore-start
abstract class CalorieStatsRepository {
  Future<DailyCalorieStats?> getStatsByDate(String userId, DateTime date);
  Future<List<DailyCalorieStats>> getStatsByDateRange(String userId, DateTime startDate, DateTime endDate);
  Future<void> saveStats(DailyCalorieStats stats);
}

class CalorieStatsRepositoryImpl implements CalorieStatsRepository {
  final FirebaseFirestore _firestore;
  
  CalorieStatsRepositoryImpl({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<DailyCalorieStats?> getStatsByDate(String userId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    try {
      final querySnapshot = await _firestore
          .collection('calorie_stats')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .get();
      
      if (querySnapshot.docs.isEmpty) return null;
      return DailyCalorieStats.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('Error fetching calorie stats: $e');
      return null;
    }
  }
  
  @override
  Future<List<DailyCalorieStats>> getStatsByDateRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      final querySnapshot = await _firestore
          .collection('calorie_stats')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStartDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(normalizedEndDate))
          .orderBy('date')
          .get();
      
      return querySnapshot.docs
          .map((doc) => DailyCalorieStats.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching calorie stats range: $e');
      return [];
    }
  }
  
  @override
  Future<void> saveStats(DailyCalorieStats stats) async {
    try {
      await _firestore
          .collection('calorie_stats')
          .doc(stats.id)
          .set(stats.toMap());
    } catch (e) {
      debugPrint('Error saving calorie stats: $e');
    }
  }
}
 // coverage:ignore-end