import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';

/// Implementasi dari ExerciseDetailService menggunakan komposisi repository
class ExerciseDetailServiceImpl implements ExerciseDetailService {
  final CardioRepository _cardioRepository;
  final SmartExerciseLogRepository _smartExerciseRepository;
  final WeightLiftingRepository _weightLiftingRepository;

  /// Konstruktor dengan dependency injection
  ExerciseDetailServiceImpl({
    required CardioRepository cardioRepository,
    required SmartExerciseLogRepository smartExerciseRepository,
    required WeightLiftingRepository weightLiftingRepository,
  })  : _cardioRepository = cardioRepository,
        _smartExerciseRepository = smartExerciseRepository,
        _weightLiftingRepository = weightLiftingRepository;

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
    if (exerciseItem.activityType != ExerciseLogHistoryItem.TYPE_CARDIO) {
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
    if (basicType == ExerciseLogHistoryItem.TYPE_SMART_EXERCISE) {
      return ExerciseLogHistoryItem.TYPE_SMART_EXERCISE;
    }

    // Jika tipe dasar adalah cardio, cek repository untuk mendapatkan tipe spesifik
    if (basicType == ExerciseLogHistoryItem.TYPE_CARDIO) {
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
    if (basicType == ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING) {
      final weightLifting = await _weightLiftingRepository.getExerciseById(id);
      
      if (weightLifting == null) {
        return 'unknown';
      }
      
      return ExerciseLogHistoryItem.TYPE_WEIGHTLIFTING;
    }

    // Default jika tipe dasar tidak dikenali
    return 'unknown';
  }
}
