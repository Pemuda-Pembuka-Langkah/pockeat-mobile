import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

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
        .map((result) => FoodLogHistoryItem.fromFoodAnalysisResult(result))
        .toList();
  }
}
