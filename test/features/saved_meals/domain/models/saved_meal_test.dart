import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

void main() {
  group('SavedMeal Model', () {
    // Define test data to match the actual implementation
    final DateTime testCreatedAt = DateTime(2023, 1, 1);
    final DateTime testUpdatedAt = DateTime(2023, 1, 2);
    
    late FoodAnalysisResult testFoodAnalysis;
    late SavedMeal testSavedMeal;
    
    setUp(() {
      // Create nutrition info for test food analysis
      final nutritionInfo = NutritionInfo(
        calories: 200,
        protein: 10,
        carbs: 20,
        fat: 5,
        saturatedFat: 2,
        sodium: 100,
        fiber: 2,
        sugar: 3,
        cholesterol: 15,
        nutritionDensity: 40,
      );
      
      // Create test food analysis
      testFoodAnalysis = FoodAnalysisResult(
        foodName: 'Test Food',
        ingredients: [
          Ingredient(name: 'Test Ingredient', servings: 1.0)
        ],
        nutritionInfo: nutritionInfo,
        warnings: ['Test warning'],
        foodImageUrl: 'https://example.com/image.jpg',
        timestamp: DateTime(2023, 1, 1),
        id: 'test-analysis-id',
        userId: 'user123',
        additionalInformation: {'test': 'info'},
        healthScore: 7.5,
      );
      
      // Create test saved meal
      testSavedMeal = SavedMeal(
        id: 'test-id',
        userId: 'user123',
        name: 'Test Meal',
        foodAnalysis: testFoodAnalysis,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );
    });
    
    test('should create SavedMeal instance with all properties', () {
      // Assert all properties are correctly set
      expect(testSavedMeal.id, equals('test-id'));
      expect(testSavedMeal.userId, equals('user123'));
      expect(testSavedMeal.name, equals('Test Meal'));
      expect(testSavedMeal.foodAnalysis, equals(testFoodAnalysis));
      expect(testSavedMeal.createdAt, equals(testCreatedAt));
      expect(testSavedMeal.updatedAt, equals(testUpdatedAt));
    });

    test('should convert to Firestore map correctly', () {
      // Act
      final Map<String, dynamic> firestoreMap = testSavedMeal.toFirestore();

      // Assert
      expect(firestoreMap['userId'], equals('user123'));
      expect(firestoreMap['name'], equals('Test Meal'));
      expect(firestoreMap['foodAnalysis'], equals(testFoodAnalysis.toJson()));
      expect(firestoreMap['createdAt'], equals(testCreatedAt));
      expect(firestoreMap['updatedAt'], equals(testUpdatedAt));
      
      // Make sure id is not included in the map as per implementation
      expect(firestoreMap.containsKey('id'), isFalse);
    });

    test('should create SavedMeal from Firestore document correctly', () {
      // Arrange - create a fake Firestore document snapshot
      final fakeFirestore = FakeFirebaseFirestore();
      final docRef = fakeFirestore.collection('saved_meals').doc('test-id');
      
      // Set up test data in Firestore format
      final testData = {
        'userId': 'user123',
        'name': 'Test Meal',
        'foodAnalysis': testFoodAnalysis.toJson(),
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'updatedAt': Timestamp.fromDate(testUpdatedAt),
      };
      
      // Set the document data
      docRef.set(testData);
      
      // Act & Assert - test the fromFirestore factory method
      expectLater(
        docRef.get().then((doc) => SavedMeal.fromFirestore(doc)),
        completion(
          isA<SavedMeal>()
            .having((m) => m.id, 'id', 'test-id')
            .having((m) => m.userId, 'userId', 'user123')
            .having((m) => m.name, 'name', 'Test Meal')
            .having((m) => m.foodAnalysis.foodName, 'foodAnalysis.foodName', testFoodAnalysis.foodName)
            .having((m) => m.createdAt, 'createdAt', testCreatedAt)
            .having((m) => m.updatedAt, 'updatedAt', testUpdatedAt)
        ),
      );
    });
    
    test('should handle missing name in Firestore document', () {
      // Arrange - create a fake Firestore document without a name field
      final fakeFirestore = FakeFirebaseFirestore();
      final docRef = fakeFirestore.collection('saved_meals').doc('test-id');
      
      // Set up test data without name field
      final testData = {
        'userId': 'user123',
        'foodAnalysis': testFoodAnalysis.toJson(),
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'updatedAt': Timestamp.fromDate(testUpdatedAt),
      };
      
      // Set the document data
      docRef.set(testData);
      
      // Act & Assert - test default name handling
      expectLater(
        docRef.get().then((doc) => SavedMeal.fromFirestore(doc)),
        completion(
          isA<SavedMeal>()
            .having((m) => m.id, 'id', 'test-id')
            .having((m) => m.name, 'name', 'Unnamed meal') // Default value from implementation
        ),
      );
    });
    
    test('should create a copy with modified fields using copyWith', () {
      // Arrange
      final DateTime newUpdatedAt = DateTime(2023, 1, 3);
      
      // Act
      final updatedMeal = testSavedMeal.copyWith(
        name: 'Updated Meal Name',
        updatedAt: newUpdatedAt,
      );
      
      // Assert
      expect(updatedMeal.id, equals(testSavedMeal.id)); // Unchanged
      expect(updatedMeal.userId, equals(testSavedMeal.userId)); // Unchanged
      expect(updatedMeal.name, equals('Updated Meal Name')); // Changed
      expect(updatedMeal.foodAnalysis, equals(testSavedMeal.foodAnalysis)); // Unchanged
      expect(updatedMeal.createdAt, equals(testSavedMeal.createdAt)); // Unchanged
      expect(updatedMeal.updatedAt, equals(newUpdatedAt)); // Changed
    });
    
    test('should update updatedAt to current time when not specified in copyWith', () {
      // Arrange - get time before and after operation
      final beforeUpdate = DateTime.now();
      
      // Act - call copyWith without specifying updatedAt
      final updatedMeal = testSavedMeal.copyWith(name: 'New Name Only');
      
      final afterUpdate = DateTime.now();
      
      // Assert
      expect(updatedMeal.name, equals('New Name Only'));
      
      // Test that updatedAt is between beforeUpdate and afterUpdate
      expect(
        updatedMeal.updatedAt.isAfter(beforeUpdate) || 
        updatedMeal.updatedAt.isAtSameMomentAs(beforeUpdate), 
        isTrue
      );
      
      expect(
        updatedMeal.updatedAt.isBefore(afterUpdate) || 
        updatedMeal.updatedAt.isAtSameMomentAs(afterUpdate), 
        isTrue
      );
    });
  });
}
