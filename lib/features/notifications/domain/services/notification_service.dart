import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:pockeat/core/di/service_locator.dart';


class NotificationService {
  final FirebaseMessaging _firebaseMessaging = getIt<FirebaseMessaging>();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      getIt<FlutterLocalNotificationsPlugin>();

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  // Android notification channel
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'calories_reminder_channel',
    'Pengingat Kalori Harian',
    description: 'Channel untuk mengirim pengingat tentang pelacakan kalori harian',
    importance: Importance.high,
  );

  // Method untuk inisialisasi notifikasi
  Future<void> initialize() async {
    // Request permission untuk notifikasi
    await _requestPermission();

    // Inisialisasi local notifications
    await _initializeLocalNotifications();

    // Set up handler untuk FCM
    _setupFCMHandlers();
  }

  // Request permission notification
  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Inisialisasi local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  // Handler ketika notifikasi di-tap
  void _onNotificationTapped(NotificationResponse details) {
    // Handle notifikasi tap berdasarkan payload
    if (details.payload == 'daily_calorie_tracking') {
      // TODO: Implementasi navigasi ke halaman tracking kalori
    }
  }

  // Setup handler untuk Firebase Cloud Messaging
  void _setupFCMHandlers() {
    // Ketika aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(message);
    });

    // Ketika aplikasi dibuka dari notifikasi (saat aplikasi di background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle tapped notification when app is in background
      _handleNotificationPayload(message.data['payload']);
    });
  }

  // Menampilkan notifikasi lokal
  Future<void> showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title ?? '',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['payload'],
      );
    }
  }

  // Handler untuk payload notifikasi
  void _handleNotificationPayload(String? payload) {
    if (payload == 'daily_calorie_tracking') {
      // TODO: Implementasi navigasi ke halaman tracking kalori
    }
  }

  // Schedule pengingat kalori harian
  Future<void> scheduleDailyCalorieReminder({
    required TimeOfDay timeOfDay,
  }) async {
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final NotificationModel notification = NotificationModel.dailyCalorieReminder(
      scheduledTime: scheduledDate,
    );

    await _scheduleLocalNotification(notification);
  }

  // Schedule notifikasi lokal
  Future<void> _scheduleLocalNotification(NotificationModel notification) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id.hashCode,
      notification.title,
      notification.body,
      _nextInstanceOfTime(notification.scheduledTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
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

  // Jadwalkan notifikasi berulang setiap hari
  Future<void> scheduleDailyRecurringReminder({
    required TimeOfDay timeOfDay,
  }) async {
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final NotificationModel notification = NotificationModel.dailyCalorieReminder(
      scheduledTime: scheduledDate,
    );

    await _scheduleRecurringLocalNotification(notification);
  }

  // Schedule notifikasi berulang lokal
  Future<void> _scheduleRecurringLocalNotification(NotificationModel notification) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id.hashCode,
      notification.title,
      notification.body,
      _nextInstanceOfTime(notification.scheduledTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
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

  // Fungsi helper untuk mendapatkan next instance dari jadwal
  tz.TZDateTime _nextInstanceOfTime(DateTime scheduledTime) {
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return tz.TZDateTime.from(scheduledDate, tz.getLocation('Asia/Jakarta'));
  }

  // Batalkan semua notifikasi
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Batalkan notifikasi spesifik
  Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }
} 