// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/sync_fitness_tracker/services/third_party_tracker_service.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockFieldValue extends Mock implements FieldValue {}
class MockWriteBatch extends Mock implements WriteBatch {}

// Create a class to override static method
class FakeFieldValue {
  static FieldValue serverTimestamp() => MockFieldValue();
}

void main() {
  late ThirdPartyTrackerService service;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockQuery mockQuery;
  late MockDocumentReference mockDocRef;
  late MockQuerySnapshot mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockQuery = MockQuery();
    mockDocRef = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();

    // Setup mock behavior
    when(() => mockFirestore.collection('third_party_tracker')).thenReturn(mockCollection);
    
    service = ThirdPartyTrackerService(firestore: mockFirestore);
  });

  group('Date formatting', () {
    test('formats date correctly as YYYY-MM-DD', () {
      final testDate1 = DateTime(2023, 1, 5);
      final testDate2 = DateTime(2025, 12, 31);

      expect(service.formatDateForTest(testDate1), '2023-01-05');
      expect(service.formatDateForTest(testDate2), '2025-12-31');
    });

    test('handles single-digit months and days with leading zero', () {
      final testDate = DateTime(2023, 5, 9);
      expect(service.formatDateForTest(testDate), '2023-05-09');
    });

    test('formats future dates correctly', () {
      final futureDate = DateTime(2025, 8, 15);
      expect(service.formatDateForTest(futureDate), '2025-08-15');
    });
  });

  group('Error handling', () {
    test('logs error message with operation and error details', () {
      // We can't directly test debug prints, but we can verify the method runs without error
      expect(() => service.handleErrorForTest('test operation', 'test error'), returnsNormally);
    });

    test('handles different error types gracefully', () {
      expect(
          () => service.handleErrorForTest(
              'test operation', Exception('test exception')),
          returnsNormally);

      expect(
          () => service.handleErrorForTest(
              'test operation', ArgumentError('invalid argument')),
          returnsNormally);
    });
  });
  group('saveTrackerData', () {
    test('does nothing when userId is empty', () async {
      // Call with empty user ID
      await service.saveTrackerData(
        userId: '',
        steps: 1000,
        caloriesBurned: 200.0,
      );

      // Verify no Firestore interaction occurred
      verifyNever(() => mockFirestore.collection(any()));
    });

    test('updates existing document when found for user and date', () async {
      // Setup mocks for document exists scenario
      final mockDoc = MockQueryDocumentSnapshot();
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> mockDocs = [mockDoc];
      
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.where('date', isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocs);
      when(() => mockDoc.id).thenReturn('doc123');
      when(() => mockCollection.doc('doc123')).thenReturn(mockDocRef);
      when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

      // Execute
      await service.saveTrackerData(
        userId: 'user123',
        steps: 1000,
        caloriesBurned: 200.0,
      );

      // Verify document was updated - using any() for the map argument since it contains FieldValue
      verify(() => mockDocRef.update(any())).called(1);
    });

    test('creates new document when none found for user and date', () async {
      // Setup mocks for document doesn't exist scenario
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> emptyDocs = [];
      
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.where('date', isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(emptyDocs);
      when(() => mockCollection.add(any())).thenAnswer((_) async => mockDocRef);

      // Execute
      await service.saveTrackerData(
        userId: 'user123',
        steps: 1000,
        caloriesBurned: 200.0,
      );

      // Verify new document was created - using any() for the map argument
      verify(() => mockCollection.add(any())).called(1);
    });

    test('handles exceptions gracefully', () async {
      // Setup mocks to throw exception
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.where('date', isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Test error'));

      // Execute - should not throw
      await expectLater(
        service.saveTrackerData(
          userId: 'user123',
          steps: 1000,
          caloriesBurned: 200.0,
        ),
        completes
      );
    });
  });

  group('resetTrackerData', () {
    test('does nothing when userId is empty', () async {
      // Call with empty user ID
      await service.resetTrackerData('');

      // Verify no Firestore interaction occurred
      verifyNever(() => mockFirestore.collection(any()));
    });

    test('resets all user documents with batch', () async {
      // Mock documents to reset
      final mockDoc1 = MockQueryDocumentSnapshot();
      final mockDoc2 = MockQueryDocumentSnapshot();
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> mockDocs = [mockDoc1, mockDoc2];
      final mockBatch = MockWriteBatch();

      // Setup mocks
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocs);
      when(() => mockFirestore.batch()).thenReturn(mockBatch);
      when(() => mockBatch.commit()).thenAnswer((_) async => []);

      // Setup document references
      final mockDocRef1 = MockDocumentReference();
      final mockDocRef2 = MockDocumentReference();
      when(() => mockDoc1.reference).thenReturn(mockDocRef1);
      when(() => mockDoc2.reference).thenReturn(mockDocRef2);
      when(() => mockBatch.update(mockDocRef1, any())).thenReturn(null);
      when(() => mockBatch.update(mockDocRef2, any())).thenReturn(null);

      // Execute
      await service.resetTrackerData('user123');

      // Verify batch operations
      verify(() => mockFirestore.batch()).called(1);
      verify(() => mockBatch.update(mockDocRef1, any())).called(1);
      verify(() => mockBatch.update(mockDocRef2, any())).called(1);
      verify(() => mockBatch.commit()).called(1);
    });

    test('handles exceptions gracefully', () async {
      // Setup mocks to throw exception
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Test error'));

      // Execute - should not throw
      await expectLater(service.resetTrackerData('user123'), completes);
    });
  });

  group('getTrackerDataForDate', () {
    test('returns default values when userId is empty', () async {
      // Call with empty user ID
      final result = await service.getTrackerDataForDate('', DateTime.now());

      // Verify default values
      expect(result, {'steps': 0, 'caloriesBurned': 0.0});
      verifyNever(() => mockFirestore.collection(any()));
    });

    test('returns data from Firestore when document exists', () async {
      // Setup mock data
      final mockDoc = MockQueryDocumentSnapshot();
      final mockData = {'steps': 8500, 'caloriesBurned': 450.5};
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> mockDocs = [mockDoc];

      // Setup mocks
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.where('date', isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocs);
      when(() => mockDoc.data()).thenReturn(mockData);

      // Execute
      final result = await service.getTrackerDataForDate('user123', DateTime.now());

      // Verify result
      expect(result, {'steps': 8500, 'caloriesBurned': 450.5});
    });

    test('converts caloriesBurned to double when needed', () async {
      // Setup mock data with integer calories
      final mockDoc = MockQueryDocumentSnapshot();
      final mockData = {'steps': 8500, 'caloriesBurned': 450};
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> mockDocs = [mockDoc];

      // Setup mocks
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.where('date', isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocs);
      when(() => mockDoc.data()).thenReturn(mockData);

      // Execute
      final result = await service.getTrackerDataForDate('user123', DateTime.now());

      // Verify caloriesBurned was converted to double
      expect(result['caloriesBurned'], 450.0);
      expect(result['caloriesBurned'].runtimeType, double);
    });

    test('returns default values when document not found', () async {
      // Setup mocks for document not found scenario
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> emptyDocs = [];
      
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.where('date', isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(emptyDocs);

      // Execute
      final result = await service.getTrackerDataForDate('user123', DateTime.now());

      // Verify default values are returned
      expect(result, {'steps': 0, 'caloriesBurned': 0.0});
    });

    test('handles null values in document data', () async {
      // Setup mock with null or missing values
      final mockDoc = MockQueryDocumentSnapshot();
      final mockData = {'steps': null, 'caloriesBurned': null};
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> mockDocs = [mockDoc];
      
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.where('date', isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocs);
      when(() => mockDoc.data()).thenReturn(mockData);

      // Execute
      final result = await service.getTrackerDataForDate('user123', DateTime.now());

      // Verify default values are used for null fields
      expect(result, {'steps': 0, 'caloriesBurned': 0.0});
    });

    test('handles exceptions gracefully', () async {
      // Setup mocks to throw exception
      when(() => mockCollection.where('userId', isEqualTo: 'user123')).thenReturn(mockQuery);
      when(() => mockQuery.where('date', isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Test error'));

      // Execute
      final result = await service.getTrackerDataForDate('user123', DateTime.now());

      // Verify default values are returned on exception
      expect(result, {'steps': 0, 'caloriesBurned': 0.0});
    });
  });
}
