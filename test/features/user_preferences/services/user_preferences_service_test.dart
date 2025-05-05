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

  group('UserPreferencesService - Exercise Calorie Compensation', () {
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

  group('UserPreferencesService - Rollover Calories', () {
    test('isRolloverCaloriesEnabled should return false by default', () async {
      // Act
      final result = await preferencesService.isRolloverCaloriesEnabled();

      // Assert
      expect(result, false);
    });

    test('isRolloverCaloriesEnabled should return value from Firestore',
        () async {
      // Arrange
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'rollover_calories_enabled': true}
      });

      // Act
      final result = await preferencesService.isRolloverCaloriesEnabled();

      // Assert
      expect(result, true);
    });

    test('setRolloverCaloriesEnabled should update value in Firestore',
        () async {
      // Act
      await preferencesService.setRolloverCaloriesEnabled(true);

      // Assert
      final docSnapshot =
          await fakeFirestore.collection('users').doc('test-user-id').get();

      expect(docSnapshot.exists, true);
      expect(docSnapshot.data()?['preferences']?['rollover_calories_enabled'],
          true);
    });

    test(
        'isRolloverCaloriesEnabled should return false when user is not logged in',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await preferencesService.isRolloverCaloriesEnabled();

      // Assert
      expect(result, false);
    });

    test(
        'setRolloverCaloriesEnabled should not update when user is not logged in',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      await preferencesService.setRolloverCaloriesEnabled(true);

      // Assert - should not throw and should not update Firestore
      final snapshot = await fakeFirestore.collection('users').get();
      expect(snapshot.docs.isEmpty, true);
    });

    test('isRolloverCaloriesEnabled should cache result in SharedPreferences',
        () async {
      // Arrange
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'rollover_calories_enabled': true}
      });

      // Act
      await preferencesService.isRolloverCaloriesEnabled();

      // Assert - check if value is cached in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('rollover_calories_enabled_test-user-id'), true);
    });

    test('isRolloverCaloriesEnabled should use cached value if available',
        () async {
      // Arrange - set value in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rollover_calories_enabled_test-user-id', true);

      // Act
      final result = await preferencesService.isRolloverCaloriesEnabled();

      // Assert - should return cached value without querying Firestore
      expect(result, true);
    });

    test('getRolloverCalories should return 0 when feature is disabled',
        () async {
      // Arrange - ensure feature is disabled
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'rollover_calories_enabled': false}
      });

      // Act
      final result = await preferencesService.getRolloverCalories();

      // Assert
      expect(result, 0);
    });

    test(
        'getRolloverCalories should calculate correctly based on TDE and previous day consumption',
        () async {
      // Arrange - enable rollover feature
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'rollover_calories_enabled': true}
      });

      // Create caloric requirement (TDE = 2500)
      await fakeFirestore.collection('caloric_requirements').add({
        'userId': 'test-user-id',
        'tde': 2500.0,
        'timestamp': Timestamp.now()
      });

      // Create yesterday's calorie stats (consumed 2000 calories)
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateString =
          "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

      await fakeFirestore.collection('calorie_stats').add({
        'userId': 'test-user-id',
        'date': dateString,
        'caloriesConsumed': 2000
      });

      // Act
      final result = await preferencesService.getRolloverCalories();

      // Assert - should be TDE - caloriesConsumed = 2500 - 2000 = 500
      expect(result, 500);
    });

    test('getRolloverCalories should cap rollover at 1000 calories', () async {
      // Arrange - enable rollover feature
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'rollover_calories_enabled': true}
      });

      // Create caloric requirement (TDE = 3000)
      await fakeFirestore.collection('caloric_requirements').add({
        'userId': 'test-user-id',
        'tde': 3000.0,
        'timestamp': Timestamp.now()
      });

      // Create yesterday's calorie stats (consumed only 1000 calories)
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateString =
          "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

      await fakeFirestore.collection('calorie_stats').add({
        'userId': 'test-user-id',
        'date': dateString,
        'caloriesConsumed': 1000
      });

      // Act
      final result = await preferencesService.getRolloverCalories();

      // Assert - should be capped at 1000 (instead of 2000)
      expect(result, 1000);
    });

    test('getRolloverCalories should round tde value correctly', () async {
      // Arrange - enable rollover feature
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'rollover_calories_enabled': true}
      });

      // Create caloric requirement with decimal (TDE = 2500.7 -> should round up to 2501)
      await fakeFirestore.collection('caloric_requirements').add({
        'userId': 'test-user-id',
        'tde': 2500.7,
        'timestamp': Timestamp.now()
      });

      // Create yesterday's calorie stats
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateString =
          "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

      await fakeFirestore.collection('calorie_stats').add({
        'userId': 'test-user-id',
        'date': dateString,
        'caloriesConsumed': 2000
      });

      // Act
      final result = await preferencesService.getRolloverCalories();

      // Assert - should be rounded TDE - caloriesConsumed = 2501 - 2000 = 501
      expect(result, 501);
    });

    test(
        'getRolloverCalories should return 0 when no previous calorie stats exist',
        () async {
      // Arrange - enable rollover feature
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'rollover_calories_enabled': true}
      });

      // Create caloric requirement
      await fakeFirestore.collection('caloric_requirements').add({
        'userId': 'test-user-id',
        'tde': 2500.0,
        'timestamp': Timestamp.now()
      });

      // Don't create any calorie stats

      // Act
      final result = await preferencesService.getRolloverCalories();

      // Assert - should return 0 when no stats exist
      expect(result, 0);
    });

    test(
        'getRolloverCalories should return 0 when no caloric requirements exist',
        () async {
      // Arrange - enable rollover feature
      await fakeFirestore.collection('users').doc('test-user-id').set({
        'preferences': {'rollover_calories_enabled': true}
      });

      // Don't create caloric requirements

      // Act
      final result = await preferencesService.getRolloverCalories();

      // Assert - should return 0 when no requirements exist
      expect(result, 0);
    });
  });
}
