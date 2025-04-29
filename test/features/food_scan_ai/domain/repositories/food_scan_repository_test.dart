// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'food_scan_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore, 
  CollectionReference<Map<String, dynamic>>, 
  DocumentReference<Map<String, dynamic>>
])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FoodScanRepository repository;
  final testFoodAnalysis = FoodAnalysisResult(
    foodName: 'Nasi Goreng',
    ingredients: [
      Ingredient(
        name: 'Nasi',
        servings: 60,
      ),
      Ingredient(
        name: 'Telur',
        servings: 20,
      ),
    ],
    nutritionInfo: NutritionInfo(
      calories: 300,
      protein: 10,
      carbs: 45,
      fat: 8,
      sodium: 400,
      fiber: 2,
      sugar: 1,
    ),
  );

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FoodScanRepository(firestore: fakeFirestore);
  });

  group('FoodScanRepository', () {
    test('save should store food analysis in Firestore', () async {
      // Act
      final id = '1';
      await repository.save(testFoodAnalysis, id);

      // Assert
      final docSnapshot =
          await fakeFirestore.collection('food_analysis').doc(id).get();

      expect(docSnapshot.exists, true);
      final data = docSnapshot.data()!;
      expect(data['food_name'], testFoodAnalysis.foodName);
      expect(data['nutrition_info']['calories'],
          testFoodAnalysis.nutritionInfo.calories);
      expect(data['ingredients'].length, testFoodAnalysis.ingredients.length);
    });

    test('getById should return food analysis', () async {
      // Arrange
      final id = '1';
      await repository.save(testFoodAnalysis, id);

      // Act
      final result = await repository.getById(id);

      // Assert
      expect(result, isNotNull);
      expect(result?.foodName, testFoodAnalysis.foodName);
      expect(result?.nutritionInfo.calories, testFoodAnalysis.nutritionInfo.calories);
      expect(result?.ingredients.length, testFoodAnalysis.ingredients.length);
    });
    test('getAll should return list of food analyses', () async {
      // Arrange
      await repository.save(testFoodAnalysis, '1');
      
      final secondAnalysis = FoodAnalysisResult(
        foodName: 'Sate Ayam',
        ingredients: [
          Ingredient(
            name: 'Ayam',
            servings: 70,
          ),
          Ingredient(
            name: 'Kacang',
            servings: 30,
          ),
        ],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 20,
          carbs: 15,
          fat: 12,
          sodium: 300,
          fiber: 1,
          sugar: 2,
        ),
      );
      await repository.save(secondAnalysis, '2');

      // Act
      final results = await repository.getAll();

      // Assert
      expect(results.length, 2);
      expect(
        results.any((item) => item.foodName == testFoodAnalysis.foodName), 
        true
      );
      expect(
        results.any((item) => item.foodName == secondAnalysis.foodName), 
        true
      );
    });

    test('getById should return null for non-existent document', () async {
      // Act
      final result = await repository.getById('non-existent-id');

      // Assert
      expect(result, isNull);
    });
  });

  group('FoodScanRepository - Exception Handling', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocument;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocument = MockDocumentReference<Map<String, dynamic>>();
      
      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
    });

    test('save should throw exception with correct error message', () async {
      when(mockDocument.set(any)).thenThrow(Exception('Network error'));
      repository = FoodScanRepository(firestore: mockFirestore);

      expect(
        () => repository.save(testFoodAnalysis, '1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to save item')
        ))
      );
    });

    test('getById should throw exception with correct error message', () async {
      when(mockDocument.get()).thenThrow(Exception('Network error'));
      repository = FoodScanRepository(firestore: mockFirestore);

      expect(
        () => repository.getById('1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to retrieve item')
        ))
      );
    });

    test('getAll should throw exception with correct error message', () async {
      when(mockCollection.get()).thenThrow(Exception('Network error'));
      repository = FoodScanRepository(firestore: mockFirestore);

      expect(
        () => repository.getAll(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to retrieve items')
        ))
      );
    });
  });

  group('FoodScanRepository - Date Filtering', () {
    late DateTime testDate;
    late FoodAnalysisResult todayAnalysis;
    late FoodAnalysisResult yesterdayAnalysis;
    late FoodAnalysisResult lastMonthAnalysis;
    late FoodAnalysisResult lastYearAnalysis;

    setUp(() async {
      testDate = DateTime(2024, 3, 15, 12, 0);
      
      todayAnalysis = FoodAnalysisResult(
        foodName: 'Today Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 300,
          protein: 10,
          carbs: 45,
          fat: 8,
          sodium: 400,
          fiber: 2,
          sugar: 1,
        ),
        timestamp: testDate,
      );

      yesterdayAnalysis = FoodAnalysisResult(
        foodName: 'Yesterday Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 8,
          carbs: 35,
          fat: 6,
          sodium: 300,
          fiber: 1,
          sugar: 1,
        ),
        timestamp: testDate.subtract(const Duration(days: 1)),
      );

      lastMonthAnalysis = FoodAnalysisResult(
        foodName: 'Last Month Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 400,
          protein: 15,
          carbs: 50,
          fat: 12,
          sodium: 500,
          fiber: 3,
          sugar: 2,
        ),
        timestamp: DateTime(2024, 2, 15),
      );

      lastYearAnalysis = FoodAnalysisResult(
        foodName: 'Last Year Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 350,
          protein: 12,
          carbs: 40,
          fat: 10,
          sodium: 450,
          fiber: 2,
          sugar: 2,
        ),
        timestamp: DateTime(2023, 3, 15),
      );

      // Save test data
      await repository.save(todayAnalysis, '1');
      await repository.save(yesterdayAnalysis, '2');
      await repository.save(lastMonthAnalysis, '3');
      await repository.save(lastYearAnalysis, '4');
    });

    test('getAnalysisResultsByDate should return results for specific date', () async {
      // Act
      final results = await repository.getAnalysisResultsByDate(testDate);

      // Assert
      expect(results.length, 1);
      expect(results.first.foodName, 'Today Food');
      expect(results.first.timestamp.day, testDate.day);
      expect(results.first.timestamp.month, testDate.month);
      expect(results.first.timestamp.year, testDate.year);
    });

    test('getAnalysisResultsByMonth should return results for specific month', () async {
      // Act
      final results = await repository.getAnalysisResultsByMonth(3, 2024);

      // Assert
      expect(results.length, 2); // Today and yesterday's food
      expect(
        results.any((result) => result.foodName == 'Today Food'),
        true,
      );
      expect(
        results.any((result) => result.foodName == 'Yesterday Food'),
        true,
      );
    });

    test('getAnalysisResultsByYear should return results for specific year', () async {
      // Act
      final results = await repository.getAnalysisResultsByYear(2024);

      // Assert
      expect(results.length, 3); // Today, yesterday, and last month's food
      expect(
        results.any((result) => result.foodName == 'Today Food'),
        true,
      );
      expect(
        results.any((result) => result.foodName == 'Yesterday Food'),
        true,
      );
      expect(
        results.any((result) => result.foodName == 'Last Month Food'),
        true,
      );
    });

    test('getAnalysisResultsByDate with limit should respect the limit', () async {
      // Save another food for the same date
      final anotherTodayAnalysis = FoodAnalysisResult(
        foodName: 'Another Today Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 200,
          protein: 5,
          carbs: 30,
          fat: 4,
          sodium: 200,
          fiber: 1,
          sugar: 1,
        ),
        timestamp: testDate,
      );
      await repository.save(anotherTodayAnalysis, '5');

      // Act
      final results = await repository.getAnalysisResultsByDate(testDate, limit: 1);

      // Assert
      expect(results.length, 1);
    });
  });

  group('FoodScanRepository - Delete Operations', () {
    test('deleteById should successfully delete existing document', () async {
      // Arrange
      const id = 'test-id';
      await repository.save(testFoodAnalysis, id);

      // Act
      final result = await repository.deleteById(id);
      final deletedDoc = await repository.getById(id);

      // Assert
      expect(result, true);
      expect(deletedDoc, isNull);
    });

    test('deleteById should return false for non-existent document', () async {
      // Act
      final result = await repository.deleteById('non-existent-id');

      // Assert
      expect(result, false);
    });

    test('deleteById should handle errors gracefully', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();
      
      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.delete()).thenThrow(Exception('Network error'));
      
      repository = FoodScanRepository(firestore: mockFirestore);

      // Act & Assert
      expect(
        () => repository.deleteById('1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to delete item')
        ))
      );
    });
  });
}
