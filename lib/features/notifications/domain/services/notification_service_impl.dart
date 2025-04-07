import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';

class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging _firebaseMessaging = getIt<FirebaseMessaging>();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      getIt<FlutterLocalNotificationsPlugin>();

  NotificationServiceImpl() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  @override
  Future<void> initialize() async {
    // Request permission untuk notifikasi
    await _requestPermission();

    // Inisialisasi local notifications
    await _initializeLocalNotifications();

    // Create notification channel for Android
    await _createNotificationChannel(NotificationChannels.caloriesReminder);
    await _createNotificationChannel(NotificationChannels.workoutReminder);
    await _createNotificationChannel(NotificationChannels.subscription);
    await _createNotificationChannel(NotificationChannels.server);

    // Set up handler untuk FCM
    _setupFCMHandlers();
  }

  @override
  Future<void> showNotificationFromFirebase(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title ?? '',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationChannels.server.id,
            NotificationChannels.server.name,
            channelDescription: NotificationChannels.server.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['payload'],
      );
    }
  }

  @override
  Future<void> scheduleLocalNotification(NotificationModel notification,
      AndroidNotificationChannel channel) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id.hashCode,
      notification.title,
      notification.body,
      nextInstanceOfTime(notification.scheduledTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: notification.payload,
    );
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }

  // Fungsi helper untuk mendapatkan next instance dari jadwal
  tz.TZDateTime nextInstanceOfTime(DateTime scheduledTime) {
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    return tz.TZDateTime.from(scheduledDate, tz.getLocation('Asia/Jakarta'));
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _createNotificationChannel(
      AndroidNotificationChannel channel) async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Setup handler untuk Firebase Cloud Messaging
  void _setupFCMHandlers() {
    // Ketika aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotificationFromFirebase(message);
    });
  }

  void _onNotificationTapped(NotificationResponse details) {
    // Handle notifikasi tap berdasarkan payload
    if (details.payload == 'daily_calorie_tracking') {
      // TODO: Implementasi navigasi ke halaman tracking kalori
    }
  }
}
