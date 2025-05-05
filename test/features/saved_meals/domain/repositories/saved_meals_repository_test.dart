import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/repositories/saved_meals_repository.dart';

// Create a mock FirebaseAuth class
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final MockUser _currentUser;

  MockFirebaseAuth(this._currentUser);

  @override
  User? get currentUser => _currentUser;
}

// Create a mock User class
class MockUser extends Mock implements User {
  @override
  final String uid;

  MockUser(this.uid);
}

@GenerateMocks([])
void main() {
  group('SavedMealsRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late SavedMealsRepository repository;
    late FoodAnalysisResult testFoodAnalysis;
    final String testUserId = 'test-user-123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(MockUser(testUserId));
      repository = SavedMealsRepository(
        firestore: fakeFirestore,
        auth: mockAuth,
      );

      // Create minimal test food analysis
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
      );
    });

    test('saveMeal - should save a meal with custom name', () async {
      // Act
      final result =
          await repository.saveMeal(testFoodAnalysis, name: 'Custom Name');

      // Assert
      expect(result, isA<SavedMeal>());
      expect(result.id, isNotEmpty);
      expect(result.userId, equals(testUserId));
      expect(result.name, equals('Custom Name'));
      expect(result.foodAnalysis, equals(testFoodAnalysis));

      // Verify data was saved to Firestore
      final savedDoc =
          await fakeFirestore.collection('saved_meals').doc(result.id).get();
      expect(savedDoc.exists, isTrue);

      final data = savedDoc.data() as Map<String, dynamic>;
      expect(data['userId'], equals(testUserId));
      expect(data['name'], equals('Custom Name'));
      expect(data['foodAnalysisId'], equals(testFoodAnalysis.id));
    });

    test('saveMeal - should use food name as default when name not provided',
        () async {
      // Act
      final result = await repository.saveMeal(testFoodAnalysis);

      // Assert
      expect(result.name, equals(testFoodAnalysis.foodName));
    });

    test('getSavedMeals - should return meals for current user as stream',
        () async {
      // Arrange - save meals for the current user
      final meal1 = await repository
          .saveMeal(testFoodAnalysis.copyWith(id: 'food1'), name: 'Meal 1');
      final meal2 = await repository
          .saveMeal(testFoodAnalysis.copyWith(id: 'food2'), name: 'Meal 2');

      // Save a meal for another user
      await fakeFirestore.collection('saved_meals').add({
        'userId': 'another-user',
        'name': 'Another user meal',
        'foodAnalysis': testFoodAnalysis.toJson(),
        'foodAnalysisId': testFoodAnalysis.id,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Act & Assert - verify stream returns only current user's meals
      repository.getSavedMeals().listen(expectAsync1((meals) {
        expect(meals, hasLength(2)); // Only current user's meals
        expect(meals.map((m) => m.id), containsAll([meal1.id, meal2.id]));
        expect(meals.every((m) => m.userId == testUserId), isTrue);
      }));
    });

    test('getSavedMeals - should sort meals by updatedAt in descending order',
        () async {
      // Arrange - create meals with specific timestamps
      final now = DateTime.now();

      final oldMeal = SavedMeal(
        id: 'old-meal',
        userId: testUserId,
        name: 'Old Meal',
        foodAnalysis: testFoodAnalysis,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      );

      final recentMeal = SavedMeal(
        id: 'recent-meal',
        userId: testUserId,
        name: 'Recent Meal',
        foodAnalysis: testFoodAnalysis,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      );

      final newestMeal = SavedMeal(
        id: 'newest-meal',
        userId: testUserId,
        name: 'Newest Meal',
        foodAnalysis: testFoodAnalysis,
        createdAt: now,
        updatedAt: now,
      );

      // Add meals in random order
      await fakeFirestore.collection('saved_meals').doc(oldMeal.id).set({
        'userId': oldMeal.userId,
        'name': oldMeal.name,
        'foodAnalysis': oldMeal.foodAnalysis.toJson(),
        'foodAnalysisId': oldMeal.foodAnalysis.id,
        'createdAt': Timestamp.fromDate(oldMeal.createdAt),
        'updatedAt': Timestamp.fromDate(oldMeal.updatedAt),
      });

      await fakeFirestore.collection('saved_meals').doc(newestMeal.id).set({
        'userId': newestMeal.userId,
        'name': newestMeal.name,
        'foodAnalysis': newestMeal.foodAnalysis.toJson(),
        'foodAnalysisId': newestMeal.foodAnalysis.id,
        'createdAt': Timestamp.fromDate(newestMeal.createdAt),
        'updatedAt': Timestamp.fromDate(newestMeal.updatedAt),
      });

      await fakeFirestore.collection('saved_meals').doc(recentMeal.id).set({
        'userId': recentMeal.userId,
        'name': recentMeal.name,
        'foodAnalysis': recentMeal.foodAnalysis.toJson(),
        'foodAnalysisId': recentMeal.foodAnalysis.id,
        'createdAt': Timestamp.fromDate(recentMeal.createdAt),
        'updatedAt': Timestamp.fromDate(recentMeal.updatedAt),
      });

      // Act & Assert - verify sort order in stream
      repository.getSavedMeals().listen(expectAsync1((meals) {
        expect(meals, hasLength(3));
        // Should be sorted by updatedAt (newest first)
        expect(meals[0].id, equals(newestMeal.id));
        expect(meals[1].id, equals(recentMeal.id));
        expect(meals[2].id, equals(oldMeal.id));
      }));
    });

    test('getSavedMeal - should return meal by ID', () async {
      // Arrange
      final savedMeal = await repository.saveMeal(testFoodAnalysis);

      // Act
      final retrievedMeal = await repository.getSavedMeal(savedMeal.id);

      // Assert
      expect(retrievedMeal, isNotNull);
      expect(retrievedMeal!.id, equals(savedMeal.id));
      expect(retrievedMeal.name, equals(savedMeal.name));
    });

    test('getSavedMeal - should return null for non-existent ID', () async {
      // Act
      final result = await repository.getSavedMeal('non-existent-id');

      // Assert
      expect(result, isNull);
    });

    test('deleteSavedMeal - should delete meal by ID', () async {
      // Arrange
      final savedMeal = await repository.saveMeal(testFoodAnalysis);
      final docRef = fakeFirestore.collection('saved_meals').doc(savedMeal.id);

      // Verify meal exists before deletion
      expect((await docRef.get()).exists, isTrue);

      // Act
      await repository.deleteSavedMeal(savedMeal.id);

      // Assert
      expect((await docRef.get()).exists, isFalse);
    });

    test('logFoodAnalysis - should save to food_analysis collection', () async {
      // Act
      final savedId = await repository.logFoodAnalysis(testFoodAnalysis);

      // Assert
      expect(savedId, isNotEmpty);

      // Verify data was saved correctly
      final doc =
          await fakeFirestore.collection('food_analysis').doc(savedId).get();
      expect(doc.exists, isTrue);

      final data = doc.data() as Map<String, dynamic>;
      expect(data['food_name'], equals(testFoodAnalysis.foodName));
      expect(data['userId'], equals(testUserId));
    });

    test('isMealSaved - should return true when meal exists', () async {
      // Arrange
      await repository.saveMeal(testFoodAnalysis);

      // Act
      final isSaved = await repository.isMealSaved(testFoodAnalysis.id);

      // Assert
      expect(isSaved, isTrue);
    });

    test('isMealSaved - should return false when meal does not exist',
        () async {
      // Act
      final isNotSaved = await repository.isMealSaved('non-existent-id');

      // Assert
      expect(isNotSaved, isFalse);
    });

    test('getFoodLogsByDate - should return food logs for specific date',
        () async {
      // Arrange
      final today = DateTime(2023, 1, 1);
      final yesterday = DateTime(2022, 12, 31);

      // Create food analyses with different dates
      final todayAnalysis1 = testFoodAnalysis.copyWith(
        id: 'today1',
        timestamp: today.add(const Duration(hours: 8)),
      );

      final todayAnalysis2 = testFoodAnalysis.copyWith(
        id: 'today2',
        timestamp: today.add(const Duration(hours: 12)),
      );

      final yesterdayAnalysis = testFoodAnalysis.copyWith(
        id: 'yesterday',
        timestamp: yesterday.add(const Duration(hours: 10)),
      );

      // Insert documents directly with Timestamp objects instead of ISO strings
      await fakeFirestore.collection('food_analysis').doc('today1').set({
        'food_name': todayAnalysis1.foodName,
        'ingredients':
            todayAnalysis1.ingredients.map((i) => i.toJson()).toList(),
        'nutrition_info': todayAnalysis1.nutritionInfo.toJson(),
        'warnings': todayAnalysis1.warnings,
        'food_image_url': todayAnalysis1.foodImageUrl,
        'timestamp': Timestamp.fromDate(
            todayAnalysis1.timestamp), // Use Timestamp object
        'id': todayAnalysis1.id,
        'userId': testUserId,
      });

      await fakeFirestore.collection('food_analysis').doc('today2').set({
        'food_name': todayAnalysis2.foodName,
        'ingredients':
            todayAnalysis2.ingredients.map((i) => i.toJson()).toList(),
        'nutrition_info': todayAnalysis2.nutritionInfo.toJson(),
        'warnings': todayAnalysis2.warnings,
        'food_image_url': todayAnalysis2.foodImageUrl,
        'timestamp': Timestamp.fromDate(
            todayAnalysis2.timestamp), // Use Timestamp object
        'id': todayAnalysis2.id,
        'userId': testUserId,
      });

      await fakeFirestore.collection('food_analysis').doc('yesterday').set({
        'food_name': yesterdayAnalysis.foodName,
        'ingredients':
            yesterdayAnalysis.ingredients.map((i) => i.toJson()).toList(),
        'nutrition_info': yesterdayAnalysis.nutritionInfo.toJson(),
        'warnings': yesterdayAnalysis.warnings,
        'food_image_url': yesterdayAnalysis.foodImageUrl,
        'timestamp': Timestamp.fromDate(
            yesterdayAnalysis.timestamp), // Use Timestamp object
        'id': yesterdayAnalysis.id,
        'userId': testUserId,
      });

      // Act
      final todayLogs = await repository.getFoodLogsByDate(today);
      final yesterdayLogs = await repository.getFoodLogsByDate(yesterday);

      // Assert
      expect(todayLogs.length, equals(2));
      expect(yesterdayLogs.length, equals(1));
    });
  });
}
