import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service_impl.dart';
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
}
