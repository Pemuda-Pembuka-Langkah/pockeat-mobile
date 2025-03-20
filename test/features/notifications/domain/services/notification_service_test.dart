import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

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


void main() {
  late NotificationService notificationService;
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin
      mockAndroidFlutterLocalNotificationsPlugin;

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

    // Setup mocks
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidFlutterLocalNotificationsPlugin =
        MockAndroidFlutterLocalNotificationsPlugin();

    // register mockFirebaseMessaging and mockFlutterLocalNotificationsPlugin
    getIt.registerSingleton<FirebaseMessaging>(mockFirebaseMessaging);
    getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
        mockFlutterLocalNotificationsPlugin);
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
    notificationService = NotificationService();

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

    test(
        'scheduleDailyCalorieReminder should create appropriate notification model',
        () async {
      // Arrange
      final timeOfDay = const TimeOfDay(hour: 10, minute: 0);

      // Act
      await notificationService.scheduleDailyCalorieReminder(
          timeOfDay: timeOfDay);

      // Assert - verify internal call with notification having correct properties
      verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            'Pengingat Kalori Harian', // Expected title
            'Jangan lupa untuk melacak asupan kalori hari ini!', // Expected body
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation:
                any(named: 'uiLocalNotificationDateInterpretation'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            payload: 'daily_calorie_tracking', // Expected payload
          )).called(1);
    });

    test('scheduleDailyRecurringReminder creates recurring notification',
        () async {
      // Arrange
      final timeOfDay = const TimeOfDay(hour: 10, minute: 0);

      // Act
      await notificationService.scheduleDailyRecurringReminder(
          timeOfDay: timeOfDay);

      // Assert
      verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: any(named: 'payload'),
          )).called(1);
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
          .createNotificationChannel(any())).called(1);
    });

    test('showLocalNotification should show notification with correct details', () async {
      // Arrange
      final mockRemoteMessage = MockRemoteMessage();
      final mockRemoteNotification = MockRemoteNotification();
      final mockAndroidNotification = MockAndroidNotification();
      
      when(() => mockRemoteMessage.notification).thenAnswer((_) => mockRemoteNotification);
      when(() => mockRemoteNotification.android).thenReturn(mockAndroidNotification);
      when(() => mockRemoteNotification.title).thenReturn('Test Title');
      when(() => mockRemoteNotification.body).thenReturn('Test Body');
      when(() => mockRemoteMessage.data).thenReturn({'payload': 'test_payload'});
      
      // Act
      await notificationService.showLocalNotification(mockRemoteMessage);
      
      // Assert
      verify(() => mockFlutterLocalNotificationsPlugin.show(
            0,
            'Test Title',
            'Test Body',
            any(),
            payload: 'test_payload',
          )).called(1);
    });
    
    test('showLocalNotification should not show notification when notification is null', () async {
      // Arrange
      final mockRemoteMessage = MockRemoteMessage();
      
      when(() => mockRemoteMessage.notification).thenReturn(null);
      when(() => mockRemoteMessage.data).thenReturn({'payload': 'test_payload'});
      
      // Act
      await notificationService.showLocalNotification(mockRemoteMessage);
      
      // Assert
      verifyNever(() => mockFlutterLocalNotificationsPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ));
    });
    
    test('showLocalNotification should not show notification when android is null', () async {
      // Arrange
      final mockRemoteMessage = MockRemoteMessage();
      final mockRemoteNotification = MockRemoteNotification();
      
      when(() => mockRemoteMessage.notification).thenReturn(mockRemoteNotification);
      when(() => mockRemoteNotification.android).thenReturn(null);
      when(() => mockRemoteNotification.title).thenReturn('Test Title');
      when(() => mockRemoteNotification.body).thenReturn('Test Body');
      
      // Act
      await notificationService.showLocalNotification(mockRemoteMessage);
      
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
}
