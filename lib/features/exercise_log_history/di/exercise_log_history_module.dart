import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service_impl.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository_impl.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository_impl.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository_impl.dart';
// coverage:ignore-start
class ExerciseLogHistoryModule {
  static void register() {
    final getIt = GetIt.instance;
    final firestore = FirebaseFirestore.instance;

    // Register repositories if not already registered
    if (!getIt.isRegistered<SmartExerciseLogRepository>()) {
      getIt.registerSingleton<SmartExerciseLogRepository>(
        SmartExerciseLogRepositoryImpl(firestore: firestore),
      );
    }

    if (!getIt.isRegistered<CardioRepository>()) {
      getIt.registerSingleton<CardioRepository>(
        CardioRepositoryImpl(firestore: firestore),
      );
    }

    if (!getIt.isRegistered<WeightLiftingRepository>()) {
      getIt.registerSingleton<WeightLiftingRepository>(
        WeightLiftingRepositoryImpl(firestore: firestore),
      );
    }

    // Register ExerciseLogHistoryService
    if (!getIt.isRegistered<ExerciseLogHistoryService>()) {
      getIt.registerSingleton<ExerciseLogHistoryService>(
        ExerciseLogHistoryServiceImpl(),
      );
    }

    // Register ExerciseDetailService
    if (!getIt.isRegistered<ExerciseDetailService>()) {
      getIt.registerSingleton<ExerciseDetailService>(
        ExerciseDetailServiceImpl(),
      );
    }
  }
}
 // coverage:ignore-end