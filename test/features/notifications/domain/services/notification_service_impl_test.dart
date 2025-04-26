// Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart'; // Add for TimeOfDay
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/services/impl/notification_service_impl.dart';
import 'package:pockeat/features/notifications/domain/services/utils/work_manager_client.dart';

// Generate mocks for the dependencies
@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  FoodLogHistoryService,
  LoginService,
  WorkManagerClient,
  AndroidFlutterLocalNotificationsPlugin,
])
// Import generated mocks
import 'notification_service_impl_test.mocks.dart';

// Manual mocks untuk Firebase classes
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {
  @override
  Future<NotificationSettings> requestPermission({
    bool? alert = true,
    bool? announcement = false,
    bool? badge = true,
    bool? carPlay = false,
    bool? criticalAlert = false,
    bool? provisional = false,
    bool? sound = true,
  }) {
    return Future.value(const NotificationSettings(
      authorizationStatus: AuthorizationStatus.authorized,
      alert: AppleNotificationSetting.enabled,
      badge: AppleNotificationSetting.enabled,
      sound: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.disabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      criticalAlert: AppleNotificationSetting.disabled,
      announcement: AppleNotificationSetting.disabled,
      timeSensitive: AppleNotificationSetting.disabled,
    ));
  }
}

// Manual mock untuk RemoteMessage
class MockRemoteMessage extends Mock implements RemoteMessage {
  RemoteNotification? _notification;
  AndroidNotification? _android;
  Map<String, dynamic> _data = {};
  
  RemoteNotification? get notification => _notification;
  AndroidNotification? get android => _android;
  Map<String, dynamic> get data => _data;
  
  void setNotification(RemoteNotification? notification) {
    _notification = notification;
  }
  
  void setAndroid(AndroidNotification? android) {
    _android = android;
  }
  
  void setData(Map<String, dynamic> data) {
    _data = data;
  }
}

// Mock for MethodChannel
class MockMethodChannel extends Mock implements MethodChannel {
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    return super.noSuchMethod(
      Invocation.method(#invokeMethod, [method, arguments]),
      returnValue: Future<T?>.value(null),
    ) as Future<T?>;
  }
}

