import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';

/// Implementasi repository Exercise Log History
///
/// Repository ini menggunakan komposisi dari berbagai repository spesifik
/// (SmartExerciseLogRepository, CardioLogRepository, dan di masa depan: WeightliftingLogRepository)
/// untuk mengambil dan mengelola history log olahraga dari berbagai sumber
class ExerciseLogHistoryServiceImpl implements ExerciseLogHistoryService {
  final SmartExerciseLogRepository _smartExerciseLogRepository;
  final CardioRepository _cardioRepository;
  // Di masa depan akan ditambahkan:
  // final WeightliftingLogRepository _weightliftingLogRepository;

  ExerciseLogHistoryServiceImpl({
    required SmartExerciseLogRepository smartExerciseLogRepository,
    required CardioRepository cardioRepository,
    // required WeightliftingLogRepository weightliftingLogRepository,
  }) : _smartExerciseLogRepository = smartExerciseLogRepository,
       _cardioRepository = cardioRepository;
  // _weightliftingLogRepository = weightliftingLogRepository;

  @override
  Future<List<ExerciseLogHistoryItem>> getAllExerciseLogs({int? limit}) async {
    try {
      // Ambil data dari SmartExerciseLog
      final smartExerciseLogs =
          await _smartExerciseLogRepository.getAllAnalysisResults(limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Ambil data dari CardioLog
      final cardioLogs = await _cardioRepository.getAllCardioActivities();
      final cardioItems = _convertCardioLogs(cardioLogs);

      // Di masa depan akan ditambahkan:
      // final weightliftingLogs = await _weightliftingLogRepository.getAllLogs(limit: limit);
      // final weightliftingItems = _convertWeightliftingLogs(weightliftingLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        ...cardioItems,
        // ...weightliftingItems,
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
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByDate(DateTime date,
      {int? limit}) async {
    try {
      // Ambil data dari SmartExerciseLog
      final smartExerciseLogs = await _smartExerciseLogRepository
          .getAnalysisResultsByDate(date, limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Ambil data dari CardioLog
      final cardioLogs = await _cardioRepository.filterByDate(date);
      final cardioItems = _convertCardioLogs(cardioLogs);

      // Di masa depan akan ditambahkan:
      // final weightliftingLogs = await _weightliftingLogRepository.getLogsByDate(date, limit: limit);
      // final weightliftingItems = _convertWeightliftingLogs(weightliftingLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        ...cardioItems,
        // ...weightliftingItems,
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
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByMonth(
      int month, int year,
      {int? limit}) async {
    try {
      // Ambil data dari SmartExerciseLog
      final smartExerciseLogs = await _smartExerciseLogRepository
          .getAnalysisResultsByMonth(month, year, limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Ambil data dari CardioLog
      final cardioLogs = await _cardioRepository.filterByMonth(month, year);
      final cardioItems = _convertCardioLogs(cardioLogs);

      // Di masa depan akan ditambahkan:
      // final weightliftingLogs = await _weightliftingLogRepository.getLogsByMonth(month, year, limit: limit);
      // final weightliftingItems = _convertWeightliftingLogs(weightliftingLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        ...cardioItems,
        // ...weightliftingItems,
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
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByYear(int year,
      {int? limit}) async {
    try {
      // Ambil data dari SmartExerciseLog
      final smartExerciseLogs = await _smartExerciseLogRepository
          .getAnalysisResultsByYear(year, limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Ambil data dari CardioLog
      final cardioLogs = await _cardioRepository.filterByYear(year);
      final cardioItems = _convertCardioLogs(cardioLogs);

      // Di masa depan akan ditambahkan:
      // final weightliftingLogs = await _weightliftingLogRepository.getLogsByYear(year, limit: limit);
      // final weightliftingItems = _convertWeightliftingLogs(weightliftingLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        ...cardioItems,
        // ...weightliftingItems,
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
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByActivityCategory(
      String activityCategory,
      {int? limit}) async {
    try {
      List<ExerciseLogHistoryItem> result = [];

      // Ambil semua log terlebih dahulu
      final allLogs = await getAllExerciseLogs(
          limit: null); // Tidak terapkan limit dulu karena akan difilter

      // Filter berdasarkan activityCategory
      result = allLogs
          .where((item) => item.activityType == activityCategory)
          .toList();

      // Terapkan limit jika ada
      if (limit != null && limit > 0 && result.length > limit) {
        return result.take(limit).toList();
      }

      return result;
    } catch (e) {
      throw Exception(
          'Failed to retrieve exercise logs by activity category: $e');
    }
  }

  // Helper method untuk mengkonversi SmartExerciseLogs menjadi ExerciseLogHistoryItems
  List<ExerciseLogHistoryItem> _convertSmartExerciseLogs(
      List<ExerciseAnalysisResult> logs) {
    return logs
        .map((log) => ExerciseLogHistoryItem.fromSmartExerciseLog(log))
        .toList();
  }

  // Helper method untuk mengkonversi CardioLogs menjadi ExerciseLogHistoryItems
  List<ExerciseLogHistoryItem> _convertCardioLogs(List<CardioActivity> logs) {
    return logs
        .map((log) => ExerciseLogHistoryItem.fromCardioLog(log))
        .toList();
  }

  // Di masa depan akan ditambahkan:
  // List<ExerciseLogHistoryItem> _convertWeightliftingLogs(List<WeightliftingLog> logs) {
  //   return logs.map((log) => ExerciseLogHistoryItem.fromWeightliftingLog(log)).toList();
  // }
}
