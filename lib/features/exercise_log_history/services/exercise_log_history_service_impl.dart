import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:get_it/get_it.dart';

/// Implementasi repository Exercise Log History
///
/// Repository ini menggunakan komposisi dari berbagai repository spesifik
/// (SmartExerciseLogRepository, CardioLogRepository, dan di masa depan: WeightliftingLogRepository)
/// untuk mengambil dan mengelola history log olahraga dari berbagai sumber
class ExerciseLogHistoryServiceImpl implements ExerciseLogHistoryService {
  late final SmartExerciseLogRepository _smartExerciseLogRepository;
  late final CardioRepository _cardioRepository;
  late final WeightLiftingRepository _weightLiftingRepository;
  final _getIt = GetIt.instance;

  ExerciseLogHistoryServiceImpl() {
    _smartExerciseLogRepository = _getIt<SmartExerciseLogRepository>();
    _cardioRepository = _getIt<CardioRepository>();
    _weightLiftingRepository = _getIt<WeightLiftingRepository>();
  }

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

      // Ambil data dari WeightLiftingLogs
      final weightLiftingLogs =
          await _weightLiftingRepository.getAllExercises();
      final weightLiftingItems = _convertWeightLiftingLogs(weightLiftingLogs);

      // Gabungkan semua item
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        ...cardioItems,
        ...weightLiftingItems,
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
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByDate(
      DateTime date) async {
    try {
      // Get smart exercise logs for this date
      final smartLogs =
          await _smartExerciseLogRepository.getAnalysisResultsByDate(date);
      final smartItems = _convertSmartExerciseLogs(smartLogs);

      // Get cardio activities for this date
      final cardioLogs = await _cardioRepository.filterByDate(date);
      final cardioItems = _convertCardioLogs(cardioLogs);

      // Get weightlifting exercises for this date
      final weightLiftingLogs =
          await _weightLiftingRepository.filterByDate(date);
      final weightLiftingItems = _convertWeightLiftingLogs(weightLiftingLogs);

      // Combine all logs
      final List<ExerciseLogHistoryItem> allLogs = [
        ...smartItems,
        ...cardioItems,
        ...weightLiftingItems,
      ];

      // Sort by timestamp (newest first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allLogs;
    } catch (e) {
      throw Exception('Failed to retrieve exercise logs by date: $e');
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByMonth(
      int month, int year) async {
    try {
      // Get smart exercise logs for this month
      final smartLogs = await _smartExerciseLogRepository
          .getAnalysisResultsByMonth(month, year);
      final smartItems = _convertSmartExerciseLogs(smartLogs);

      // Get cardio activities for this month
      final cardioLogs = await _cardioRepository.filterByMonth(month, year);
      final cardioItems = _convertCardioLogs(cardioLogs);

      // Get weightlifting exercises for this month
      final weightLiftingLogs =
          await _weightLiftingRepository.filterByMonth(month, year);
      final weightLiftingItems = _convertWeightLiftingLogs(weightLiftingLogs);

      // Combine all logs
      final List<ExerciseLogHistoryItem> allLogs = [
        ...smartItems,
        ...cardioItems,
        ...weightLiftingItems,
      ];

      // Sort by timestamp (newest first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allLogs;
    } catch (e) {
      throw Exception('Failed to retrieve exercise logs by month: $e');
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByYear(int year) async {
    try {
      // Get smart exercise logs for this year
      final smartLogs =
          await _smartExerciseLogRepository.getAnalysisResultsByYear(year);
      final smartItems = _convertSmartExerciseLogs(smartLogs);

      // Get cardio activities for this year
      final cardioLogs = await _cardioRepository.filterByYear(year);
      final cardioItems = _convertCardioLogs(cardioLogs);

      // Get weightlifting exercises for this year
      final weightLiftingLogs =
          await _weightLiftingRepository.filterByYear(year);
      final weightLiftingItems = _convertWeightLiftingLogs(weightLiftingLogs);

      // Combine all logs
      final List<ExerciseLogHistoryItem> allLogs = [
        ...smartItems,
        ...cardioItems,
        ...weightLiftingItems,
      ];

      // Sort by timestamp (newest first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allLogs;
    } catch (e) {
      throw Exception('Failed to retrieve exercise logs by year: $e');
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

  // Helper method untuk mengkonversi WeightLiftingLogs menjadi ExerciseLogHistoryItems
  List<ExerciseLogHistoryItem> _convertWeightLiftingLogs(
      List<WeightLifting> logs) {
    return logs
        .map((log) => ExerciseLogHistoryItem.fromWeightliftingLog(log))
        .toList();
  }
}
