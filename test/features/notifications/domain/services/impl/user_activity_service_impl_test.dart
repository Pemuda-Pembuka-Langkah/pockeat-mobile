// Dart imports:

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/services/impl/user_activity_service_impl.dart';

// Generate mocks for SharedPreferences
@GenerateMocks([SharedPreferences])
import 'user_activity_service_impl_test.mocks.dart';

void main() {
  late UserActivityServiceImpl userActivityService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    userActivityService = UserActivityServiceImpl(prefs: mockSharedPreferences);
  });

  group('UserActivityServiceImpl', () {
    group('trackAppOpen', () {
      test('should store current time in shared preferences', () async {
        // Stub the setInt method to return true for successful operation
        when(mockSharedPreferences.setInt(any, any))
            .thenAnswer((_) async => true);

        // Act
        await userActivityService.trackAppOpen();

        // Assert
        // Verify setInt was called with the correct constant key
        verify(mockSharedPreferences.setInt(
          NotificationConstants.lastAppOpenTimeKey,
          any,
        )).called(1);

        // // We can't verify the exact milliseconds value due to timing,
        // // but we can verify it's close to now
        // final captured = verify(mockSharedPreferences.setInt(
        //   NotificationConstants.lastAppOpenTimeKey,
        //   captureAny,
        // )).captured.first as int;

        // // The captured time should be close to our current time
        // // Allow a 1 second (1000 milliseconds) tolerance
        // expect((captured - nowMillis).abs() < 1000, isTrue,
        //     reason: 'Stored timestamp should be close to current time');
      });
    });

    group('getLastOpenTime', () {
      test('should return null when no last open time is stored', () async {
        // Arrange
        when(mockSharedPreferences.getInt(any)).thenReturn(null);

        // Act
        final result = await userActivityService.getLastOpenTime();

        // Assert
        expect(result, isNull);
        verify(mockSharedPreferences
                .getInt(NotificationConstants.lastAppOpenTimeKey))
            .called(1);
      });

      test('should return DateTime from stored milliseconds', () async {
        // Arrange
        final testTime = DateTime(2025, 4, 20, 10, 30); // Fixed test time
        final testMillis = testTime.millisecondsSinceEpoch;
        when(mockSharedPreferences
                .getInt(NotificationConstants.lastAppOpenTimeKey))
            .thenReturn(testMillis);

        // Act
        final result = await userActivityService.getLastOpenTime();

        // Assert
        expect(result, isNotNull);
        expect(result, equals(testTime));
        verify(mockSharedPreferences
                .getInt(NotificationConstants.lastAppOpenTimeKey))
            .called(1);
      });
    });

    group('getInactiveDuration', () {
      test('should return zero duration when no last open time', () async {
        // Arrange
        when(mockSharedPreferences.getInt(any)).thenReturn(null);

        // Act
        final result = await userActivityService.getInactiveDuration();

        // Assert
        expect(result, equals(Duration.zero));
      });

      test('should return correct duration since last open time', () async {
        // Arrange
        final now = DateTime.now();
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        final twoHoursAgoMillis = twoHoursAgo.millisecondsSinceEpoch;

        when(mockSharedPreferences
                .getInt(NotificationConstants.lastAppOpenTimeKey))
            .thenReturn(twoHoursAgoMillis);

        // Act
        final result = await userActivityService.getInactiveDuration();

        // Assert
        // Allow small timing inconsistency (a few seconds) since DateTime.now() may differ
        // between the test and the implementation
        expect(result.inHours, equals(2));

        // Difference shouldn't exceed a few seconds at most
        expect((result - const Duration(hours: 2)).inSeconds.abs() < 5, isTrue,
            reason: 'Duration should be approximately 2 hours');
      });
    });

    group('isInactiveFor', () {
      test(
          'should return true when inactive duration exceeds specified duration',
          () async {
        // Arrange
        final now = DateTime.now();
        final threeHoursAgo = now.subtract(const Duration(hours: 3));
        final threeHoursAgoMillis = threeHoursAgo.millisecondsSinceEpoch;

        when(mockSharedPreferences
                .getInt(NotificationConstants.lastAppOpenTimeKey))
            .thenReturn(threeHoursAgoMillis);

        // Act
        final result =
            await userActivityService.isInactiveFor(const Duration(hours: 2));

        // Assert
        expect(result, isTrue);
      });

      test(
          'should return false when inactive duration is less than specified duration',
          () async {
        // Arrange
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        final oneHourAgoMillis = oneHourAgo.millisecondsSinceEpoch;

        when(mockSharedPreferences
                .getInt(NotificationConstants.lastAppOpenTimeKey))
            .thenReturn(oneHourAgoMillis);

        // Act
        final result =
            await userActivityService.isInactiveFor(const Duration(hours: 2));

        // Assert
        expect(result, isFalse);
      });

      test('should return false when no activity tracked yet', () async {
        // Arrange
        when(mockSharedPreferences.getInt(any)).thenReturn(null);

        // Act
        final result =
            await userActivityService.isInactiveFor(const Duration(hours: 2));

        // Assert
        expect(result, isFalse);
      });
    });

    // Edge case tests
    group('edge cases', () {
      test('should handle very long inactivity periods correctly', () async {
        // Arrange - simulate 30 days of inactivity
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        final thirtyDaysAgoMillis = thirtyDaysAgo.millisecondsSinceEpoch;

        when(mockSharedPreferences
                .getInt(NotificationConstants.lastAppOpenTimeKey))
            .thenReturn(thirtyDaysAgoMillis);

        // Act
        final duration = await userActivityService.getInactiveDuration();
        final isInactiveForOneDay =
            await userActivityService.isInactiveFor(const Duration(days: 1));
        final isInactiveForSixtyDays =
            await userActivityService.isInactiveFor(const Duration(days: 60));

        // Assert
        expect(duration.inDays, equals(30));
        expect(isInactiveForOneDay, isTrue);
        expect(isInactiveForSixtyDays, isFalse);
      });

      test('should handle future timestamps gracefully', () async {
        // Arrange - unlikely case of future timestamp (perhaps due to device clock change)
        final now = DateTime.now();
        final oneDayInFuture = now.add(const Duration(days: 1));
        final futureDayMillis = oneDayInFuture.millisecondsSinceEpoch;

        when(mockSharedPreferences
                .getInt(NotificationConstants.lastAppOpenTimeKey))
            .thenReturn(futureDayMillis);

        // Act
        final duration = await userActivityService.getInactiveDuration();

        // Assert - should return a negative duration
        expect(duration.isNegative, isTrue);
        expect(duration.inDays.abs(), equals(0));
      });
    });
  });
}
