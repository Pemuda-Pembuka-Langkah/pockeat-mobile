// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service_impl.dart';
import 'pet_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FoodLogHistoryService>(),
  MockSpec<CalorieStatsService>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
])
void main() {
  late PetServiceImpl petService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockCalorieStatsService mockCalorieStatsService;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockDocSnapshot;

  const String testUserId = 'test-user-id';

  setUp(() {
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockCalorieStatsService = MockCalorieStatsService();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();

    // Reset GetIt instance
    if (GetIt.instance.isRegistered<FoodLogHistoryService>()) {
      GetIt.instance.unregister<FoodLogHistoryService>();
    }
    if (GetIt.instance.isRegistered<CalorieStatsService>()) {
      GetIt.instance.unregister<CalorieStatsService>();
    }

    // Register mocks
    GetIt.instance.registerSingleton<FirebaseFirestore>(mockFirebaseFirestore);
    GetIt.instance
        .registerSingleton<FoodLogHistoryService>(mockFoodLogHistoryService);
    GetIt.instance
        .registerSingleton<CalorieStatsService>(mockCalorieStatsService);

    // Setup the chain of calls
    when(mockFirebaseFirestore.collection('caloric_requirements'))
        .thenReturn(mockCollection);
    when(mockCollection.doc(testUserId)).thenReturn(mockDocRef);
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

    // Set up the snapshot properties
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.data()).thenReturn({'tdee': 2000.0});

    // Initialize service
    petService = PetServiceImpl();
  });

  group('getPetMood', () {
    test('should return happy when user has food logs today', () async {
      // Arrange
      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .thenAnswer((_) async => [
                FoodLogHistoryItem(
                    title: 'Test',
                    subtitle: 'Test',
                    timestamp: today,
                    calories: 500)
              ]);

      // Act
      final result = await petService.getPetMood(testUserId);

      // Assert
      expect(result, 'happy');
      verify(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .called(1);
    });

    test('should return sad when user has no food logs today', () async {
      // Arrange
      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .thenAnswer((_) async => []);

      // Act
      final result = await petService.getPetMood(testUserId);

      // Assert
      expect(result, 'sad');
      verify(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .called(1);
    });
  });

  group('getPetHeart', () {
    test('should return 4 hearts when calories > 75% of target', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 1600, // 80% dari 2000
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getPetHeart(testUserId);

      // Assert
      expect(result, 4);
      verify(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .called(1);
    });

    test('should return 3 hearts when calories between 50-75% of target',
        () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 1200, // 60% dari 2000
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getPetHeart(testUserId);

      // Assert
      expect(result, 3);
    });

    test('should return 2 hearts when calories between 25-50% of target',
        () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 800, // 40% dari 2000
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getPetHeart(testUserId);

      // Assert
      expect(result, 2);
    });

    test('should return 1 heart when calories between 0-25% of target',
        () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 400, // 20% dari 2000
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getPetHeart(testUserId);

      // Assert
      expect(result, 1);
    });

    test('should return 0 hearts when no calories logged', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 0,
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getPetHeart(testUserId);

      // Assert
      expect(result, 0);
    });
  });

  group('getIsPetCalorieOverTarget', () {
    test('should return true when calories exceed 120% of target', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 2500, // 125% of 2000
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getIsPetCalorieOverTarget(testUserId);

      // Assert
      expect(result, true);
      verify(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .called(1);
      verify(mockFirebaseFirestore.collection('caloric_requirements')).called(1);
    });

    test('should return false when calories are below 100% of target', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 1995,
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getIsPetCalorieOverTarget(testUserId);

      // Assert
      expect(result, false);
      verify(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .called(1);
    });

    test('should return false when calories are exactly at target', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 2000, // 100% of 2000
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getIsPetCalorieOverTarget(testUserId);

      // Assert
      expect(result, false);
    });

    test('should return false when calories are below target', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 1500, // 75% of 2000
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getIsPetCalorieOverTarget(testUserId);

      // Assert
      expect(result, false);
    });
  });

  group('getIsPetCalorieOverTarget error handling', () {
    test('should return false when userId is empty', () async {
      // Act
      final result = await petService.getIsPetCalorieOverTarget('');

      // Assert
      expect(result, false);
      verifyNever(mockCalorieStatsService.calculateStatsForDate(any, any));
    });

    test('should return false when document does not exist', () async {
      // Arrange
      when(mockDocSnapshot.exists).thenReturn(false);

      // Act
      final result = await petService.getIsPetCalorieOverTarget(testUserId);

      // Assert
      expect(result, false);
      verify(mockCalorieStatsService.calculateStatsForDate(testUserId, any)).called(1);
    });

    test('should return false when tdee field is missing', () async {
      // Arrange
      when(mockDocSnapshot.data()).thenReturn({});

      // Act
      final result = await petService.getIsPetCalorieOverTarget(testUserId);

      // Assert
      expect(result, false);
      verify(mockCalorieStatsService.calculateStatsForDate(testUserId, any)).called(1);
    });

    test('should return false when calorie stats service throws exception', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenThrow(Exception('Service failure'));

      // Act
      final result = await petService.getIsPetCalorieOverTarget(testUserId);

      // Assert
      expect(result, false);
    });

    test('should return true when tdee is zero', () async {
      // Arrange
      when(mockDocSnapshot.data()).thenReturn({'tdee': 0});
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 1500,
                caloriesBurned: 0,
              ));

      // Act
      final result = await petService.getIsPetCalorieOverTarget(testUserId);

      // Assert
      expect(result, true);
    });
  });

  group('getPetInformation', () {
    test('should return PetInformation with happy mood when conditions are good', () async {
      // Arrange
      // Mock the individual method calls that getPetInformation depends on
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 1800, // 90% of target (not over)
                caloriesBurned: 0,
              ));

      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .thenAnswer((_) async => [
                FoodLogHistoryItem(
                    title: 'Test',
                    subtitle: 'Test',
                    timestamp: today,
                    calories: 500)
              ]);

      // Act
      final result = await petService.getPetInformation(testUserId);

      // Assert
      expect(result.name, 'Panda');
      expect(result.heart, 4); // 90% of target is 4 hearts
      expect(result.mood, 'happy');
      expect(result.isCalorieOverTarget, false);
    });

    test('should return PetInformation with sad mood when calories are over target', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 2500, // 125% of target (over)
                caloriesBurned: 0,
              ));

      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .thenAnswer((_) async => [
                FoodLogHistoryItem(
                    title: 'Test',
                    subtitle: 'Test',
                    timestamp: today,
                    calories: 500)
              ]);

      // Act
      final result = await petService.getPetInformation(testUserId);

      // Assert
      expect(result.name, 'Panda');
      expect(result.heart, 4); // 125% of target is 4 hearts
      expect(result.mood, 'sad'); // Should be sad despite having logs, because calories are over
      expect(result.isCalorieOverTarget, true);
    });

    test('should return PetInformation with sad mood when no food logs exist', () async {
      // Arrange
      when(mockCalorieStatsService.calculateStatsForDate(testUserId, any))
          .thenAnswer((_) async => DailyCalorieStats(
                userId: testUserId,
                date: DateTime.now(),
                caloriesConsumed: 1500, // 75% of target (not over)
                caloriesBurned: 0,
              ));

      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .thenAnswer((_) async => []); // No food logs

      // Act
      final result = await petService.getPetInformation(testUserId);

      // Assert
      expect(result.name, 'Panda');
      expect(result.heart, 3); // 75% of target is 3 hearts
      expect(result.mood, 'sad'); // Should be sad because no food logs
      expect(result.isCalorieOverTarget, false);
    });
  });

  tearDown(() {
    GetIt.instance.reset();
  });
}
