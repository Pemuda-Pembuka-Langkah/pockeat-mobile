
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
  final LoginService _loginService;
  final FoodLogHistoryService _foodLogHistoryService;
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
        _loginService = loginService ?? getIt<LoginService>(),
        _foodLogHistoryService = foodLogHistoryService ?? getIt<FoodLogHistoryService>(),
        _workManagerClient = workManagerClient ?? WorkManagerClient() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  @override
  Future<void> initialize() async {
    // Inisialisasi local notifications (tanpa request permission)
    // Permission sudah ditangani oleh PermissionService
    await _initializeLocalNotifications();
    // Create notification channels for Android
    await _createNotificationChannel(NotificationChannels.server);
    await _createNotificationChannel(NotificationChannels.mealReminder);
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
      onDidReceiveNotificationResponse: _onNotificationTapped
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
    // Handle meal reminder notification tap
    else if (details.payload == NotificationConstants.mealReminderPayload) {
      // Create a deeplink that will navigate to the food log entry screen using quickLog format
      // Format must match _isQuickLogLink method in DeepLinkServiceImpl
      const deepLinkUri = 'pockeat://?widgetName=mealReminder&type=log';
      
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
    // Handle daily streak notifications
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
    // Handle master meal reminder toggle
    else if (channelId == NotificationConstants.mealReminderChannelId) {
      // Always cancel existing notifications first to avoid duplicates
      debugPrint("Toggling master meal reminder setting: $enabled");
      await cancelNotificationsByChannel(channelId);

      // Save master notification status to SharedPreferences
      await _prefs.setBool(
          NotificationConstants.prefMealReminderMasterEnabled, enabled);

      if (enabled) {
        // Schedule meal reminders if master setting is enabled
        // (individual meal types will only be scheduled if their own toggle is enabled)
        debugPrint("Setting up meal reminder notifications");
        await _setupNotificationByChannel(channelId);
      }
    }
    // Handle individual meal type toggles
    else if (channelId == NotificationConstants.breakfast ||
             channelId == NotificationConstants.lunch ||
             channelId == NotificationConstants.dinner) {
      // Get the corresponding preference key for this meal type
      final prefKey = NotificationConstants.getMealTypeEnabledKey(channelId);
      
      // Save individual meal type status
      debugPrint("Toggling $channelId reminder: $enabled");
      await _prefs.setBool(prefKey, enabled);
      
      // Cancel existing notification for this meal type
      String taskName;
      switch (channelId) {
        case NotificationConstants.breakfast:
          taskName = NotificationConstants.breakfastReminderTaskName;
          break;
        case NotificationConstants.lunch:
          taskName = NotificationConstants.lunchReminderTaskName;
          break;
        case NotificationConstants.dinner:
          taskName = NotificationConstants.dinnerReminderTaskName;
          break;
        default:
          throw ArgumentError('Invalid meal type: $channelId');
      }
      
      // Cancel the existing task for this meal type
      await _workManagerClient.cancelByUniqueName(taskName);
      
      // Only reschedule if both master toggle and individual toggle are enabled
      final isMasterEnabled = await isNotificationEnabled(NotificationConstants.mealReminderChannelId);
      if (enabled && isMasterEnabled) {
        // Schedule just this meal type
        await _scheduleMealReminder(channelId);
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
    // Master meal reminder toggle - default to true
    else if (channelId == NotificationConstants.mealReminderChannelId) {
      // If key doesn't exist, create it with default value true
      if (!_prefs.containsKey(NotificationConstants.prefMealReminderMasterEnabled)) {
        await _prefs.setBool(
            NotificationConstants.prefMealReminderMasterEnabled, true);
        return true;
      }
      return _prefs.getBool(NotificationConstants.prefMealReminderMasterEnabled) ??
          true;
    }
    // Individual meal type toggles - default to true
    else if (channelId == NotificationConstants.breakfast ||
             channelId == NotificationConstants.lunch ||
             channelId == NotificationConstants.dinner) {
      final prefKey = NotificationConstants.getMealTypeEnabledKey(channelId);
      
      // If key doesn't exist, create it with default value true
      if (!_prefs.containsKey(prefKey)) {
        await _prefs.setBool(prefKey, true);
        return true;
      }
      return _prefs.getBool(prefKey) ?? true;
    }

    // For other notification types, default to false
    final key = NotificationConstants.getNotificationStatusKey(channelId);
    return _prefs.getBool(key) ?? false;
  }

  Future<void> _setupNotificationByChannel(String channelId) async {
    // Handle daily streak notifications
    if (channelId == NotificationConstants.dailyStreakChannelId) {
      // For streak channel, we use WorkManager to schedule the background task
      // that calculates streak at the time of notification
      debugPrint("Setting up daily streak notification");
      await _scheduleStreakNotification();
    } 
    // Handle meal reminder notifications
    else if (channelId == NotificationConstants.mealReminderChannelId) {
      debugPrint("Setting up meal reminder notifications");
      await _scheduleMealReminders();
    }
    // Other notification types are not implemented at this time
  }

  Future<void> cancelNotificationsByChannel(String channelId) async {
    // Handle daily streak notifications
    if (channelId == NotificationConstants.dailyStreakChannelId) {
      await cancelNotification(NotificationConstants.dailyStreakNotificationId);
      // Also cancel the WorkManager task for streak notifications
      await _workManagerClient
          .cancelByUniqueName(NotificationConstants.streakCalculationTaskName);
    }
    // Handle meal reminder notifications
    else if (channelId == NotificationConstants.mealReminderChannelId) {
      await cancelNotification(NotificationConstants.mealReminderNotificationId);
      // Cancel all meal reminder tasks
      await _workManagerClient
          .cancelByUniqueName(NotificationConstants.breakfastReminderTaskName);
      await _workManagerClient
          .cancelByUniqueName(NotificationConstants.lunchReminderTaskName);
      await _workManagerClient
          .cancelByUniqueName(NotificationConstants.dinnerReminderTaskName);
    }
    // Other notification types are not implemented at this time
  }

  Future<void> _setupDefaultRecurringNotifications() async {
    // Set up daily streak notifications if enabled
    final isStreakEnabled =
        await isNotificationEnabled(NotificationConstants.dailyStreakChannelId);

    debugPrint("isStreakEnabled: $isStreakEnabled");
    if (isStreakEnabled) {
      debugPrint("Setting up daily streak notification");
      await _setupNotificationByChannel(
          NotificationConstants.dailyStreakChannelId);
    }
    
    // Set up meal reminder notifications if enabled
    final isMealReminderEnabled =
        await isNotificationEnabled(NotificationConstants.mealReminderChannelId);
    
    debugPrint("isMealReminderEnabled: $isMealReminderEnabled");
    if (isMealReminderEnabled) {
      debugPrint("Setting up meal reminder notifications");
      await _setupNotificationByChannel(
          NotificationConstants.mealReminderChannelId);
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

  // Schedule meal reminder notifications for breakfast, lunch, and dinner
  Future<void> _scheduleMealReminders() async {
    // Only schedule meal types that are individually enabled
    if (await isMealTypeEnabled(NotificationConstants.breakfast)) {
      await _scheduleMealReminder(NotificationConstants.breakfast);
    }
    
    if (await isMealTypeEnabled(NotificationConstants.lunch)) {
      await _scheduleMealReminder(NotificationConstants.lunch);
    }
    
    if (await isMealTypeEnabled(NotificationConstants.dinner)) {
      await _scheduleMealReminder(NotificationConstants.dinner);
    }
  }
  
  // Helper method to check if a specific meal type is enabled
  Future<bool> isMealTypeEnabled(String mealType) async {
    final prefKey = NotificationConstants.getMealTypeEnabledKey(mealType);
    return _prefs.getBool(prefKey) ?? true; // Default to true if not set
  }
  
  // Schedule a single meal reminder notification
  Future<void> _scheduleMealReminder(String mealType) async {
    // Get the meal-specific task name
    String taskName;
    switch (mealType) {
      case NotificationConstants.breakfast:
        taskName = NotificationConstants.breakfastReminderTaskName;
        break;
      case NotificationConstants.lunch:
        taskName = NotificationConstants.lunchReminderTaskName;
        break;
      case NotificationConstants.dinner:
        taskName = NotificationConstants.dinnerReminderTaskName;
        break;
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }
    
    // Cancel any existing task for this meal type
    await _workManagerClient.cancelByUniqueName(taskName);
    
    // Get user's preferred notification time for this meal type (or use default)
    debugPrint("Getting notification time for $mealType");
    final prefKey = NotificationConstants.getMealTypeKey(mealType);
    final hourKey = "${prefKey}_hour";
    final minuteKey = "${prefKey}_minute";
    
    final hour = _prefs.getInt(hourKey);
    final minute = _prefs.getInt(minuteKey);
    
    // Use stored time or default based on meal type
    TimeOfDay notificationTime;
    switch (mealType) {
      case NotificationConstants.breakfast:
        notificationTime = TimeOfDay(
          hour: hour ?? NotificationConstants.defaultBreakfastHour,
          minute: minute ?? NotificationConstants.defaultBreakfastMinute,
        );
        break;
      case NotificationConstants.lunch:
        notificationTime = TimeOfDay(
          hour: hour ?? NotificationConstants.defaultLunchHour,
          minute: minute ?? NotificationConstants.defaultLunchMinute,
        );
        break;
      case NotificationConstants.dinner:
        notificationTime = TimeOfDay(
          hour: hour ?? NotificationConstants.defaultDinnerHour,
          minute: minute ?? NotificationConstants.defaultDinnerMinute,
        );
        break;
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }
    
    debugPrint("$mealType notification time: ${notificationTime.hour}:${notificationTime.minute}");
    
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
    
    debugPrint("$mealType initial delay: ${initialDelay.inHours}h ${initialDelay.inMinutes % 60}m");
    
    // Register the daily task with WorkManager
    await _workManagerClient.registerPeriodicTask(
      taskName, // Unique name
      taskName, // Use same specific task name instead of generic one
      frequency: const Duration(days: 1),
      initialDelay: initialDelay,
      inputData: {
        'notification_id': NotificationConstants.mealReminderNotificationId,
        'notification_channel': NotificationConstants.mealReminderChannelId,
      },
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
    
    debugPrint("Scheduled $mealType reminder notification");
  }
  
  // Update meal reminder time
  Future<void> updateMealReminderTime(String mealType, TimeOfDay time) async {
    // Save the new notification time
    final prefKey = NotificationConstants.getMealTypeKey(mealType);
    final hourKey = "${prefKey}_hour";
    final minuteKey = "${prefKey}_minute";
    
    await _prefs.setInt(hourKey, time.hour);
    await _prefs.setInt(minuteKey, time.minute);
    
    // Only reschedule if both master toggle and individual toggle are enabled
    final isMasterEnabled = await isNotificationEnabled(NotificationConstants.mealReminderChannelId);
    final isTypeEnabled = await isMealTypeEnabled(mealType);
    
    if (isMasterEnabled && isTypeEnabled) {
      // Cancel existing reminder for this meal type
      String taskName;
      switch (mealType) {
        case NotificationConstants.breakfast:
          taskName = NotificationConstants.breakfastReminderTaskName;
          break;
        case NotificationConstants.lunch:
          taskName = NotificationConstants.lunchReminderTaskName;
          break;
        case NotificationConstants.dinner:
          taskName = NotificationConstants.dinnerReminderTaskName;
          break;
        default:
          throw ArgumentError('Invalid meal type: $mealType');
      }
      
      await _workManagerClient.cancelByUniqueName(taskName);
      
      // Reschedule with new time
      await _scheduleMealReminder(mealType);
    }
  }
  
  // Get the current notification time for a meal type
  Future<TimeOfDay> getMealReminderTime(String mealType) async {
    final prefKey = NotificationConstants.getMealTypeKey(mealType);
    final hourKey = "${prefKey}_hour";
    final minuteKey = "${prefKey}_minute";
    
    final hour = _prefs.getInt(hourKey);
    final minute = _prefs.getInt(minuteKey);
    
    // Return stored time or default based on meal type
    switch (mealType) {
      case NotificationConstants.breakfast:
        return TimeOfDay(
          hour: hour ?? NotificationConstants.defaultBreakfastHour,
          minute: minute ?? NotificationConstants.defaultBreakfastMinute,
        );
      case NotificationConstants.lunch:
        return TimeOfDay(
          hour: hour ?? NotificationConstants.defaultLunchHour,
          minute: minute ?? NotificationConstants.defaultLunchMinute,
        );
      case NotificationConstants.dinner:
        return TimeOfDay(
          hour: hour ?? NotificationConstants.defaultDinnerHour,
          minute: minute ?? NotificationConstants.defaultDinnerMinute,
        );
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }
  }
}
// coverage:ignore-end
