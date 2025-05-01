import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/repositories/saved_meals_repository.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';

// Generate mocks using the @GenerateMocks annotation
@GenerateMocks([SavedMealsRepository, FoodTextAnalysisService])
import 'saved_meal_service_test.mocks.dart';

void main() {
  group('SavedMealService', () {
    // Test variables
    late SavedMealService service;
    late MockSavedMealsRepository repository;
    late MockFoodTextAnalysisService textAnalysisService;

    // Test data
    late FoodAnalysisResult testFoodAnalysis;
    late SavedMeal testSavedMeal;
    final DateTime now = DateTime.now();

    setUp(() {
      repository = MockSavedMealsRepository();
      textAnalysisService = MockFoodTextAnalysisService();

      service = SavedMealService(
        repository: repository,
        textAnalysisService: textAnalysisService,
      );

      // Create test food analysis
      testFoodAnalysis = FoodAnalysisResult(
        id: 'test-analysis-id',
        foodName: 'Test Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 200,
          protein: 10,
          carbs: 20,
          fat: 5,
          sodium: 100,
          fiber: 2,
          sugar: 3,
        ),
        warnings: ['Test warning'],
        timestamp: now,
        userId: 'user123',
      );

      // Create test saved meal
      testSavedMeal = SavedMeal(
        id: 'test-meal-id',
        userId: 'user123',
        name: 'Test Meal',
        foodAnalysis: testFoodAnalysis,
        createdAt: now,
        updatedAt: now,
      );
    });

    test('getSavedMeals - should return stream of saved meals', () {
      // Arrange
      final mealsStream = Stream.value([testSavedMeal]);
      when(repository.getSavedMeals()).thenAnswer((_) => mealsStream);

      // Act
      final result = service.getSavedMeals();

      // Assert
      expect(result, emits([testSavedMeal]));
    });

    test('getSavedMeals - should handle exceptions', () {
      // Arrange
      when(repository.getSavedMeals()).thenThrow(Exception('Test error'));

      // Act & Assert
      expect(() => service.getSavedMeals(), throwsException);
    });

    test('getSavedMeal - should get a meal by ID', () async {
      // Arrange
      when(repository.getSavedMeal('test-meal-id'))
          .thenAnswer((_) async => testSavedMeal);

      // Act
      final result = await service.getSavedMeal('test-meal-id');

      // Assert
      expect(result, equals(testSavedMeal));
    });

    test('getSavedMeal - should return null when meal not found', () async {
      // Arrange
      when(repository.getSavedMeal('non-existent-id'))
          .thenAnswer((_) async => null);

      // Act
      final result = await service.getSavedMeal('non-existent-id');

      // Assert
      expect(result, isNull);
    });

    test('getSavedMeal - should handle exceptions', () {
      // Arrange
      when(repository.getSavedMeal('error-id'))
          .thenThrow(Exception('Test error'));

      // Act & Assert
      expect(() => service.getSavedMeal('error-id'), throwsException);
    });

    test('saveMeal - should save a meal with custom name', () async {
      // Arrange
      when(repository.saveMeal(testFoodAnalysis, name: 'Custom Name'))
          .thenAnswer((_) async => testSavedMeal);

      // Act
      final result =
          await service.saveMeal(testFoodAnalysis, name: 'Custom Name');

      // Assert
      expect(result, equals(testSavedMeal));
    });

    test('saveMeal - should save a meal with default name', () async {
      // Arrange
      when(repository.saveMeal(testFoodAnalysis, name: null))
          .thenAnswer((_) async => testSavedMeal);

      // Act
      final result = await service.saveMeal(testFoodAnalysis);

      // Assert
      expect(result, equals(testSavedMeal));
    });

    test('saveMeal - should handle exceptions', () {
      // Arrange
      when(repository.saveMeal(testFoodAnalysis, name: null))
          .thenThrow(Exception('Test error'));

      // Act & Assert
      expect(() => service.saveMeal(testFoodAnalysis), throwsException);
    });

    test('correctSavedMealAnalysis - should correct a meal analysis', () async {
      // Arrange
      final correctedAnalysis = testFoodAnalysis.copyWith(
        foodName: 'Corrected Food',
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 15,
          carbs: 20,
          fat: 5,
          sodium: 100,
          fiber: 2,
          sugar: 3,
        ),
      );

      when(textAnalysisService.correctAnalysis(testFoodAnalysis, 'Update food'))
          .thenAnswer((_) async => correctedAnalysis);

      // Act
      final result =
          await service.correctSavedMealAnalysis(testSavedMeal, 'Update food');

      // Assert
      expect(result, equals(correctedAnalysis));
      expect(result.foodName, equals('Corrected Food'));
      expect(result.nutritionInfo.calories, equals(250));
      expect(result.nutritionInfo.protein, equals(15));
    });

    test('correctSavedMealAnalysis - should handle exceptions', () {
      // Arrange
      when(textAnalysisService.correctAnalysis(
              testFoodAnalysis, 'Error comment'))
          .thenThrow(Exception('Test error'));

      // Act & Assert
      expect(
          () =>
              service.correctSavedMealAnalysis(testSavedMeal, 'Error comment'),
          throwsException);
    });

    test('logFoodAnalysis - should save food analysis', () async {
      // Arrange
      when(repository.logFoodAnalysis(testFoodAnalysis))
          .thenAnswer((_) async => 'logged-id');

      // Act
      final result = await service.logFoodAnalysis(testFoodAnalysis);

      // Assert
      expect(result, equals('logged-id'));
    });

    test('logFoodAnalysis - should handle exceptions', () {
      // Arrange
      when(repository.logFoodAnalysis(testFoodAnalysis))
          .thenThrow(Exception('Test error'));

      // Act & Assert
      expect(() => service.logFoodAnalysis(testFoodAnalysis), throwsException);
    });

    test('deleteSavedMeal - should delete a meal by ID', () async {
      // Arrange
      when(repository.deleteSavedMeal('test-meal-id')).thenAnswer((_) async {});

      // Act
      await service.deleteSavedMeal('test-meal-id');

      // Assert - verify the repository method was called
      verify(repository.deleteSavedMeal('test-meal-id')).called(1);
    });

    test('deleteSavedMeal - should handle exceptions', () {
      // Arrange
      when(repository.deleteSavedMeal('error-id'))
          .thenThrow(Exception('Test error'));

      // Act & Assert
      expect(() => service.deleteSavedMeal('error-id'), throwsException);
    });

    test('isMealSaved - should check if a meal is saved', () async {
      // Arrange
      when(repository.isMealSaved('existing-id')).thenAnswer((_) async => true);
      when(repository.isMealSaved('non-existing-id'))
          .thenAnswer((_) async => false);

      // Act
      final isExistingSaved = await service.isMealSaved('existing-id');
      final isNonExistingSaved = await service.isMealSaved('non-existing-id');

      // Assert
      expect(isExistingSaved, isTrue);
      expect(isNonExistingSaved, isFalse);
    });

    test('isMealSaved - should handle exceptions', () {
      // Arrange
      when(repository.isMealSaved('error-id'))
          .thenThrow(Exception('Test error'));

      // Act & Assert
      expect(() => service.isMealSaved('error-id'), throwsException);
    });
  });
}
