import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository_impl.dart';

// Mock Firebase dependencies with explicit generic types
@GenerateMocks([], customMocks: [
  MockSpec<FirebaseFirestore>(
    as: #MockFirebaseFirestore,
  ),
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockCollectionReference,
  ),
  MockSpec<DocumentReference<Map<String, dynamic>>>(
    as: #MockDocumentReference,
  ),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(
    as: #MockDocumentSnapshot,
  ),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(
    as: #MockQuerySnapshot,
  ),
  MockSpec<Query<Map<String, dynamic>>>(
    as: #MockQuery,
  ),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
    as: #MockQueryDocumentSnapshot,
  )
])
import 'smart_exercise_log_repository_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockDocumentSnapshot mockDocSnapshot;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQuery mockQuery;

  // The actual repository implementation to test
  late SmartExerciseLogRepository repository;

  setUp(() {
    // Setup mocks
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQuery = MockQuery();

    // Initialize the repository with mock Firestore
    repository = SmartExerciseLogRepositoryImpl(firestore: mockFirestore);

    // Setup common mock behaviors
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocument);
  });

  group('SmartExerciseLogRepositoryImpl Constructor', () {
    test('should initialize with provided FirebaseFirestore instance', () {
      // Act
      final repository = SmartExerciseLogRepositoryImpl(firestore: mockFirestore);
      
      // Setup mock behavior untuk saveAnalysisResult
      when(mockDocument.set(any)).thenAnswer((_) => Future<void>.value());
      
      // Perform an operation to verify the correct instance is used
      repository.saveAnalysisResult(ExerciseAnalysisResult(
        exerciseType: 'Test',
        duration: '10 minutes',
        intensity: 'Low',
        estimatedCalories: 100,
        timestamp: DateTime.now(),
        originalInput: 'Test input'
      ));
      
      // Assert
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
    });
  });

  group('saveAnalysisResult', () {
    test('should save result and return its id', () async {
      // Arrange
      final result = ExerciseAnalysisResult(
        id: 'test-id-123',
        exerciseType: 'Running',
        duration: '30 menit',
        intensity: 'Sedang',
        estimatedCalories: 300,
        timestamp: DateTime.now(),
        originalInput: 'Lari 30 menit dengan intensitas sedang',
      );

      // Setup mock Firestore behavior
      when(mockDocument.set(any)).thenAnswer((_) => Future<void>.value());
      
      // Act
      final resultId = await repository.saveAnalysisResult(result);

      // Assert
      expect(resultId, 'test-id-123');
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.doc('test-id-123')).called(1);
      verify(mockDocument.set(any)).called(1);
    });

    test('should throw Exception when saving fails', () async {
      // Arrange
      final result = ExerciseAnalysisResult(
        exerciseType: 'Running',
        duration: '30 menit',
        intensity: 'Sedang',
        estimatedCalories: 300,
        timestamp: DateTime.now(),
        originalInput: 'Lari 30 menit',
      );

      // Setup mock to throw an error
      when(mockDocument.set(any))
          .thenThrow(FirebaseException(plugin: 'firestore'));

      // Act & Assert
      expect(() => repository.saveAnalysisResult(result),
          throwsA(isA<Exception>()));
    });
  });

  group('getAnalysisResultFromId', () {
    test('should return result when found', () async {
      // Arrange
      final mockData = {
        'exerciseType': 'HIIT Workout',
        'duration': '20 menit',
        'intensity': 'Tinggi',
        'estimatedCalories': 250,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'originalInput': 'HIIT 20 menit',
      };

      // Setup mock document behavior
      when(mockDocument.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(mockData);
      when(mockDocSnapshot.id).thenReturn('test-id-123');

      // Act
      final result = await repository.getAnalysisResultFromId('test-id-123');

      // Assert
      expect(result, isNotNull);
      expect(result?.id, 'test-id-123');
      expect(result?.exerciseType, 'HIIT Workout');
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.doc('test-id-123')).called(1);
      verify(mockDocument.get()).called(1);
    });

    test('should return null when not found', () async {
      // Arrange
      when(mockDocument.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);

      // Act
      final result =
          await repository.getAnalysisResultFromId('non-existent-id');

      // Assert
      expect(result, isNull);
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.doc('non-existent-id')).called(1);
    });

    test('should throw Exception when retrieval fails', () async {
      // Arrange
      when(mockDocument.get())
          .thenThrow(FirebaseException(plugin: 'firestore'));

      // Act & Assert
      expect(() => repository.getAnalysisResultFromId('error-id'),
          throwsA(isA<Exception>()));
    });
  });

  group('getAllAnalysisResults', () {
    test('should return empty list when no results saved', () async {
      // Arrange
      final List<MockQueryDocumentSnapshot> emptyDocs = [];

      // Setup mock query behavior
      when(mockCollection.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(emptyDocs);

      // Act
      final results = await repository.getAllAnalysisResults();

      // Assert
      expect(results, isEmpty);
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.orderBy('timestamp', descending: true)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('should return all saved results', () async {
      // Arrange
      final mockQueryDoc1 = MockQueryDocumentSnapshot();
      final mockQueryDoc2 = MockQueryDocumentSnapshot();

      final mockData1 = {
        'exerciseType': 'Running',
        'duration': '30 menit',
        'intensity': 'Sedang',
        'estimatedCalories': 300,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'originalInput': 'Lari 30 menit',
      };

      final mockData2 = {
        'exerciseType': 'Yoga',
        'duration': '45 menit',
        'intensity': 'Rendah',
        'estimatedCalories': 150,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'originalInput': 'Yoga 45 menit santai',
      };

      // Setup mock docs
      when(mockQueryDoc1.data()).thenReturn(mockData1);
      when(mockQueryDoc1.id).thenReturn('id-1');
      when(mockQueryDoc2.data()).thenReturn(mockData2);
      when(mockQueryDoc2.id).thenReturn('id-2');

      final List<MockQueryDocumentSnapshot> mockDocs = [
        mockQueryDoc1,
        mockQueryDoc2
      ];

      // Setup mock query behavior
      when(mockCollection.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final results = await repository.getAllAnalysisResults();

      // Assert
      expect(results.length, 2);
      expect(results[0].exerciseType, 'Running');
      expect(results[1].exerciseType, 'Yoga');
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.orderBy('timestamp', descending: true)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('should throw Exception when retrieval fails', () async {
      // Arrange
      when(mockCollection.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(FirebaseException(plugin: 'firestore'));

      // Act & Assert
      expect(
          () => repository.getAllAnalysisResults(), throwsA(isA<Exception>()));
    });
  });

  // Tests for time filtering methods
  group('getAnalysisResultsByDate', () {
    test('should return results for specific date', () async {
      // Arrange
      final testDate = DateTime(2024, 3, 15);
      final startOfDay = DateTime(2024, 3, 15);
      final endOfDay = DateTime(2024, 3, 15, 23, 59, 59, 999);
      
      final mockQueryDoc1 = MockQueryDocumentSnapshot();
      final mockQueryDoc2 = MockQueryDocumentSnapshot();

      final mockData1 = {
        'exerciseType': 'Running',
        'duration': '30 menit',
        'intensity': 'Sedang',
        'estimatedCalories': 300,
        'timestamp': DateTime(2024, 3, 15, 10, 30).millisecondsSinceEpoch,
        'originalInput': 'Lari 30 menit',
      };

      final mockData2 = {
        'exerciseType': 'Yoga',
        'duration': '45 menit',
        'intensity': 'Rendah',
        'estimatedCalories': 150,
        'timestamp': DateTime(2024, 3, 15, 16, 0).millisecondsSinceEpoch,
        'originalInput': 'Yoga 45 menit santai',
      };

      // Setup mock docs
      when(mockQueryDoc1.data()).thenReturn(mockData1);
      when(mockQueryDoc1.id).thenReturn('id-1');
      when(mockQueryDoc2.data()).thenReturn(mockData2);
      when(mockQueryDoc2.id).thenReturn('id-2');

      final List<MockQueryDocumentSnapshot> mockDocs = [
        mockQueryDoc1,
        mockQueryDoc2
      ];

      // Setup mock query behavior
      when(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final results = await repository.getAnalysisResultsByDate(testDate);

      // Assert
      expect(results.length, 2);
      expect(results[0].exerciseType, 'Running');
      expect(results[1].exerciseType, 'Yoga');
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.orderBy('timestamp', descending: true)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('should return empty list when no results on date', () async {
      // Arrange
      final testDate = DateTime(2024, 3, 15);
      final startOfDay = DateTime(2024, 3, 15);
      final endOfDay = DateTime(2024, 3, 15, 23, 59, 59, 999);
      
      final List<MockQueryDocumentSnapshot> emptyDocs = [];

      // Setup mock query behavior
      when(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(emptyDocs);

      // Act
      final results = await repository.getAnalysisResultsByDate(testDate);

      // Assert
      expect(results, isEmpty);
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.orderBy('timestamp', descending: true)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('should throw Exception when retrieval by date fails', () async {
      // Arrange
      final testDate = DateTime(2024, 3, 15);
      final startOfDay = DateTime(2024, 3, 15);
      final endOfDay = DateTime(2024, 3, 15, 23, 59, 59, 999);
      
      // Setup mock to throw an error
      when(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get())
          .thenThrow(FirebaseException(plugin: 'firestore'));

      // Act & Assert
      expect(() => repository.getAnalysisResultsByDate(testDate),
          throwsA(isA<Exception>()));
    });
  });

  group('getAnalysisResultsByMonth', () {
    test('should return results for specific month', () async {
      // Arrange
      final testMonth = 3; // March
      final testYear = 2024;
      final startOfMonth = DateTime(2024, 3, 1);
      final endOfMonth = DateTime(2024, 4, 1).subtract(const Duration(milliseconds: 1));
      
      final mockQueryDoc1 = MockQueryDocumentSnapshot();
      final mockQueryDoc2 = MockQueryDocumentSnapshot();

      final mockData1 = {
        'exerciseType': 'Running',
        'duration': '30 menit',
        'intensity': 'Sedang',
        'estimatedCalories': 300,
        'timestamp': DateTime(2024, 3, 15, 10, 30).millisecondsSinceEpoch,
        'originalInput': 'Lari 30 menit',
      };

      final mockData2 = {
        'exerciseType': 'Yoga',
        'duration': '45 menit',
        'intensity': 'Rendah',
        'estimatedCalories': 150,
        'timestamp': DateTime(2024, 3, 20, 16, 0).millisecondsSinceEpoch,
        'originalInput': 'Yoga 45 menit santai',
      };

      // Setup mock docs
      when(mockQueryDoc1.data()).thenReturn(mockData1);
      when(mockQueryDoc1.id).thenReturn('id-1');
      when(mockQueryDoc2.data()).thenReturn(mockData2);
      when(mockQueryDoc2.id).thenReturn('id-2');

      final List<MockQueryDocumentSnapshot> mockDocs = [
        mockQueryDoc1,
        mockQueryDoc2
      ];

      // Setup mock query behavior
      when(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfMonth.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfMonth.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final results = await repository.getAnalysisResultsByMonth(testMonth, testYear);

      // Assert
      expect(results.length, 2);
      expect(results[0].exerciseType, 'Running');
      expect(results[1].exerciseType, 'Yoga');
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfMonth.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfMonth.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.orderBy('timestamp', descending: true)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('should handle December correctly (edge case)', () async {
      // Arrange
      final testMonth = 12; // December
      final testYear = 2024;
      final startOfMonth = DateTime(2024, 12, 1);
      final endOfMonth = DateTime(2025, 1, 1).subtract(const Duration(milliseconds: 1));
      
      final List<MockQueryDocumentSnapshot> emptyDocs = [];

      // Setup mock query behavior
      when(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfMonth.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfMonth.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(emptyDocs);

      // Act
      final results = await repository.getAnalysisResultsByMonth(testMonth, testYear);

      // Assert
      expect(results, isEmpty);
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfMonth.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfMonth.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.orderBy('timestamp', descending: true)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('should handle invalid month by throwing Exception', () async {
      // Setup a mock repository with real validation
      final repository = SmartExerciseLogRepositoryImpl(firestore: mockFirestore);
      
      // Act & Assert - we're expecting the actual repository to throw
      expect(() => repository.getAnalysisResultsByMonth(13, 2024),
          throwsA(predicate((e) => e.toString().contains('Month must be between 1 and 12'))));
      expect(() => repository.getAnalysisResultsByMonth(0, 2024),
          throwsA(predicate((e) => e.toString().contains('Month must be between 1 and 12'))));
    });

    test('should throw Exception when retrieval by month fails', () async {
      // Arrange
      final testMonth = 3;
      final testYear = 2024;

      // Setup mock Firestore to throw error at the collection level
      when(mockFirestore.collection('exerciseAnalysis'))
          .thenThrow(FirebaseException(plugin: 'firestore'));

      // Act & Assert
      expect(() => repository.getAnalysisResultsByMonth(testMonth, testYear),
          throwsA(isA<Exception>()));
    });
  });

  group('getAnalysisResultsByYear', () {
    test('should return results for specific year', () async {
      // Arrange
      final testYear = 2024;
      final startOfYear = DateTime(2024, 1, 1);
      final endOfYear = DateTime(2025, 1, 1).subtract(const Duration(milliseconds: 1));
      
      final mockQueryDoc1 = MockQueryDocumentSnapshot();
      final mockQueryDoc2 = MockQueryDocumentSnapshot();
      final mockQueryDoc3 = MockQueryDocumentSnapshot();

      final mockData1 = {
        'exerciseType': 'Running',
        'duration': '30 menit',
        'intensity': 'Sedang',
        'estimatedCalories': 300,
        'timestamp': DateTime(2024, 3, 15).millisecondsSinceEpoch,
        'originalInput': 'Lari 30 menit',
      };

      final mockData2 = {
        'exerciseType': 'Yoga',
        'duration': '45 menit',
        'intensity': 'Rendah',
        'estimatedCalories': 150,
        'timestamp': DateTime(2024, 6, 20).millisecondsSinceEpoch,
        'originalInput': 'Yoga 45 menit santai',
      };
      
      final mockData3 = {
        'exerciseType': 'Swimming',
        'duration': '1 jam',
        'intensity': 'Tinggi',
        'estimatedCalories': 500,
        'timestamp': DateTime(2024, 9, 5).millisecondsSinceEpoch,
        'originalInput': 'Berenang 1 jam',
      };

      // Setup mock docs
      when(mockQueryDoc1.data()).thenReturn(mockData1);
      when(mockQueryDoc1.id).thenReturn('id-1');
      when(mockQueryDoc2.data()).thenReturn(mockData2);
      when(mockQueryDoc2.id).thenReturn('id-2');
      when(mockQueryDoc3.data()).thenReturn(mockData3);
      when(mockQueryDoc3.id).thenReturn('id-3');

      final List<MockQueryDocumentSnapshot> mockDocs = [
        mockQueryDoc1,
        mockQueryDoc2,
        mockQueryDoc3
      ];

      // Setup mock query behavior
      when(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfYear.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfYear.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final results = await repository.getAnalysisResultsByYear(testYear);

      // Assert
      expect(results.length, 3);
      expect(results[0].exerciseType, 'Running');
      expect(results[1].exerciseType, 'Yoga');
      expect(results[2].exerciseType, 'Swimming');
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfYear.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfYear.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.orderBy('timestamp', descending: true)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('should return empty list when no results in year', () async {
      // Arrange
      final testYear = 2023;
      final startOfYear = DateTime(2023, 1, 1);
      final endOfYear = DateTime(2024, 1, 1).subtract(const Duration(milliseconds: 1));
      
      final List<MockQueryDocumentSnapshot> emptyDocs = [];

      // Setup mock query behavior
      when(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfYear.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfYear.millisecondsSinceEpoch))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(emptyDocs);

      // Act
      final results = await repository.getAnalysisResultsByYear(testYear);

      // Assert
      expect(results, isEmpty);
      verify(mockFirestore.collection('exerciseAnalysis')).called(1);
      verify(mockCollection.where('timestamp', isGreaterThanOrEqualTo: startOfYear.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.where('timestamp', isLessThanOrEqualTo: endOfYear.millisecondsSinceEpoch)).called(1);
      verify(mockQuery.orderBy('timestamp', descending: true)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('should throw Exception when retrieval by year fails', () async {
      // Arrange
      final testYear = 2024;

      // Setup mock Firestore to throw error at the collection level
      when(mockFirestore.collection('exerciseAnalysis'))
          .thenThrow(FirebaseException(plugin: 'firestore'));

      // Act & Assert
      expect(() => repository.getAnalysisResultsByYear(testYear),
          throwsA(isA<Exception>()));
    });
  });
}