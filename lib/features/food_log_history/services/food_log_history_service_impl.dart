import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class FoodLogHistoryServiceImpl implements FoodLogHistoryService {
  final FoodScanRepository _foodScanRepository;

  FoodLogHistoryServiceImpl({
    required FoodScanRepository foodScanRepository,
  }) : _foodScanRepository = foodScanRepository;

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
  Future<bool> isFoodStreakMaintained(String userId) async {
    try {
      // Check today
      final today = DateTime.now();
      final todayLogs = await getFoodLogsByDate(userId, today);
      if (todayLogs.isNotEmpty) return true;

      // Check yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayLogs = await getFoodLogsByDate(userId, yesterday);
      return yesterdayLogs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getFoodStreakDays(String userId) async {
    try {
      int streakDays = 0;
      bool streakContinues = true;
      DateTime checkDate = DateTime.now();

      // If no logs today yet, start checking from yesterday
      final todayLogs = await getFoodLogsByDate(userId, checkDate);
      if (todayLogs.isEmpty) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Check consecutive days
      while (streakContinues && streakDays < 100) {
        final logs = await getFoodLogsByDate(userId, checkDate);

        if (logs.isNotEmpty) {
          streakDays++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          streakContinues = false;
        }
      }

      return streakDays;
    } catch (e) {
      return 0;
    }
  }
}
