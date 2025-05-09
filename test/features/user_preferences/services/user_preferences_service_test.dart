// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late UserPreferencesService preferencesService;
  late Map<String, Object> sharedPrefsValues;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Setup mock auth
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');

    // Setup shared preferences
    sharedPrefsValues = <String, Object>{};
    SharedPreferences.setMockInitialValues(sharedPrefsValues);

    // Initialize the service with mocks
    preferencesService = UserPreferencesService(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  group('UserPreferencesService', () {
    test('isExerciseCalorieCompensationEnabled should return false by default',
        () async {
      // Act
      final result =
          await preferencesService.isExerciseCalorieCompensationEnabled();

      // Assert
      expect(result, false);
    });

    test(
        'isExerciseCalorieCompensationEnabled should return value from Firestore',
        () async {
      // Arrange
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'exercise_calorie_compensation_enabled': true}
      });

      // Act
      final result =
          await preferencesService.isExerciseCalorieCompensationEnabled();

      // Assert
      expect(result, true);
    });

    test(
        'setExerciseCalorieCompensationEnabled should update value in Firestore',
        () async {
      // Act
      await preferencesService.setExerciseCalorieCompensationEnabled(true);

      // Assert
      final docSnapshot =
          await fakeFirestore.collection('users').doc('test-user-id').get();

      expect(docSnapshot.exists, true);
      expect(
          docSnapshot.data()?['preferences']
              ?['exercise_calorie_compensation_enabled'],
          true);
    });

    test(
        'isExerciseCalorieCompensationEnabled should return false when user is not logged in',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result =
          await preferencesService.isExerciseCalorieCompensationEnabled();

      // Assert
      expect(result, false);
    });

    test(
        'setExerciseCalorieCompensationEnabled should not update when user is not logged in',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      await preferencesService.setExerciseCalorieCompensationEnabled(true);

      // Assert - should not throw and should not update Firestore
      final snapshot = await fakeFirestore.collection('users').get();
      expect(snapshot.docs.isEmpty, true);
    });

    test(
        'isExerciseCalorieCompensationEnabled should cache result in SharedPreferences',
        () async {
      // Arrange
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'exercise_calorie_compensation_enabled': true}
      });

      // Act
      await preferencesService.isExerciseCalorieCompensationEnabled();

      // Assert - check if value is cached in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(
          prefs.getBool('exercise_calorie_compensation_enabled_test-user-id'),
          true);
    });

    test(
        'isExerciseCalorieCompensationEnabled should use cached value if available',
        () async {
      // Arrange - set value in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'exercise_calorie_compensation_enabled_test-user-id', true);

      // Act
      final result =
          await preferencesService.isExerciseCalorieCompensationEnabled();

      // Assert - should return cached value without querying Firestore
      expect(result, true);
    });
  });
}
