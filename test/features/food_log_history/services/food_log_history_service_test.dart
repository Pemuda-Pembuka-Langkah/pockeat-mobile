import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';

@GenerateMocks([FoodScanRepository])
import 'food_log_history_service_test.mocks.dart';

void main() {
  late FoodLogHistoryService service;
  late MockFoodScanRepository mockFoodScanRepository;

  final testDate = DateTime(2023, 5, 15);

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
    ),
  ];

  setUp(() {
    mockFoodScanRepository = MockFoodScanRepository();
    service = FoodLogHistoryServiceImpl(
      foodScanRepository: mockFoodScanRepository,
    );
  });

  group('FoodLogHistoryService', () {
    test('getAllFoodLogs should return all food logs', () async {
      // Arrange
      when(mockFoodScanRepository.getAll())
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.getAllFoodLogs();

      // Assert
      expect(result.length, sampleFoodResults.length);
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAll()).called(1);
    });

    test(
        'getFoodLogsByDate should return food logs for specific date (line 40)',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByDate(any))
          .thenAnswer((_) async => [sampleFoodResults[0]]);

      // Act
      final result = await service.getFoodLogsByDate(testDate);

      // Assert
      expect(result.length, 1);
      expect(result[0].title, 'Chicken Salad');
      verify(mockFoodScanRepository.getAnalysisResultsByDate(testDate))
          .called(1);
    });

    test(
        'getFoodLogsByMonth should return food logs for specific month (line 59)',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByMonth(any, any))
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.getFoodLogsByMonth(5, 2023);

      // Assert
      expect(result.length, 2);
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAnalysisResultsByMonth(5, 2023))
          .called(1);
    });

    test(
        'getFoodLogsByYear should return food logs for specific year (line 77)',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByYear(any))
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.getFoodLogsByYear(2023);

      // Assert
      expect(result.length, 2);
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAnalysisResultsByYear(2023)).called(1);
    });

    test('searchFoodLogs should filter by query (line 106-110)', () async {
      // Arrange
      when(mockFoodScanRepository.getAll())
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.searchFoodLogs('Chicken');

      // Assert
      expect(result.length, 1);
      expect(result[0].title, 'Chicken Salad');
      verify(mockFoodScanRepository.getAll()).called(1);
    });

    test(
        '_convertFoodAnalysisResults should convert analysis results to history items',
        () async {
      // Arrange - We'll use the service implementation to access the private method

      // Act
      // We call this method by using the public methods
      when(mockFoodScanRepository.getAll())
          .thenAnswer((_) async => sampleFoodResults);
      final result = await service.getAllFoodLogs();

      // Assert - check if conversion worked
      expect(result.length, sampleFoodResults.length);
      expect(result[0].title, sampleFoodResults[0].foodName);
      expect(result[0].calories, sampleFoodResults[0].nutritionInfo.calories);
      verify(mockFoodScanRepository.getAll()).called(1);
    });
  });
}
