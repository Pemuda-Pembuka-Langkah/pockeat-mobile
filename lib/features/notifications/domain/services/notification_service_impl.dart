// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pockeat/features/notifications/domain/services/utils/work_manager_client.dart';
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart' show getIt, setupDependencies;
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';
import 'package:pockeat/features/notifications/domain/model/streak_message.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';

class NotificationServiceImpl implements NotificationService {
  static const String _prefixNotificationStatus = 'notification_status_';
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final SharedPreferences _prefs;
  final FoodLogHistoryService _foodLogHistoryService;
  final LoginService _loginService;
  final WorkManagerClient _workManagerClient;
  

  // Background task identifier for streak calculation
  static const String _streakCalculationTask = 'streak_calculation_task';
  // Default time for streak notification (10:00 AM)
  static const TimeOfDay _defaultStreakNotificationTime = TimeOfDay(hour: 10, minute: 0);

  NotificationServiceImpl({
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin,
    SharedPreferences? prefs,
    FoodLogHistoryService? foodLogHistoryService,
    LoginService? loginService,
    WorkManagerClient? workManagerClient,
  }) : _firebaseMessaging = firebaseMessaging ?? getIt<FirebaseMessaging>(),
       _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin ?? getIt<FlutterLocalNotificationsPlugin>(),
       _prefs = prefs ?? getIt<SharedPreferences>(),
       _foodLogHistoryService = foodLogHistoryService ?? getIt<FoodLogHistoryService>(),
       _loginService = loginService ?? getIt<LoginService>(),
       _workManagerClient = workManagerClient ?? WorkManagerClient() {
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
    await _createNotificationChannel(NotificationChannels.mealReminder);
    await _createNotificationChannel(NotificationChannels.workoutReminder);
    await _createNotificationChannel(NotificationChannels.subscription);
    await _createNotificationChannel(NotificationChannels.server);
    await _createNotificationChannel(NotificationChannels.dailyStreak);
    // Set up handler untuk FCM
    _setupFCMHandlers();
    
    // Initialize WorkManager
    await _initializeWorkManager();

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
    
    // Cancel all WorkManager tasks
    await _workManagerClient.cancelAll();
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

  void _onNotificationTapped(NotificationResponse details) async {
    // Handle notifikasi tap berdasarkan payload
    if (details.payload == 'daily_calorie_tracking') {
      // Arahkan ke halaman tracking makanan
      final deepLinkService = getIt<DeepLinkService>();
      await deepLinkService.handleDeepLink(
        Uri.parse('pockeat://quick-log')
      );
    } else if (details.payload == 'streak_celebration') {
      final userId = (await _loginService.getCurrentUser())?.uid;
      if (userId == null) return;
      
      // Hitung streak terbaru secara real-time saat notifikasi di-tap
      final currentStreakDays = await _foodLogHistoryService.getFoodStreakDays(userId);
      
      // Buat URI dengan parameter streak days
      final streakUri = Uri.parse('pockeat://streak-celebration?streakDays=$currentStreakDays');
      
      // Gunakan DeepLinkService untuk navigasi ke halaman streak celebration
      final deepLinkService = getIt<DeepLinkService>();
      await deepLinkService.handleDeepLink(streakUri);
    }
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
            calorieReminder, NotificationChannels.mealReminder);
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

      case 'daily_streak_channel':
        // For streak channel, we'll use WorkManager to schedule the background task
        // that calculates streak at the time of notification
        await _scheduleStreakNotification();
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
      case 'daily_streak_channel':
        await cancelNotification('daily_streak_channel');
        // Also cancel the WorkManager task for streak notifications
        if (channelId == 'daily_streak_channel') {
          await _workManagerClient.cancelByUniqueName(_streakCalculationTask);
        }
        break;
    }
  }

  // Initialize WorkManager for background tasks
  Future<void> _initializeWorkManager() async {
    await _workManagerClient.initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );
  }
  
  Future<void> _setupDefaultRecurringNotifications() async {
    // Cek status notifikasi sebelum menjadwalkan
    final isCaloriesEnabled =
        await isNotificationEnabled('calories_reminder_channel');
    final isWorkoutEnabled =
        await isNotificationEnabled('workout_reminder_channel');
    final isStreakEnabled = await isNotificationEnabled('daily_streak_channel');

    if (isCaloriesEnabled) {
      await _setupNotificationByChannel('calories_reminder_channel');
    }

    if (isWorkoutEnabled) {
      await _setupNotificationByChannel('workout_reminder_channel');
    }

    if (isStreakEnabled) {
      await _setupNotificationByChannel('daily_streak_channel');
    }
  }
  
  // Schedule the streak notification background task
  Future<void> _scheduleStreakNotification() async {
    // Get user's preferred notification time (or use default)
    final preferredTimeString = _prefs.getString('streak_notification_time');
    TimeOfDay notificationTime = _defaultStreakNotificationTime;
    
    if (preferredTimeString != null) {
      final timeParts = preferredTimeString.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          notificationTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
    
    // Calculate the initial delay to the scheduled time
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );
    // If the scheduled time for today has already passed, schedule for tomorrow
    final initialDelay = scheduledTime.isAfter(now) 
        ? scheduledTime.difference(now) 
        : scheduledTime.add(const Duration(days: 1)).difference(now);
    
    // Cancel any existing tasks
    await _workManagerClient.cancelByUniqueName(_streakCalculationTask);
    
    // Schedule the daily task
    await _workManagerClient.registerPeriodicTask(
      _streakCalculationTask,
      'Daily Streak Calculation',
      frequency: const Duration(days: 1),
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
  
  // Show streak notification with real-time streak data
  Future<void> showStreakNotification() async {
    try {
      // First check if streak notifications are enabled
      final isStreakEnabled = await isNotificationEnabled('daily_streak_channel');
      if (!isStreakEnabled) {
        // Notifications are disabled, don't show anything
        // Consider also canceling future WorkManager tasks here
        await _workManagerClient.cancelByUniqueName(_streakCalculationTask);
        return;
      }
      
      final userId = (await _loginService.getCurrentUser())?.uid;
      if (userId == null) return;
      
      // Calculate streak in real-time when notification is about to be shown
      final streakDays = await _foodLogHistoryService.getFoodStreakDays(userId);
      
      // Only show notification if there's an active streak
      if (streakDays > 0) {
        // Create appropriate message based on streak count
        final streakMessage = StreakMessageFactory.createMessage(streakDays);
        
        // Create and show notification immediately with panda image
        final BigPictureStyleInformation bigPictureStyleInformation =
            BigPictureStyleInformation(
          const DrawableResourceAndroidBitmap('panda_happy_notif'),
          largeIcon: const DrawableResourceAndroidBitmap('panda_happy_notif'),
          contentTitle: streakMessage.title,
          summaryText: streakMessage.body,
          htmlFormatContent: true,
          htmlFormatContentTitle: true,
        );
        
        await _flutterLocalNotificationsPlugin.show(
          'streak_celebration'.hashCode,
          streakMessage.title,
          streakMessage.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationChannels.dailyStreak.id,
              NotificationChannels.dailyStreak.name,
              channelDescription: NotificationChannels.dailyStreak.description,
              icon: '@mipmap/ic_launcher',
              styleInformation: bigPictureStyleInformation,
              playSound: true,
              priority: Priority.high,
              importance: Importance.high,
            ),
          ),
          payload: 'streak_celebration',
        );
      }
    } catch (e) {
      debugPrint('Error showing streak notification: $e');
    }
  }
}

// WorkManager callback dispatcher - must be top-level or static
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Initialize service locator
    await setupDependencies();
    
    // Get notification service
    final notificationService = getIt<NotificationService>() as NotificationServiceImpl;
    
    if (taskName == NotificationServiceImpl._streakCalculationTask) {
      // Show streak notification with real-time streak data
      await notificationService.showStreakNotification();
    }
    
    return true;
  });
}
