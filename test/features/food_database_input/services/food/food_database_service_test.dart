import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/domain/repositories/nutrition_database_repository.dart';
import 'package:pockeat/features/food_database_input/services/base/supabase.dart';
import 'package:pockeat/features/food_database_input/services/food/food_database_service.dart';

@GenerateMocks([
  NutritionDatabaseRepository,
  SupabaseService,
  FirebaseAuth,
  FirebaseFirestore,
  User
])
import 'food_database_service_test.mocks.dart';

void main() {
  late NutritionDatabaseService service;
  late MockSupabaseService mockSupabaseService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockFirebaseFirestore mockFirestore;
  late MockNutritionDatabaseRepository mockRepository;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockRepository = MockNutritionDatabaseRepository();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');

    service = NutritionDatabaseService(
      supabase: mockSupabaseService,
      auth: mockFirebaseAuth,
      firestore: mockFirestore,
      repository: mockRepository,
    );
  });

  group('NutritionDatabaseService', () {
    // Test food data
    final testFoods = [
      FoodAnalysisResult(
        id: 'food_1',
        foodName: 'Apple',
        nutritionInfo: NutritionInfo(
          calories: 52.0,
          protein: 0.3,
          carbs: 14.0,
          fat: 0.2,
          saturatedFat: 0.0,
          sodium: 1.0,
          fiber: 2.4,
          sugar: 10.0,
          cholesterol: 0.0,
          nutritionDensity: 8.2,
          vitaminsAndMinerals: {'vitamin_c': 4.6},
        ),
        ingredients: [Ingredient(name: 'Apple', servings: 52.0)],
        warnings: [],
        additionalInformation: {'database_id': 1},
      ),
      FoodAnalysisResult(
        id: 'food_2',
        foodName: 'Banana',
        nutritionInfo: NutritionInfo(
          calories: 89.0,
          protein: 1.1,
          carbs: 23.0,
          fat: 0.3,
          saturatedFat: 0.1,
          sodium: 1.0,
          fiber: 2.6,
          sugar: 12.0,
          cholesterol: 0.0,
          nutritionDensity: 7.5,
          vitaminsAndMinerals: {'vitamin_c': 8.7},
        ),
        ingredients: [Ingredient(name: 'Banana', servings: 89.0)],
        warnings: [],
        additionalInformation: {'database_id': 2},
      ),
    ];

    // Mock Supabase response data
    final supabaseFoodData = [
      {
        'id': 1,
        'name': 'Apple',
        'nutrition': {
          'calories': 52.0,
          'protein': 0.3,
          'carbs': 14.0,
          'fat': 0.2,
          'saturatedFat': 0.0,
          'sodium': 1.0,
          'fiber': 2.4,
          'sugar': 10.0,
          'cholesterol': 0.0,
        },
        'nutrition_density': 8.2,
        'vitamins': {'vitamin_c': 4.6},
      },
      {
        'id': 2,
        'name': 'Banana',
        'nutrition': {
          'calories': 89.0,
          'protein': 1.1,
          'carbs': 23.0,
          'fat': 0.3,
          'saturatedFat': 0.1,
          'sodium': 1.0,
          'fiber': 2.6,
          'sugar': 12.0,
          'cholesterol': 0.0,
        },
        'nutrition_density': 7.5,
        'vitamins': {'vitamin_c': 8.7},
      },
    ];

    test('getAllFoods should return transformed food analysis results',
        () async {
      // Arrange
      when(mockSupabaseService.getAllFoods())
          .thenAnswer((_) async => supabaseFoodData);

      // Act
      final results = await service.getAllFoods();

      // Assert
      expect(results.length, 2);
      expect(results[0].foodName, 'Apple');
      expect(results[0].nutritionInfo.calories, 52.0);
      expect(results[1].foodName, 'Banana');
      expect(results[1].nutritionInfo.calories, 89.0);
    });

    test('searchFoods should return matching food analysis results', () async {
      // Arrange
      when(mockSupabaseService.searchFoods('apple'))
          .thenAnswer((_) async => [supabaseFoodData[0]]);

      // Act
      final results = await service.searchFoods('apple');

      // Assert
      expect(results.length, 1);
      expect(results[0].foodName, 'Apple');
      expect(results[0].nutritionInfo.calories, 52.0);
    });

    test('adjustPortion should scale nutritional values correctly', () async {
      // Arrange
      const originalPortion = 100.0;
      const newPortion = 150.0;

      // Act
      final result = await service.adjustPortion(testFoods[0], newPortion);

      // Assert
      expect(result.nutritionInfo.calories, 78.0); // 52 * (150/100)
      expect(result.nutritionInfo.protein, 0.45); // 0.3 * (150/100)
      expect(result.nutritionInfo.carbs, 21.0); // 14 * (150/100)
      expect(result.nutritionInfo.fat, 0.3); // 0.2 * (150/100)
      expect(result.additionalInformation['adjusted_portion'], 150.0);
    });

    test('getSavedMeals should retrieve meals from repository', () async {
      // Arrange
      when(mockRepository.getAll()).thenAnswer((_) async => testFoods);

      // Act
      final results = await service.getSavedMeals();

      // Assert
      expect(results.length, 2);
      verify(mockRepository.getAll()).called(1);
    });

    test('createLocalMeal should combine foods correctly', () async {
      // Act
      final selected = [
        // Make copies of test foods with count information
        testFoods[0].copyWith(additionalInformation: {
          ...testFoods[0].additionalInformation,
          'count': 2,
        }),
        testFoods[1].copyWith(additionalInformation: {
          ...testFoods[1].additionalInformation,
          'count': 1,
        }),
      ];

      final result = service.createLocalMeal(selected, 'Test Combined Meal');

      // Assert
      expect(result.foodName, 'Test Combined Meal');
      expect(result.nutritionInfo.calories, 193.0); // (52 * 2) + 89
      expect(result.nutritionInfo.protein, 1.7); // (0.3 * 2) + 1.1
      expect(result.nutritionInfo.carbs, 51.0); // (14 * 2) + 23
      expect(result.nutritionInfo.fat, 0.7); // (0.2 * 2) + 0.3
      expect(result.ingredients.length, 2);
      expect(result.id.contains('meal_local_'), true);
    });

    test('saveMealToFirebase should save meal using repository', () async {
      // Arrange
      when(mockRepository.save(any, any)).thenAnswer((_) async => 'meal_123');
      final meal =
          testFoods[0].copyWith(id: 'meal_local_123', foodName: 'Test Meal');

      // Act
      final result = await service.saveMealToFirebase(meal);

      // Assert
      expect(result, 'meal_123');
      verify(mockRepository.save(any, 'Test Meal')).called(1);
    });

    test('getMealsByDate should retrieve meals for a specific date', () async {
      // Arrange
      final testDate = DateTime(2025, 4, 27);
      when(mockRepository.getAnalysisResultsByDate(testDate))
          .thenAnswer((_) async => testFoods);

      // Act
      final results = await service.getMealsByDate(testDate);

      // Assert
      expect(results.length, 2);
      verify(mockRepository.getAnalysisResultsByDate(testDate)).called(1);
    });

    test('getMealsByMonth should retrieve meals for a specific month',
        () async {
      // Arrange
      when(mockRepository.getAnalysisResultsByMonth(4, 2025))
          .thenAnswer((_) async => testFoods);

      // Act
      final results = await service.getMealsByMonth(4, 2025);

      // Assert
      expect(results.length, 2);
      verify(mockRepository.getAnalysisResultsByMonth(4, 2025)).called(1);
    });
  });
}
