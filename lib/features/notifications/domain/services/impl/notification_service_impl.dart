
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart' show getIt;
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/notifications/domain/services/utils/work_manager_client.dart';

// Project imports:

// coverage:ignore-start
class NotificationServiceImpl implements NotificationService {
  // Using constants from NotificationConstants instead of hardcoded strings
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final SharedPreferences _prefs;
  final FoodLogHistoryService _foodLogHistoryService;
  final LoginService _loginService;
  final WorkManagerClient _workManagerClient;

  // Using background task identifier from NotificationConstants
  // Using default time from NotificationConstants

  NotificationServiceImpl({
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin,
    SharedPreferences? prefs,
    FoodLogHistoryService? foodLogHistoryService,
    LoginService? loginService,
    WorkManagerClient? workManagerClient,
  })  : _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin ??
            getIt<FlutterLocalNotificationsPlugin>(),
        _prefs = prefs ?? getIt<SharedPreferences>(),
        _foodLogHistoryService =
            foodLogHistoryService ?? getIt<FoodLogHistoryService>(),
        _loginService = loginService ?? getIt<LoginService>(),
        _workManagerClient = workManagerClient ?? WorkManagerClient() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  @override
  Future<void> initialize() async {
    // Inisialisasi local notifications (tanpa request permission)
    // Permission sudah ditangani oleh PermissionService
    await _initializeLocalNotifications();
    // Create notification channel for Android
    await _createNotificationChannel(NotificationChannels.server);
    await _createNotificationChannel(NotificationChannels.dailyStreak);
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
            icon: '@mipmap/launcher_icon',
          ),
        ),
        payload: message.data['payload'],
      );
    }
  }

  @override
  Future<void> scheduleLocalNotification(NotificationModel notification,
      AndroidNotificationChannel channel) async {
    // For daily streak notifications, use the dedicated method
    if (channel.id == NotificationConstants.dailyStreakChannelId) {
      await _scheduleStreakNotification();
    }
    // Other notification types are not implemented at this time
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
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Metode _requestPermission dihapus karena permission handling dipindahkan ke PermissionService

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
    if (details.payload == NotificationConstants.dailyStreakPayload) {
      final userId = (await _loginService.getCurrentUser())?.uid;
      if (userId == null) return;

      // Hitung streak terbaru secara real-time saat notifikasi di-tap
      final currentStreakDays =
          await _foodLogHistoryService.getFoodStreakDays(userId);

      // Use platform channel to launch a native Android intent with the deeplink
      // This will be caught by the OS and redirected to our app, triggering the
      // deeplink handler in main.dart
      final deepLinkUri =
          'pockeat://streak-celebration?streakDays=$currentStreakDays';

      // Create a platform channel for launching URIs
      const platformChannel = MethodChannel('com.pockeat/notification_actions');

      // Call the native method to open the URI
      await platformChannel.invokeMethod('launchUri', {
        'uri': deepLinkUri,
      });
    }
  }

  @override
  Future<void> toggleNotification(String channelId, bool enabled) async {
    // We're focusing only on daily streak notifications
    if (channelId == NotificationConstants.dailyStreakChannelId) {
      // Always cancel existing notifications first to avoid duplicates
      debugPrint("Canceling existing notification for channel: $channelId");
      await cancelNotificationsByChannel(channelId);

      // Save notification status to SharedPreferences
      await _prefs.setBool(
          NotificationConstants.prefDailyStreakEnabled, enabled);

      if (enabled) {
        // Schedule notification if enabled
        debugPrint("Setting up notification for channel: $channelId");
        await _setupNotificationByChannel(channelId);
      }
    }
  }

  @override
  Future<bool> isNotificationEnabled(String channelId) async {
    // For daily streak notifications, default to true if key doesn't exist
    if (channelId == NotificationConstants.dailyStreakChannelId) {
      // If key doesn't exist, create it with default value true
      if (!_prefs.containsKey(NotificationConstants.prefDailyStreakEnabled)) {
        await _prefs.setBool(
            NotificationConstants.prefDailyStreakEnabled, true);
        return true;
      }
      return _prefs.getBool(NotificationConstants.prefDailyStreakEnabled) ??
          true;
    }

    // For other notification types, default to false
    final key = NotificationConstants.getNotificationStatusKey(channelId);
    return _prefs.getBool(key) ?? false;
  }

  Future<void> _setupNotificationByChannel(String channelId) async {
    // We're focusing only on daily streak notifications
    if (channelId == NotificationConstants.dailyStreakChannelId) {
      // For streak channel, we use WorkManager to schedule the background task
      // that calculates streak at the time of notification
      debugPrint("Setting up daily streak notification");
      await _scheduleStreakNotification();
    }
    // Other notification types are not implemented at this time
  }

  Future<void> cancelNotificationsByChannel(String channelId) async {
    // We're focusing only on daily streak notifications
    if (channelId == NotificationConstants.dailyStreakChannelId) {
      await cancelNotification(NotificationConstants.dailyStreakNotificationId);
      // Also cancel the WorkManager task for streak notifications
      await _workManagerClient
          .cancelByUniqueName(NotificationConstants.streakCalculationTaskName);
    }
    // Other notification types are not implemented at this time
  }

  Future<void> _setupDefaultRecurringNotifications() async {
    // We're focusing only on daily streak notifications and making them enabled by default
    final isStreakEnabled =
        await isNotificationEnabled(NotificationConstants.dailyStreakChannelId);

    debugPrint("isStreakEnabled: $isStreakEnabled");
    if (isStreakEnabled) {
      debugPrint("Setting up daily streak notification");
      await _setupNotificationByChannel(
          NotificationConstants.dailyStreakChannelId);
    }
  }

  // Schedule the streak notification background task
  Future<void> _scheduleStreakNotification() async {
    // Get user's preferred notification time (or use default)
    debugPrint("Getting notification time");
    final hour = _prefs.getInt(NotificationConstants.prefDailyStreakHour);
    final minute = _prefs.getInt(NotificationConstants.prefDailyStreakMinute);
    // Use stored time or default
    TimeOfDay notificationTime = const TimeOfDay(
        hour: NotificationConstants.defaultStreakNotificationHour,
        minute: NotificationConstants.defaultStreakNotificationMinute);
    if (hour != null && minute != null) {
      notificationTime = TimeOfDay(hour: hour, minute: minute);
    }
    debugPrint(
        "Notification time: ${notificationTime.hour}:${notificationTime.minute}");

    // Calculate the initial delay to the scheduled time
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );
    debugPrint("Scheduled time: ${scheduledTime.hour}:${scheduledTime.minute}");
    // If the scheduled time for today has already passed, schedule for tomorrow
    final initialDelay = scheduledTime.isAfter(now)
        ? scheduledTime.difference(now)
        : scheduledTime.add(const Duration(days: 1)).difference(now);

    // Cancel any existing tasks
    await _workManagerClient
        .cancelByUniqueName(NotificationConstants.streakCalculationTaskName);
    debugPrint("Cancelled existing streak calculation task");

    // Schedule the daily task - make sure task name and unique name match exactly
    await _workManagerClient.registerPeriodicTask(
      NotificationConstants.streakCalculationTaskName, // Unique name
      NotificationConstants
          .streakCalculationTaskName, // Task name (must match exactly)
      frequency: const Duration(days: 1),
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    debugPrint(
        "Scheduled streak calculation task with name: ${NotificationConstants.streakCalculationTaskName}");
  }
}
// coverage:ignore-end
