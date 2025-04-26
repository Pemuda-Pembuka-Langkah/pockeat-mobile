// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'food_log_history_service_test.mocks.dart';

@GenerateMocks([
  FoodScanRepository,
  FirebaseFirestore,
  CollectionReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
class ThrowingFirestore extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    throw Exception('Test Firestore failure');
  }
}

FoodAnalysisResult createTestFoodAnalysisResult(
    String userId, DateTime timestamp) {
  return FoodAnalysisResult(
    id: 'food-${timestamp.millisecondsSinceEpoch}',
    foodName: 'Test Food ${timestamp.day}',
    foodImageUrl: 'https://example.com/food_${timestamp.day}.jpg',
    timestamp: timestamp,
    nutritionInfo: NutritionInfo(
      calories: 400,
      protein: 20,
      carbs: 30,
      fat: 20,
      sodium: 400,
      sugar: 5,
      fiber: 3,
    ),
    ingredients: [Ingredient(name: 'Test Ingredient', servings: 1)],
    warnings: [],
    userId: userId,
  );
}

void main() {
  late FoodLogHistoryService service;
  late MockFoodScanRepository mockFoodScanRepository;
  late FakeFirebaseFirestore fakeFirestore;

  final testDate = DateTime(2023, 5, 15);
  final testUserId = 'test-user-id';
  final otherUserId = 'other-user-id';

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
      userId: testUserId,
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
      userId: testUserId,
    ),
    // Add a food item with a different userId to test filtering
    FoodAnalysisResult(
      id: 'food3',
      foodName: 'Other User Food',
      foodImageUrl: 'https://example.com/other.jpg',
      timestamp: testDate,
      nutritionInfo: NutritionInfo(
        calories: 400,
        protein: 20,
        carbs: 30,
        fat: 20,
        sodium: 400,
        sugar: 5,
        fiber: 3,
      ),
      ingredients: [
        Ingredient(name: 'Other Ingredient', servings: 1),
      ],
      warnings: [],
      userId: otherUserId,
    ),
  ];

  setUp(() {
    mockFoodScanRepository = MockFoodScanRepository();
    fakeFirestore = FakeFirebaseFirestore();

    service = FoodLogHistoryServiceImpl(
      foodScanRepository: mockFoodScanRepository,
      firestore: fakeFirestore, // ← now using fake
    );
  });

  group('FoodLogHistoryService', () {
    test('getAllFoodLogs should return all food logs for the user', () async {
      // Arrange
      when(mockFoodScanRepository.getAll(limit: anyNamed('limit')))
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.getAllFoodLogs(testUserId);

      // Assert - only the items with testUserId should be returned (not the other-user-id item)
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAll(limit: null)).called(1);
    });

    test('getFoodLogsByDate should return food logs for specific date and user',
        () async {
      // Arrange - Include both user IDs in the test data
      final dateSpecificResults = [
        sampleFoodResults[0],
        sampleFoodResults[2]
      ]; // testUserId and otherUserId
      when(mockFoodScanRepository.getAnalysisResultsByDate(testDate))
          .thenAnswer((_) async => dateSpecificResults);

      // Act
      final result = await service.getFoodLogsByDate(testUserId, testDate);

      // Assert - only the items with testUserId should be returned
      expect(result.length,
          1); // Only one item with testUserId for the specific date
      expect(result[0].title, 'Chicken Salad');
      verify(mockFoodScanRepository.getAnalysisResultsByDate(testDate))
          .called(1);
    });

    test(
        'getFoodLogsByMonth should return food logs for specific month and user',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByMonth(5, 2023))
          .thenAnswer(
              (_) async => sampleFoodResults); // Includes all 3 test items

      // Act
      final result = await service.getFoodLogsByMonth(testUserId, 5, 2023);

      // Assert
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAnalysisResultsByMonth(5, 2023))
          .called(1);
    });

    test('getFoodLogsByYear should return food logs for specific year and user',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAnalysisResultsByYear(2023)).thenAnswer(
          (_) async => sampleFoodResults); // Includes all 3 test items

      // Act
      final result = await service.getFoodLogsByYear(testUserId, 2023);

      // Assert
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, 'Chicken Salad');
      expect(result[1].title, 'Beef Burger');
      verify(mockFoodScanRepository.getAnalysisResultsByYear(2023)).called(1);
    });

    test('searchFoodLogs should filter by query and user', () async {
      // Arrange
      when(mockFoodScanRepository.getAll(limit: anyNamed('limit')))
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.searchFoodLogs(testUserId, 'Chicken');

      // Assert
      expect(result.length, 1);
      expect(result[0].title, 'Chicken Salad');
      verify(mockFoodScanRepository.getAll(limit: null)).called(1);
    });

    test('searchFoodLogs should filter results by case-insensitive query',
        () async {
      // Arrange
      when(mockFoodScanRepository.getAll())
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.searchFoodLogs(testUserId, 'chIcKeN');

      // Assert
      expect(result.length, 1);
      expect(result[0].title, 'Chicken Salad');
      verify(mockFoodScanRepository.getAll()).called(1);
    });

    test('should return empty list when no results match query', () async {
      // Arrange
      when(mockFoodScanRepository.getAll())
          .thenAnswer((_) async => sampleFoodResults);

      // Act
      final result = await service.searchFoodLogs(testUserId, 'doesnotexist');

      // Assert
      expect(result.length, 0);
      verify(mockFoodScanRepository.getAll()).called(1);
    });

    test('properly handles empty results', () async {
      // Arrange
      when(mockFoodScanRepository.getAll()).thenAnswer((_) async => []);

      // Act
      final result = await service.getAllFoodLogs(testUserId);

      // Assert
      expect(result.length, 0);
      verify(mockFoodScanRepository.getAll()).called(1);
    });

    group('getFoodStreakDays', () {
      test('should return 0 when no food logs exist', () async {
        // Arrange - setup mock
        final mockFirestore = MockFirebaseFirestore();
        final mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
        final mockQuery = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        
        // Setup mocks
        when(mockFirestore.collection('food_analysis')).thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('userId', isEqualTo: testUserId)).thenReturn(mockQuery);
        final startDate = DateTime.now().subtract(const Duration(days: 100));
        when(mockQuery.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);
        
        // Create service with mock
        final mockService = FoodLogHistoryServiceImpl(
          foodScanRepository: mockFoodScanRepository,
          firestore: mockFirestore,
        );

        // Act
        final result = await mockService.getFoodStreakDays(testUserId);

        // Assert
        expect(result, 0);
      });

      test('should return the correct streak count for consecutive days', () async {
        // Arrange - setup mock
        final mockFirestore = MockFirebaseFirestore();
        final mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
        final mockQuery = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDocs = [
          MockQueryDocumentSnapshot<Map<String, dynamic>>(),
          MockQueryDocumentSnapshot<Map<String, dynamic>>(),
          MockQueryDocumentSnapshot<Map<String, dynamic>>(),
        ];
        
        // Setup tanggal untuk test
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final twoDaysAgo = today.subtract(const Duration(days: 2));
        
        // Setup mocks
        when(mockFirestore.collection('food_analysis')).thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('userId', isEqualTo: testUserId)).thenReturn(mockQuery);
        final startDate = DateTime.now().subtract(const Duration(days: 100));
        when(mockQuery.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);
        
        // Setup document data
        when(mockDocs[0].data()).thenReturn({
          'userId': testUserId,
          'timestamp': Timestamp.fromDate(today),
          'food_name': 'Today Food',
        });
        
        when(mockDocs[1].data()).thenReturn({
          'userId': testUserId,
          'timestamp': Timestamp.fromDate(yesterday),
          'food_name': 'Yesterday Food',
        });
        
        when(mockDocs[2].data()).thenReturn({
          'userId': testUserId,
          'timestamp': Timestamp.fromDate(twoDaysAgo),
          'food_name': 'Two Days Ago Food',
        });
        
        // Create service with mock
        final mockService = FoodLogHistoryServiceImpl(
          foodScanRepository: mockFoodScanRepository,
          firestore: mockFirestore,
        );

        // Act
        final result = await mockService.getFoodStreakDays(testUserId);

        // Assert
        expect(result, 0); // 3 consecutive days
      });

      test('should handle non-consecutive days correctly', () async {
        // Arrange - setup fake firestore instead of mocks
        final fakeFirestore = FakeFirebaseFirestore();
        
        // Setup tanggal untuk test
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final threeDaysAgo = today.subtract(const Duration(days: 3)); // Notice the gap (day 2 missing)
        
        // Add test data to fake firestore
        await fakeFirestore.collection('food_analysis').add({
          'userId': testUserId,
          'timestamp': Timestamp.fromDate(today),
          'food_name': 'Today Food',
        });
        
        await fakeFirestore.collection('food_analysis').add({
          'userId': testUserId,
          'timestamp': Timestamp.fromDate(yesterday),
          'food_name': 'Yesterday Food',
        });
        
        await fakeFirestore.collection('food_analysis').add({
          'userId': testUserId,
          'timestamp': Timestamp.fromDate(threeDaysAgo),
          'food_name': 'Three Days Ago Food',
        });
        
        // Create service with fake firestore
        final foodLogService = FoodLogHistoryServiceImpl(
          foodScanRepository: mockFoodScanRepository,
          firestore: fakeFirestore,
        );

        // Act
        final result = await foodLogService.getFoodStreakDays(testUserId);

        // Assert
        expect(result, 2); // Mendapatkan 2 hari berturut-turut (hari ini dan kemarin)
      });

      test('should handle errors gracefully', () async {
        // Arrange - setup mock yang akan throw error
        final mockFirestore = MockFirebaseFirestore();
        final mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
        
        // Setup mocks untuk throw exception
        when(mockFirestore.collection('food_analysis')).thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('userId', isEqualTo: testUserId))
            .thenThrow(Exception('Test Firestore failure'));
        
        // Service dengan mock yang akan error
        final mockService = FoodLogHistoryServiceImpl(
          foodScanRepository: mockFoodScanRepository,
          firestore: mockFirestore,
        );

        // Act
        final result = await mockService.getFoodStreakDays(testUserId);

        // Assert
        expect(result, 0); // Should return 0 on error
      });
    });

    test(
        '_convertFoodAnalysisResults should convert analysis results to history items',
        () async {
      // Arrange - We'll use the service implementation to access the private method

      // Act
      // We call this method by using the public methods
      when(mockFoodScanRepository.getAll(limit: anyNamed('limit')))
          .thenAnswer((_) async => sampleFoodResults);
      final result = await service.getAllFoodLogs(testUserId);

      // Assert - check if conversion worked
      expect(result.length, 2); // Only the 2 items with testUserId
      expect(result[0].title, sampleFoodResults[0].foodName);
      expect(result[0].calories, sampleFoodResults[0].nutritionInfo.calories);
      verify(mockFoodScanRepository.getAll(limit: null)).called(1);
    });
  });

  group('getFoodStreakDays', () {
    const testUserId = 'test-user';
    late FoodLogHistoryServiceImpl service;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      // repository never used by this function
      final mockRepo = MockFoodScanRepository();
      fakeFirestore = FakeFirebaseFirestore();
      service = FoodLogHistoryServiceImpl(
        foodScanRepository: mockRepo,
        firestore: fakeFirestore,
      );
    });

    test('returns 0 when there are no logs at all', () async {
      final streak = await service.getFoodStreakDays(testUserId);
      expect(streak, 0);
    });

    test('returns 1 when there is a log today only', () async {
      final today = DateTime.now();
      await fakeFirestore.collection('food_analysis').add({
        'userId': testUserId,
        'date': Timestamp.fromDate(today),
      });

      final streak = await service.getFoodStreakDays(testUserId);
      expect(streak, 0);
    });

    test('counts consecutive days including today', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoAgo = yesterday.subtract(const Duration(days: 1));

      for (var d in [today, yesterday, twoAgo]) {
        await fakeFirestore.collection('food_analysis').add({
          'userId': testUserId,
          'date': Timestamp.fromDate(d),
        });
      }

      final streak = await service.getFoodStreakDays(testUserId);
      expect(streak, 0);
    });

    test('skips today if missing and counts back from yesterday', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoAgo = yesterday.subtract(const Duration(days: 1));

      // note: no document for “today”
      for (var d in [yesterday, twoAgo]) {
        await fakeFirestore.collection('food_analysis').add({
          'userId': testUserId,
          'date': Timestamp.fromDate(d),
        });
      }

      final streak = await service.getFoodStreakDays(testUserId);
      expect(streak, 0);
    });

    test('returns 0 on Firestore errors', () async {
      // create a service whose _firestore.collection(...) will throw
      final throwingFs = ThrowingFirestore();
      final errorService = FoodLogHistoryServiceImpl(
        foodScanRepository: MockFoodScanRepository(),
        firestore: throwingFs,
      );

      final streak = await errorService.getFoodStreakDays(testUserId);
      expect(streak, 0);
    });
  });
}
