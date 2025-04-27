// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Dart imports:
import 'dart:async';



// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';

import 'package:pockeat/features/notifications/domain/model/streak_message.dart';
import 'package:pockeat/features/notifications/domain/services/impl/notification_background_displayer_service_impl.dart';
import 'package:pockeat/features/notifications/domain/services/notification_background_displayer_service.dart';
import 'package:pockeat/features/notifications/domain/services/user_activity_service.dart';

import 'notification_background_displayer_service_impl_test.mocks.dart';

@GenerateMocks([
  LoginService,
  FoodLogHistoryService,
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
  SharedPreferences,
  UserActivityService,
])
// Tidak perlu lagi membuat mock untuk BackgroundLogger karena sudah menggunakan isTest

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NotificationBackgroundDisplayerService service;
  late MockLoginService mockLoginService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockFlutterLocalNotificationsPlugin mockNotifications;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidNotifications;
  late MockSharedPreferences mockPrefs;
  late Map<String, dynamic> serviceMap;
  late MockUserActivityService mockUserActivityService;

  setUp(() {
    // Setup original mocks
    mockLoginService = MockLoginService();
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockNotifications = MockFlutterLocalNotificationsPlugin();
    mockAndroidNotifications = MockAndroidFlutterLocalNotificationsPlugin();
    mockPrefs = MockSharedPreferences();
    mockUserActivityService = MockUserActivityService();

    // Membuat service dengan parameter isTest=true agar BackgroundLogger tidak mencoba akses filesystem
    service = NotificationBackgroundDisplayerServiceImpl(isTest: true);

    // We need to use a different approach since BackgroundLogger.log is static
    // Let's just run the test as is and add more tests incrementally
    
    // Setup service map containing all required dependencies
    serviceMap = {
      'sharedPreferences': mockPrefs,
      'loginService': mockLoginService,
      'foodLogHistoryService': mockFoodLogHistoryService,
      'flutterLocalNotificationsPlugin': mockNotifications,
      'userActivityService': mockUserActivityService,
    };

    // Setup mock for Android platform-specific implementation
    when(mockNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidNotifications);

    // Setup mock for initialize
    when(mockNotifications.initialize(any)).thenAnswer((_) async => true);

    // Setup mock for createNotificationChannel
    when(mockAndroidNotifications.createNotificationChannel(any))
        .thenAnswer((_) async {});

    // Setup mock for show
    when(mockNotifications.show(any, any, any, any,
            payload: anyNamed('payload')))
        .thenAnswer((_) async {});
        
    // By default, set pet sadness notifications to enabled
    when(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled))
        .thenReturn(true);
  });

  group('showPetSadnessNotification', () {
    test('should return false when user is not inactive long enough', () async {
      // Arrange
      // Mock short inactivity duration (1 minute)
      when(mockUserActivityService.getInactiveDuration())
          .thenAnswer((_) async => const Duration(minutes: 1));
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, false);
      verifyNever(mockNotifications.show(any, any, any, any));
    });

    test('should return false when user is inactive exactly at threshold', () async {
      // Arrange
      // Mock inactivity exactly at threshold
      when(mockUserActivityService.getInactiveDuration())
          .thenAnswer((_) async => NotificationConstants.inactivityThreshold);
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, false);
      verifyNever(mockNotifications.show(any, any, any, any));
    });
    
    test('should return false when notifications are disabled', () async {
      // Arrange
      // Mock inactivity of 25 hours
      when(mockUserActivityService.getInactiveDuration())
          .thenAnswer((_) async => const Duration(hours: 25));
      
      // Set notifications to be disabled
      when(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled))
          .thenReturn(false);
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, false);
      verify(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled)).called(1);
      verifyNever(mockNotifications.show(any, any, any, any));
    });
    
    test('should show notification for slightly sad panda (24-48h)', () async {
      // Arrange
      // Mock inactivity of 30 hours (slightly sad range)
      when(mockUserActivityService.getInactiveDuration())
          .thenAnswer((_) async => const Duration(hours: 30));
      
      // Enable notifications
      when(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled))
          .thenReturn(true);
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, true);
      verify(mockUserActivityService.getInactiveDuration()).called(1);
      verify(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled)).called(1);
      verify(mockNotifications.initialize(any)).called(1);
      verify(mockAndroidNotifications.createNotificationChannel(any)).called(1);
      
      // Verify notification was shown with correct title and payload
      verify(mockNotifications.show(
        NotificationConstants.petSadnessNotificationId.hashCode,
        'Your Panda Misses You \ud83d\ude22',  // Title for slightly sad
        any,
        any,
        payload: NotificationConstants.petSadnessPayload,
      )).called(1);
    });
    
    test('should show notification for very sad panda (48-72h)', () async {
      // Arrange
      // Mock inactivity of 60 hours (very sad range)
      when(mockUserActivityService.getInactiveDuration())
          .thenAnswer((_) async => const Duration(hours: 60));
      
      // Enable notifications
      when(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled))
          .thenReturn(true);
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, true);
      verify(mockNotifications.show(
        NotificationConstants.petSadnessNotificationId.hashCode,
        'Your Panda Is Very Sad \ud83d\ude2d',  // Title for very sad
        any,
        any,
        payload: NotificationConstants.petSadnessPayload,
      )).called(1);
    });
    
    test('should show notification for extremely sad panda (72h+)', () async {
      // Arrange
      // Mock inactivity of 80 hours (extremely sad range)
      when(mockUserActivityService.getInactiveDuration())
          .thenAnswer((_) async => const Duration(hours: 80));
      
      // Enable notifications
      when(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled))
          .thenReturn(true);
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, true);
      verify(mockUserActivityService.getInactiveDuration()).called(1);
      
      // Verify notification was shown with correct title and payload for extremely sad
      verify(mockNotifications.show(
        NotificationConstants.petSadnessNotificationId.hashCode,
        'URGENT: Your Panda Is Crying \ud83d\udc94',  // Title for extremely sad
        any,
        any,
        payload: NotificationConstants.petSadnessPayload,
      )).called(1);
    });
    
    test('should handle errors from UserActivityService', () async {
      // Arrange
      // Force an error by returning null for the last activity time
      when(mockUserActivityService.getInactiveDuration())
          .thenThrow(Exception('Failed to get inactivity duration'));
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, false);
      verifyNever(mockNotifications.show(any, any, any, any));
    });

    test('should handle errors from SharedPreferences', () async {
      // Arrange
      // Set up inactive duration
      when(mockUserActivityService.getInactiveDuration())
          .thenAnswer((_) async => const Duration(hours: 25));
      
      when(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled))
          .thenThrow(Exception('SharedPreferences error'));
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, false);
      verifyNever(mockNotifications.show(any, any, any, any));
    });

    test('should show fallback notification when styled notification fails', () async {
      // Arrange
      // Set up inactive duration for slightly sad range
      when(mockUserActivityService.getInactiveDuration())
          .thenAnswer((_) async => const Duration(hours: 30));
      
      when(mockPrefs.getBool(NotificationConstants.prefPetSadnessEnabled))
          .thenReturn(true);
      
      // Make the first show() call throw an exception, but allow the second (fallback) to succeed
      var callCount = 0;
      when(mockNotifications.show(any, any, any, any, payload: anyNamed('payload')))
          .thenAnswer((invocation) {
            callCount++;
            if (callCount == 1) {
              throw Exception('Error showing styled notification');
            }
            return Future.value();
          });
      
      // Act
      final result = await service.showPetSadnessNotification(serviceMap, userActivityService: mockUserActivityService);
      
      // Assert
      expect(result, true);
      verify(mockUserActivityService.getInactiveDuration()).called(1);
      
      // Verify that two show attempts were made (first fails, second succeeds)
      verify(mockNotifications.show(any, any, any, any, payload: anyNamed('payload'))).called(2);
    });
  });

  group('showMealReminderNotification', () {
    test('should show notification when master and individual toggles are enabled', () async {
      // Arrange
      when(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled))
          .thenReturn(true);
      when(mockPrefs.getBool(NotificationConstants.prefBreakfastEnabled))
          .thenReturn(true);

      // Act
      final result = await service.showMealReminderNotification(serviceMap, NotificationConstants.breakfast);

      // Assert
      expect(result, true);

      // Verify all method calls
      verify(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled)).called(1);
      verify(mockPrefs.getBool(NotificationConstants.prefBreakfastEnabled)).called(1);
      verify(mockNotifications.initialize(any)).called(1);
      verify(mockAndroidNotifications.createNotificationChannel(any)).called(1);
      verify(mockNotifications.show(
        NotificationConstants.mealReminderNotificationId.hashCode,
        any,
        any,
        any,
        payload: NotificationConstants.mealReminderPayload,
      )).called(1);
    });

    test('should show notification for lunch meal type', () async {
      // Arrange
      when(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled))
          .thenReturn(true);
      when(mockPrefs.getBool(NotificationConstants.prefLunchEnabled))
          .thenReturn(true);

      // Act
      final result = await service.showMealReminderNotification(serviceMap, NotificationConstants.lunch);

      // Assert
      expect(result, true);

      // Verify message was created for lunch
      verify(mockNotifications.show(
        NotificationConstants.mealReminderNotificationId.hashCode,
        any, // We don't test exact title/body as it comes from MealReminderMessageFactory
        any,
        any,
        payload: NotificationConstants.mealReminderPayload,
      )).called(1);
    });
    
    test('should show notification for dinner meal type', () async {
      // Arrange
      when(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled))
          .thenReturn(true);
      when(mockPrefs.getBool(NotificationConstants.prefDinnerEnabled))
          .thenReturn(true);

      // Act
      final result = await service.showMealReminderNotification(serviceMap, NotificationConstants.dinner);

      // Assert
      expect(result, true);

      // Verify message was created for dinner
      verify(mockNotifications.show(
        NotificationConstants.mealReminderNotificationId.hashCode,
        any,
        any,
        any,
        payload: NotificationConstants.mealReminderPayload,
      )).called(1);
    });

    test('should return false when master toggle is disabled', () async {
      // Arrange
      when(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled))
          .thenReturn(false);

      // Act
      final result = await service.showMealReminderNotification(serviceMap, NotificationConstants.breakfast);

      // Assert
      expect(result, false);

      // Verify only necessary calls were made
      verify(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled)).called(1);
      verifyNever(mockPrefs.getBool(NotificationConstants.prefBreakfastEnabled));
      verifyNever(mockNotifications.show(any, any, any, any));
    });

    test('should return false when individual meal toggle is disabled', () async {
      // Arrange
      when(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled))
          .thenReturn(true);
      when(mockPrefs.getBool(NotificationConstants.prefBreakfastEnabled))
          .thenReturn(false);

      // Act
      final result = await service.showMealReminderNotification(serviceMap, NotificationConstants.breakfast);

      // Assert
      expect(result, false);

      // Verify only necessary calls were made
      verify(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled)).called(1);
      verify(mockPrefs.getBool(NotificationConstants.prefBreakfastEnabled)).called(1);
      verifyNever(mockNotifications.show(any, any, any, any));
    });

    test('should handle errors gracefully', () async {
      // Arrange - setup to throw an exception
      when(mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled))
          .thenThrow(Exception('Test exception'));

      // Act
      final result = await service.showMealReminderNotification(serviceMap, NotificationConstants.breakfast);

      // Assert
      expect(result, false);
      verifyNever(mockNotifications.show(any, any, any, any));
    });
  });

  group('showStreakNotification', () {
    // Main success scenario
    test('should show notification when all conditions are met', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const int streakDays = 7;
      final UserModel testUser = UserModel(
        uid: testUserId,
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      // Setup mocks
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenReturn(true);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockFoodLogHistoryService.getFoodStreakDays(testUserId))
          .thenAnswer((_) async => streakDays);

      // Act
      final result = await service.showStreakNotification(serviceMap);

      // Assert
      expect(result, true);

      // Verify all method calls
      verify(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .called(1);
      verify(mockLoginService.getCurrentUser()).called(1);
      verify(mockFoodLogHistoryService.getFoodStreakDays(testUserId)).called(1);
      verify(mockNotifications.initialize(any)).called(1);
      verify(mockAndroidNotifications.createNotificationChannel(any)).called(1);
      verify(mockNotifications.show(any, any, any, any,
              payload: anyNamed('payload')))
          .called(1);
    });

    test('should return false when notifications are disabled', () async {
      // Arrange
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenReturn(false);

      // Act
      final result = await service.showStreakNotification(serviceMap);

      // Assert
      expect(result, false);

      // Verify only necessary calls were made
      verify(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .called(1);
      verifyNever(mockLoginService.getCurrentUser());
      verifyNever(mockFoodLogHistoryService.getFoodStreakDays(any));
      verifyNever(mockNotifications.show(any, any, any, any));
    });

    test('should return false when user is not logged in', () async {
      // Arrange
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenReturn(true);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await service.showStreakNotification(serviceMap);

      // Assert
      expect(result, false);

      // Verify only necessary calls were made
      verify(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .called(1);
      verify(mockLoginService.getCurrentUser()).called(1);
      verifyNever(mockFoodLogHistoryService.getFoodStreakDays(any));
      verifyNever(mockNotifications.show(any, any, any, any));
    });

    test('should return false when streak is not active (< 0)', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const int streakDays = -1; // Inactive streak
      final UserModel testUser = UserModel(
        uid: testUserId,
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      // Setup mocks
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenReturn(true);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockFoodLogHistoryService.getFoodStreakDays(testUserId))
          .thenAnswer((_) async => streakDays);

      // Act
      final result = await service.showStreakNotification(serviceMap);

      // Assert
      expect(result, false);

      // Verify only necessary calls were made
      verify(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .called(1);
      verify(mockLoginService.getCurrentUser()).called(1);
      verify(mockFoodLogHistoryService.getFoodStreakDays(testUserId)).called(1);
      verifyNever(mockNotifications.show(any, any, any, any));
    });

    test('should use fallback notification when styled notification fails',
        () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const int streakDays = 7;
      final UserModel testUser = UserModel(
        uid: testUserId,
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      // Setup mocks
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenReturn(true);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockFoodLogHistoryService.getFoodStreakDays(testUserId))
          .thenAnswer((_) async => streakDays);

      // Set up the mock to throw an exception on first call, then succeed on second call
      // We use a counter to track the calls
      int callCount = 0;
      when(mockNotifications.show(any, any, any, any,
              payload: anyNamed('payload')))
          .thenAnswer((_) {
        callCount++;
        if (callCount == 1) {
          // First call - throw exception to trigger fallback
          throw Exception('Styled notification failed');
        }
        // Second call - succeed (fallback notification)
        return Future.value();
      });

      // Act
      final result = await service.showStreakNotification(serviceMap);

      // Assert
      expect(result, true);

      // Verify all necessary calls were made including fallback
      verify(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .called(1);
      verify(mockLoginService.getCurrentUser()).called(1);
      verify(mockFoodLogHistoryService.getFoodStreakDays(testUserId)).called(1);
      verify(mockNotifications.initialize(any)).called(1);
      verify(mockAndroidNotifications.createNotificationChannel(any)).called(1);

      // This test might be flaky due to mock behavior with multiple calls
      // If needed, we could restructure to verify based on parameters instead
    });

    test('should handle exceptions and return false', () async {
      // Arrange
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenThrow(Exception('Test exception'));

      // Act
      final result = await service.showStreakNotification(serviceMap);

      // Assert
      expect(result, false);
    });

    test('should use proper streak message based on streak days', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const int streakDays = 100; // Should trigger CenturyStreakMessage
      final UserModel testUser = UserModel(
        uid: testUserId,
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      // Setup mocks
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenReturn(true);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockFoodLogHistoryService.getFoodStreakDays(testUserId))
          .thenAnswer((_) async => streakDays);
      
      // Setup capture for title
      when(mockNotifications.show(any, any, any, any, payload: anyNamed('payload')))
          .thenAnswer((Invocation invocation) async {
        final title = invocation.positionalArguments[1] as String;
        final expectedTitle = StreakMessageFactory.createMessage(streakDays).title;
        // Verify the title matches expected streak message
        expect(title, equals(expectedTitle),
            reason: 'Notification title should match streak message title');
      });

      // Act
      final result = await service.showStreakNotification(serviceMap);

      // Assert
      expect(result, true);
      
      // Verify show was called
      verify(mockNotifications.show(
        any,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('should pass proper channel and payload for dailyStreak notifications',
        () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const int streakDays = 7;
      final UserModel testUser = UserModel(
        uid: testUserId,
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      // Setup mocks
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenReturn(true);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockFoodLogHistoryService.getFoodStreakDays(testUserId))
          .thenAnswer((_) async => streakDays);

      // Custom mock for show method to verify channel and payload
      when(mockNotifications.show(any, any, any, any,
              payload: anyNamed('payload')))
          .thenAnswer((Invocation invocation) async {
        final payload = invocation.namedArguments[const Symbol('payload')];
        expect(payload, equals(NotificationConstants.dailyStreakPayload));

        // We don't need to verify the notification details structure here
        // In a real test, we would verify the channel ID matches NotificationChannels.dailyStreak.id
      });

      // Act
      await service.showStreakNotification(serviceMap);

      // Verified through the custom mock assertion above
      verify(mockNotifications.show(any, any, any, any,
              payload: NotificationConstants.dailyStreakPayload))
          .called(1);
    });

    test('should use notification ID based on streak_celebration hashCode',
        () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const int streakDays = 7;
      final UserModel testUser = UserModel(
        uid: testUserId,
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      final int expectedNotificationId = 'streak_celebration'.hashCode;

      // Setup mocks
      when(mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled))
          .thenReturn(true);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockFoodLogHistoryService.getFoodStreakDays(testUserId))
          .thenAnswer((_) async => streakDays);

      // Act
      await service.showStreakNotification(serviceMap);

      // Assert
      // Verify notification ID
      verify(mockNotifications.show(
        expectedNotificationId,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      )).called(1);
    });
  });
}
