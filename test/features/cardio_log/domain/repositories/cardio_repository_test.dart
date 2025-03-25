import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/cardio_log/domain/models/models.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository_impl.dart';

import 'cardio_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  Query
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late CardioRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();

    when(mockFirestore.collection('cardioActivities'))
        .thenReturn(mockCollection);

    repository = CardioRepositoryImpl(firestore: mockFirestore);
  });

  group('CardioRepository Tests', () {
    test('should retrieve activities for a specific user', () async {
      // Setup mock query and response
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockUserQuery = MockQuery<Map<String, dynamic>>();
      final mockQueryWithOrder = MockQuery<Map<String, dynamic>>();
      final mockDocs = [
        _createMockQueryDocSnap('running', DateTime(2023, 3, 15)),
      ];

      // Set up all mocks before any actions are performed
      when(mockCollection.where('userId', isEqualTo: 'test-user-id'))
          .thenReturn(mockUserQuery);
      when(mockUserQuery.orderBy('date', descending: true))
          .thenReturn(mockQueryWithOrder);
      when(mockQueryWithOrder.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Call method under test
      final results = await repository.getActivitiesByUser('test-user-id');

      // Verify
      expect(results.length, 1);
      expect(results[0].userId, 'test-user-id');
    });

    group('saveCardioActivity Tests', () {
      test('should save running activity successfully', () async {
        // Setup mock document
        const String activityId = 'ab3fe3eb-4fc1-405f-9dbb-3af8e1e4c2ef';
        when(mockCollection.doc(activityId)).thenReturn(mockDocument);
        when(mockDocument.set(any))
            .thenAnswer((_) async => Future<void>.value());

        // Create test running activity
        final activity = RunningActivity(
          userId: "test-user-id",
          id: activityId,
          date: DateTime(2023, 3, 15),
          startTime: DateTime(2023, 3, 15, 9, 0),
          endTime: DateTime(2023, 3, 15, 9, 30),
          distanceKm: 5.0,
          caloriesBurned: 300,
        );

        // Call method under test
        final result = await repository.saveCardioActivity(activity);

        // Verify interaction with Firestore
        verify(mockCollection.doc(activityId)).called(1);
        verify(mockDocument.set(any)).called(1);
        expect(result, activityId);
      });

      test('should save cycling activity successfully', () async {
        // Setup mock document
        const String activityId = 'cd3fe3eb-4fc1-405f-9dbb-3af8e1e4c2ee';
        when(mockCollection.doc(activityId)).thenReturn(mockDocument);
        when(mockDocument.set(any))
            .thenAnswer((_) async => Future<void>.value());

        // Create test cycling activity
        final activity = CyclingActivity(
          userId: "test-user-id",
          id: activityId,
          date: DateTime(2023, 3, 15),
          startTime: DateTime(2023, 3, 15, 10, 0),
          endTime: DateTime(2023, 3, 15, 11, 0),
          distanceKm: 20.0,
          cyclingType: CyclingType.mountain,
          caloriesBurned: 500,
        );

        // Call method under test
        final result = await repository.saveCardioActivity(activity);

        // Verify interaction with Firestore
        verify(mockCollection.doc(activityId)).called(1);
        verify(mockDocument.set(any)).called(1);
        expect(result, activityId);
      });

      test('should save swimming activity successfully', () async {
        // Setup mock document
        const String activityId = 'ef3fe3eb-4fc1-405f-9dbb-3af8e1e4c2ed';
        when(mockCollection.doc(activityId)).thenReturn(mockDocument);
        when(mockDocument.set(any))
            .thenAnswer((_) async => Future<void>.value());

        // Create test swimming activity
        final activity = SwimmingActivity(
          userId: "test-user-id",
          id: activityId,
          date: DateTime(2023, 3, 15),
          startTime: DateTime(2023, 3, 15, 14, 0),
          endTime: DateTime(2023, 3, 15, 14, 45),
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          caloriesBurned: 400,
        );

        // Call method under test
        final result = await repository.saveCardioActivity(activity);

        // Verify interaction with Firestore
        verify(mockCollection.doc(activityId)).called(1);
        verify(mockDocument.set(any)).called(1);
        expect(result, activityId);
      });

      test('should throw exception when save fails', () async {
        // Setup mock to throw exception
        const String activityId = 'ff3fe3eb-4fc1-405f-9dbb-3af8e1e4c2ec';
        when(mockCollection.doc(activityId)).thenReturn(mockDocument);
        when(mockDocument.set(any)).thenThrow(Exception('Test error'));

        // Create test activity
        final activity = RunningActivity(
          userId: "test-user-id",
          id: activityId,
          date: DateTime(2023, 3, 15),
          startTime: DateTime(2023, 3, 15, 9, 0),
          endTime: DateTime(2023, 3, 15, 9, 30),
          distanceKm: 5.0,
          caloriesBurned: 300,
        );

        // Verify exception is thrown
        expect(() => repository.saveCardioActivity(activity), throwsException);
      });
    });

    group('getCardioActivityById Tests', () {
      test('should retrieve running activity by ID successfully', () async {
        // Setup mock document and snapshot
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        final testDate = DateTime(2023, 3, 15);
        final testStartTime = DateTime(2023, 3, 15, 9, 0);
        final testEndTime = DateTime(2023, 3, 15, 9, 30);

        when(mockCollection.doc('test-id')).thenReturn(mockDocument);
        when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.data()).thenReturn({
          'id': 'test-id',
          'type': 'running',
          'date': testDate.millisecondsSinceEpoch,
          'startTime': testStartTime.millisecondsSinceEpoch,
          'endTime': testEndTime.millisecondsSinceEpoch,
          'distanceKm': 5.0,
          'caloriesBurned': 300.0,
        });

        // Call method under test
        final result = await repository.getCardioActivityById('test-id');

        // Verify interaction and result
        verify(mockCollection.doc('test-id')).called(1);
        verify(mockDocument.get()).called(1);

        expect(result, isA<RunningActivity>());
        expect(result?.type, CardioType.running);
        expect(result?.caloriesBurned, 300.0);
      });

      test('should return null when document does not exist', () async {
        // Setup mock document and snapshot
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockCollection.doc('non-existent-id')).thenReturn(mockDocument);
        when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(false);

        // Call method under test
        final result =
            await repository.getCardioActivityById('non-existent-id');

        // Verify interaction and result
        verify(mockCollection.doc('non-existent-id')).called(1);
        verify(mockDocument.get()).called(1);
        expect(result, isNull);
      });

      test('should throw exception when get fails', () async {
        // Setup mock to throw exception
        when(mockCollection.doc('test-id')).thenReturn(mockDocument);
        when(mockDocument.get()).thenThrow(Exception('Test error'));

        // Verify exception is thrown
        expect(
            () => repository.getCardioActivityById('test-id'), throwsException);
      });
    });

    group('getAllCardioActivities Tests', () {
      test('should retrieve all cardio activities successfully', () async {
        // Setup mock query and snapshot
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDocs = [
          _createMockQueryDocSnap('running', DateTime(2023, 3, 15)),
          _createMockQueryDocSnap('cycling', DateTime(2023, 3, 16)),
          _createMockQueryDocSnap('swimming', DateTime(2023, 3, 17)),
        ];

        when(mockCollection.orderBy('date', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Call method under test
        final results = await repository.getAllCardioActivities();

        // Verify interaction and results
        verify(mockCollection.orderBy('date', descending: true)).called(1);
        verify(mockQuery.get()).called(1);

        expect(results.length, 3);
        expect(results[0].type, CardioType.running);
        expect(results[1].type, CardioType.cycling);
        expect(results[2].type, CardioType.swimming);
      });

      test('should return empty list when no activities exist', () async {
        // Setup mock query and snapshot
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

        when(mockCollection.orderBy('date', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // Call method under test
        final results = await repository.getAllCardioActivities();

        // Verify interaction and results
        verify(mockCollection.orderBy('date', descending: true)).called(1);
        verify(mockQuery.get()).called(1);
        expect(results.isEmpty, true);
      });

      test('should throw exception when query fails', () async {
        // Setup mock to throw exception
        when(mockCollection.orderBy('date', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenThrow(Exception('Test error'));

        // Verify exception is thrown
        expect(() => repository.getAllCardioActivities(), throwsException);
      });
    });

    group('getCardioActivitiesByType Tests', () {
      test('should retrieve cardio activities by type successfully', () async {
        // Setup mock query and snapshot
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDocs = [
          _createMockQueryDocSnap('running', DateTime(2023, 3, 15)),
          _createMockQueryDocSnap('running', DateTime(2023, 3, 16)),
        ];

        when(mockCollection.where('type', isEqualTo: 'running'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('date', descending: true)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Call method under test
        final results =
            await repository.getCardioActivitiesByType(CardioType.running);

        // Verify interaction and results
        verify(mockCollection.where('type', isEqualTo: 'running')).called(1);
        verify(mockQuery.orderBy('date', descending: true)).called(1);
        verify(mockQuery.get()).called(1);

        expect(results.length, 2);
        expect(results[0].type, CardioType.running);
        expect(results[1].type, CardioType.running);
      });

      test('should return empty list when no activities of type exist',
          () async {
        // Setup mock query and snapshot
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

        when(mockCollection.where('type', isEqualTo: 'cycling'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('date', descending: true)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // Call method under test
        final results =
            await repository.getCardioActivitiesByType(CardioType.cycling);

        // Verify interaction and results
        verify(mockCollection.where('type', isEqualTo: 'cycling')).called(1);
        verify(mockQuery.orderBy('date', descending: true)).called(1);
        verify(mockQuery.get()).called(1);
        expect(results.isEmpty, true);
      });

      test('should throw exception when query by type fails', () async {
        // Setup mock to throw exception
        when(mockCollection.where('type', isEqualTo: 'swimming'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('date', descending: true)).thenReturn(mockQuery);
        when(mockQuery.get()).thenThrow(Exception('Test error'));

        // Verify exception is thrown
        expect(() => repository.getCardioActivitiesByType(CardioType.swimming),
            throwsException);
      });
    });

    group('deleteCardioActivity Tests', () {
      test('should delete cardio activity successfully', () async {
        // Setup mock document
        when(mockCollection.doc('test-id')).thenReturn(mockDocument);
        when(mockDocument.delete()).thenAnswer((_) async {});

        // Call method under test
        final result = await repository.deleteCardioActivity('test-id');

        // Verify interaction and result
        verify(mockCollection.doc('test-id')).called(1);
        verify(mockDocument.delete()).called(1);
        expect(result, true);
      });

      test('should throw exception when delete fails', () async {
        // Setup mock to throw exception
        when(mockCollection.doc('test-id')).thenReturn(mockDocument);
        when(mockDocument.delete()).thenThrow(Exception('Test error'));

        // Verify exception is thrown
        expect(
            () => repository.deleteCardioActivity('test-id'), throwsException);
      });
    });

    // Tests for the new methods
    group('filterByDate Tests', () {
      test('should retrieve activities for a specific date', () async {
        // Setup test date
        final testDate = DateTime(2023, 3, 15);
        final startOfDayMs =
            DateTime(2023, 3, 15, 0, 0, 0).millisecondsSinceEpoch;
        final endOfDayMs =
            DateTime(2023, 3, 15, 23, 59, 59, 999).millisecondsSinceEpoch;

        // Setup mock queries
        final mockQueryForDate1 = MockQuery<Map<String, dynamic>>();
        final mockQueryForDate2 = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDocs = [
          _createMockQueryDocSnap('running', testDate),
          _createMockQueryDocSnap('cycling', testDate),
        ];

        when(mockCollection.where('date', isGreaterThanOrEqualTo: startOfDayMs))
            .thenReturn(mockQueryForDate1);
        when(mockQueryForDate1.where('date', isLessThanOrEqualTo: endOfDayMs))
            .thenReturn(mockQueryForDate2);
        when(mockQueryForDate2.orderBy('date', descending: true))
            .thenReturn(mockQueryForDate2);
        when(mockQueryForDate2.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Call method under test
        final results = await repository.filterByDate(testDate);

        // Verify interaction and results
        verify(mockCollection.where('date',
                isGreaterThanOrEqualTo: startOfDayMs))
            .called(1);
        verify(mockQueryForDate1.where('date', isLessThanOrEqualTo: endOfDayMs))
            .called(1);
        verify(mockQueryForDate2.orderBy('date', descending: true)).called(1);
        verify(mockQueryForDate2.get()).called(1);

        expect(results.length, 2);
        expect(results[0].type, CardioType.running);
        expect(results[1].type, CardioType.cycling);
      });

      test('should return empty list when no activities on date', () async {
        // Setup test date
        final testDate = DateTime(2023, 3, 15);
        final startOfDayMs =
            DateTime(2023, 3, 15, 0, 0, 0).millisecondsSinceEpoch;
        final endOfDayMs =
            DateTime(2023, 3, 15, 23, 59, 59, 999).millisecondsSinceEpoch;

        // Setup mock queries
        final mockQueryForDate1 = MockQuery<Map<String, dynamic>>();
        final mockQueryForDate2 = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

        when(mockCollection.where('date', isGreaterThanOrEqualTo: startOfDayMs))
            .thenReturn(mockQueryForDate1);
        when(mockQueryForDate1.where('date', isLessThanOrEqualTo: endOfDayMs))
            .thenReturn(mockQueryForDate2);
        when(mockQueryForDate2.orderBy('date', descending: true))
            .thenReturn(mockQueryForDate2);
        when(mockQueryForDate2.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // Call method under test
        final results = await repository.filterByDate(testDate);

        // Verify interaction and results
        verify(mockQueryForDate2.get()).called(1);
        expect(results.isEmpty, true);
      });

      test('should throw exception when query by date fails', () async {
        // Setup test date
        final testDate = DateTime(2023, 3, 15);
        final startOfDayMs =
            DateTime(2023, 3, 15, 0, 0, 0).millisecondsSinceEpoch;
        final endOfDayMs =
            DateTime(2023, 3, 15, 23, 59, 59, 999).millisecondsSinceEpoch;

        // Setup mock queries
        final mockQueryForDate1 = MockQuery<Map<String, dynamic>>();
        final mockQueryForDate2 = MockQuery<Map<String, dynamic>>();

        when(mockCollection.where('date', isGreaterThanOrEqualTo: startOfDayMs))
            .thenReturn(mockQueryForDate1);
        when(mockQueryForDate1.where('date', isLessThanOrEqualTo: endOfDayMs))
            .thenReturn(mockQueryForDate2);
        when(mockQueryForDate2.orderBy('date', descending: true))
            .thenReturn(mockQueryForDate2);
        when(mockQueryForDate2.get()).thenThrow(Exception('Test error'));

        // Verify exception is thrown
        expect(() => repository.filterByDate(testDate), throwsException);
      });
    });

    group('filterByMonth Tests', () {
      test('should retrieve activities for a specific month', () async {
        // Setup test month and year
        final month = 3; // March
        final year = 2023;
        final startOfMonthMs = DateTime(2023, 3, 1).millisecondsSinceEpoch;
        final endOfMonthMs =
            DateTime(2023, 3, 31, 23, 59, 59, 999).millisecondsSinceEpoch;

        // Setup mock queries
        final mockQueryForMonth1 = MockQuery<Map<String, dynamic>>();
        final mockQueryForMonth2 = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDocs = [
          _createMockQueryDocSnap('running', DateTime(2023, 3, 15)),
          _createMockQueryDocSnap('cycling', DateTime(2023, 3, 20)),
          _createMockQueryDocSnap('swimming', DateTime(2023, 3, 25)),
        ];

        when(mockCollection.where('date',
                isGreaterThanOrEqualTo: startOfMonthMs))
            .thenReturn(mockQueryForMonth1);
        when(mockQueryForMonth1.where('date',
                isLessThanOrEqualTo: endOfMonthMs))
            .thenReturn(mockQueryForMonth2);
        when(mockQueryForMonth2.orderBy('date', descending: true))
            .thenReturn(mockQueryForMonth2);
        when(mockQueryForMonth2.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Call method under test
        final results = await repository.filterByMonth(month, year);

        // Verify interaction and results
        verify(mockCollection.where('date',
                isGreaterThanOrEqualTo: startOfMonthMs))
            .called(1);
        verify(mockQueryForMonth1.where('date',
                isLessThanOrEqualTo: endOfMonthMs))
            .called(1);
        verify(mockQueryForMonth2.orderBy('date', descending: true)).called(1);
        verify(mockQueryForMonth2.get()).called(1);

        expect(results.length, 3);
      });

      test('should throw Exception when invalid month provided', () async {
        // Invalid month (13)
        expect(() => repository.filterByMonth(13, 2023), throwsException);

        // Invalid month (0)
        expect(() => repository.filterByMonth(0, 2023), throwsException);
      });

      test('should throw exception when query by month fails', () async {
        // Setup test month and year
        final month = 3; // March
        final year = 2023;
        final startOfMonthMs = DateTime(2023, 3, 1).millisecondsSinceEpoch;
        final endOfMonthMs =
            DateTime(2023, 3, 31, 23, 59, 59, 999).millisecondsSinceEpoch;

        // Setup mock queries
        final mockQueryForMonth1 = MockQuery<Map<String, dynamic>>();
        final mockQueryForMonth2 = MockQuery<Map<String, dynamic>>();

        when(mockCollection.where('date',
                isGreaterThanOrEqualTo: startOfMonthMs))
            .thenReturn(mockQueryForMonth1);
        when(mockQueryForMonth1.where('date',
                isLessThanOrEqualTo: endOfMonthMs))
            .thenReturn(mockQueryForMonth2);
        when(mockQueryForMonth2.orderBy('date', descending: true))
            .thenReturn(mockQueryForMonth2);
        when(mockQueryForMonth2.get()).thenThrow(Exception('Test error'));

        // Verify exception is thrown
        expect(() => repository.filterByMonth(month, year), throwsException);
      });
    });

    group('filterByYear Tests', () {
      test('should retrieve activities for a specific year', () async {
        // Setup test year
        final year = 2023;
        final startOfYearMs = DateTime(2023, 1, 1).millisecondsSinceEpoch;
        final endOfYearMs =
            DateTime(2023, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;

        // Setup mock queries
        final mockQueryForYear1 = MockQuery<Map<String, dynamic>>();
        final mockQueryForYear2 = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDocs = [
          _createMockQueryDocSnap('running', DateTime(2023, 1, 15)),
          _createMockQueryDocSnap('cycling', DateTime(2023, 6, 20)),
          _createMockQueryDocSnap('swimming', DateTime(2023, 12, 25)),
        ];

        when(mockCollection.where('date',
                isGreaterThanOrEqualTo: startOfYearMs))
            .thenReturn(mockQueryForYear1);
        when(mockQueryForYear1.where('date', isLessThanOrEqualTo: endOfYearMs))
            .thenReturn(mockQueryForYear2);
        when(mockQueryForYear2.orderBy('date', descending: true))
            .thenReturn(mockQueryForYear2);
        when(mockQueryForYear2.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Call method under test
        final results = await repository.filterByYear(year);

        // Verify interaction and results
        verify(mockCollection.where('date',
                isGreaterThanOrEqualTo: startOfYearMs))
            .called(1);
        verify(mockQueryForYear1.where('date',
                isLessThanOrEqualTo: endOfYearMs))
            .called(1);
        verify(mockQueryForYear2.orderBy('date', descending: true)).called(1);
        verify(mockQueryForYear2.get()).called(1);

        expect(results.length, 3);
      });

      test('should throw exception when query by year fails', () async {
        // Setup test year
        final year = 2023;
        final startOfYearMs = DateTime(2023, 1, 1).millisecondsSinceEpoch;
        final endOfYearMs =
            DateTime(2023, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;

        // Setup mock queries
        final mockQueryForYear1 = MockQuery<Map<String, dynamic>>();
        final mockQueryForYear2 = MockQuery<Map<String, dynamic>>();

        when(mockCollection.where('date',
                isGreaterThanOrEqualTo: startOfYearMs))
            .thenReturn(mockQueryForYear1);
        when(mockQueryForYear1.where('date', isLessThanOrEqualTo: endOfYearMs))
            .thenReturn(mockQueryForYear2);
        when(mockQueryForYear2.orderBy('date', descending: true))
            .thenReturn(mockQueryForYear2);
        when(mockQueryForYear2.get()).thenThrow(Exception('Test error'));

        // Verify exception is thrown
        expect(() => repository.filterByYear(year), throwsException);
      });
    });

    group('getActivitiesWithLimit Tests', () {
      test('should retrieve limited number of activities', () async {
        // Setup mock queries
        final mockQueryWithLimit = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDocs = [
          _createMockQueryDocSnap('running', DateTime(2023, 3, 15)),
          _createMockQueryDocSnap('cycling', DateTime(2023, 3, 10)),
        ];

        when(mockCollection.orderBy('date', descending: true))
            .thenReturn(mockQueryWithLimit);
        when(mockQueryWithLimit.limit(2)).thenReturn(mockQueryWithLimit);
        when(mockQueryWithLimit.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Call method under test
        final results = await repository.getActivitiesWithLimit(2);

        // Verify interaction and results
        verify(mockCollection.orderBy('date', descending: true)).called(1);
        verify(mockQueryWithLimit.limit(2)).called(1);
        verify(mockQueryWithLimit.get()).called(1);

        expect(results.length, 2);
      });

      test('should throw exception when query with limit fails', () async {
        // Setup mock queries
        final mockQueryWithLimit = MockQuery<Map<String, dynamic>>();

        // Setup all mocks before any repository method is called
        when(mockCollection.orderBy('date', descending: true))
            .thenReturn(mockQueryWithLimit);
        when(mockQueryWithLimit.limit(5)).thenReturn(mockQueryWithLimit);
        when(mockQueryWithLimit.get()).thenThrow(Exception('Test error'));

        // Use expectLater for async exceptions
        await expectLater(
            repository.getActivitiesWithLimit(5), throwsException);
      });
    });
  });
}

// Helper function to create mock query document snapshots
MockQueryDocumentSnapshot<Map<String, dynamic>> _createMockQueryDocSnap(
    String type, DateTime date) {
  final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
  final String testId = 'test-$type-${date.millisecondsSinceEpoch}';
  final startTime = date.add(const Duration(hours: 9));
  final endTime = date.add(const Duration(hours: 10));

  final Map<String, dynamic> data = {
    'id': testId,
    'userId': 'test-user-id',
    'type': type,
    'date': date.millisecondsSinceEpoch,
    'startTime': startTime.millisecondsSinceEpoch,
    'endTime': endTime.millisecondsSinceEpoch,
    'caloriesBurned': 300.0,
  };

  // Add type-specific fields
  switch (type) {
    case 'running':
      data['distanceKm'] = 5.0;
      break;
    case 'cycling':
      data['distanceKm'] = 20.0;
      data['cyclingType'] = 'mountain';
      break;
    case 'swimming':
      data['laps'] = 20;
      data['poolLength'] = 25.0;
      data['stroke'] = 'Freestyle (Front Crawl)';
      break;
  }

  // Configure mock outside of any other when() block
  when(mockDoc.id).thenReturn(testId);
  when(mockDoc.data()).thenReturn(data);
  return mockDoc;
}
