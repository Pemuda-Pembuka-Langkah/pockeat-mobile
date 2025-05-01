// Dart imports:
import 'dart:async';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/domain/repositories/nutrition_database_repository.dart';
import 'package:pockeat/features/food_database_input/services/base/supabase.dart';
import 'package:pockeat/features/food_database_input/services/food/food_database_service.dart';

// Mock classes using mocktail
class MockSupabaseService extends Mock implements SupabaseService {}

class MockNutritionDatabaseRepository extends Mock
    implements NutritionDatabaseRepository {}

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockUser extends Mock implements firebase_auth.User {
  @override
  String get uid => 'test_user_id'; // Add uid implementation
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Mock for Supabase client
class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late NutritionDatabaseService service;
  late MockSupabaseService mockSupabaseService;
  late MockNutritionDatabaseRepository mockRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockFirebaseFirestore mockFirestore;
  late MockSupabaseClient mockSupabaseClient;

  // Test data
  final testFood = {
    'id': 1,
    'food': 'Apple',
    'caloric_value': 52.0,
    'protein': 0.3,
    'carbohydrates': 14.0,
    'fat': 0.2,
    'saturated_fats': 0.0,
    'sodium': 0.001, // Will be multiplied by 1000 in conversion
    'dietary_fiber': 2.4,
    'sugars': 10.4,
    'cholesterol': 0.0,
    'nutrition_density': 8.5,
    'vitamin_a': 3.0,
    'vitamin_b1': 0.02,
    'vitamin_b11': 0.0,
    'vitamin_b12': 0.0,
    'vitamin_b2': 0.03,
    'vitamin_b3': 0.1,
    'vitamin_b5': 0.1,
    'vitamin_b6': 0.04,
    'vitamin_c': 4.6,
    'vitamin_d': 0.0,
    'vitamin_e': 0.2,
    'vitamin_k': 2.2,
    'calcium': 6.0,
    'copper': 0.03,
    'iron': 0.1,
    'magnesium': 5.0,
    'manganese': 0.04,
    'phosphorus': 11.0,
    'potassium': 107.0,
    'selenium': 0.0,
    'zinc': 0.04,
    'water': 85.6,
    'monounsaturated_fats': 0.0,
    'polyunsaturated_fats': 0.1
  };

  final testFoodsList = [testFood];

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(FoodAnalysisResult(
      foodName: "Test Food",
      nutritionInfo: NutritionInfo(
        calories: 100,
        protein: 10,
        carbs: 20,
        fat: 5,
        sodium: 100,
        fiber: 2,
        sugar: 5,
      ),
      ingredients: [],
    ));
    registerFallbackValue("test_id");
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue('nutrition_data');
    registerFallbackValue('food');
    registerFallbackValue('%apple%');
    registerFallbackValue(20);
  });

  setUp(() {
    // Initialize mocks
    mockSupabaseService = MockSupabaseService();
    mockRepository = MockNutritionDatabaseRepository();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockSupabaseClient = MockSupabaseClient();

    // Configure basic mocks
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockSupabaseService.client).thenReturn(mockSupabaseClient);

    // Create service with mocks
    service = NutritionDatabaseService(mockSupabaseService,
        auth: mockFirebaseAuth,
        repository: mockRepository,
        firestore: mockFirestore);
  });

  group('NutritionDatabaseService', () {
    test('getAllFoods should fetch and convert food data correctly', () async {
      // Arrange
      when(() => mockSupabaseService.fetchFromTable(
            'nutrition_data',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => testFoodsList);

      // Act
      final results = await service.getAllFoods(limit: 20, offset: 0);

      // Assert
      expect(results.length, 1);
      expect(results[0].foodName, 'Apple');
      expect(results[0].nutritionInfo.calories, 52.0);
      expect(results[0].nutritionInfo.protein, 0.3);
      expect(results[0].nutritionInfo.sodium, 1.0); // 0.001 * 1000

      // Verify vitamins and minerals were converted correctly
      expect(results[0].nutritionInfo.vitaminsAndMinerals['vitamin_c'], 4.6);
      expect(results[0].nutritionInfo.vitaminsAndMinerals['calcium'], 6.0);

      // Verify the method was called with correct parameters
      verify(() => mockSupabaseService.fetchFromTable(
            'nutrition_data',
            limit: 20,
            offset: 0,
            orderBy: 'food',
          )).called(1);
    });

    test('searchFoods should perform search correctly', () async {
      // Instead of mocking the Supabase query chain, mock the entire method
      when(() => mockSupabaseService.fetchFromTable(
            'nutrition_data',
            limit: any(named: 'limit'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => testFoodsList);

      // Act
      final results = await service.searchFoods('apple');
    });

    test('getFoodById should fetch a single food item correctly', () async {
      // Arrange - setup the mock to return test food
      when(() => mockSupabaseService.getById('nutrition_data', 'id', 1))
          .thenAnswer((_) async => testFood);

      // Act
      final result = await service.getFoodById(1);

      // Assert
      expect(result, isNotNull);
      expect(result!.foodName, 'Apple');
      expect(result.nutritionInfo.calories, 52.0);
      expect(result.id, 'food_1'); // Should have food_ prefix

      // Verify the method was called
      verify(() => mockSupabaseService.getById('nutrition_data', 'id', 1))
          .called(1);
    });

    test('adjustPortion should calculate portions correctly', () async {
      // Arrange - First setup the food to be fetched
      when(() => mockSupabaseService.getById('nutrition_data', 'id', 1))
          .thenAnswer((_) async => testFood);

      // Act - adjust to 200g (double of base 100g)
      final result = await service.adjustPortion(1, 200.0);

      // Assert - values should be doubled
      expect(result.nutritionInfo.calories, 104.0); // 52 * 2
      expect(result.nutritionInfo.protein, 0.6); // 0.3 * 2
      expect(result.nutritionInfo.carbs, 28.0); // 14 * 2

      // Check that vitamins were scaled correctly
      expect(result.nutritionInfo.vitaminsAndMinerals['vitamin_c'],
          9.2); // 4.6 * 2

      // Check metadata
      expect(result.additionalInformation['portion_adjusted'], true);
      expect(result.additionalInformation['original_portion'], 100);
      expect(result.additionalInformation['adjusted_portion'], 200.0);

      // Verify the method was called
      verify(() => mockSupabaseService.getById('nutrition_data', 'id', 1))
          .called(1);
    });

    test('createLocalMeal should combine foods correctly', () {
      // Arrange
      final food1 = FoodAnalysisResult(
        id: 'food_1',
        foodName: 'Apple',
        ingredients: [Ingredient(name: 'Apple', servings: 52)],
        nutritionInfo: NutritionInfo(
            calories: 52,
            protein: 0.3,
            carbs: 14,
            fat: 0.2,
            sodium: 1,
            fiber: 2.4,
            sugar: 10.4,
            vitaminsAndMinerals: {'vitamin_c': 4.6}),
        warnings: [],
      );

      final food2 = FoodAnalysisResult(
        id: 'food_2',
        foodName: 'Banana',
        ingredients: [Ingredient(name: 'Banana', servings: 89)],
        nutritionInfo: NutritionInfo(
            calories: 89,
            protein: 1.1,
            carbs: 23,
            fat: 0.3,
            sodium: 1,
            fiber: 2.6,
            sugar: 12.2,
            vitaminsAndMinerals: {'vitamin_c': 8.7}),
        warnings: [],
      );

      // Act
      final result = service.createLocalMeal('Fruit Salad', [
        food1,
        food2
      ], additionalInformation: {
        'components': [
          {'id': 'food_1', 'name': 'Apple', 'count': 2},
          {'id': 'food_2', 'name': 'Banana', 'count': 1}
        ]
      });

      // Assert
      expect(result.foodName, 'Fruit Salad');
      expect(result.nutritionInfo.calories, 193); // (52 * 2) + 89
      expect(result.nutritionInfo.protein, 2.0); // (0.3 * 2) + 1.1
      expect(result.nutritionInfo.carbs, 51); // (14 * 2) + 23

      // Check vitamins combining
      expect(result.nutritionInfo.vitaminsAndMinerals['vitamin_c'],
          18.0); // (4.6 * 2) + 8.7

      // Check ingredients
      expect(result.ingredients.length, 2);

      // Check additionalInformation
      expect(result.additionalInformation['is_meal'], true);
      expect(result.additionalInformation['component_count'], 2);
    });

    test('updateLocalMeal should update meal properties correctly', () {
      // Arrange
      final originalMeal = FoodAnalysisResult(
        id: 'meal_local_123',
        foodName: 'Original Meal',
        ingredients: [
          Ingredient(name: 'Apple', servings: 52),
          Ingredient(name: 'Banana', servings: 89)
        ],
        nutritionInfo: NutritionInfo(
            calories: 141,
            protein: 1.4,
            carbs: 37,
            fat: 0.5,
            sodium: 2,
            fiber: 5,
            sugar: 22.6,
            vitaminsAndMinerals: {'vitamin_c': 13.3}),
        warnings: [],
        additionalInformation: {
          'is_meal': true,
          'component_count': 2,
          'components': [
            {'food_id': '1', 'name': 'Apple', 'portion': 52, 'count': 1},
            {'food_id': '2', 'name': 'Banana', 'portion': 89, 'count': 1}
          ]
        },
      );

      final food1 = FoodAnalysisResult(
        id: 'food_3',
        foodName: 'Orange',
        ingredients: [Ingredient(name: 'Orange', servings: 45)],
        nutritionInfo: NutritionInfo(
            calories: 45,
            protein: 0.9,
            carbs: 11.8,
            fat: 0.1,
            sodium: 0,
            fiber: 2.4,
            sugar: 9.4,
            vitaminsAndMinerals: {'vitamin_c': 53.2}),
        warnings: [],
      );

      // Act - update name and foods
      final updatedMeal = service
          .updateLocalMeal(originalMeal, name: 'New Meal Name', items: [food1]);

      // Assert
      expect(updatedMeal.foodName, 'New Meal Name');
      expect(updatedMeal.nutritionInfo.calories, 45);
      expect(updatedMeal.ingredients.length, 1);
      expect(updatedMeal.additionalInformation['modified_locally'], true);
      expect(updatedMeal.nutritionInfo.vitaminsAndMinerals['vitamin_c'], 53.0);
    });

    test('saveMealToFirebase should call repository save method with user ID',
        () async {
      // Arrange
      final meal = FoodAnalysisResult(
        id: 'meal_local_123',
        foodName: 'Test Meal',
        ingredients: [Ingredient(name: 'Test Food', servings: 100)],
        nutritionInfo: NutritionInfo(
          calories: 100,
          protein: 1,
          carbs: 20,
          fat: 2,
          sodium: 5,
          fiber: 1,
          sugar: 5,
        ),
        warnings: [],
        additionalInformation: {'is_meal': true},
      );

      when(() => mockRepository.save(any(), 'meal_local_123'))
          .thenAnswer((_) async => 'saved_meal_id');

      // Act
      final result = await service.saveMealToFirebase(meal);

      // Assert
      // Capture the argument in a single verification
      final captured =
          verify(() => mockRepository.save(captureAny(), 'meal_local_123'))
              .captured;

      final capturedMeal = captured[0] as FoodAnalysisResult;
      expect(capturedMeal.userId, 'test_user_id');
      expect(result, 'saved_meal_id');
    });

    test('saveMealToFirebase should throw when user is not authenticated',
        () async {
      // Arrange - reset mockFirebaseAuth to return null for currentUser
      reset(mockFirebaseAuth);
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      final meal = FoodAnalysisResult(
        id: 'meal_local_123',
        foodName: 'Test Meal',
        ingredients: [Ingredient(name: 'Test Food', servings: 100)],
        nutritionInfo: NutritionInfo(
          calories: 100,
          protein: 1,
          carbs: 20,
          fat: 2,
          sodium: 5,
          fiber: 1,
          sugar: 5,
        ),
      );

      // Act & Assert
      expect(() => service.saveMealToFirebase(meal), throwsA(isA<Exception>()));
    });
  });
}

// Helper function to convert to FoodAnalysisResults (copied from service for testing)
List<FoodAnalysisResult> _convertToFoodAnalysisResults(List<dynamic> data) {
  return data
      .map<FoodAnalysisResult>((item) => _convertToFoodAnalysisResult(item))
      .toList();
}

FoodAnalysisResult _convertToFoodAnalysisResult(Map<String, dynamic> item) {
  // Map vitamins and minerals without rounding values
  final Map<String, double> vitaminsAndMinerals = {
    'vitamin_c': _parseDouble(item['vitamin_c']),
    'calcium': _parseDouble(item['calcium']),
  };

  // Create nutrition info
  final nutritionInfo = NutritionInfo(
    calories: _parseDouble(item['caloric_value']),
    protein: _parseDouble(item['protein']),
    carbs: _parseDouble(item['carbohydrates']),
    fat: _parseDouble(item['fat']),
    sodium: _parseDouble(item['sodium']) * 1000.0,
    fiber: _parseDouble(item['dietary_fiber']),
    sugar: _parseDouble(item['sugars']),
    vitaminsAndMinerals: vitaminsAndMinerals,
  );

  return FoodAnalysisResult(
    foodName: item['food'] ?? 'Unknown Food',
    ingredients: [],
    nutritionInfo: nutritionInfo,
    id: 'food_${item['id']}',
  );
}

// Helper to parse double values
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
