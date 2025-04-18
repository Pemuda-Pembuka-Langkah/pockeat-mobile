import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/repositories/exercise_progress_repository_impl.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/services/exercise_progress_service.dart';

class ExerciseProgressModule {
  static void register() {
    final getIt = GetIt.instance;
    
    // Register repository
    if (!getIt.isRegistered<ExerciseProgressRepository>()) {
      getIt.registerSingleton<ExerciseProgressRepository>(
        ExerciseProgressRepositoryImpl(
          exerciseLogHistoryService: getIt<ExerciseLogHistoryService>(),
          auth: FirebaseAuth.instance,
        )
      );
    }
    
    // Register service
    if (!getIt.isRegistered<ExerciseProgressService>()) {
      getIt.registerSingleton<ExerciseProgressService>(
        ExerciseProgressService(
          repository: getIt<ExerciseProgressRepository>(),
        )
      );
    }
  }
}