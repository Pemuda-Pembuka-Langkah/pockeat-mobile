import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service_impl.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocking kelas yang dibutuhkan
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockRemoteMessage extends Mock implements RemoteMessage {}

class MockRemoteNotification extends Mock implements RemoteNotification {}

class MockAndroidNotification extends Mock implements AndroidNotification {}

class MockNotificationResponse extends Mock implements NotificationResponse {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NotificationService notificationService;
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin
      mockAndroidFlutterLocalNotificationsPlugin;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    final AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'calories_reminder_channel',
      'Pengingat Kalori Harian',
      description:
          'Channel untuk mengirim pengingat tentang pelacakan kalori harian',
      importance: Importance.high,
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    tz.TZDateTime scheduledDateTime =
        tz.TZDateTime.from(scheduledDate, tz.getLocation('Asia/Jakarta'));

    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
      ),
    );

    UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation =
        UILocalNotificationDateInterpretation.absoluteTime;

    registerFallbackValue(initializationSettings);
    registerFallbackValue(channel);
    registerFallbackValue(scheduledDateTime);
    registerFallbackValue(notificationDetails);
    registerFallbackValue(uiLocalNotificationDateInterpretation);

    // if registered, unregister first
    if (getIt.isRegistered<FirebaseMessaging>()) {
      getIt.unregister<FirebaseMessaging>();
    }
    if (getIt.isRegistered<FlutterLocalNotificationsPlugin>()) {
      getIt.unregister<FlutterLocalNotificationsPlugin>();
    }
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }

    // Setup mocks
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidFlutterLocalNotificationsPlugin =
        MockAndroidFlutterLocalNotificationsPlugin();
    mockPrefs = MockSharedPreferences();

    // register mockFirebaseMessaging and mockFlutterLocalNotificationsPlugin
    getIt.registerSingleton<FirebaseMessaging>(mockFirebaseMessaging);
    getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
        mockFlutterLocalNotificationsPlugin);
    getIt.registerSingleton<SharedPreferences>(mockPrefs);
  });

  setUp(() async {
    // Inisialisasi timezone untuk unit testing
    try {
      tz.initializeTimeZones();
    } catch (_) {
      // Timezone sudah diinisialisasi, abaikan error
    }

    // Reset semua mock
    reset(mockFirebaseMessaging);
    reset(mockFlutterLocalNotificationsPlugin);
    reset(mockAndroidFlutterLocalNotificationsPlugin);

    // Setup return values untuk mockFlutterLocalNotificationsPlugin
    when(() => mockFlutterLocalNotificationsPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
        )).thenAnswer((_) async => true);

    when(() => mockFlutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidFlutterLocalNotificationsPlugin);

    when(() => mockAndroidFlutterLocalNotificationsPlugin
        .createNotificationChannel(any())).thenAnswer((_) async {});

    when(() => mockFlutterLocalNotificationsPlugin.cancelAll())
        .thenAnswer((_) async {});

    when(() => mockFlutterLocalNotificationsPlugin.cancel(any()))
        .thenAnswer((_) async {});

    when(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          uiLocalNotificationDateInterpretation:
              any(named: 'uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    when(() => mockFlutterLocalNotificationsPlugin.show(
          any(),
          any(),
          any(),
          any(),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    // Setup NotificationService untuk pengujian
    notificationService = NotificationServiceImpl();

    await notificationService.initialize();
  });

  group('NotificationService Tests', () {
    test('cancelAllNotifications should call plugin.cancelAll', () async {
      // Act

      await notificationService.cancelAllNotifications();

      // Assert
      verify(() => mockFlutterLocalNotificationsPlugin.cancelAll()).called(1);
    });

    test('cancelNotification should call plugin.cancel with correct hash',
        () async {
      // Arrange
      const String notificationId = 'test-id';

      // Act
      await notificationService.cancelNotification(notificationId);

      // Assert
      verify(() => mockFlutterLocalNotificationsPlugin
          .cancel(notificationId.hashCode)).called(1);
    });

    test('mocks are properly registered', () {
      expect(getIt<FirebaseMessaging>(), equals(mockFirebaseMessaging));
      expect(getIt<FlutterLocalNotificationsPlugin>(),
          equals(mockFlutterLocalNotificationsPlugin));
    });

    test('initialize should request permission and setup notifications',
        () async {
      // Assert
      verify(() => mockFlutterLocalNotificationsPlugin.initialize(
            any(),
            onDidReceiveNotificationResponse:
                any(named: 'onDidReceiveNotificationResponse'),
          )).called(1);

      verify(() => mockAndroidFlutterLocalNotificationsPlugin
          .createNotificationChannel(any())).called(4);
    });
  });

  group("test local notification", () {
    test('scheduleLocalNotification should schedule notification correctly',
        () async {
      // Arrange
      final now = DateTime.now();
      final scheduledTime = now.add(const Duration(minutes: 1));

      final notification = NotificationModel(
        id: 'test-notification',
        title: 'Test Title',
        body: 'Test Body',
        payload: 'test_payload',
        scheduledTime: scheduledTime,
      );

      final channel = const AndroidNotificationChannel(
        'test_channel',
        'Test Channel',
        description: 'Test Channel Description',
        importance: Importance.high,
      );

      // Act
      await notificationService.scheduleLocalNotification(
          notification, channel);

      // Assert
      verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(), // id.hashCode bisa berbeda
            'Test Title',
            'Test Body',
            any(), // waktu akan berbeda
            any(), // NotificationDetails bisa berbeda
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'test_payload',
          )).called(1);
    });

    test('scheduleLocalNotification should use correct timezone', () async {
      // Arrange
      final now = DateTime.now();
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        10, // set specific hour
        30, // set specific minute
      );

      final notification = NotificationModel(
        id: 'test-notification',
        title: 'Test Title',
        body: 'Test Body',
        payload: 'test_payload',
        scheduledTime: scheduledTime,
      );

      final channel = const AndroidNotificationChannel(
        'test_channel',
        'Test Channel',
        description: 'Test Channel Description',
        importance: Importance.high,
      );

      // Act
      await notificationService.scheduleLocalNotification(
          notification, channel);

      // Assert
      verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(
                that: predicate((tz.TZDateTime time) =>
                    time.isUtc ==
                    tz.TZDateTime.from(time, tz.getLocation('Asia/Jakarta'))
                        .isUtc)),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation:
                any(named: 'uiLocalNotificationDateInterpretation'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            payload: any(named: 'payload'),
          )).called(1);
    });
  });

  group('test firebase notification', () {
    test(
        'showNotificationFromFirebase should show notification when data valid',
        () async {
      // Arrange
      final mockRemoteNotification = MockRemoteNotification();
      final mockAndroidNotification = MockAndroidNotification();
      final mockRemoteMessage = MockRemoteMessage();

      // Setup mock values
      when(() => mockRemoteMessage.notification)
          .thenAnswer((_) => mockRemoteNotification);
      when(() => mockRemoteNotification.android)
          .thenReturn(mockAndroidNotification);
      when(() => mockRemoteNotification.title).thenReturn('Test Title');
      when(() => mockRemoteNotification.body).thenReturn('Test Body');
      when(() => mockRemoteMessage.data)
          .thenReturn({'payload': 'test_payload'});

      // Act
      await notificationService.showNotificationFromFirebase(mockRemoteMessage);

      // Assert
      verify(() => mockFlutterLocalNotificationsPlugin.show(
            0,
            'Test Title',
            'Test Body',
            any(),
            payload: 'test_payload',
          )).called(1);
    });

    test('showNotificationFromFirebase should handle null notification data',
        () async {
      // Arrange
      final mockMessage = MockRemoteMessage();
      when(() => mockMessage.notification).thenReturn(null);

      // Act
      await notificationService.showNotificationFromFirebase(mockMessage);

      // Assert
      verifyNever(() => mockFlutterLocalNotificationsPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ));
    });

    test('showNotificationFromFirebase should handle null android notification',
        () async {
      // Arrange
      final mockRemoteNotification = MockRemoteNotification();
      final mockMessage = MockRemoteMessage();

      when(() => mockMessage.notification).thenReturn(mockRemoteNotification);
      when(() => mockMessage.notification?.android).thenReturn(null);

      // Act
      await notificationService.showNotificationFromFirebase(mockMessage);

      // Assert
      verifyNever(() => mockFlutterLocalNotificationsPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ));
    });
  });

  group('Notification Toggle Tests', () {
    test('toggleNotification should enable notification correctly', () async {
      // Arrange
      const String channelId = 'calories_reminder_channel';
      const String channelId2 = 'workout_reminder_channel';
      when(() => mockPrefs.setBool('notification_status_$channelId', true))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.getBool('notification_status_$channelId'))
          .thenReturn(true);

      // Act
      await notificationService.toggleNotification(channelId, true);

      // Assert
      verify(() => mockPrefs.setBool('notification_status_$channelId', true))
          .called(1);
      verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            'Waktu Tracking Kalori!',
            'Jangan lupa untuk mencatat asupan kalori hari ini',
            any(),
            any(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'daily_calorie_tracking',
          )).called(1);

      reset(mockPrefs);
      when(() => mockPrefs.setBool('notification_status_$channelId2', true))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.getBool('notification_status_$channelId2'))
          .thenReturn(true);

      // Act
      await notificationService.toggleNotification(channelId2, true);

      // Assert
      verify(() => mockPrefs.setBool('notification_status_$channelId2', true))
          .called(1);
      verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            'Waktunya Workout!',
            'Jangan lewatkan sesi workout hari ini',
            any(),
            any(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'daily_workout',
          )).called(1);
    });

    test('toggleNotification should disable notification correctly', () async {
      // Arrange
      const String channelId = 'calories_reminder_channel';
      when(() => mockPrefs.setBool('notification_status_$channelId', false))
          .thenAnswer((_) async => true);

      // Act
      await notificationService.toggleNotification(channelId, false);

      // Assert
      verify(() => mockPrefs.setBool('notification_status_$channelId', false))
          .called(1);
      verify(() =>
              mockFlutterLocalNotificationsPlugin.cancel('daily_calorie_reminder'.hashCode))
          .called(1);

      reset(mockPrefs);
      const String channelId2 = 'workout_reminder_channel';
      when(() => mockPrefs.setBool('notification_status_$channelId2', false))
          .thenAnswer((_) async => true);

      // Act
      await notificationService.toggleNotification(channelId2, false);

      // Assert
      verify(() => mockPrefs.setBool('notification_status_$channelId2', false))
          .called(1);
      verify(() =>
              mockFlutterLocalNotificationsPlugin.cancel('daily_workout_reminder'.hashCode))
          .called(1);
    });

    test('isNotificationEnabled should return correct status', () async {
      // Arrange
      reset(mockPrefs);
      const String channelId = 'calories_reminder_channel';
      when(() => mockPrefs.getBool('notification_status_$channelId'))
          .thenReturn(true);

      
      // Act
      final result = await notificationService.isNotificationEnabled(channelId);

      // Assert
      expect(result, true);
      verify(() => mockPrefs.getBool('notification_status_$channelId')).called(1);
    });

    test('isNotificationEnabled should return false when no status saved', () async {
      // Arrange
      reset(mockPrefs);
      const String channelId = 'calories_reminder_channel';
      when(() => mockPrefs.getBool('notification_status_$channelId'))
          .thenReturn(null);
      
      // Act
      final result = await notificationService.isNotificationEnabled(channelId);

      // Assert
      expect(result, false);
      verify(() => mockPrefs.getBool('notification_status_$channelId')).called(1);
    });

    test('_setupDefaultRecurringNotifications should schedule enabled notifications only',
        () async {
      // Arrange
      when(() => mockPrefs.getBool('notification_status_calories_reminder_channel'))
          .thenReturn(true);
      when(() => mockPrefs.getBool('notification_status_workout_reminder_channel'))
          .thenReturn(false);

      // Re-initialize service to trigger _setupDefaultRecurringNotifications
      await notificationService.initialize();

      // Assert
      // Verify calories reminder was scheduled
      verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            'Waktu Tracking Kalori!',
            'Jangan lupa untuk mencatat asupan kalori hari ini',
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation:
                any(named: 'uiLocalNotificationDateInterpretation'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            payload: 'daily_calorie_tracking',
          )).called(1);

      // Verify workout reminder was not scheduled
      verifyNever(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            'Waktunya Workout!',
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation:
                any(named: 'uiLocalNotificationDateInterpretation'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            payload: 'daily_workout',
          ));
    });
  });
}
