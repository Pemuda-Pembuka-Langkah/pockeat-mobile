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
}
