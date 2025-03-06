import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/domain/repositories/exercise_log_history_repository.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';

/// Implementasi repository Exercise Log History
/// 
/// Repository ini menggunakan komposisi dari berbagai repository spesifik
/// (SmartExerciseLogRepository, dan di masa depan: WeightliftingLogRepository, CardioLogRepository)
/// untuk mengambil dan mengelola history log olahraga dari berbagai sumber
class ExerciseLogHistoryRepositoryImpl implements ExerciseLogHistoryRepository {
  final SmartExerciseLogRepository _smartExerciseLogRepository;
  // Di masa depan akan ditambahkan:
  // final WeightliftingLogRepository _weightliftingLogRepository;
  // final CardioLogRepository _cardioLogRepository;

  ExerciseLogHistoryRepositoryImpl({
    required SmartExerciseLogRepository smartExerciseLogRepository,
    // required WeightliftingLogRepository weightliftingLogRepository,
    // required CardioLogRepository cardioLogRepository,
  }) : _smartExerciseLogRepository = smartExerciseLogRepository;
      // _weightliftingLogRepository = weightliftingLogRepository,
      // _cardioLogRepository = cardioLogRepository;

  @override
  Future<List<ExerciseLogHistoryItem>> getAllExerciseLogs({int? limit}) async {
    try {
      // Ambil data dari SmartExerciseLog
      final smartExerciseLogs = await _smartExerciseLogRepository.getAllAnalysisResults(limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Di masa depan akan ditambahkan:
      // final weightliftingLogs = await _weightliftingLogRepository.getAllLogs(limit: limit);
      // final weightliftingItems = _convertWeightliftingLogs(weightliftingLogs);
      // 
      // final cardioLogs = await _cardioLogRepository.getAllLogs(limit: limit);
      // final cardioItems = _convertCardioLogs(cardioLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        // ...weightliftingItems,
        // ...cardioItems,
      ];

      // Urutkan berdasarkan timestamp (terbaru dulu)
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Terapkan limit jika ada
      if (limit != null && limit > 0 && allItems.length > limit) {
        return allItems.take(limit).toList();
      }

      return allItems;
    } catch (e) {
      throw Exception('Failed to retrieve exercise logs: $e');
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByDate(DateTime date, {int? limit}) async {
    try {
      // Ambil data dari SmartExerciseLog
      final smartExerciseLogs = await _smartExerciseLogRepository.getAnalysisResultsByDate(date, limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Di masa depan akan ditambahkan:
      // final weightliftingLogs = await _weightliftingLogRepository.getLogsByDate(date, limit: limit);
      // final weightliftingItems = _convertWeightliftingLogs(weightliftingLogs);
      // 
      // final cardioLogs = await _cardioLogRepository.getLogsByDate(date, limit: limit);
      // final cardioItems = _convertCardioLogs(cardioLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        // ...weightliftingItems,
        // ...cardioItems,
      ];

      // Urutkan berdasarkan timestamp (terbaru dulu)
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Terapkan limit jika ada
      if (limit != null && limit > 0 && allItems.length > limit) {
        return allItems.take(limit).toList();
      }

      return allItems;
    } catch (e) {
      throw Exception('Failed to retrieve exercise logs by date: $e');
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByMonth(int month, int year, {int? limit}) async {
    try {
      // Ambil data dari SmartExerciseLog
      final smartExerciseLogs = await _smartExerciseLogRepository.getAnalysisResultsByMonth(month, year, limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Di masa depan akan ditambahkan:
      // final weightliftingLogs = await _weightliftingLogRepository.getLogsByMonth(month, year, limit: limit);
      // final weightliftingItems = _convertWeightliftingLogs(weightliftingLogs);
      // 
      // final cardioLogs = await _cardioLogRepository.getLogsByMonth(month, year, limit: limit);
      // final cardioItems = _convertCardioLogs(cardioLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        // ...weightliftingItems,
        // ...cardioItems,
      ];

      // Urutkan berdasarkan timestamp (terbaru dulu)
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Terapkan limit jika ada
      if (limit != null && limit > 0 && allItems.length > limit) {
        return allItems.take(limit).toList();
      }

      return allItems;
    } catch (e) {
      throw Exception('Failed to retrieve exercise logs by month: $e');
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByYear(int year, {int? limit}) async {
    try {
      // Ambil data dari SmartExerciseLog
      final smartExerciseLogs = await _smartExerciseLogRepository.getAnalysisResultsByYear(year, limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Di masa depan akan ditambahkan:
      // final weightliftingLogs = await _weightliftingLogRepository.getLogsByYear(year, limit: limit);
      // final weightliftingItems = _convertWeightliftingLogs(weightliftingLogs);
      // 
      // final cardioLogs = await _cardioLogRepository.getLogsByYear(year, limit: limit);
      // final cardioItems = _convertCardioLogs(cardioLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        // ...weightliftingItems,
        // ...cardioItems,
      ];

      // Urutkan berdasarkan timestamp (terbaru dulu)
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Terapkan limit jika ada
      if (limit != null && limit > 0 && allItems.length > limit) {
        return allItems.take(limit).toList();
      }

      return allItems;
    } catch (e) {
      throw Exception('Failed to retrieve exercise logs by year: $e');
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByActivityCategory(String activityCategory, {int? limit}) async {
    try {
      List<ExerciseLogHistoryItem> result = [];

      // Ambil semua log terlebih dahulu
      final allLogs = await getAllExerciseLogs(limit: null); // Tidak terapkan limit dulu karena akan difilter
      
      // Filter berdasarkan activityCategory
      result = allLogs.where((item) => item.activityType == activityCategory).toList();

      // Terapkan limit jika ada
      if (limit != null && limit > 0 && result.length > limit) {
        return result.take(limit).toList();
      }

      return result;
    } catch (e) {
      throw Exception('Failed to retrieve exercise logs by activity category: $e');
    }
  }

  // Helper method untuk mengkonversi SmartExerciseLogs menjadi ExerciseLogHistoryItems
  List<ExerciseLogHistoryItem> _convertSmartExerciseLogs(List<ExerciseAnalysisResult> logs) {
    return logs.map((log) => ExerciseLogHistoryItem.fromSmartExerciseLog(log)).toList();
  }

  // Di masa depan akan ditambahkan:
  // List<ExerciseLogHistoryItem> _convertWeightliftingLogs(List<WeightliftingLog> logs) {
  //   return logs.map((log) => ExerciseLogHistoryItem.fromWeightliftingLog(log)).toList();
  // }
  // 
  // List<ExerciseLogHistoryItem> _convertCardioLogs(List<CardioLog> logs) {
  //   return logs.map((log) => ExerciseLogHistoryItem.fromCardioLog(log)).toList();
  // }
}
