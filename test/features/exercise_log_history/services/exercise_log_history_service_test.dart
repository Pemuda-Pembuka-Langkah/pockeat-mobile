import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

@GenerateMocks([SmartExerciseLogRepository, CardioRepository, WeightLiftingRepository, FirebaseAuth, User])
void main() {
  late MockSmartExerciseLogRepository mockSmartExerciseLogRepository;
  late MockCardioRepository mockCardioRepository;
  late MockWeightLiftingRepository mockWeightLiftingRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late ExerciseLogHistoryService service;
  final getIt = GetIt.instance;
  final testUserId = 'test-user-id';

  setUp(() {
    mockSmartExerciseLogRepository = MockSmartExerciseLogRepository();
    mockCardioRepository = MockCardioRepository();
    mockWeightLiftingRepository = MockWeightLiftingRepository();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    
    // Set up mock user and auth
    when(mockUser.uid).thenReturn(testUserId);
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

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
      ExerciseLogHistoryServiceImpl(auth: mockFirebaseAuth),
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
      userId: testUserId,
    );

    final smartExerciseLog2 = ExerciseAnalysisResult(
      id: 'smart-2',
      exerciseType: 'Swimming',
      duration: '45 minutes',
      intensity: 'Medium',
      estimatedCalories: 250,
      timestamp: DateTime(2025, 3, 5, 14, 0),
      originalInput: 'I swam for 45 minutes',
      userId: testUserId,
    );

    final smartExerciseLog3 = ExerciseAnalysisResult(
      id: 'smart-3',
      exerciseType: 'Cycling',
      duration: '60 minutes',
      intensity: 'Low',
      estimatedCalories: 400,
      timestamp: DateTime(2025, 2, 15, 16, 0),
      originalInput: 'I cycled for 60 minutes',
      userId: testUserId,
    );

    // Cardio test data
    final cardioLog1 = RunningActivity(
      id: 'cardio-1',
      userId: testUserId,
      date: DateTime(2025, 3, 6, 11, 0),
      startTime: DateTime(2025, 3, 6, 11, 0),
      endTime: DateTime(2025, 3, 6, 11, 30),
      distanceKm: 5.0,
      caloriesBurned: 350,
    );

    final cardioLog2 = CyclingActivity(
      id: 'cardio-2',
      userId: testUserId,
      date: DateTime(2025, 3, 5, 15, 0),
      startTime: DateTime(2025, 3, 5, 15, 0),
      endTime: DateTime(2025, 3, 5, 16, 0),
      distanceKm: 20.0,
      cyclingType: CyclingType.commute,
      caloriesBurned: 450,
    );

    final cardioLog3 = SwimmingActivity(
      id: 'cardio-3',
      userId: testUserId,
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
      userId: testUserId,
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
      userId: testUserId,
      sets: [
        WeightLiftingSet(weight: 100.0, reps: 8, duration: 60.0),
        WeightLiftingSet(weight: 110.0, reps: 6, duration: 60.0),
      ],
      timestamp: DateTime(2025, 3, 5, 14, 0), // Same time as smartExerciseLog2
    );

    test('should get all exercise logs', () async {
      // Arrange
      when(mockSmartExerciseLogRepository.getAnalysisResultsByUser(
              testUserId, limit: anyNamed('limit')))
          .thenAnswer((_) async => [smartExerciseLog1, smartExerciseLog2]);

      when(mockCardioRepository.getActivitiesByUser(testUserId))
          .thenAnswer((_) async => [cardioLog1, cardioLog2]);

      when(mockWeightLiftingRepository.getExercisesByUser(testUserId))
          .thenAnswer((_) async => [weightLiftingLog1, weightLiftingLog2]);

      // Act
      final result = await service.getAllExerciseLogs(testUserId, limit: 6);

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
          .thenAnswer((_) async => [smartExerciseLog1]);

      when(mockCardioRepository.filterByDate(testDate))
          .thenAnswer((_) async => [cardioLog1]);

      when(mockWeightLiftingRepository.filterByDate(testDate))
          .thenAnswer((_) async => [weightLiftingLog1]);

      // Act
      final result = await service.getExerciseLogsByDate(testUserId, testDate);

      // Assert
      expect(result.length, 3);
      
      // Verify there is a weightlifting item from testDate
      final weightliftingItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeWeightlifting)
          .toList();
      expect(weightliftingItems.length, 1);
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
      final result =
          await service.getExerciseLogsByMonth(testUserId, testMonth, testYear);

      // Assert
      expect(result.length, 6);
      
      // Verify there are weightlifting items
      final weightliftingItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeWeightlifting)
          .toList();
      expect(weightliftingItems.length, 2);
      expect(weightliftingItems[0].title, 'Bench Press');
      expect(weightliftingItems[1].title, 'Squats');
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
      final result = await service.getExerciseLogsByYear(testUserId, testYear);

      // Assert
      expect(result.length, 8);
      
      // Verify there are weightlifting items
      final weightliftingItems = result
          .where((item) =>
              item.activityType == ExerciseLogHistoryItem.typeWeightlifting)
          .toList();
      expect(weightliftingItems.length, 2);
    });

    test('should apply limit parameter when getting all exercise logs',
        () async {
      // Arrange - setup more data than limit
      when(mockSmartExerciseLogRepository.getAnalysisResultsByUser(
              testUserId, limit: anyNamed('limit')))
          .thenAnswer((_) async =>
              [smartExerciseLog1, smartExerciseLog2, smartExerciseLog3]);

      when(mockCardioRepository.getActivitiesByUser(testUserId))
          .thenAnswer((_) async => [cardioLog1, cardioLog2, cardioLog3]);

      when(mockWeightLiftingRepository.getExercisesByUser(testUserId))
          .thenAnswer((_) async => [weightLiftingLog1, weightLiftingLog2]);

      // Act - request with limit of 4
      final result = await service.getAllExerciseLogs(testUserId, limit: 4);

      // Assert
      expect(result.length, 4);
    });

    // Error handling tests
    test('should return empty list when getAllExerciseLogs fails', () async {
      // Arrange - setup repository to throw
      when(mockSmartExerciseLogRepository.getAnalysisResultsByUser(
              testUserId, limit: anyNamed('limit')))
          .thenThrow(Exception('Repository failure'));

      // Act and Assert
      final result = await service.getAllExerciseLogs(testUserId);
      expect(result, isEmpty);
    });

    test('should return empty list when getExerciseLogsByDate fails', () async {
      // Arrange - setup repository to throw
      when(mockSmartExerciseLogRepository.getAnalysisResultsByDate(testDate))
          .thenThrow(Exception('Repository failure'));

      // Act and Assert
      final result = await service.getExerciseLogsByDate(testUserId, testDate);
      expect(result, isEmpty);
    });

    test('should return empty list when getExerciseLogsByMonth fails', () async {
      // Arrange - setup repository to throw
      when(mockSmartExerciseLogRepository.getAnalysisResultsByMonth(
              testMonth, testYear))
          .thenThrow(Exception('Repository failure'));

      // Act and Assert
      final result = await service.getExerciseLogsByMonth(testUserId, testMonth, testYear);
      expect(result, isEmpty);
    });

    test('should return empty list when getExerciseLogsByYear fails', () async {
      // Arrange - setup repository to throw
      when(mockSmartExerciseLogRepository.getAnalysisResultsByYear(testYear))
          .thenThrow(Exception('Repository failure'));

      // Act and Assert
      final result = await service.getExerciseLogsByYear(testUserId, testYear);
      expect(result, isEmpty);
    });
  });
}