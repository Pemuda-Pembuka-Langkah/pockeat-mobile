// Package imports:
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
])
void main() {
  late PetServiceImpl petService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockCalorieStatsService mockCalorieStatsService;
  const String testUserId = 'test-user-id';

  setUp(() {
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockCalorieStatsService = MockCalorieStatsService();

    // Reset GetIt instance
    if (GetIt.instance.isRegistered<FoodLogHistoryService>()) {
      GetIt.instance.unregister<FoodLogHistoryService>();
    }
    if (GetIt.instance.isRegistered<CalorieStatsService>()) {
      GetIt.instance.unregister<CalorieStatsService>();
    }

    // Register mocks
    GetIt.instance.registerSingleton<FoodLogHistoryService>(mockFoodLogHistoryService);
    GetIt.instance.registerSingleton<CalorieStatsService>(mockCalorieStatsService);

    // Initialize service
    petService = PetServiceImpl();
  });

  group('getPetMood', () {
    test('should return happy when user has food logs today', () async {
      // Arrange
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .thenAnswer((_) async => [FoodLogHistoryItem(title: 'Test', subtitle: 'Test', timestamp: today, calories: 500)]);

      // Act
      final result = await petService.getPetMood(testUserId);

      // Assert
      expect(result, 'happy');
      verify(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today)).called(1);
    });

    test('should return sad when user has no food logs today', () async {
      // Arrange
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today))
          .thenAnswer((_) async => []);

      // Act
      final result = await petService.getPetMood(testUserId);

      // Assert
      expect(result, 'sad');
      verify(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, today)).called(1);
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
      verify(mockCalorieStatsService.calculateStatsForDate(testUserId, any)).called(1);
    });

    test('should return 3 hearts when calories between 50-75% of target', () async {
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

    test('should return 2 hearts when calories between 25-50% of target', () async {
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

    test('should return 1 heart when calories between 0-25% of target', () async {
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

  tearDown(() {
    GetIt.instance.reset();
  });
}
