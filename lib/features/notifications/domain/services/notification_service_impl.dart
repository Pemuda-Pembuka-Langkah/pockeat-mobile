import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging _firebaseMessaging = getIt<FirebaseMessaging>();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      getIt<FlutterLocalNotificationsPlugin>();
  final SharedPreferences _prefs = getIt<SharedPreferences>();

  // Konstanta untuk key SharedPreferences
  static const String _prefixNotificationStatus = 'notification_status_';

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

    // Jadwalkan notifikasi default
    await _setupDefaultRecurringNotifications();
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
    if (details.payload == 'daily_calorie_tracking') {}
  }

  @override
  Future<void> toggleNotification(String channelId, bool enabled) async {
    // Simpan status notifikasi ke SharedPreferences
    await _prefs.setBool('$_prefixNotificationStatus$channelId', enabled);

    if (enabled) {
      // Jika diaktifkan, jadwalkan ulang notifikasi
      await _setupNotificationByChannel(channelId);
    } else {
      // Jika dinonaktifkan, batalkan notifikasi yang terkait
      await cancelNotificationsByChannel(channelId);
    }
  }

  @override
  Future<bool> isNotificationEnabled(String channelId) async {
    return _prefs.getBool('$_prefixNotificationStatus$channelId') ?? false;
  }

  Future<void> _setupNotificationByChannel(String channelId) async {
    switch (channelId) {
      case 'calories_reminder_channel':
        final calorieReminder = NotificationModel(
          id: 'daily_calorie_reminder',
          title: 'Waktu Tracking Kalori!',
          body: 'Jangan lupa untuk mencatat asupan kalori hari ini',
          scheduledTime: DateTime(2024, 1, 1, 8, 0),
          payload: 'daily_calorie_tracking',
        );
        await scheduleLocalNotification(
            calorieReminder, NotificationChannels.caloriesReminder);
        break;

      case 'workout_reminder_channel':
        final workoutReminder = NotificationModel(
          id: 'daily_workout_reminder',
          title: 'Waktunya Workout!',
          body: 'Jangan lewatkan sesi workout hari ini',
          scheduledTime: DateTime(2024, 1, 1, 8, 0),
          payload: 'daily_workout',
        );
        await scheduleLocalNotification(
            workoutReminder, NotificationChannels.workoutReminder);
        break;
    }
  }

  Future<void> cancelNotificationsByChannel(String channelId) async {
    switch (channelId) {
      case 'calories_reminder_channel':
        await cancelNotification('daily_calorie_reminder');
        break;
      case 'workout_reminder_channel':
        await cancelNotification('daily_workout_reminder');
        break;
    }
  }

  Future<void> _setupDefaultRecurringNotifications() async {
    // Cek status notifikasi sebelum menjadwalkan
    final isCaloriesEnabled =
        await isNotificationEnabled('calories_reminder_channel');
    final isWorkoutEnabled =
        await isNotificationEnabled('workout_reminder_channel');

    if (isCaloriesEnabled) {
      await _setupNotificationByChannel('calories_reminder_channel');
    }

    if (isWorkoutEnabled) {
      await _setupNotificationByChannel('workout_reminder_channel');
    }
  }
}
