import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/domain/repositories/nutrition_database_repository.dart';

// Generate mocks specific for this test file
@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference,
  DocumentReference,
  Query
])
import 'nutrition_database_repository_test.mocks.dart';

void main() {
  late NutritionDatabaseRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockQuery<Map<String, dynamic>> mockQuery;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();

    // Set up user authentication
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');

    // Set up firestore collection references
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
    when(mockDocRef.collection('meals')).thenReturn(mockCollection);
    when(mockCollection.orderBy('timestamp', descending: true))
        .thenReturn(mockQuery);

    repository = NutritionDatabaseRepository(
      firestore: mockFirestore,
    );
  });

  group('NutritionDatabaseRepository', () {
    final testMealData = FoodAnalysisResult(
      id: 'test_id',
      foodName: 'Test Meal',
      nutritionInfo: NutritionInfo(
        calories: 100,
        protein: 10,
        carbs: 20,
        fat: 5,
        saturatedFat: 2,
        sodium: 50,
        fiber: 3,
        sugar: 5,
        cholesterol: 10,
        nutritionDensity: 8,
        vitaminsAndMinerals: {'vitamin_c': 10},
      ),
      ingredients: [
        Ingredient(name: 'Test Ingredient', servings: 100),
      ],
      warnings: ['Test Warning'],
      timestamp: DateTime(2025, 4, 27),
    );

    test('save should add meal to the database with meal prefix', () async {
      // Arrange
      when(mockDocRef.collection('meals')).thenReturn(mockCollection);
      when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);
      when(mockDocRef.id).thenReturn('meal_1');
      when(mockDocRef.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.save(testMealData, 'Test Meal');

      // Assert
      verify(mockCollection.add(any)).called(1);
      expect(result, 'meal_1');
    });

    test('getAll should retrieve all meals with correct ordering', () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
      when(mockQueryDocSnapshot.id).thenReturn('1');
      when(mockQueryDocSnapshot.data()).thenReturn({
        'foodName': 'Test Meal',
        'nutritionInfo': {
          'calories': 100,
          'protein': 10,
          'carbs': 20,
          'fat': 5,
        },
        'ingredients': [
          {'name': 'Test Ingredient', 'servings': 100}
        ],
        'warnings': ['Test Warning'],
        'timestamp': Timestamp.fromDate(DateTime(2025, 4, 27)),
      });

      // Act
      final results = await repository.getAll();

      // Assert
      expect(results.length, 1);
      expect(results[0].id, '1');
      expect(results[0].foodName, 'Test Meal');
    });

    test('getAnalysisResultsByDate should retrieve meals for a specific date',
        () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
      when(mockQueryDocSnapshot.id).thenReturn('1');
      when(mockQueryDocSnapshot.data()).thenReturn({
        'foodName': 'Test Meal',
        'nutritionInfo': {
          'calories': 100,
          'protein': 10,
          'carbs': 20,
          'fat': 5,
        },
        'ingredients': [
          {'name': 'Test Ingredient', 'servings': 100}
        ],
        'warnings': ['Test Warning'],
        'timestamp': Timestamp.fromDate(DateTime(2025, 4, 27)),
      });

      // Act
      final results =
          await repository.getAnalysisResultsByDate(DateTime(2025, 4, 27));

      // Assert
      expect(results.length, 1);
      expect(results[0].id, '1');
      expect(results[0].foodName, 'Test Meal');
    });

    test(
        'getAnalysisResultsByMonth should retrieve meals for a specific month and year',
        () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
      when(mockQueryDocSnapshot.id).thenReturn('1');
      when(mockQueryDocSnapshot.data()).thenReturn({
        'foodName': 'Test Meal',
        'nutritionInfo': {
          'calories': 100,
          'protein': 10,
          'carbs': 20,
          'fat': 5,
        },
        'ingredients': [
          {'name': 'Test Ingredient', 'servings': 100}
        ],
        'warnings': ['Test Warning'],
        'timestamp': Timestamp.fromDate(DateTime(2025, 4, 27)),
      });

      // Act
      final results = await repository.getAnalysisResultsByMonth(4, 2025);

      // Assert
      expect(results.length, 1);
      expect(results[0].id, '1');
      expect(results[0].foodName, 'Test Meal');
    });
  });
}

// Mock classes for Firebase
class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<T> {}
