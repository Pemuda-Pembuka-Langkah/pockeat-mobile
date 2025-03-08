import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/weight_training_log/domain/models/exercise.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/exercise_repository_impl.dart';

// Generate mocks for Firebase
@GenerateMocks([
  FirebaseFirestore, 
  CollectionReference, 
  DocumentReference,
  Query,
  QuerySnapshot,
  DocumentSnapshot,
  QueryDocumentSnapshot,
])
// This import should be after the annotation
import 'exercise_repository_impl_test.mocks.dart';

void main() {
  late ExerciseRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late List<MockQueryDocumentSnapshot<Map<String, dynamic>>> mockDocs;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  
  final testExercise = Exercise(
    id: 'test-id',
    name: 'Bench Press',
    bodyPart: 'Chest',
    metValue: 3.5,
    sets: [
      ExerciseSet(weight: 20.0, reps: 12, duration: 60.0),
    ],
  );

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockDocs = [];
    
    // Setup behavior for collections
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    
    repository = ExerciseRepositoryImpl(firestore: mockFirestore);
  });

  group('saveExercise', () {
    test('should save exercise to Firestore successfully', () async {
      // Setup
      when(mockCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.set(any)).thenAnswer((_) => Future.value());
      
      // Execute
      final result = await repository.saveExercise(testExercise);
      
      // Verify
      verify(mockFirestore.collection('exercises')).called(1);
      verify(mockCollection.doc(testExercise.id)).called(1);
      verify(mockDocRef.set(testExercise.toJson())).called(1);
      expect(result, testExercise.id);
    });

    test('should throw exception when saving fails', () async {
      // Setup
      when(mockCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.set(any)).thenThrow(Exception('Firestore error'));
      
      // Execute & Verify
      expect(
        () => repository.saveExercise(testExercise),
        throwsException,
      );
    });
  });

  group('getExerciseById', () {
    test('should get exercise by id when it exists', () async {
      // Setup
      final exerciseData = testExercise.toJson();
      
      when(mockCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(exerciseData);
      
      // Execute
      final result = await repository.getExerciseById('test-id');
      
      // Verify
      verify(mockFirestore.collection('exercises')).called(1);
      verify(mockCollection.doc('test-id')).called(1);
      verify(mockDocRef.get()).called(1);
      expect(result?.id, testExercise.id);
      expect(result?.name, testExercise.name);
      expect(result?.bodyPart, testExercise.bodyPart);
    });

    test('should return null when document does not exist', () async {
      // Setup
      when(mockCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);
      
      // Execute
      final result = await repository.getExerciseById('test-id');
      
      // Verify
      expect(result, isNull);
    });

    test('should throw exception when retrieval fails', () async {
      // Setup
      when(mockCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenThrow(Exception('Firestore error'));
      
      // Execute & Verify
      expect(
        () => repository.getExerciseById('test-id'),
        throwsException,
      );
    });
  });

  group('getAllExercises', () {
    test('should return list of exercises', () async {
      // Setup
      final mockDocSnap = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocSnap.data()).thenReturn(testExercise.toJson());
      mockDocs = [mockDocSnap];
      
      when(mockCollection.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      
      // Execute
      final result = await repository.getAllExercises();
      
      // Verify
      verify(mockFirestore.collection('exercises')).called(1);
      verify(mockCollection.orderBy('name')).called(1);
      verify(mockQuery.get()).called(1);
      expect(result.length, 1);
      expect(result.first.id, testExercise.id);
    });

    test('should return empty list when no exercises exist', () async {
      // Setup
      mockDocs = [];
      
      when(mockCollection.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      
      // Execute
      final result = await repository.getAllExercises();
      
      // Verify
      expect(result, isEmpty);
    });

    test('should throw exception when retrieval fails', () async {
      // Setup
      when(mockCollection.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Firestore error'));
      
      // Execute & Verify
      expect(
        () => repository.getAllExercises(),
        throwsException,
      );
    });
  });

  group('getExercisesByBodyPart', () {
    test('should return exercises filtered by body part', () async {
      // Setup
      final mockDocSnap = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocSnap.data()).thenReturn(testExercise.toJson());
      mockDocs = [mockDocSnap];
      
      when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo'))).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      
      // Execute
      final result = await repository.getExercisesByBodyPart('Chest');
      
      // Verify
      verify(mockFirestore.collection('exercises')).called(1);
      verify(mockCollection.where('bodyPart', isEqualTo: 'Chest')).called(1);
      expect(result.length, 1);
      expect(result.first.bodyPart, 'Chest');
    });

    test('should throw exception when retrieval fails', () async {
      // Setup
      when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo'))).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Firestore error'));
      
      // Execute & Verify
      expect(
        () => repository.getExercisesByBodyPart('Chest'),
        throwsException,
      );
    });
  });

  group('deleteExercise', () {
    test('should delete exercise successfully', () async {
      // Setup
      when(mockCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenAnswer((_) => Future.value());
      
      // Execute
      final result = await repository.deleteExercise('test-id');
      
      // Verify
      verify(mockFirestore.collection('exercises')).called(1);
      verify(mockCollection.doc('test-id')).called(1);
      verify(mockDocRef.delete()).called(1);
      expect(result, true);
    });

    test('should throw exception when deletion fails', () async {
      // Setup
      when(mockCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenThrow(Exception('Firestore error'));
      
      // Execute & Verify
      expect(
        () => repository.deleteExercise('test-id'),
        throwsException,
      );
    });
  });

  group('filterByDate', () {
    final testDate = DateTime(2025, 3, 8);
    final dateString = '2025-03-08';
    
    test('should return exercises for specific date', () async {
      // Setup
      final mockDocSnap = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocSnap.data()).thenReturn({
        ...testExercise.toJson(),
        'dateCreated': dateString
      });
      mockDocs = [mockDocSnap];
      
      when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo'))).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      
      // Execute
      final result = await repository.filterByDate(testDate);
      
      // Verify
      verify(mockFirestore.collection('exercises')).called(1);
      verify(mockCollection.where('dateCreated', isEqualTo: dateString)).called(1);
      expect(result.length, 1);
    });

    test('should throw exception when filtering by date fails', () async {
      // Setup
      when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo'))).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Firestore error'));
      
      // Execute & Verify
      expect(
        () => repository.filterByDate(DateTime(2025, 3, 8)),
        throwsException,
      );
    });
  });

  group('filterByMonth', () {
    test('should return exercises for specific month and year', () async {
      // Setup
      final testMonth = 3;
      final testYear = 2025;
      
      final mockDocSnap = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocSnap.data()).thenReturn({
        ...testExercise.toJson(),
        'dateCreated': '2025-03-08'
      });
      mockDocs = [mockDocSnap];
      
      when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      
      // Execute
      final result = await repository.filterByMonth(testMonth, testYear);
      
      // Verify
      verify(mockFirestore.collection('exercises')).called(1);
      expect(result.length, 1);
    });

    test('should throw ArgumentError for invalid month', () async {
      // Execute & Verify
      expect(
        () => repository.filterByMonth(13, 2025),
        throwsArgumentError,
      );
    });

    test('should throw exception when filtering by month fails', () async {
      // Setup
      when(mockCollection.get()).thenThrow(Exception('Firestore error'));
      
      // Execute & Verify
      expect(
        () => repository.filterByMonth(3, 2025),
        throwsException,
      );
    });
  });

  group('getExercisesWithLimit', () {
    test('should return limited number of exercises', () async {
      // Setup
      final mockDocSnap = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocSnap.data()).thenReturn(testExercise.toJson());
      mockDocs = [mockDocSnap];
      
      when(mockCollection.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      
      // Execute
      final result = await repository.getExercisesWithLimit(10);
      
      // Verify
      verify(mockFirestore.collection('exercises')).called(1);
      verify(mockCollection.orderBy('name')).called(1);
      verify(mockQuery.limit(10)).called(1);
      expect(result.length, 1);
    });

    test('should throw exception when getting exercises with limit fails', () async {
      // Setup
      when(mockCollection.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Firestore error'));
      
      // Execute & Verify
      expect(
        () => repository.getExercisesWithLimit(10),
        throwsException,
      );
    });
  });

  group('getExerciseCategories', () {
    test('should return list of exercise categories', () {
      // Execute
      final result = repository.getExerciseCategories();
      
      // Verify
      expect(result, isA<List<String>>());
      expect(result, contains('Upper Body'));
      expect(result, contains('Lower Body'));
      expect(result, contains('Core'));
      expect(result, contains('Full Body'));
      expect(result.length, 4);
    });
  });

  group('getExercisesByCategoryName', () {
    test('should return exercises for a valid category', () {
      // Execute
      final result = repository.getExercisesByCategoryName('Upper Body');
      
      // Verify
      expect(result, isA<Map<String, double>>());
      expect(result.containsKey('Bench Press'), isTrue);
      expect(result['Bench Press'], 5.0);
    });

    test('should return empty map for invalid category', () {
      // Execute
      final result = repository.getExercisesByCategoryName('Invalid Category');
      
      // Verify
      expect(result, isEmpty);
    });
  });

  group('getExerciseMETValue', () {
    test('should return MET value when category and exercise name are provided', () {
      // Execute
      final result = repository.getExerciseMETValue('Bench Press', 'Upper Body');
      
      // Verify
      expect(result, 5.0);
    });

    test('should return MET value when only exercise name is provided', () {
      // Execute
      final result = repository.getExerciseMETValue('Bench Press');
      
      // Verify
      expect(result, 5.0);
    });

    test('should return default MET value when exercise not found in specified category', () {
      // Execute
      final result = repository.getExerciseMETValue('Bench Press', 'Lower Body');
      
      // Verify
      expect(result, 3.0);
    });

    test('should return default MET value when exercise not found in any category', () {
      // Execute
      final result = repository.getExerciseMETValue('Unknown Exercise');
      
      // Verify
      expect(result, 3.0);
    });
  });
}