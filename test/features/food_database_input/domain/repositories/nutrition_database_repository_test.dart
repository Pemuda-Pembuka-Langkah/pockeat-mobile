// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/domain/repositories/nutrition_database_repository.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>
])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late NutritionDatabaseRepository repository;
  final testFoodAnalysisResult = FoodAnalysisResult(
    foodName: 'Test Meal',
    ingredients: [
      Ingredient(
        name: 'Rice',
        servings: 50,
      ),
      Ingredient(
        name: 'Chicken',
        servings: 30,
      ),
    ],
    nutritionInfo: NutritionInfo(
      calories: 350,
      protein: 25,
      carbs: 40,
      fat: 10,
      sodium: 450,
      fiber: 2,
      sugar: 1,
    ),
    additionalInformation: {
      'is_meal': true,
      'component_count': 2,
    },
  );

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = NutritionDatabaseRepository(firestore: fakeFirestore);
  });

  group('NutritionDatabaseRepository', () {
    test('save should store food analysis in Firestore with meal prefix',
        () async {
      // Act
      final id = 'test_meal_id';
      final result = await repository.save(testFoodAnalysisResult, id);

      // Assert
      expect(result, 'test_meal_id');

      final docSnapshot =
          await fakeFirestore.collection('food_analysis').doc(id).get();

      expect(docSnapshot.exists, true);
      final data = docSnapshot.data()!;
      expect(data['food_name'], testFoodAnalysisResult.foodName);
      expect(data['nutrition_info']['calories'],
          testFoodAnalysisResult.nutritionInfo.calories);
      expect(data['ingredients'].length,
          testFoodAnalysisResult.ingredients.length);
      expect(data['additional_information']['is_meal'], true);
    });

    test('getById should return food analysis with transformed ID', () async {
      // Arrange
      final id = 'test_meal_id';
      await repository.save(testFoodAnalysisResult, id);

      // Act
      final result = await repository.getById(id);

      // Assert
      expect(result, isNotNull);
      expect(result?.foodName, testFoodAnalysisResult.foodName);
      expect(result?.nutritionInfo.calories,
          testFoodAnalysisResult.nutritionInfo.calories);
      expect(result?.ingredients.length,
          testFoodAnalysisResult.ingredients.length);
      expect(result?.id, 'meal_$id'); // Should have meal_ prefix
      expect(result?.additionalInformation['is_meal'], true);
      expect(result?.additionalInformation['saved_to_firebase'], true);
    });

    test('getAll should return list of food analyses', () async {
      // Arrange
      await repository.save(testFoodAnalysisResult, 'meal1');

      final secondAnalysis = FoodAnalysisResult(
        foodName: 'Second Test Meal',
        ingredients: [
          Ingredient(
            name: 'Pasta',
            servings: 70,
          ),
          Ingredient(
            name: 'Sauce',
            servings: 30,
          ),
        ],
        nutritionInfo: NutritionInfo(
          calories: 400,
          protein: 15,
          carbs: 60,
          fat: 8,
          sodium: 500,
          fiber: 3,
          sugar: 4,
        ),
        additionalInformation: {
          'is_meal': true,
          'component_count': 2,
        },
      );

      await repository.save(secondAnalysis, 'meal2');

      // Act
      final results = await repository.getAll();

      // Assert
      expect(results.length, 2);
      expect(results.any((item) => item.foodName == 'Test Meal'), true);
      expect(results.any((item) => item.foodName == 'Second Test Meal'), true);
    });

    test('deleteById should remove item from database', () async {
      // Arrange
      final id = 'test_meal_id';
      await repository.save(testFoodAnalysisResult, id);

      // Act
      final result = await repository.deleteById(id);

      // Assert
      expect(result, true);
      final docSnapshot =
          await fakeFirestore.collection('food_analysis').doc(id).get();
      expect(docSnapshot.exists, false);
    });

    test('getAnalysisResultsByDate should return items from specific date',
        () async {
      // Arrange
      final testDate = DateTime(2025, 4, 30);

      // Create a meal with a specific date
      final mealWithDate = testFoodAnalysisResult.copyWith(
        timestamp: testDate,
      );

      // Instead of saving the meal directly using repository.save,
      // manually create the document with a proper Firestore Timestamp
      await fakeFirestore.collection('food_analysis').doc('meal_today').set({
        ...repository.toMap(mealWithDate),
        'timestamp': Timestamp.fromDate(testDate),
      });

      // Create another meal with a different date
      final differentDate = DateTime(2025, 4, 29);
      final mealDifferentDate = testFoodAnalysisResult.copyWith(
        timestamp: differentDate,
        foodName: 'Different Day Meal',
      );

      // Again, manually set the document with a proper Timestamp
      await fakeFirestore
          .collection('food_analysis')
          .doc('meal_yesterday')
          .set({
        ...repository.toMap(mealDifferentDate),
        'timestamp': Timestamp.fromDate(differentDate),
      });

      // Act
      final resultsToday = await repository.getAnalysisResultsByDate(testDate);
      final resultsYesterday =
          await repository.getAnalysisResultsByDate(differentDate);

      // Assert
      expect(resultsToday.length, 1);
      expect(resultsToday.first.foodName, 'Test Meal');

      expect(resultsYesterday.length, 1);
      expect(resultsYesterday.first.foodName, 'Different Day Meal');
    });

    test('getAnalysisResultsByMonth should return items from specific month',
        () async {
      // Arrange
      final aprilDate = DateTime(2025, 4, 15);
      final mayDate = DateTime(2025, 5, 15);

      final aprilMeal = testFoodAnalysisResult.copyWith(
        timestamp: aprilDate,
        foodName: 'April Meal',
      );

      final mayMeal = testFoodAnalysisResult.copyWith(
        timestamp: mayDate,
        foodName: 'May Meal',
      );

      // Manually create documents with proper Firestore Timestamp objects
      await fakeFirestore.collection('food_analysis').doc('meal_april').set({
        ...repository.toMap(aprilMeal),
        'timestamp': Timestamp.fromDate(aprilDate),
      });

      await fakeFirestore.collection('food_analysis').doc('meal_may').set({
        ...repository.toMap(mayMeal),
        'timestamp': Timestamp.fromDate(mayDate),
      });

      // Act
      final aprilResults = await repository.getAnalysisResultsByMonth(4, 2025);
      final mayResults = await repository.getAnalysisResultsByMonth(5, 2025);

      // Assert
      expect(aprilResults.length, 1);
      expect(aprilResults.first.foodName, 'April Meal');

      expect(mayResults.length, 1);
      expect(mayResults.first.foodName, 'May Meal');
    });
  });
}
