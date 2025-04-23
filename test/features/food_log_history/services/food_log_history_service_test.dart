// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'food_log_history_service_test.mocks.dart';

@GenerateMocks([FoodScanRepository])

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

    test(
        'getFoodLogsByDate should return food logs for specific date and user',
        () async {
      // Arrange - Include both user IDs in the test data
      final dateSpecificResults = [sampleFoodResults[0], sampleFoodResults[2]]; // testUserId and otherUserId
      when(mockFoodScanRepository.getAnalysisResultsByDate(testDate))
          .thenAnswer((_) async => dateSpecificResults);

      // Act
      final result = await service.getFoodLogsByDate(testUserId, testDate);

      // Assert - only the items with testUserId should be returned
      expect(result.length, 1); // Only one item with testUserId for the specific date
      expect(result[0].title, 'Chicken Salad');
      verify(mockFoodScanRepository.getAnalysisResultsByDate(testDate))
          .called(1);
    });

    test(
        'getFoodLogsByMonth should return food logs for specific month and user',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByMonth(5, 2023))
          .thenAnswer((_) async => sampleFoodResults); // Includes all 3 test items

      // Act
      final result = await service.getFoodLogsByMonth(testUserId, 5, 2023);

      // Assert
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAnalysisResultsByMonth(5, 2023))
          .called(1);
    });

    test(
        'getFoodLogsByYear should return food logs for specific year and user',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByYear(2023))
          .thenAnswer((_) async => sampleFoodResults); // Includes all 3 test items

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
  });
}
