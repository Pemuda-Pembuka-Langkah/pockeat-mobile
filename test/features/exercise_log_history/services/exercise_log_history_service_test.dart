import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'exercise_log_history_service_test.mocks.dart';

@GenerateMocks(
    [SmartExerciseLogRepository, CardioRepository, WeightLiftingRepository])
void main() {
  late MockSmartExerciseLogRepository mockSmartExerciseLogRepository;
  late MockCardioRepository mockCardioRepository;
  late MockWeightLiftingRepository mockWeightLiftingRepository;
  late ExerciseLogHistoryService service;
  final getIt = GetIt.instance;

  setUp(() {
    mockSmartExerciseLogRepository = MockSmartExerciseLogRepository();
    mockCardioRepository = MockCardioRepository();
    mockWeightLiftingRepository = MockWeightLiftingRepository();

    // Register mocks in GetIt
    if (getIt.isRegistered<SmartExerciseLogRepository>()) {
      getIt.unregister<SmartExerciseLogRepository>();
    }
    getIt.registerSingleton<SmartExerciseLogRepository>(
        mockSmartExerciseLogRepository);

    if (getIt.isRegistered<CardioRepository>()) {
      getIt.unregister<CardioRepository>();
    }
    getIt.registerSingleton<CardioRepository>(mockCardioRepository);

    if (getIt.isRegistered<WeightLiftingRepository>()) {
      getIt.unregister<WeightLiftingRepository>();
    }
    getIt.registerSingleton<WeightLiftingRepository>(
        mockWeightLiftingRepository);

    // Register service
    if (getIt.isRegistered<ExerciseLogHistoryService>()) {
      getIt.unregister<ExerciseLogHistoryService>();
    }
    getIt.registerSingleton<ExerciseLogHistoryService>(
      ExerciseLogHistoryServiceImpl(),
    );

    service = getIt<ExerciseLogHistoryService>();
  });

  tearDown(() {
    // Reset GetIt
    getIt.reset();
  });

  group('ExerciseLogHistoryRepository', () {
    // Test data
    final testDate = DateTime(2025, 3, 6);
    final testMonth = 3;
    final testYear = 2025;

    final smartExerciseLog1 = ExerciseAnalysisResult(
      id: 'smart-1',
      exerciseType: 'Running',
      duration: '30 minutes',
      intensity: 'High',
      estimatedCalories: 300,
      timestamp: DateTime(2025, 3, 6, 10, 0),
      originalInput: 'I ran for 30 minutes',
    );

    final smartExerciseLog2 = ExerciseAnalysisResult(
      id: 'smart-2',
      exerciseType: 'Swimming',
      duration: '45 minutes',
      intensity: 'Medium',
      estimatedCalories: 250,
      timestamp: DateTime(2025, 3, 5, 14, 0),
      originalInput: 'I swam for 45 minutes',
    );

    final smartExerciseLog3 = ExerciseAnalysisResult(
      id: 'smart-3',
      exerciseType: 'Cycling',
      duration: '60 minutes',
      intensity: 'Low',
      estimatedCalories: 400,
      timestamp: DateTime(2025, 2, 15, 16, 0),
      originalInput: 'I cycled for 60 minutes',
    );

    // Cardio test data
    final cardioLog1 = RunningActivity(
      id: 'cardio-1',
      userId: "test-user-id",
      date: DateTime(2025, 3, 6, 11, 0),
      startTime: DateTime(2025, 3, 6, 11, 0),
      endTime: DateTime(2025, 3, 6, 11, 30),
      distanceKm: 5.0,
      caloriesBurned: 350,
    );

    final cardioLog2 = CyclingActivity(
      id: 'cardio-2',
      userId: "test-user-id",
      date: DateTime(2025, 3, 5, 15, 0),
      startTime: DateTime(2025, 3, 5, 15, 0),
      endTime: DateTime(2025, 3, 5, 16, 0),
      distanceKm: 20.0,
      cyclingType: CyclingType.commute,
      caloriesBurned: 450,
    );

    final cardioLog3 = SwimmingActivity(
      id: 'cardio-3',
      userId: "test-user-id",
      date: DateTime(2025, 2, 14, 9, 0),
      startTime: DateTime(2025, 2, 14, 9, 0),
      endTime: DateTime(2025, 2, 14, 9, 45),
      laps: 20,
      poolLength: 50.0,
      stroke: 'freestyle',
      caloriesBurned: 500,
    );

    // Weightlifting test data
    final weightLiftingLog1 = WeightLifting(
      id: 'weight-1',
      name: 'Bench Press',
      bodyPart: 'Chest',
      metValue: 4.0,
      sets: [
        WeightLiftingSet(weight: 80.0, reps: 10, duration: 60.0),
        WeightLiftingSet(weight: 85.0, reps: 8, duration: 60.0),
        WeightLiftingSet(weight: 90.0, reps: 6, duration: 60.0),
      ],
      timestamp: DateTime(2025, 3, 6, 10, 0), // Same time as smartExerciseLog1
    );

    final weightLiftingLog2 = WeightLifting(
      id: 'weight-2',
      name: 'Squats',
      bodyPart: 'Legs',
      metValue: 6.0,
      sets: [
        WeightLiftingSet(weight: 100.0, reps: 8, duration: 60.0),
        WeightLiftingSet(weight: 110.0, reps: 6, duration: 60.0),
      ],
      timestamp: DateTime(2025, 3, 5, 14, 0), // Same time as smartExerciseLog2
    );

    test('should get all exercise logs', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(
              limit: anyNamed('limit')))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);

      when(mockCardioRepository.getAllCardioActivities())
          .thenAnswer((_) async => [cardioLog1, cardioLog2]);

      when(mockWeightLiftingRepository.getAllExercises())
          .thenAnswer((_) async => [weightLiftingLog1, weightLiftingLog2]);

      // Act
      final result = await service.getAllExerciseLogs();

      // Assert
      expect(result.length, 6); // 2 smart + 2 cardio + 2 weightlifting

      // Verify there are weightlifting items
      final weightliftingItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeWeightlifting)
          .toList();
      expect(weightliftingItems.length, 2);
      expect(weightliftingItems[0].title, 'Bench Press');
      expect(weightliftingItems[1].title, 'Squats');
    });

    test('should get logs by date including weightlifting logs', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);

      when(mockCardioRepository.filterByDate(testDate))
          .thenAnswer((_) async => [cardioLog1, cardioLog2]);

      when(mockWeightLiftingRepository.filterByDate(testDate))
          .thenAnswer((_) async => [weightLiftingLog1, weightLiftingLog2]);

      // Act
      final result = await service.getExerciseLogsByDate(testDate);

      // Assert
      expect(result.length, 6); // 2 smart + 2 cardio + 2 weightlifting

      // Verify if different types exist
      final smartItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeSmartExercise)
          .toList();
      expect(smartItems.length, 2);

      final cardioItems = result
          .where(
              (item) => item.activityType == ExerciseLogHistoryItem.typeCardio)
          .toList();
      expect(cardioItems.length, 2);

      final weightliftingItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeWeightlifting)
          .toList();
      expect(weightliftingItems.length, 2);
      expect(weightliftingItems[0].title, 'Bench Press');
    });

    test('should get logs by month including weightlifting logs', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(
              testMonth, testYear))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);

      when(mockCardioRepository.filterByMonth(testMonth, testYear))
          .thenAnswer((_) async => [cardioLog1, cardioLog2]);

      when(mockWeightLiftingRepository.filterByMonth(testMonth, testYear))
          .thenAnswer((_) async => [weightLiftingLog1, weightLiftingLog2]);

      // Act
      final result = await service.getExerciseLogsByMonth(testMonth, testYear);

      // Assert
      expect(result.length, 6); // 2 smart + 2 cardio + 2 weightlifting

      // Check that all source types are present
      final smartItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeSmartExercise)
          .toList();
      final cardioItems = result
          .where(
              (item) => item.activityType == ExerciseLogHistoryItem.typeCardio)
          .toList();
      final weightliftingItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeWeightlifting)
          .toList();

      expect(smartItems.length, 2);
      expect(cardioItems.length, 2);
      expect(weightliftingItems.length, 2);

      // Verify the source IDs are present
      final sourceIds = result.map((item) => item.sourceId).toList();
      expect(sourceIds.contains('smart-1'), isTrue);
      expect(sourceIds.contains('smart-2'), isTrue);
      expect(sourceIds.contains('cardio-1'), isTrue);
      expect(sourceIds.contains('cardio-2'), isTrue);
      expect(sourceIds.contains('weight-1'), isTrue);
      expect(sourceIds.contains('weight-2'), isTrue);

      // Verify correct timestamp sorting
      for (int i = 0; i < result.length - 1; i++) {
        // Each timestamp should be less than or equal to the previous one (newest first)
        expect(
            result[i].timestamp.isAfter(result[i + 1].timestamp) ||
                result[i].timestamp.isAtSameMomentAs(result[i + 1].timestamp),
            isTrue);
      }

      verify(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(
              testMonth, testYear))
          .called(1);
      verify(mockCardioRepository.filterByMonth(testMonth, testYear)).called(1);
      verify(mockWeightLiftingRepository.filterByMonth(testMonth, testYear))
          .called(1);
    });

    test('should get logs by year including weightlifting logs', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear))
          .thenAnswer((_) async =>
              [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      when(mockCardioRepository.filterByYear(testYear))
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      when(mockWeightLiftingRepository.filterByYear(testYear))
          .thenAnswer((_) async => [weightLiftingLog1, weightLiftingLog2]);

      // Act
      final result = await service.getExerciseLogsByYear(testYear);

      // Assert
      expect(result.length, 8); // 3 smart + 3 cardio + 2 weightlifting

      // Check that all source types are present
      final smartItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeSmartExercise)
          .toList();
      final cardioItems = result
          .where(
              (item) => item.activityType == ExerciseLogHistoryItem.typeCardio)
          .toList();
      final weightliftingItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeWeightlifting)
          .toList();

      expect(smartItems.length, 3);
      expect(cardioItems.length, 3);
      expect(weightliftingItems.length, 2);

      // Verify the source IDs are present
      final sourceIds = result.map((item) => item.sourceId).toList();
      expect(sourceIds.contains('cardio-1'), isTrue);
      expect(sourceIds.contains('weight-1'), isTrue);
      expect(sourceIds.contains('smart-1'), isTrue);
      expect(sourceIds.contains('cardio-2'), isTrue);
      expect(sourceIds.contains('weight-2'), isTrue);
      expect(sourceIds.contains('smart-2'), isTrue);
      expect(sourceIds.contains('smart-3'), isTrue);
      expect(sourceIds.contains('cardio-3'), isTrue);

      verify(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear))
          .called(1);
      verify(mockCardioRepository.filterByYear(testYear)).called(1);
      verify(mockWeightLiftingRepository.filterByYear(testYear)).called(1);
    });

    test(
        'should order weightlifting logs by timestamp when combined with other types',
        () async {
      // Arrange - create logs with different timestamps
      final recentDate = DateTime(2025, 3, 10, 10, 0);
      final oldDate = DateTime(2025, 3, 8, 9, 0);

      final recentSmartLog = ExerciseAnalysisResult(
        id: 'smart-recent',
        exerciseType: 'Running',
        duration: '30 minutes',
        intensity: 'High',
        estimatedCalories: 300,
        timestamp: recentDate, // Most recent
        originalInput: 'I ran for 30 minutes',
      );

      final recentWeightLiftingLog = WeightLifting(
        id: 'weight-recent',
        name: 'Deadlift',
        bodyPart: 'Back',
        metValue: 4.0,
        sets: [
          WeightLiftingSet(weight: 150.0, reps: 10, duration: 60.0),
          WeightLiftingSet(weight: 155.0, reps: 8, duration: 60.0),
          WeightLiftingSet(weight: 160.0, reps: 6, duration: 60.0),
        ],
        timestamp: recentDate, // Add timestamp matching the expected date
      );

      final oldCardioLog = RunningActivity(
        id: 'cardio-old',
        userId: "test-user-id",
        date: oldDate,
        startTime: oldDate,
        endTime: oldDate.add(Duration(minutes: 30)),
        distanceKm: 5.0,
        caloriesBurned: 350,
      );

      when(mockSmartExerciseLogRepository.getAllAnalysisResults(limit: null))
          .thenAnswer((_) async => [recentSmartLog]);
      when(mockCardioRepository.getAllCardioActivities())
          .thenAnswer((_) async => [oldCardioLog]);
      when(mockWeightLiftingRepository.getAllExercises())
          .thenAnswer((_) async => [recentWeightLiftingLog]);

      // Act
      final result = await service.getAllExerciseLogs();

      // Assert
      expect(result.length, 3);
      // Check the converted ExerciseLogHistoryItems have correct timestamps
      // and are sorted properly (newest first)
      expect(result[0].timestamp, recentDate); // Most recent first

      // Updated order based on timestamp rather than activity type
      expect(result[0].activityType, ExerciseLogHistoryItem.typeSmartExercise);
      expect(result[1].activityType, ExerciseLogHistoryItem.typeWeightlifting);
      expect(result[2].activityType, ExerciseLogHistoryItem.typeCardio);
    });

    test('should apply limit parameter when getting all exercise logs',
        () async {
      // Arrange - setup more data than limit
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(
              limit: anyNamed('limit')))
          .thenAnswer((_) async =>
              [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      when(mockCardioRepository.getAllCardioActivities())
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      when(mockWeightLiftingRepository.getAllExercises())
          .thenAnswer((_) async => [weightLiftingLog1, weightLiftingLog2]);

      // Act - request with limit of 4
      final result = await service.getAllExerciseLogs(limit: 4);

      // Assert
      expect(result.length,
          4); // Should be limited to 4 even though we have 8 items

      // Verify the items are sorted by timestamp (newest first)
      for (int i = 0; i < result.length - 1; i++) {
        expect(
            result[i].timestamp.isAfter(result[i + 1].timestamp) ||
                result[i].timestamp.isAtSameMomentAs(result[i + 1].timestamp),
            isTrue);
      }
    });

    // Error handling tests
    test('should throw exception when getAllExerciseLogs fails', () async {
      // Arrange - setup repository to throw
      when(mockSmartExerciseLogRepository.getAllAnalysisResults(
              limit: anyNamed('limit')))
          .thenThrow(Exception('Repository failure'));

      // Act and Assert
      expect(() => service.getAllExerciseLogs(), throwsException);
    });

    test('should throw exception when getExerciseLogsByDate fails', () async {
      // Arrange - setup repository to throw
      when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate))
          .thenThrow(Exception('Repository failure'));

      // Act and Assert
      expect(() => service.getExerciseLogsByDate(testDate), throwsException);
    });

    test('should throw exception when getExerciseLogsByMonth fails', () async {
      // Arrange - setup repository to throw
      when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(
              testMonth, testYear))
          .thenThrow(Exception('Repository failure'));

      // Act and Assert
      expect(() => service.getExerciseLogsByMonth(testMonth, testYear),
          throwsException);
    });

    test('should throw exception when getExerciseLogsByYear fails', () async {
      // Arrange - setup repository to throw
      when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear))
          .thenThrow(Exception('Repository failure'));

      // Act and Assert
      expect(() => service.getExerciseLogsByYear(testYear), throwsException);
    });
  });
}
