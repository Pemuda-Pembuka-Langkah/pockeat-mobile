// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';

class ExerciseLogHistoryServiceImpl implements ExerciseLogHistoryService {
  late final SmartExerciseLogRepository _smartExerciseLogRepository;
  late final CardioRepository _cardioRepository;
  late final WeightLiftingRepository _weightLiftingRepository;
  final _getIt = GetIt.instance;
  // ignore: unused_field
  final FirebaseAuth _auth;

  ExerciseLogHistoryServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance {
    _smartExerciseLogRepository = _getIt<SmartExerciseLogRepository>();
    _cardioRepository = _getIt<CardioRepository>();
    _weightLiftingRepository = _getIt<WeightLiftingRepository>();
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getAllExerciseLogs(String userId,
      {int? limit}) async {
    try {
      // Get smart exercise logs
      final smartExerciseLogs = await _smartExerciseLogRepository
          .getAnalysisResultsByUser(userId, limit: limit);
      final smartExerciseItems = _convertSmartExerciseLogs(smartExerciseLogs);

      // Get cardio logs
      final cardioLogs = await _cardioRepository.getActivitiesByUser(userId);
      final cardioItems = _convertCardioLogs(cardioLogs);

      // Get weightlifting logs
      final weightLiftingLogs =
          await _weightLiftingRepository.getExercisesByUser(userId);
      final weightLiftingItems = _convertWeightLiftingLogs(weightLiftingLogs);

      // Combine items
      final allItems = <ExerciseLogHistoryItem>[
        ...smartExerciseItems,
        ...cardioItems,
        ...weightLiftingItems,
      ];

      // Sort by timestamp (newest first)
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply limit if needed
      if (limit != null && limit > 0 && allItems.length > limit) {
        return allItems.take(limit).toList();
      }

      return allItems;
    } catch (e) {
      // Return empty list on error instead of throwing
      return [];
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByDate(
      String userId, DateTime date) async {
    try {
      // Get smart exercise logs for this date and user
      final smartLogs =
          await _smartExerciseLogRepository.getAnalysisResultsByDate(date);
      final filteredSmartLogs =
          smartLogs.where((log) => log.userId == userId).toList();
      final smartItems = _convertSmartExerciseLogs(filteredSmartLogs);

      // Get cardio activities for this date
      final cardioLogs = await _cardioRepository.filterByDate(date);
      final filteredCardioLogs =
          cardioLogs.where((log) => log.userId == userId).toList();
      final cardioItems = _convertCardioLogs(filteredCardioLogs);

      // Get weightlifting exercises for this date
      final weightLiftingLogs =
          await _weightLiftingRepository.filterByDate(date);
      final filteredWeightLiftingLogs =
          weightLiftingLogs.where((log) => log.userId == userId).toList();
      final weightLiftingItems =
          _convertWeightLiftingLogs(filteredWeightLiftingLogs);

      // Combine all logs
      final allLogs = [
        ...smartItems,
        ...cardioItems,
        ...weightLiftingItems,
      ];

      // Sort by timestamp (newest first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      print("allLogs: $allLogs");
      return allLogs;
    } catch (e) {
      // Return empty list instead of throwing
      return [];
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByMonth(
      String userId, int month, int year) async {
    try {
      // Get smart exercise logs for this month
      final smartLogs = await _smartExerciseLogRepository
          .getAnalysisResultsByMonth(month, year);
      final filteredSmartLogs =
          smartLogs.where((log) => log.userId == userId).toList();
      final smartItems = _convertSmartExerciseLogs(filteredSmartLogs);

      // Get cardio activities for this month
      final cardioLogs = await _cardioRepository.filterByMonth(month, year);
      final filteredCardioLogs =
          cardioLogs.where((log) => log.userId == userId).toList();
      final cardioItems = _convertCardioLogs(filteredCardioLogs);

      // Get weightlifting exercises for this month
      final weightLiftingLogs =
          await _weightLiftingRepository.filterByMonth(month, year);
      final filteredWeightLiftingLogs =
          weightLiftingLogs.where((log) => log.userId == userId).toList();
      final weightLiftingItems =
          _convertWeightLiftingLogs(filteredWeightLiftingLogs);

      // Combine all logs
      final allLogs = [
        ...smartItems,
        ...cardioItems,
        ...weightLiftingItems,
      ];

      // Sort by timestamp (newest first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allLogs;
    } catch (e) {
      // Return empty list instead of throwing
      return [];
    }
  }

  @override
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByYear(
      String userId, int year) async {
    try {
      // Get smart exercise logs for this year
      final smartLogs =
          await _smartExerciseLogRepository.getAnalysisResultsByYear(year);
      final filteredSmartLogs =
          smartLogs.where((log) => log.userId == userId).toList();
      final smartItems = _convertSmartExerciseLogs(filteredSmartLogs);

      // Get cardio activities for this year
      final cardioLogs = await _cardioRepository.filterByYear(year);
      final filteredCardioLogs =
          cardioLogs.where((log) => log.userId == userId).toList();
      final cardioItems = _convertCardioLogs(filteredCardioLogs);

      // Get weightlifting exercises for this year
      final weightLiftingLogs =
          await _weightLiftingRepository.filterByYear(year);
      final filteredWeightLiftingLogs =
          weightLiftingLogs.where((log) => log.userId == userId).toList();
      final weightLiftingItems =
          _convertWeightLiftingLogs(filteredWeightLiftingLogs);

      // Combine all logs
      final allLogs = [
        ...smartItems,
        ...cardioItems,
        ...weightLiftingItems,
      ];

      // Sort by timestamp (newest first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allLogs;
    } catch (e) {
      // Return empty list instead of throwing
      return [];
    }
  }

  // Helper methods remain the same
  List<ExerciseLogHistoryItem> _convertSmartExerciseLogs(
      List<ExerciseAnalysisResult> logs) {
    return logs
        .map((log) => ExerciseLogHistoryItem.fromSmartExerciseLog(log))
        .toList();
  }

  List<ExerciseLogHistoryItem> _convertCardioLogs(List<CardioActivity> logs) {
    return logs
        .map((log) => ExerciseLogHistoryItem.fromCardioLog(log))
        .toList();
  }

  List<ExerciseLogHistoryItem> _convertWeightLiftingLogs(
      List<WeightLifting> logs) {
    return logs
        .map((log) => ExerciseLogHistoryItem.fromWeightliftingLog(log))
        .toList();
  }
}
