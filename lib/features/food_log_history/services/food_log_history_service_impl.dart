import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class FoodLogHistoryServiceImpl implements FoodLogHistoryService {
  final FoodScanRepository _foodScanRepository;
  final FirebaseFirestore _firestore;

  FoodLogHistoryServiceImpl({
    required FoodScanRepository foodScanRepository,
    FirebaseFirestore? firestore,
  })  : _foodScanRepository = foodScanRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<FoodLogHistoryItem>> getAllFoodLogs(String userId, {int? limit}) async {
    try {
      final foodScanResults = await _foodScanRepository.getAll(limit: limit);
      final filteredResults = foodScanResults.where((result) => result.userId == userId).toList();
      final foodItems = _convertFoodAnalysisResults(filteredResults);
      
      foodItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      if (limit != null && foodItems.length > limit) {
        return foodItems.sublist(0, limit);
      }

      return foodItems;
    } catch (e) {
      throw Exception('Failed to retrieve food logs: $e');
    }
  }

  @override
  Future<List<FoodLogHistoryItem>> getFoodLogsByDate(String userId, DateTime date) async {
    try {
      final foodScanResults = await _foodScanRepository.getAnalysisResultsByDate(date);
      final filteredResults = foodScanResults.where((result) => result.userId == userId).toList();
      
      return _convertFoodAnalysisResults(filteredResults);
    } catch (e) {
      throw Exception('Failed to retrieve food logs by date: $e');
    }
  }

  @override
  Future<List<FoodLogHistoryItem>> getFoodLogsByMonth(String userId, int month, int year) async {
    try {
      final foodScanResults = await _foodScanRepository.getAnalysisResultsByMonth(month, year);
      final filteredResults = foodScanResults.where((result) => result.userId == userId).toList();
      
      return _convertFoodAnalysisResults(filteredResults);
    } catch (e) {
      throw Exception('Failed to retrieve food logs by month: $e');
    }
  }

  @override
  Future<List<FoodLogHistoryItem>> getFoodLogsByYear(String userId, int year) async {
    try {
      final foodScanResults = await _foodScanRepository.getAnalysisResultsByYear(year);
      final filteredResults = foodScanResults.where((result) => result.userId == userId).toList();
      
      return _convertFoodAnalysisResults(filteredResults);
    } catch (e) {
      throw Exception('Failed to retrieve food logs by year: $e');
    }
  }

  @override
  Future<List<FoodLogHistoryItem>> searchFoodLogs(String userId, String query) async {
    try {
      final foodItems = await getAllFoodLogs(userId);
      final lowercaseQuery = query.toLowerCase();

      return foodItems.where((item) {
        return item.title.toLowerCase().contains(lowercaseQuery) ||
            item.subtitle.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search food logs: $e');
    }
  }

  List<FoodLogHistoryItem> _convertFoodAnalysisResults(
      List<FoodAnalysisResult> results) {
    return results
        .map((result) {
          // Add 7 hours to the timestamp to convert from UTC to Indonesia time (UTC+7)
          final localTimestamp = result.timestamp.add(const Duration(hours: 7));
          
          // Create a modified result with the adjusted timestamp
          final adjustedResult = FoodAnalysisResult(
            foodName: result.foodName,
            ingredients: result.ingredients,
            nutritionInfo: result.nutritionInfo,
            warnings: result.warnings,
            foodImageUrl: result.foodImageUrl,
            timestamp: localTimestamp,  // Use the adjusted timestamp
            id: result.id,
            isLowConfidence: result.isLowConfidence,
            userId: result.userId,
          );
          
          return FoodLogHistoryItem.fromFoodAnalysisResult(adjustedResult);
        })
        .toList();
  }

  @override
  Future<int> getFoodStreakDays(String userId) async {
  try {
    final DateTime today = DateTime.now();
    final DateTime startDate = today.subtract(const Duration(days: 100)); // Reasonable limit
    
    // Single query to get logs within date range
    final QuerySnapshot querySnapshot = await _firestore
        .collection('foodLogs')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: today)
        .orderBy('date', descending: true)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      return 0;
    }
    
    // Process logs in memory instead of multiple queries
    final Map<String, bool> daysWithLogs = {};
    for (var doc in querySnapshot.docs) {
      final DateTime date = (doc['date'] as Timestamp).toDate();
      final String dateKey = '${date.year}-${date.month}-${date.day}';
      daysWithLogs[dateKey] = true;
    }
    
    // Calculate streak
    int streakDays = 0;
    DateTime checkDate = today;
    
    // If no logs today, start from yesterday
    String checkDateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
    if (!daysWithLogs.containsKey(checkDateKey)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    // Count consecutive days
    bool streakContinues = true;
    while (streakContinues && streakDays < 100) {
      checkDateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
      if (daysWithLogs.containsKey(checkDateKey)) {
        streakDays++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        streakContinues = false;
      }
    }
    
    return streakDays;
  } catch (e) {
    debugPrint('Error getting streak days: $e');
    // Consider returning cached value if available
    return 0;
  }
}
}
