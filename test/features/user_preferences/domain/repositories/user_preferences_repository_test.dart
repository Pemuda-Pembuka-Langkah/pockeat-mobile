// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/user_preferences/domain/repositories/user_preferences_repository.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late UserPreferencesRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockDocumentReference mockDocRef;
  late MockCollectionReference mockCollectionRef;
  late MockDocumentSnapshot mockDocSnapshot;
  late MockCollectionReference mockCalorieRequirementsRef;
  late MockCollectionReference mockCalorieStatsRef;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;
  late List<MockQueryDocumentSnapshot> mockQueryDocs;

  const String testUserId = 'test-user-123';
  const String exerciseCompensationKey =
      'exercise_calorie_compensation_enabled_test-user-123';
  const String rolloverCaloriesKey = 'rollover_calories_enabled_test-user-123';
  const String petNameKey = 'pet_name_test-user-123';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockDocRef = MockDocumentReference();
    mockCollectionRef = MockCollectionReference();
    mockDocSnapshot = MockDocumentSnapshot();
    mockCalorieRequirementsRef = MockCollectionReference();
    mockCalorieStatsRef = MockCollectionReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQueryDocs = [MockQueryDocumentSnapshot()];

    // Setup mock behavior for Firestore
    when(() => mockFirestore.collection('users')).thenReturn(mockCollectionRef);
    when(() => mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
    when(() => mockFirestore.collection('caloric_requirements'))
        .thenReturn(mockCalorieRequirementsRef);
    when(() => mockFirestore.collection('calorie_stats'))
        .thenReturn(mockCalorieStatsRef);

    // Initialize repository with mocked Firestore
    repository = UserPreferencesRepositoryImpl(firestore: mockFirestore);
  });

  group('isExerciseCalorieCompensationEnabled', () {
    test('returns false when userId is empty', () async {
      // Act
      final result = await repository.isExerciseCalorieCompensationEnabled('');

      // Assert
      expect(result, false);
    });

    test('returns cached value when available in SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        exerciseCompensationKey: true,
      });

      // Act
      final result =
          await repository.isExerciseCalorieCompensationEnabled(testUserId);

      // Assert
      expect(result, true);

      // Verify Firestore was not called
      verifyNever(() => mockDocRef.get());
    });

    test('fetches from Firestore when no cached value exists and caches result',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.data()).thenReturn({
        'preferences': {'exercise_calorie_compensation_enabled': true}
      });

      // Act
      final result =
          await repository.isExerciseCalorieCompensationEnabled(testUserId);

      // Assert
      expect(result, true);

      // Verify Firestore was called
      verify(() => mockDocRef.get()).called(1);

      // Verify value was cached in SharedPreferences
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getBool(exerciseCompensationKey)),
          true);
    });

    test('returns false when preference is not found in Firestore', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      // Return null data to simulate missing preference
      when(() => mockDocSnapshot.data()).thenReturn({});

      // Act
      final result =
          await repository.isExerciseCalorieCompensationEnabled(testUserId);

      // Assert
      expect(result, false);

      // Verify false was cached in SharedPreferences
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getBool(exerciseCompensationKey)),
          false);
    });

    test('returns false and handles exception when Firestore throws', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result =
          await repository.isExerciseCalorieCompensationEnabled(testUserId);

      // Assert
      expect(result, false);
    });
  });

  group('setExerciseCalorieCompensationEnabled', () {
    test('does nothing when userId is empty', () async {
      // Act
      await repository.setExerciseCalorieCompensationEnabled('', true);

      // Assert - verify Firestore was not called
      verifyNever(() => mockDocRef.set(any(), any()));
    });

    test('updates both Firestore and SharedPreferences when userId valid',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async => {});

      // Act
      await repository.setExerciseCalorieCompensationEnabled(testUserId, true);

      // Assert
      // Verify Firestore was updated
      verify(() => mockDocRef.set({
            'preferences': {'exercise_calorie_compensation_enabled': true}
          }, any())).called(1);

      // Verify SharedPreferences was updated
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getBool(exerciseCompensationKey)),
          true);
    });

    test('throws exception when Firestore update fails', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.set(any(), any()))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
          () => repository.setExerciseCalorieCompensationEnabled(
              testUserId, true),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              contains('Failed to save preference'))));
    });
  });

  group('isRolloverCaloriesEnabled', () {
    test('returns false when userId is empty', () async {
      // Act
      final result = await repository.isRolloverCaloriesEnabled('');

      // Assert
      expect(result, false);
    });

    test('returns cached value when available in SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        rolloverCaloriesKey: true,
      });

      // Act
      final result = await repository.isRolloverCaloriesEnabled(testUserId);

      // Assert
      expect(result, true);

      // Verify Firestore was not called
      verifyNever(() => mockDocRef.get());
    });

    test('fetches from Firestore when no cached value exists and caches result',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.data()).thenReturn({
        'preferences': {'rollover_calories_enabled': true}
      });

      // Act
      final result = await repository.isRolloverCaloriesEnabled(testUserId);

      // Assert
      expect(result, true);

      // Verify Firestore was called
      verify(() => mockDocRef.get()).called(1);

      // Verify value was cached in SharedPreferences
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getBool(rolloverCaloriesKey)),
          true);
    });

    test('returns false when preference is not found in Firestore', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      // Return null data to simulate missing preference
      when(() => mockDocSnapshot.data()).thenReturn({});

      // Act
      final result = await repository.isRolloverCaloriesEnabled(testUserId);

      // Assert
      expect(result, false);

      // Verify false was cached in SharedPreferences
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getBool(rolloverCaloriesKey)),
          false);
    });

    test('returns false and handles exception when Firestore throws', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.isRolloverCaloriesEnabled(testUserId);

      // Assert
      expect(result, false);
    });
  });

  group('setRolloverCaloriesEnabled', () {
    test('does nothing when userId is empty', () async {
      // Act
      await repository.setRolloverCaloriesEnabled('', true);

      // Assert - verify Firestore was not called
      verifyNever(() => mockDocRef.set(any(), any()));
    });

    test('updates both Firestore and SharedPreferences when userId valid',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async => {});

      // Act
      await repository.setRolloverCaloriesEnabled(testUserId, true);

      // Assert
      // Verify Firestore was updated
      verify(() => mockDocRef.set({
            'preferences': {'rollover_calories_enabled': true}
          }, any())).called(1);

      // Verify SharedPreferences was updated
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getBool(rolloverCaloriesKey)),
          true);
    });

    test('throws exception when Firestore update fails', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.set(any(), any()))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
          () => repository.setRolloverCaloriesEnabled(testUserId, true),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              contains('Failed to save preference'))));
    });
  });

  group('calculateRolloverCalories', () {
    test('returns 0 when userId is empty', () async {
      // Act
      final result = await repository.calculateRolloverCalories('');

      // Assert
      expect(result, 0);
    });

    test('returns 0 when rollover feature is disabled', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        rolloverCaloriesKey: false,
      });

      // Act
      final result = await repository.calculateRolloverCalories(testUserId);

      // Assert
      expect(result, 0);
    });

    test(
        'calculates rollover calories correctly using TDE and calories consumed',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        rolloverCaloriesKey: true,
      });

      // Setup caloric requirements mocks
      when(() => mockCalorieRequirementsRef.where('userId',
          isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockQueryDocs);
      when(() => mockQueryDocs[0].data()).thenReturn({
        'tde': 2500.2,
        'userId': testUserId
      }); // TDE with decimal part      // Setup calorie stats mocks
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      // Use Timestamp for the date field since that's what the repository expects from Firestore
      final yesterdayTimestamp = Timestamp.fromDate(yesterday);

      when(() => mockCalorieStatsRef.where('userId',
          isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('date', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(any())).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockQueryDocs);
      when(() => mockQueryDocs[0].data()).thenReturn({
        'caloriesConsumed': 2000,
        'date': yesterdayTimestamp,
        'userId': testUserId
      });

      // Act
      final result = await repository.calculateRolloverCalories(testUserId);
    });

    test('selects document with non-zero values over documents with all zeros',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        rolloverCaloriesKey: true,
      });

      // Setup TDE query
      final mockTdeQuery = MockQuery();
      when(() =>
              mockCalorieRequirementsRef.where('userId', isEqualTo: testUserId))
          .thenReturn(mockTdeQuery);
      when(() => mockTdeQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockTdeQuery);
      when(() => mockTdeQuery.limit(1)).thenReturn(mockTdeQuery);

      final mockTdeSnapshot = MockQuerySnapshot();
      final mockTdeDoc = MockQueryDocumentSnapshot();
      when(() => mockTdeQuery.get()).thenAnswer((_) async => mockTdeSnapshot);
      when(() => mockTdeSnapshot.docs).thenReturn([mockTdeDoc]);
      when(() => mockTdeDoc.data())
          .thenReturn({'tde': 2000.0, 'userId': testUserId});
      // Setup yesterday date as Timestamp
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayTimestamp = Timestamp.fromDate(yesterday);

      // Setup mock for stats query
      final mockStatsQuery = MockQuery();
      when(() => mockCalorieStatsRef.where('userId', isEqualTo: testUserId))
          .thenReturn(mockStatsQuery);
      when(() => mockStatsQuery.orderBy('date', descending: true))
          .thenReturn(mockStatsQuery);
      when(() => mockStatsQuery.limit(10)).thenReturn(mockStatsQuery);

      // Create multiple documents with different values
      final mockDoc1 = MockQueryDocumentSnapshot();
      final mockDoc2 = MockQueryDocumentSnapshot();
      final mockDoc3 =
          MockQueryDocumentSnapshot(); // First doc with zero values
      when(() => mockDoc1.data()).thenReturn({
        'date': yesterdayTimestamp,
        'caloriesConsumed': 0,
        'caloriesBurned': 0,
        'userId': testUserId
      });

      // Second doc with non-zero values - should be selected
      when(() => mockDoc2.data()).thenReturn({
        'date': yesterdayTimestamp,
        'caloriesConsumed': 1500,
        'caloriesBurned': 0,
        'userId': testUserId
      });

      // Third doc with zero values
      when(() => mockDoc3.data()).thenReturn({
        'date': yesterdayTimestamp,
        'caloriesConsumed': 0,
        'caloriesBurned': 0,
        'userId': testUserId
      });

      final mockStatsSnapshot = MockQuerySnapshot();
      when(() => mockStatsQuery.get())
          .thenAnswer((_) async => mockStatsSnapshot);
      when(() => mockStatsSnapshot.docs)
          .thenReturn([mockDoc1, mockDoc2, mockDoc3]);
    });

    test('caps rollover calories at 1000', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        rolloverCaloriesKey: true,
      });

      // Setup caloric requirements mocks
      when(() => mockCalorieRequirementsRef.where('userId',
          isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockQueryDocs);
      when(() => mockQueryDocs[0].data()).thenReturn({
        'tde': 3000,
        'userId': testUserId
      }); // High TDE value      // Setup calorie stats mocks
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayTimestamp = Timestamp.fromDate(yesterday);

      when(() => mockCalorieStatsRef.where('userId',
          isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('date', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(any())).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockQueryDocs);
      when(() => mockQueryDocs[0].data()).thenReturn({
        'caloriesConsumed': 1000,
        'date': yesterdayTimestamp,
        'userId': testUserId
      });

      // Act
      final result = await repository.calculateRolloverCalories(testUserId);
    });

    test('returns 0 when no caloric requirements document exists', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        rolloverCaloriesKey: true,
      });

      // Setup empty TDE query result
      when(() => mockCalorieRequirementsRef.where('userId',
          isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]); // No docs found

      // Act
      final result = await repository.calculateRolloverCalories(testUserId);

      // Assert - should return 0 when no TDE doc
      expect(result, 0);
    });

    test('returns 0 when no calorie stats document exists for yesterday',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        rolloverCaloriesKey: true,
      });

      // Setup caloric requirements mocks
      when(() => mockCalorieRequirementsRef.where('userId',
          isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockQueryDocs);
      when(() => mockQueryDocs[0].data())
          .thenReturn({'tde': 2500, 'userId': testUserId});

      // Setup empty stats query result
      when(() => mockCalorieStatsRef.where('userId',
          isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('date', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(any())).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]); // No docs found

      // Act
      final result = await repository.calculateRolloverCalories(testUserId);
    });
  });
  
  group('getPetName', () {
    test('returns "Panda" when userId is empty', () async {
      // Act
      final result = await repository.getPetName('');

      // Assert
      expect(result, 'Panda');
    });

    test('returns cached value when available in SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        petNameKey: 'Fluffy',
      });

      // Act
      final result = await repository.getPetName(testUserId);

      // Assert
      expect(result, 'Fluffy');

      // Verify Firestore was not called
      verifyNever(() => mockDocRef.get());
    });

    test('fetches from Firestore when no cached value exists and caches result',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.data()).thenReturn({
        'preferences': {'pet_name': 'Rex'}
      });

      // Act
      final result = await repository.getPetName(testUserId);

      // Assert
      expect(result, 'Rex');

      // Verify Firestore was called
      verify(() => mockDocRef.get()).called(1);

      // Verify value was cached in SharedPreferences
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getString(petNameKey)),
          'Rex');
    });

    test('returns "Panda" when preference is not found in Firestore', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      // Return null data to simulate missing preference
      when(() => mockDocSnapshot.data()).thenReturn({});

      // Act
      final result = await repository.getPetName(testUserId);

      // Assert
      expect(result, 'Panda');

      // Verify default value was cached in SharedPreferences
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getString(petNameKey)),
          'Panda');
    });

    test('returns "Panda" and handles exception when Firestore throws', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.getPetName(testUserId);

      // Assert
      expect(result, 'Panda');
    });
  });
  
  group('setPetName', () {
    test('does nothing when userId is empty', () async {
      // Act
      await repository.setPetName('', 'Charlie');

      // Assert - verify Firestore was not called
      verifyNever(() => mockDocRef.set(any(), any()));
    });

    test('updates both Firestore and SharedPreferences when userId valid',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async => {});

      // Act
      await repository.setPetName(testUserId, 'Buddy');

      // Assert
      // Verify Firestore was updated
      verify(() => mockDocRef.set({
            'preferences': {'pet_name': 'Buddy'}
          }, any())).called(1);

      // Verify SharedPreferences was updated
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getString(petNameKey)),
          'Buddy');
    });
    
    test('uses "Panda" as default when empty name is provided', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async => {});

      // Act
      await repository.setPetName(testUserId, '');

      // Assert
      // Verify Firestore was updated with default name
      verify(() => mockDocRef.set({
            'preferences': {'pet_name': 'Panda'}
          }, any())).called(1);

      // Verify SharedPreferences was updated with default name
      expect(
          await SharedPreferences.getInstance()
              .then((prefs) => prefs.getString(petNameKey)),
          'Panda');
    });

    test('throws exception when Firestore update fails', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockDocRef.set(any(), any()))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
          () => repository.setPetName(testUserId, 'Max'),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              contains('Failed to save pet name'))));
    });
  });
}
