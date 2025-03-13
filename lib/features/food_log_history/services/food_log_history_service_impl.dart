import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

/// Implementasi service Food Log History
///
/// Service ini menggunakan komposisi dari berbagai repository spesifik
/// (FoodScanRepository dan di masa depan repository lainnya)
/// untuk mengambil dan mengelola history log makanan dari berbagai sumber
class FoodLogHistoryServiceImpl implements FoodLogHistoryService {
  final FoodScanRepository _foodScanRepository;

  FoodLogHistoryServiceImpl({
    required FoodScanRepository foodScanRepository,
  }) : _foodScanRepository = foodScanRepository;

  @override
  Future<List<FoodLogHistoryItem>> getAllFoodLogs({int? limit}) async {
    try {
      // Ambil data dari FoodScanRepository
      final foodAnalysisResults =
          await _foodScanRepository.getAll(limit: limit);
      
      final foodItems = _convertFoodAnalysisResults(foodAnalysisResults);
      
      // Urutkan berdasarkan timestamp terbaru
      foodItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Batasi jumlah item jika diperlukan
      if (limit != null && foodItems.length > limit) {
        return foodItems.sublist(0, limit);
      }

      return foodItems;
    } catch (e) {
      throw Exception('Failed to retrieve food logs: $e');
    }
  }

  @override
  Future<List<FoodLogHistoryItem>> getFoodLogsByDate(DateTime date) async {
    try {
      // Ambil data dari FoodScanRepository untuk tanggal tertentu
      final foodAnalysisResults =
          await _foodScanRepository.getAnalysisResultsByDate(date);
      
      final foodItems = _convertFoodAnalysisResults(foodAnalysisResults);

      return foodItems;
    } catch (e) {
      throw Exception('Failed to retrieve food logs by date: $e');
    }
  }

  @override
  Future<List<FoodLogHistoryItem>> getFoodLogsByMonth(
      int month, int year) async {
    try {
      // Ambil data dari FoodScanRepository untuk bulan dan tahun tertentu
      final foodAnalysisResults =
          await _foodScanRepository.getAnalysisResultsByMonth(month, year);
      
      final foodItems = _convertFoodAnalysisResults(foodAnalysisResults);

      return foodItems;
    } catch (e) {
      throw Exception('Failed to retrieve food logs by month: $e');
    }
  }

  @override
  Future<List<FoodLogHistoryItem>> getFoodLogsByYear(int year) async {
    try {
      // Ambil data dari FoodScanRepository untuk tahun tertentu
      final foodAnalysisResults =
          await _foodScanRepository.getAnalysisResultsByYear(year);
      
      final foodItems = _convertFoodAnalysisResults(foodAnalysisResults);

      return foodItems;
    } catch (e) {
      throw Exception('Failed to retrieve food logs by year: $e');
    }
  }
  
  @override
  Future<List<FoodLogHistoryItem>> searchFoodLogs(String query) async {
    try {
      // Ambil semua data terlebih dahulu
      final foodItems = await getAllFoodLogs();
      
      // Filter berdasarkan query
      final lowercaseQuery = query.toLowerCase();
      final filteredItems = foodItems.where((item) {
        return item.title.toLowerCase().contains(lowercaseQuery) ||
            item.subtitle.toLowerCase().contains(lowercaseQuery);
      }).toList();
      
      return filteredItems;
    } catch (e) {
      throw Exception('Failed to search food logs: $e');
    }
  }

  // Helper method untuk mengkonversi FoodAnalysisResult menjadi FoodLogHistoryItem
  List<FoodLogHistoryItem> _convertFoodAnalysisResults(
      List<FoodAnalysisResult> results) {
    return results
        .map((result) => FoodLogHistoryItem.fromFoodAnalysisResult(result))
        .toList();
  }
}
