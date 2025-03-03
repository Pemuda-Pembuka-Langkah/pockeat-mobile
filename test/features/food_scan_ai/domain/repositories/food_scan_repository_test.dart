import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_scan_repository_test.mocks.dart';
import 'package:mockito/mockito.dart';

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
        percentage: 60.0,
        allergen: false,
      ),
      Ingredient(
        name: 'Telur',
        percentage: 20.0,
        allergen: true,
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
            percentage: 70.0,
            allergen: false,
          ),
          Ingredient(
            name: 'Kacang',
            percentage: 30.0,
            allergen: true,
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
}