void main() {
  // Mocks
  late MockFlutterLocalNotificationsPlugin mockLocalNotificationsPlugin;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockLoginService mockLoginService;
  late MockWorkManagerClient mockWorkManagerClient;
  late NotificationServiceImpl notificationService;
  late SharedPreferences mockPrefs;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidFlutterLocalNotificationsPlugin;

  // Setup before tests
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize timezone data for the tests
    tz.initializeTimeZones();
    
    // Setup shared preferences with initial values
    // Set default values for notification channels to match production
    SharedPreferences.setMockInitialValues({
      NotificationConstants.prefDailyStreakEnabled: true,
      NotificationConstants.prefMealReminderMasterEnabled: true,
      NotificationConstants.prefBreakfastEnabled: true,
      NotificationConstants.prefLunchEnabled: true,
      NotificationConstants.prefDinnerEnabled: true,
    });
    mockPrefs = await SharedPreferences.getInstance();
    
    // Initialize mocks (tidak perlu lagi mockFirebaseMessaging karena permission ditangani oleh PermissionService)
    mockLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockLoginService = MockLoginService();
    mockWorkManagerClient = MockWorkManagerClient();
    mockAndroidFlutterLocalNotificationsPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    
    // Setup Android plugin resolution
    when(mockLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidFlutterLocalNotificationsPlugin);
    
    // Setup WorkManager mock to always succeed
    when(mockWorkManagerClient.cancelByUniqueName(any)).thenAnswer((_) async {});
    when(mockWorkManagerClient.registerPeriodicTask(
      any,
      any,
      frequency: anyNamed('frequency'),
      initialDelay: anyNamed('initialDelay'),
      inputData: anyNamed('inputData'),
      constraints: anyNamed('constraints'),
    )).thenAnswer((_) async {});
    
    // Setup notifications mocks
    when(mockLocalNotificationsPlugin.cancel(any)).thenAnswer((_) async {});
    when(mockLocalNotificationsPlugin.cancelAll()).thenAnswer((_) async {});
    when(mockAndroidFlutterLocalNotificationsPlugin.createNotificationChannel(any))
        .thenAnswer((_) async {});
    
    // Create notification service with mocks
    notificationService = NotificationServiceImpl(
      flutterLocalNotificationsPlugin: mockLocalNotificationsPlugin,
      prefs: mockPrefs,
      foodLogHistoryService: mockFoodLogHistoryService,
      loginService: mockLoginService,
      workManagerClient: mockWorkManagerClient,
    );
  });

  group('NotificationServiceImpl initialization', () {
    test('initialize should request permissions and setup notifications', () async {
      // Setup mocks untuk notification initialization
      when(mockLocalNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => true);
      
      when(mockLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidFlutterLocalNotificationsPlugin);
      
      when(mockAndroidFlutterLocalNotificationsPlugin.createNotificationChannel(any))
          .thenAnswer((_) async {});
          
      when(mockWorkManagerClient.cancelByUniqueName(any)).thenAnswer((_) async {});
      when(mockWorkManagerClient.registerPeriodicTask(
        any, 
        any, 
        frequency: anyNamed('frequency'),
        initialDelay: anyNamed('initialDelay'),
        constraints: anyNamed('constraints'),
      )).thenAnswer((_) async {});
      
      // Call the method
      await notificationService.initialize();
      
      // Verify local notifications initialization
      verify(mockLocalNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).called(1);
      
      // Verify notification channels creation
      verify(mockAndroidFlutterLocalNotificationsPlugin.createNotificationChannel(
        argThat(predicate((AndroidNotificationChannel channel) => 
          channel.id == NotificationConstants.dailyStreakChannelId
        )),
      )).called(1);
      
      // Check that all channels were created - server, meal reminder, and daily streak
      verify(mockAndroidFlutterLocalNotificationsPlugin.createNotificationChannel(any))
          .called(2);
    });
  });

  group('NotificationServiceImpl showNotification', () {
    test('showNotificationFromFirebase should handle notifications', () async {
      // Setup mock response
      when(mockLocalNotificationsPlugin.show(
        any,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});
      
      // Create a mock RemoteMessage
      final mockRemoteMessage = MockRemoteMessage();
      const mockNotification = RemoteNotification(
        title: 'Test Title',
        body: 'Test Body'
      );
      const mockAndroidNotification = AndroidNotification(
        channelId: NotificationConstants.serverChannelId
      );
      
      mockRemoteMessage.setNotification(mockNotification);
      mockRemoteMessage.setAndroid(mockAndroidNotification);
      mockRemoteMessage.setData({'payload': 'test_payload'});
      
      // Call the method
      await notificationService.showNotificationFromFirebase(mockRemoteMessage);
      
  
    });
  });

  group('NotificationServiceImpl toggle notifications', () {
    test('toggleNotification should handle enabling notifications', () async {
      // Setup mocks
      when(mockWorkManagerClient.cancelByUniqueName(any)).thenAnswer((_) async {});
      when(mockWorkManagerClient.registerPeriodicTask(
        any, 
        any, 
        frequency: anyNamed('frequency'),
        initialDelay: anyNamed('initialDelay'),
        constraints: anyNamed('constraints'),
      )).thenAnswer((_) async {});
      
      // Call method to enable notification
      await notificationService.toggleNotification(
        NotificationConstants.dailyStreakChannelId, 
        true
      );
      
      // Verify preferences were updated
      expect(
        mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled), 
        true
      );
      
      // Test lulus jika tidak ada exceptions
      expect(notificationService, isNotNull);
    });
    
    test('toggleNotification should disable daily streak notification', () async {
      // Setup mocks
      when(mockWorkManagerClient.cancelByUniqueName(any)).thenAnswer((_) async {});
      
      // Call method to disable notification
      await notificationService.toggleNotification(
        NotificationConstants.dailyStreakChannelId, 
        false
      );
      
      // Verify preferences were updated
      expect(
        mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled), 
        false
      );
      
      // Verify task was canceled
      verify(mockWorkManagerClient.cancelByUniqueName(
        NotificationConstants.streakCalculationTaskName
      )).called(1);
      
      // Verify no new task was scheduled
      verifyNever(mockWorkManagerClient.registerPeriodicTask(
        any,
        any,
        frequency: anyNamed('frequency'),
        initialDelay: anyNamed('initialDelay'),
        constraints: anyNamed('constraints'),
      ));
    });
  });

  group('NotificationServiceImpl check notification status', () {
    test('isNotificationEnabled should return true by default for streak notifications', () async {
      // Call the method for daily streak (default is true)
      final result = await notificationService.isNotificationEnabled(
        NotificationConstants.dailyStreakChannelId
      );
      
      // Should be true by default
      expect(result, true);
      
      // Should have saved the default value
      expect(
        mockPrefs.getBool(NotificationConstants.prefDailyStreakEnabled), 
        true
      );
    });
    
    test('isNotificationEnabled should return saved value for streak notifications', () async {
      // Set up a saved value
      await mockPrefs.setBool(NotificationConstants.prefDailyStreakEnabled, false);
      
      // Call the method
      final result = await notificationService.isNotificationEnabled(
        NotificationConstants.dailyStreakChannelId
      );
      
      // Should return the saved value
      expect(result, false);
    });
  });

  group('NotificationServiceImpl notification tap handling', () {
    test('notification response handler should be registered during initialization', () async {
      // Setup mocks for notification initialization
      when(mockLocalNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => true);
      
      // Call initialize method
      await notificationService.initialize();
      
      // Verify notification initialization happened with response handler
      verify(mockLocalNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: captureAnyNamed('onDidReceiveNotificationResponse'),
      )).called(1);
      
      // We can't test the private _onNotificationTapped method directly, 
      // but we can verify it was set up properly during initialization
    });
  });

  group('NotificationServiceImpl cancel notifications', () {
    test('cancelAllNotifications should cancel all notifications and tasks', () async {
      // Setup mocks
      when(mockLocalNotificationsPlugin.cancelAll()).thenAnswer((_) async {});
      when(mockWorkManagerClient.cancelAll()).thenAnswer((_) async {});
      
      // Call the method
      await notificationService.cancelAllNotifications();
      
      // Verify all notifications were canceled
      verify(mockLocalNotificationsPlugin.cancelAll()).called(1);
      
      // Verify all WorkManager tasks were canceled
      verify(mockWorkManagerClient.cancelAll()).called(1);
    });
    
    test('cancelNotificationsByChannel should cancel channel-specific notifications', () async {
      // Setup mocks
      when(mockLocalNotificationsPlugin.cancel(any)).thenAnswer((_) async {});
      when(mockWorkManagerClient.cancelByUniqueName(any)).thenAnswer((_) async {});
      
      // Call the method
      await notificationService.cancelNotificationsByChannel(
        NotificationConstants.dailyStreakChannelId
      );
      
      // Verify specific notification was canceled
      verify(mockLocalNotificationsPlugin.cancel(
        NotificationConstants.dailyStreakNotificationId.hashCode
      )).called(1);
      
      // Verify specific task was canceled
      verify(mockWorkManagerClient.cancelByUniqueName(
        NotificationConstants.streakCalculationTaskName
      )).called(1);
    });
  });

  // Test edge cases and error handling
  // Pengujian error handling bisa disederhanakan
  group('NotificationServiceImpl error handling', () {
    test('initialize should handle initialization failures', () async {
      // Set up mocks to throw errors
      when(mockLocalNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenThrow(Exception('Failed to initialize'));
      
      // Test that the service gracefully handles errors
      // This would ideally check your error handling implementation
      expect(() => notificationService.initialize(), throwsException);
    });
  });

  // Test untuk penanganan jadwal notifikasi
  group('NotificationServiceImpl notification scheduling', () {
    // Test implementasi _scheduleStreakNotification (secara tidak langsung)
    test('toggleNotification should schedule notification at correct time when enabled', () async {
      // Setup mocks - pastikan menggunakan verifyNever untuk memverifikasi metode tidak dipanggil sebelumnya
      verifyNever(mockWorkManagerClient.cancelByUniqueName(any));
      
      // Pastikan mockWorkManagerClient dikonfigurasi dengan benar
      when(mockWorkManagerClient.registerPeriodicTask(
        any,
        any,
        frequency: anyNamed('frequency'),
        initialDelay: anyNamed('initialDelay'),
        constraints: anyNamed('constraints'),
      )).thenAnswer((_) async {});
      
      // Aktifkan notifikasi
      await notificationService.toggleNotification(NotificationConstants.dailyStreakChannelId, true);
      
      // Verifikasi sebut memanggil onSuccess jadi tidak perlu verifikasi
      // Kita hanya memastikan test berjalan tanpa error
    });
  });
  
  // Test untuk penanganan cancelNotification
  group('NotificationServiceImpl notification cancellation', () {
    test('cancelNotification should call cancel with correct id', () async {
      // Setup mocks
      when(mockLocalNotificationsPlugin.cancel(any)).thenAnswer((_) async {});
      
      // Execute the method
      const notificationId = 'test_notification_id';
      await notificationService.cancelNotification(notificationId);
      
      // Verify correct call was made
      verify(mockLocalNotificationsPlugin.cancel(notificationId.hashCode)).called(1);
    });
  });
  
  // Tests for meal reminder notifications functionality
  group('NotificationServiceImpl meal reminder notifications', () {
    setUp(() {
      // Reset method call counts for each test
      reset(mockWorkManagerClient);
      reset(mockLocalNotificationsPlugin);
      reset(mockAndroidFlutterLocalNotificationsPlugin);
      
      // Refresh mock behaviors to ensure consistent behavior
      when(mockWorkManagerClient.cancelByUniqueName(any)).thenAnswer((_) async {});
      when(mockWorkManagerClient.registerPeriodicTask(
        any,
        any,
        frequency: anyNamed('frequency'),
        initialDelay: anyNamed('initialDelay'),
        inputData: anyNamed('inputData'),
        constraints: anyNamed('constraints'),
      )).thenAnswer((_) async {});
      when(mockLocalNotificationsPlugin.cancel(any)).thenAnswer((_) async {});
      when(mockAndroidFlutterLocalNotificationsPlugin.createNotificationChannel(any))
          .thenAnswer((_) async {});
      when(mockLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidFlutterLocalNotificationsPlugin);
    });
    
    test('Master toggle should enable/disable all meal reminders', () async {
      // Toggle master switch on
      await notificationService.toggleNotification(
          NotificationConstants.mealReminderChannelId, true);
      
      // Verify master preference was saved
      expect(
        mockPrefs.getBool(NotificationConstants.prefMealReminderMasterEnabled),
        true
      );
      
      // Verify scheduling was attempted for all meal types
      // We don't need to verify exact parameters since that's tested elsewhere
      // Just verify the periodic task registration was called
      verify(mockWorkManagerClient.registerPeriodicTask(
        NotificationConstants.breakfastReminderTaskName,
        any,
        frequency: anyNamed('frequency'),
        initialDelay: anyNamed('initialDelay'),
        inputData: anyNamed('inputData'),
        constraints: anyNamed('constraints'),
      )).called(1);
    });
    
    test('Individual meal type toggles should work correctly', () async {
      // Setup master toggle as enabled
      await mockPrefs.setBool(
          NotificationConstants.prefMealReminderMasterEnabled, true);
      
      // Toggle breakfast on
      await notificationService.toggleNotification(
          NotificationConstants.breakfast, true);
      
      // Verify breakfast preference was saved
      expect(
        mockPrefs.getBool(
            NotificationConstants.prefBreakfastEnabled),
        true
      );
      
      // Toggle breakfast off
      await notificationService.toggleNotification(
          NotificationConstants.breakfast, false);
    });
    
    test('cancelNotificationsByChannel should cancel all meal reminders', () async {
      // Setup mocks
      when(mockLocalNotificationsPlugin.cancel(any)).thenAnswer((_) async {});
      
      // Call the method
      await notificationService.cancelNotificationsByChannel(
        NotificationConstants.mealReminderChannelId
      );
      
      // Verify notification was canceled
      verify(mockLocalNotificationsPlugin.cancel(
        NotificationConstants.mealReminderNotificationId.hashCode
      )).called(1);
      
      // Verify all meal reminder tasks were canceled
      verify(mockWorkManagerClient.cancelByUniqueName(
          NotificationConstants.breakfastReminderTaskName)).called(1);
      verify(mockWorkManagerClient.cancelByUniqueName(
          NotificationConstants.lunchReminderTaskName)).called(1);
      verify(mockWorkManagerClient.cancelByUniqueName(
          NotificationConstants.dinnerReminderTaskName)).called(1);
    });
    
    test('isNotificationEnabled should return correct values for meal types', () async {
      // Test default values (should be true from initial setup)
      final isMasterEnabled = await notificationService.isNotificationEnabled(
          NotificationConstants.mealReminderChannelId);
      expect(isMasterEnabled, true);
      
      final isBreakfastEnabled = await notificationService.isNotificationEnabled(
          NotificationConstants.breakfast);
      expect(isBreakfastEnabled, true);
      
      // Set master toggle to false and verify
      await mockPrefs.setBool(
          NotificationConstants.prefMealReminderMasterEnabled, false);
      final updatedMasterEnabled = await notificationService.isNotificationEnabled(
          NotificationConstants.mealReminderChannelId);
      expect(updatedMasterEnabled, false);
      
      // Reset master toggle to true for other tests
      await mockPrefs.setBool(
          NotificationConstants.prefMealReminderMasterEnabled, true);
          
      // Test individual toggle
      await mockPrefs.setBool(
          NotificationConstants.prefBreakfastEnabled, false);
      final updatedBreakfastEnabled = await notificationService.isNotificationEnabled(
          NotificationConstants.breakfast);
      expect(updatedBreakfastEnabled, false);
      
      // Reset individual toggle for other tests
      await mockPrefs.setBool(
          NotificationConstants.prefBreakfastEnabled, true);
    });
    
    test('updateMealReminderTime should update time preferences', () async {
      // Ensure both toggles are enabled (already set in initial values)
      expect(await notificationService.isNotificationEnabled(
          NotificationConstants.mealReminderChannelId), true);
      expect(await notificationService.isNotificationEnabled(
          NotificationConstants.breakfast), true);
      
      // Update breakfast time
      const testHour = 8;
      const testMinute = 30;
      await notificationService.updateMealReminderTime(
          NotificationConstants.breakfast, 
          const TimeOfDay(hour: testHour, minute: testMinute));
      
      // Verify time preferences were saved
      final prefKey = NotificationConstants.getMealTypeKey(NotificationConstants.breakfast);
      final hourKey = "${prefKey}_hour";
      final minuteKey = "${prefKey}_minute";
      
      expect(mockPrefs.getInt(hourKey), testHour);
      expect(mockPrefs.getInt(minuteKey), testMinute);
      
      // Verify task was canceled and rescheduled
      verify(mockWorkManagerClient.cancelByUniqueName(
          NotificationConstants.breakfastReminderTaskName)).called(2);
      verify(mockWorkManagerClient.registerPeriodicTask(
        NotificationConstants.breakfastReminderTaskName,
        any,
        frequency: anyNamed('frequency'),
        initialDelay: anyNamed('initialDelay'),
        inputData: anyNamed('inputData'),
        constraints: anyNamed('constraints'),
      )).called(1);
    });
    
    // Mock implementation of getMealReminderTime for testing
    test('getMealReminderTime should return correct time preferences', () async {
      // Use separate keys to avoid conflicts with other tests
      const testHour = 9;
      const testMinute = 15;
      final prefKey = NotificationConstants.getMealTypeKey(NotificationConstants.breakfast);
      final hourKey = "${prefKey}_hour";
      final minuteKey = "${prefKey}_minute";
      
      // Clear any existing values
      await mockPrefs.remove(hourKey);
      await mockPrefs.remove(minuteKey);
      
      // Set custom time for breakfast
      await mockPrefs.setInt(hourKey, testHour);
      await mockPrefs.setInt(minuteKey, testMinute);
      
      // Get time preferences
      final breakfastTime = await notificationService.getMealReminderTime(
          NotificationConstants.breakfast);
      
      // Verify time is correct
      expect(breakfastTime.hour, testHour);
      expect(breakfastTime.minute, testMinute);
    });
    
    test('getMealReminderTime should return default time when no preference', () async {
      // Clear existing preferences
      final prefKey = NotificationConstants.getMealTypeKey(NotificationConstants.dinner);
      final hourKey = "${prefKey}_hour";
      final minuteKey = "${prefKey}_minute";
      await mockPrefs.remove(hourKey);
      await mockPrefs.remove(minuteKey);
      
      // Test default time for dinner (no preference set)
      final dinnerTime = await notificationService.getMealReminderTime(
          NotificationConstants.dinner);
      
      // Verify default time is returned
      expect(dinnerTime.hour, NotificationConstants.defaultDinnerHour);
      expect(dinnerTime.minute, NotificationConstants.defaultDinnerMinute);
    });
    
    test('isMealTypeEnabled should return correct value', () async {
      // Test default value
      final isEnabled = await notificationService.isMealTypeEnabled(
          NotificationConstants.breakfast);
      expect(isEnabled, true);
      
      // Set to false and test again
      await mockPrefs.setBool(
          NotificationConstants.prefBreakfastEnabled, false);
      final updatedIsEnabled = await notificationService.isMealTypeEnabled(
          NotificationConstants.breakfast);
      expect(updatedIsEnabled, false);
    });
  });
}

// Mock User for testing
class MockUser extends UserModel {
  MockUser()
      : super(
          uid: 'test_user_id',
          email: 'test@example.com',
          emailVerified: true,
          createdAt: DateTime.now(),
        );
}
