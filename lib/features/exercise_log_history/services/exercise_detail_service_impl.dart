// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';

/// Implementasi dari ExerciseDetailService menggunakan komposisi repository
class ExerciseDetailServiceImpl implements ExerciseDetailService {
  late final CardioRepository _cardioRepository;
  late final SmartExerciseLogRepository _smartExerciseRepository;
  late final WeightLiftingRepository _weightLiftingRepository;
  final _getIt = GetIt.instance;

  /// Konstruktor dengan dependency injection dari GetIt
  ExerciseDetailServiceImpl() {
    _cardioRepository = _getIt<CardioRepository>();
    _smartExerciseRepository = _getIt<SmartExerciseLogRepository>();
    _weightLiftingRepository = _getIt<WeightLiftingRepository>();
  }

  @override
  Future<dynamic> getSmartExerciseDetail(String id) async {
    return await _smartExerciseRepository.getAnalysisResultFromId(id);
  }

  @override
  Future<T?> getCardioActivityDetail<T extends CardioActivity>(
      String id) async {
    final cardioActivity = await _cardioRepository.getCardioActivityById(id);

    if (cardioActivity == null) return null;

    // CardioActivityFactory di CardioRepository sudah melakukan konversi ke subclass yang tepat
    // sehingga kita hanya perlu mengecek tipe
    if (cardioActivity is T) {
      return cardioActivity;
    }

    throw Exception(
        'Requested type ${T.toString()} does not match actual type ${cardioActivity.runtimeType}');
  }

  @override
  Future<WeightLifting?> getWeightLiftingDetail(String id) async {
    return await _weightLiftingRepository.getExerciseById(id);
  }

  @override
  String getCardioTypeFromHistoryItem(ExerciseLogHistoryItem exerciseItem) {
    // Pastikan ini adalah tipe cardio
    if (exerciseItem.activityType != ExerciseLogHistoryItem.typeCardio) {
      return 'unknown';
    }

    // Mendeteksi tipe cardio dari judul
    final title = exerciseItem.title.toLowerCase();
    if (title.contains('running')) {
      return 'running';
    } else if (title.contains('cycling')) {
      return 'cycling';
    } else if (title.contains('swimming')) {
      return 'swimming';
    }

    return 'unknown';
  }

  @override
  Future<String> getActualActivityType(String id, String basicType) async {
    // Jika tipe dasar adalah smart_exercise, kembalikan itu langsung
    if (basicType == ExerciseLogHistoryItem.typeSmartExercise) {
      return ExerciseLogHistoryItem.typeSmartExercise;
    }

    // Jika tipe dasar adalah cardio, cek repository untuk mendapatkan tipe spesifik
    if (basicType == ExerciseLogHistoryItem.typeCardio) {
      final cardioActivity = await _cardioRepository.getCardioActivityById(id);

      if (cardioActivity == null) {
        return 'unknown';
      }

      // Tentukan tipe cardio berdasarkan instance
      switch (cardioActivity.type) {
        case CardioType.running:
          return 'running';
        case CardioType.cycling:
          return 'cycling';
        case CardioType.swimming:
          return 'swimming';
      }
    }

    // Jika tipe dasar adalah weightlifting, kembalikan tipe itu
    if (basicType == ExerciseLogHistoryItem.typeWeightlifting) {
      final weightLifting = await _weightLiftingRepository.getExerciseById(id);

      if (weightLifting == null) {
        return 'unknown';
      }

      return ExerciseLogHistoryItem.typeWeightlifting;
    }

    // Default jika tipe dasar tidak dikenali
    return 'unknown';
  }

  @override
  Future<bool> deleteExerciseLog(String id, String activityType) async {
    try {
      // Menggunakan pattern yang sesuai dengan desain komposisi
      if (activityType == ExerciseLogHistoryItem.typeSmartExercise) {
        // Gunakan repository SmartExerciseLog untuk menghapus
        return await _smartExerciseRepository.deleteById(id);
      } else if (activityType == ExerciseLogHistoryItem.typeCardio) {
        // Gunakan repository Cardio untuk menghapus
        final cardioResult = await _cardioRepository.deleteCardioActivity(id);
        return cardioResult;
      } else if (activityType == ExerciseLogHistoryItem.typeWeightlifting) {
        // Gunakan repository WeightLifting untuk menghapus
        final weightLiftingResult =
            await _weightLiftingRepository.deleteExercise(id);
        return weightLiftingResult;
      }

      // Jika tipe tidak dikenali, return false
      return false;
    } catch (e) {
      return false;
    }
  }
}
