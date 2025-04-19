import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';

@GenerateMocks([FoodScanRepository])
import 'food_log_history_service_test.mocks.dart';

FoodAnalysisResult createTestFoodAnalysisResult(
    String userId, DateTime timestamp) {
  return FoodAnalysisResult(
    id: 'food-${timestamp.millisecondsSinceEpoch}',
    foodName: 'Test Food ${timestamp.day}',
    foodImageUrl: 'https://example.com/food_${timestamp.day}.jpg',
    timestamp: timestamp,
    nutritionInfo: NutritionInfo(
      calories: 400,
      protein: 20,
      carbs: 30,
      fat: 20,
      sodium: 400,
      sugar: 5,
      fiber: 3,
    ),
    ingredients: [Ingredient(name: 'Test Ingredient', servings: 1)],
    warnings: [],
    userId: userId,
  );
}

void main() {
  late FoodLogHistoryService service;
  late MockFoodScanRepository mockFoodScanRepository;

  final testDate = DateTime(2023, 5, 15);
  final testUserId = 'test-user-id';
  final otherUserId = 'other-user-id';

  // Sample data
  final List<FoodAnalysisResult> sampleFoodResults = [
    FoodAnalysisResult(
      id: 'food1',
      foodName: 'Chicken Salad',
      foodImageUrl: 'https://example.com/chicken.jpg',
      timestamp: testDate,
      nutritionInfo: NutritionInfo(
        calories: 350,
        protein: 30,
        carbs: 10,
        fat: 15,
        sodium: 200,
        sugar: 2,
        fiber: 5,
      ),
      ingredients: [
        Ingredient(name: 'Chicken', servings: 1),
        Ingredient(name: 'Lettuce', servings: 1),
      ],
      warnings: [],
      userId: testUserId,
    ),
    FoodAnalysisResult(
      id: 'food2',
      foodName: 'Beef Burger',
      foodImageUrl: 'https://example.com/burger.jpg',
      timestamp: testDate.subtract(const Duration(days: 1)),
      nutritionInfo: NutritionInfo(
        calories: 550,
        protein: 25,
        carbs: 40,
        fat: 30,
        sodium: 800,
        sugar: 8,
        fiber: 3,
      ),
      ingredients: [
        Ingredient(name: 'Beef Patty', servings: 1),
        Ingredient(name: 'Bun', servings: 1),
      ],
      warnings: ['High sodium content'],
      userId: testUserId,
    ),
    // Add a food item with a different userId to test filtering
    FoodAnalysisResult(
      id: 'food3',
      foodName: 'Other User Food',
      foodImageUrl: 'https://example.com/other.jpg',
      timestamp: testDate,
      nutritionInfo: NutritionInfo(
        calories: 400,
        protein: 20,
        carbs: 30,
        fat: 20,
        sodium: 400,
        sugar: 5,
        fiber: 3,
      ),
      ingredients: [
        Ingredient(name: 'Other Ingredient', servings: 1),
      ],
      warnings: [],
      userId: otherUserId,
    ),
  ];

  setUp(() {
    mockFoodScanRepository = MockFoodScanRepository();
    service = FoodLogHistoryServiceImpl(
      foodScanRepository: mockFoodScanRepository,
    );
  });

  group('FoodLogHistoryService', () {
    test('getAllFoodLogs should return all food logs for the user', () async {
      // Arrange
      when(mockFoodScanRepository.getAll(limit: anyNamed('limit')))
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.getAllFoodLogs(testUserId);

      // Assert - only the items with testUserId should be returned (not the other-user-id item)
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAll(limit: null)).called(1);
    });

    test('getFoodLogsByDate should return food logs for specific date and user',
        () async {
      // Arrange - Include both user IDs in the test data
      final dateSpecificResults = [
        sampleFoodResults[0],
        sampleFoodResults[2]
      ]; // testUserId and otherUserId
      when(mockFoodScanRepository.getAnalysisResultsByDate(testDate))
          .thenAnswer((_) async => dateSpecificResults);

      // Act
      final result = await service.getFoodLogsByDate(testUserId, testDate);

      // Assert - only the items with testUserId should be returned
      expect(result.length,
          1); // Only one item with testUserId for the specific date
      expect(result[0].title, 'Chicken Salad');
      verify(mockFoodScanRepository.getAnalysisResultsByDate(testDate))
          .called(1);
    });

    test(
        'getFoodLogsByMonth should return food logs for specific month and user',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByMonth(5, 2023))
          .thenAnswer(
              (_) async => sampleFoodResults); // Includes all 3 test items

      // Act
      final result = await service.getFoodLogsByMonth(testUserId, 5, 2023);

      // Assert
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAnalysisResultsByMonth(5, 2023))
          .called(1);
    });

    test('getFoodLogsByYear should return food logs for specific year and user',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByYear(2023)).thenAnswer(
          (_) async => sampleFoodResults); // Includes all 3 test items

      // Act
      final result = await service.getFoodLogsByYear(testUserId, 2023);

      // Assert
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAnalysisResultsByYear(2023)).called(1);
    });

    test('searchFoodLogs should filter by query and user', () async {
      // Arrange
      when(mockFoodScanRepository.getAll(limit: anyNamed('limit')))
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.searchFoodLogs(testUserId, 'Chicken');

      // Assert
      expect(result.length, 1);
      expect(result[0].title, 'Chicken Salad');
      verify(mockFoodScanRepository.getAll(limit: null)).called(1);
    });

    test(
        '_convertFoodAnalysisResults should convert analysis results to history items',
        () async {
      // Arrange - We'll use the service implementation to access the private method

      // Act
      // We call this method by using the public methods
      when(mockFoodScanRepository.getAll(limit: anyNamed('limit')))
          .thenAnswer((_) async => sampleFoodResults);
      final result = await service.getAllFoodLogs(testUserId);

      // Assert - check if conversion worked
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, sampleFoodResults[0].foodName);
      expect(result[0].calories, sampleFoodResults[0].nutritionInfo.calories);
      verify(mockFoodScanRepository.getAll(limit: null)).called(1);
    });

    test('isFoodStreakMaintained should return true when there are logs today',
        () async {
      // Arrange
      final today = DateTime.now();
      final todayLogs = [
        FoodAnalysisResult(
          id: 'food-today',
          foodName: 'Today Food',
          foodImageUrl: 'https://example.com/today.jpg',
          timestamp: today,
          nutritionInfo: NutritionInfo(
            calories: 400,
            protein: 20,
            carbs: 30,
            fat: 20,
            sodium: 400,
            sugar: 5,
            fiber: 3,
          ),
          ingredients: [Ingredient(name: 'Today Ingredient', servings: 1)],
          warnings: [],
          userId: testUserId,
        ),
      ];

      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenAnswer((_) async => todayLogs);

      // Act
      final result = await service.isFoodStreakMaintained(testUserId);

      // Assert
      expect(result, true);
      verify(mockFoodScanRepository.getAnalysisResultsByDate(any)).called(1);
    });

    test(
      'isFoodStreakMaintained should return true when there are logs yesterday but not today',
      () async {
        // Arrange
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        final yesterdayLogs = [
          createTestFoodAnalysisResult(testUserId, yesterday)
        ];

        // Stub today (normalized) to empty
        when(
          mockFoodScanRepository.getAnalysisResultsByDate(
            argThat(
              predicate<DateTime>((date) =>
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day),
            ),
          ),
        ).thenAnswer((_) async => []);

        // Stub yesterday (normalized) to non-empty
        when(
          mockFoodScanRepository.getAnalysisResultsByDate(
            argThat(
              predicate<DateTime>((date) =>
                  date.year == yesterday.year &&
                  date.month == yesterday.month &&
                  date.day == yesterday.day),
            ),
          ),
        ).thenAnswer((_) async => yesterdayLogs);

        // Act
        final result = await service.isFoodStreakMaintained(testUserId);

        // Assert
        expect(result, true);
        verify(
          mockFoodScanRepository.getAnalysisResultsByDate(
            argThat(
              predicate<DateTime>((date) =>
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day),
            ),
          ),
        ).called(1);
        verify(
          mockFoodScanRepository.getAnalysisResultsByDate(
            argThat(
              predicate<DateTime>((date) =>
                  date.year == yesterday.year &&
                  date.month == yesterday.month &&
                  date.day == yesterday.day),
            ),
          ),
        ).called(1);
      },
    );

    test(
        'isFoodStreakMaintained should return false when there are no logs today or yesterday',
        () async {
      // Arrange
      // Empty logs for both today and yesterday
      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenAnswer((_) async => []);

      // Act
      final result = await service.isFoodStreakMaintained(testUserId);

      // Assert
      expect(result, false);
      // Called twice - once for today, once for yesterday
      verify(mockFoodScanRepository.getAnalysisResultsByDate(any)).called(2);
    });

    test('isFoodStreakMaintained should return false when an exception occurs',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenThrow(Exception('Test exception'));

      // Act
      final result = await service.isFoodStreakMaintained(testUserId);

      // Assert
      expect(result, false);
      verify(mockFoodScanRepository.getAnalysisResultsByDate(any)).called(1);
    });

    test(
        'getFoodStreakDays should return correct streak count when logs exist for consecutive days',
        () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      // Stub only these three dates to have logs
      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenAnswer((inv) {
        final dt = inv.positionalArguments[0] as DateTime;
        final dateOnly = DateTime(dt.year, dt.month, dt.day);
        if (dateOnly == today ||
            dateOnly == yesterday ||
            dateOnly == twoDaysAgo) {
          return Future.value([createTestFoodAnalysisResult(testUserId, dt)]);
        }
        return Future.value([]);
      });

      final result = await service.getFoodStreakDays(testUserId);
      expect(result, 3);
      // today,yesterday,2 days ago, then 3+ days yields empty => 4 calls total
      verify(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .called(greaterThanOrEqualTo(4));
    });

    test(
        'getFoodStreakDays should start counting from yesterday if no logs today',
        () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      // Stub so today has no logs, but yesterday & the day before do
      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenAnswer((inv) {
        final dt = inv.positionalArguments[0] as DateTime;
        final dateOnly = DateTime(dt.year, dt.month, dt.day);
        if (dateOnly == today) {
          return Future.value([]); // no today
        } else if (dateOnly == yesterday || dateOnly == twoDaysAgo) {
          return Future.value([createTestFoodAnalysisResult(testUserId, dt)]);
        }
        return Future.value([]);
      });

      final result = await service.getFoodStreakDays(testUserId);
      expect(result, 2);
      // calls: today (empty), yesterday, 2 days ago, then stops => ≥3 calls
      verify(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .called(greaterThanOrEqualTo(3));
    });

    test('getFoodStreakDays should return 0 when no logs exist', () async {
      // Arrange
      // No logs for any day
      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenAnswer((_) async => []);

      // Act
      final result = await service.getFoodStreakDays(testUserId);

      // Assert
      expect(result, 0);
      // Should be called exactly twice (today and yesterday)
      verify(mockFoodScanRepository.getAnalysisResultsByDate(any)).called(2);
    });

    test('getFoodStreakDays should return 0 when an exception occurs',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenThrow(Exception('Test exception'));

      // Act
      final result = await service.getFoodStreakDays(testUserId);

      // Assert
      expect(result, 0);
      verify(mockFoodScanRepository.getAnalysisResultsByDate(any)).called(1);
    });

    test('getFoodStreakDays should respect the max streak limit of 100 days',
        () async {
      // Arrange
      // Return valid logs for any date requested
      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenAnswer((invocation) {
        final date = invocation.positionalArguments[0] as DateTime;
        return Future.value([createTestFoodAnalysisResult(testUserId, date)]);
      });

      // Act
      final result = await service.getFoodStreakDays(testUserId);

      // Assert
      expect(result, 100); // Should cap at 100 days
      // Should be called 101 times (today + 100 previous days)
      verify(mockFoodScanRepository.getAnalysisResultsByDate(any)).called(101);
    });
  });
}
