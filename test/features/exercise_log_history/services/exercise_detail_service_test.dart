import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';

// Generate mocks for repositories
@GenerateMocks(
    [CardioRepository, SmartExerciseLogRepository, WeightLiftingRepository])
import 'exercise_detail_service_test.mocks.dart';

void main() {
  group('ExerciseDetailService Implementation Tests', () {
    late MockCardioRepository mockCardioRepository;
    late MockSmartExerciseLogRepository mockSmartExerciseRepository;
    late MockWeightLiftingRepository mockWeightLiftingRepository;
    late ExerciseDetailService exerciseDetailService;
    final getIt = GetIt.instance;

    // Sample data for testing
    final runningActivity = RunningActivity(
      id: 'run-1',
      date: DateTime(2025, 3, 1),
      startTime: DateTime(2025, 3, 1, 8, 0),
      endTime: DateTime(2025, 3, 1, 8, 30),
      distanceKm: 5.0,
      caloriesBurned: 350,
    );

    final cyclingActivity = CyclingActivity(
      id: 'cycle-1',
      date: DateTime(2025, 3, 2),
      startTime: DateTime(2025, 3, 2, 10, 0),
      endTime: DateTime(2025, 3, 2, 11, 0),
      distanceKm: 20.0,
      cyclingType: CyclingType.commute,
      caloriesBurned: 450,
    );

    final swimmingActivity = SwimmingActivity(
      id: 'swim-1',
      date: DateTime(2025, 3, 3),
      startTime: DateTime(2025, 3, 3, 16, 0),
      endTime: DateTime(2025, 3, 3, 16, 45),
      laps: 20,
      poolLength: 50.0,
      stroke: 'freestyle',
      caloriesBurned: 500,
    );

    final smartExerciseResult = ExerciseAnalysisResult(
      id: 'smart-1',
      exerciseType: 'Push-ups',
      duration: '15 min',
      intensity: 'High',
      estimatedCalories: 120,
      metValue: 8.0,
      timestamp: DateTime(2025, 3, 4),
      originalInput: 'I did push-ups for 15 minutes',
    );

    // Create a sample weight lifting exercise with a set
    final weightLiftingSet = WeightLiftingSet(
      weight: 60.0,
      reps: 12,
      duration: 45.0,
    );

    final weightLiftingExercise = WeightLifting(
      id: 'weight-1',
      name: 'Bench Press',
      bodyPart: 'Chest',
      metValue: 6.0,
      timestamp: DateTime(2025, 3, 5),
      sets: [weightLiftingSet],
    );

    setUp(() {
      mockCardioRepository = MockCardioRepository();
      mockSmartExerciseRepository = MockSmartExerciseLogRepository();
      mockWeightLiftingRepository = MockWeightLiftingRepository();

      // Register mocks in GetIt
      if (getIt.isRegistered<CardioRepository>()) {
        getIt.unregister<CardioRepository>();
      }
      getIt.registerSingleton<CardioRepository>(mockCardioRepository);

      if (getIt.isRegistered<SmartExerciseLogRepository>()) {
        getIt.unregister<SmartExerciseLogRepository>();
      }
      getIt.registerSingleton<SmartExerciseLogRepository>(
          mockSmartExerciseRepository);

      if (getIt.isRegistered<WeightLiftingRepository>()) {
        getIt.unregister<WeightLiftingRepository>();
      }
      getIt.registerSingleton<WeightLiftingRepository>(
          mockWeightLiftingRepository);

      // Register service
      if (getIt.isRegistered<ExerciseDetailService>()) {
        getIt.unregister<ExerciseDetailService>();
      }
      getIt.registerSingleton<ExerciseDetailService>(
        ExerciseDetailServiceImpl(),
      );

      exerciseDetailService = getIt<ExerciseDetailService>();
    });

    tearDown(() {
      // Reset GetIt
      getIt.reset();
    });

    group('Smart Exercise Detail Tests', () {
      test('getSmartExerciseDetail should return exercise data when found',
          () async {
        // Arrange
        when(mockSmartExerciseRepository.getAnalysisResultFromId('smart-1'))
            .thenAnswer((_) async => smartExerciseResult);

        // Act
        final result =
            await exerciseDetailService.getSmartExerciseDetail('smart-1');

        // Assert
        expect(result, equals(smartExerciseResult));
        verify(mockSmartExerciseRepository.getAnalysisResultFromId('smart-1'))
            .called(1);
      });

      test('getSmartExerciseDetail should return null when not found',
          () async {
        // Arrange
        when(mockSmartExerciseRepository
                .getAnalysisResultFromId('non-existent'))
            .thenAnswer((_) async => null);

        // Act
        final result =
            await exerciseDetailService.getSmartExerciseDetail('non-existent');

        // Assert
        expect(result, isNull);
        verify(mockSmartExerciseRepository
                .getAnalysisResultFromId('non-existent'))
            .called(1);
      });
    });

    group('Cardio Activity Detail Tests', () {
      test('getCardioActivityDetail should return running activity', () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('run-1'))
            .thenAnswer((_) async => runningActivity);

        // Act
        final result = await exerciseDetailService
            .getCardioActivityDetail<RunningActivity>('run-1');

        // Assert
        expect(result, isA<RunningActivity>());
        expect(result?.id, equals('run-1'));
        verify(mockCardioRepository.getCardioActivityById('run-1')).called(1);
      });

      test('getCardioActivityDetail should return cycling activity', () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('cycle-1'))
            .thenAnswer((_) async => cyclingActivity);

        // Act
        final result = await exerciseDetailService
            .getCardioActivityDetail<CyclingActivity>('cycle-1');

        // Assert
        expect(result, isA<CyclingActivity>());
        expect(result?.id, equals('cycle-1'));
        verify(mockCardioRepository.getCardioActivityById('cycle-1')).called(1);
      });

      test('getCardioActivityDetail should return swimming activity', () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('swim-1'))
            .thenAnswer((_) async => swimmingActivity);

        // Act
        final result = await exerciseDetailService
            .getCardioActivityDetail<SwimmingActivity>('swim-1');

        // Assert
        expect(result, isA<SwimmingActivity>());
        expect(result?.id, equals('swim-1'));
        verify(mockCardioRepository.getCardioActivityById('swim-1')).called(1);
      });

      test('getCardioActivityDetail should throw when type mismatch', () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('run-1'))
            .thenAnswer((_) async => runningActivity);

        // Act & Assert
        expect(
          () => exerciseDetailService
              .getCardioActivityDetail<CyclingActivity>('run-1'),
          throwsA(isA<Exception>()),
        );
        verify(mockCardioRepository.getCardioActivityById('run-1')).called(1);
      });

      test('getCardioActivityDetail should return null when activity not found',
          () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('non-existent'))
            .thenAnswer((_) async => null);

        // Act
        final result = await exerciseDetailService
            .getCardioActivityDetail<RunningActivity>('non-existent');

        // Assert
        expect(result, isNull);
        verify(mockCardioRepository.getCardioActivityById('non-existent'))
            .called(1);
      });
    });

    group('Cardio Type Detection Tests', () {
      test('getCardioTypeFromHistoryItem should detect running from title', () {
        // Arrange
        final historyItem = ExerciseLogHistoryItem(
          id: 'run-1',
          title: 'Morning Running Session',
          subtitle: 'Morning run in the park',
          timestamp: DateTime(2025, 3, 1),
          activityType: ExerciseLogHistoryItem.typeCardio,
          caloriesBurned: 350,
          sourceId: 'run-src-1',
        );

        // Act
        final result =
            exerciseDetailService.getCardioTypeFromHistoryItem(historyItem);

        // Assert
        expect(result, equals('running'));
      });

      test('getCardioTypeFromHistoryItem should detect cycling from title', () {
        // Arrange
        final historyItem = ExerciseLogHistoryItem(
          id: 'cycle-1',
          title: 'Cycling to Work',
          subtitle: 'Commute cycling',
          timestamp: DateTime(2025, 3, 2),
          activityType: ExerciseLogHistoryItem.typeCardio,
          caloriesBurned: 450,
          sourceId: 'cycle-src-1',
        );

        // Act
        final result =
            exerciseDetailService.getCardioTypeFromHistoryItem(historyItem);

        // Assert
        expect(result, equals('cycling'));
      });

      test('getCardioTypeFromHistoryItem should detect swimming from title',
          () {
        // Arrange
        final historyItem = ExerciseLogHistoryItem(
          id: 'swim-1',
          title: 'Swimming Session',
          subtitle: 'Freestyle laps',
          timestamp: DateTime(2025, 3, 3),
          activityType: ExerciseLogHistoryItem.typeCardio,
          caloriesBurned: 500,
          sourceId: 'swim-src-1',
        );

        // Act
        final result =
            exerciseDetailService.getCardioTypeFromHistoryItem(historyItem);

        // Assert
        expect(result, equals('swimming'));
      });

      test(
          'getCardioTypeFromHistoryItem should return unknown for non-cardio type',
          () {
        // Arrange
        final historyItem = ExerciseLogHistoryItem(
          id: 'smart-1',
          title: 'Push-ups Session',
          subtitle: 'Strength training',
          timestamp: DateTime(2025, 3, 4),
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
          caloriesBurned: 120,
          sourceId: 'smart-src-1',
        );

        // Act
        final result =
            exerciseDetailService.getCardioTypeFromHistoryItem(historyItem);

        // Assert
        expect(result, equals('unknown'));
      });
    });

    group('Actual Activity Type Tests', () {
      test('getActualActivityType should return smart_exercise type directly',
          () async {
        // Act
        final result = await exerciseDetailService.getActualActivityType(
            'smart-1', ExerciseLogHistoryItem.typeSmartExercise);

        // Assert
        expect(result, equals(ExerciseLogHistoryItem.typeSmartExercise));
        verifyZeroInteractions(mockCardioRepository);
      });

      test('getActualActivityType should detect running for cardio type',
          () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('run-1'))
            .thenAnswer((_) async => runningActivity);

        // Act
        final result = await exerciseDetailService.getActualActivityType(
            'run-1', ExerciseLogHistoryItem.typeCardio);

        // Assert
        expect(result, equals('running'));
        verify(mockCardioRepository.getCardioActivityById('run-1')).called(1);
      });

      test('getActualActivityType should detect cycling for cardio type',
          () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('cycle-1'))
            .thenAnswer((_) async => cyclingActivity);

        // Act
        final result = await exerciseDetailService.getActualActivityType(
            'cycle-1', ExerciseLogHistoryItem.typeCardio);

        // Assert
        expect(result, equals('cycling'));
        verify(mockCardioRepository.getCardioActivityById('cycle-1')).called(1);
      });

      test('getActualActivityType should detect swimming for cardio type',
          () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('swim-1'))
            .thenAnswer((_) async => swimmingActivity);

        // Act
        final result = await exerciseDetailService.getActualActivityType(
            'swim-1', ExerciseLogHistoryItem.typeCardio);

        // Assert
        expect(result, equals('swimming'));
        verify(mockCardioRepository.getCardioActivityById('swim-1')).called(1);
      });

      test(
          'getActualActivityType should return unknown when cardio activity not found',
          () async {
        // Arrange
        when(mockCardioRepository.getCardioActivityById('non-existent'))
            .thenAnswer((_) async => null);

        // Act
        final result = await exerciseDetailService.getActualActivityType(
            'non-existent', ExerciseLogHistoryItem.typeCardio);

        // Assert
        expect(result, equals('unknown'));
        verify(mockCardioRepository.getCardioActivityById('non-existent'))
            .called(1);
      });

      test('getActualActivityType should identify weightlifting type correctly',
          () async {
        // Arrange
        when(mockWeightLiftingRepository.getExerciseById('weight-1'))
            .thenAnswer((_) async => weightLiftingExercise);

        // Act
        final result = await exerciseDetailService.getActualActivityType(
            'weight-1', ExerciseLogHistoryItem.typeWeightlifting);

        // Assert
        expect(result, equals(ExerciseLogHistoryItem.typeWeightlifting));
        verify(mockWeightLiftingRepository.getExerciseById('weight-1'))
            .called(1);
      });

      test(
          'getActualActivityType should return unknown for non-existent weightlifting',
          () async {
        // Arrange
        when(mockWeightLiftingRepository.getExerciseById('non-existent'))
            .thenAnswer((_) async => null);

        // Act
        final result = await exerciseDetailService.getActualActivityType(
            'non-existent', ExerciseLogHistoryItem.typeWeightlifting);

        // Assert
        expect(result, equals('unknown'));
        verify(mockWeightLiftingRepository.getExerciseById('non-existent'))
            .called(1);
      });
    });

    group('Weight Lifting Detail Tests', () {
      test(
          'getWeightLiftingDetail should return weight lifting exercise when found',
          () async {
        // Arrange
        when(mockWeightLiftingRepository.getExerciseById('weight-1'))
            .thenAnswer((_) async => weightLiftingExercise);

        // Act
        final result =
            await exerciseDetailService.getWeightLiftingDetail('weight-1');

        // Assert
        expect(result, equals(weightLiftingExercise));
        expect(result?.id, equals('weight-1'));
        expect(result?.name, equals('Bench Press'));
        expect(result?.bodyPart, equals('Chest'));
        expect(result?.sets.length, equals(1));
        expect(result?.sets[0].weight, equals(60.0));
        expect(result?.sets[0].reps, equals(12));
        verify(mockWeightLiftingRepository.getExerciseById('weight-1'))
            .called(1);
      });

      test('getWeightLiftingDetail should return null when exercise not found',
          () async {
        // Arrange
        when(mockWeightLiftingRepository.getExerciseById('non-existent'))
            .thenAnswer((_) async => null);

        // Act
        final result =
            await exerciseDetailService.getWeightLiftingDetail('non-existent');

        // Assert
        expect(result, isNull);
        verify(mockWeightLiftingRepository.getExerciseById('non-existent'))
            .called(1);
      });
    });

    group('Delete Exercise Log Tests', () {
      test(
          'deleteExerciseLog should return true when smart exercise deleted successfully',
          () async {
        // Arrange
        const exerciseId = 'smart-1';
        when(mockSmartExerciseRepository.deleteById(exerciseId))
            .thenAnswer((_) async => true);

        // Act
        final result = await exerciseDetailService.deleteExerciseLog(
            exerciseId, ExerciseLogHistoryItem.typeSmartExercise);

        // Assert
        expect(result, isTrue);
        verify(mockSmartExerciseRepository.deleteById(exerciseId)).called(1);
      });

      test(
          'deleteExerciseLog should return false when smart exercise not found',
          () async {
        // Arrange
        const exerciseId = 'non-existent-smart';
        when(mockSmartExerciseRepository.deleteById(exerciseId))
            .thenAnswer((_) async => false);

        // Act
        final result = await exerciseDetailService.deleteExerciseLog(
            exerciseId, ExerciseLogHistoryItem.typeSmartExercise);

        // Assert
        expect(result, isFalse);
        verify(mockSmartExerciseRepository.deleteById(exerciseId)).called(1);
      });

      test(
          'deleteExerciseLog should return true when cardio activity deleted successfully',
          () async {
        // Arrange
        const exerciseId = 'run-1';
        when(mockCardioRepository.deleteCardioActivity(exerciseId))
            .thenAnswer((_) async => true);

        // Act
        final result = await exerciseDetailService.deleteExerciseLog(
            exerciseId, ExerciseLogHistoryItem.typeCardio);

        // Assert
        expect(result, isTrue);
        verify(mockCardioRepository.deleteCardioActivity(exerciseId)).called(1);
      });

      test(
          'deleteExerciseLog should return false when cardio activity not found',
          () async {
        // Arrange
        const exerciseId = 'non-existent-cardio';
        when(mockCardioRepository.deleteCardioActivity(exerciseId))
            .thenAnswer((_) async => false);

        // Act
        final result = await exerciseDetailService.deleteExerciseLog(
            exerciseId, ExerciseLogHistoryItem.typeCardio);

        // Assert
        expect(result, isFalse);
        verify(mockCardioRepository.deleteCardioActivity(exerciseId)).called(1);
      });

      test(
          'deleteExerciseLog should return true when weightlifting exercise deleted successfully',
          () async {
        // Arrange
        const exerciseId = 'weight-1';
        when(mockWeightLiftingRepository.deleteExercise(exerciseId))
            .thenAnswer((_) async => true);

        // Act
        final result = await exerciseDetailService.deleteExerciseLog(
            exerciseId, ExerciseLogHistoryItem.typeWeightlifting);

        // Assert
        expect(result, isTrue);
        verify(mockWeightLiftingRepository.deleteExercise(exerciseId))
            .called(1);
      });

      test(
          'deleteExerciseLog should return false when weightlifting exercise not found',
          () async {
        // Arrange
        const exerciseId = 'non-existent-weight';
        when(mockWeightLiftingRepository.deleteExercise(exerciseId))
            .thenAnswer((_) async => false);

        // Act
        final result = await exerciseDetailService.deleteExerciseLog(
            exerciseId, ExerciseLogHistoryItem.typeWeightlifting);

        // Assert
        expect(result, isFalse);
        verify(mockWeightLiftingRepository.deleteExercise(exerciseId))
            .called(1);
      });

      test(
          'deleteExerciseLog should return false when activity type is unknown',
          () async {
        // Arrange
        const exerciseId = 'some-id';

        // Act
        final result = await exerciseDetailService.deleteExerciseLog(
            exerciseId, 'unknown_type');

        // Assert
        expect(result, isFalse);
        verifyNever(
            mockSmartExerciseRepository.deleteById(argThat(isA<String>())));
        verifyNever(
            mockCardioRepository.deleteCardioActivity(argThat(isA<String>())));
        verifyNever(
            mockWeightLiftingRepository.deleteExercise(argThat(isA<String>())));
      });

      test('deleteExerciseLog should handle exceptions gracefully', () async {
        // Arrange
        const exerciseId = 'error-id';
        when(mockSmartExerciseRepository.deleteById(exerciseId))
            .thenThrow(Exception('Test error'));

        // Act
        final result = await exerciseDetailService.deleteExerciseLog(
            exerciseId, ExerciseLogHistoryItem.typeSmartExercise);

        // Assert
        expect(result, isFalse);
        verify(mockSmartExerciseRepository.deleteById(exerciseId)).called(1);
      });
    });
  });
}
