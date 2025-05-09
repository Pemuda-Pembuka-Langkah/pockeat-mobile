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

void main() {
  late UserPreferencesRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockDocumentReference mockDocRef;
  late MockCollectionReference mockCollectionRef;
  late MockDocumentSnapshot mockDocSnapshot;

  const String testUserId = 'test-user-123';
  const String exerciseCompensationKey =
      'exercise_calorie_compensation_enabled_test-user-123';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockDocRef = MockDocumentReference();
    mockCollectionRef = MockCollectionReference();
    mockDocSnapshot = MockDocumentSnapshot();

    // Setup mock behavior for Firestore
    when(() => mockFirestore.collection('users')).thenReturn(mockCollectionRef);
    when(() => mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);

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
}
