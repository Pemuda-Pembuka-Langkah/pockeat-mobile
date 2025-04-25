// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/core/utils/background_logger.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';
import 'package:pockeat/features/notifications/domain/model/streak_message.dart';
import 'package:pockeat/features/notifications/domain/services/notification_background_displayer_service.dart';

/// Implementation of NotificationBackgroundDisplayerService
class NotificationBackgroundDisplayerServiceImpl
    implements NotificationBackgroundDisplayerService {
  // Parameter untuk testing
  final bool isTest;

  /// Constructor
  /// [isTest] - Set true untuk testing mode di mana platform dependencies akan di-bypass
  NotificationBackgroundDisplayerServiceImpl({this.isTest = false});

  @override
  Future<bool> showStreakNotification(Map<String, dynamic> services) async {
    try {
      await BackgroundLogger.log("Starting notification process",
          tag: "STREAK_NOTIFICATION", isTest: isTest);

      final prefs = services['sharedPreferences'] as SharedPreferences;
      await BackgroundLogger.log("Got SharedPreferences",
          tag: "STREAK_NOTIFICATION", isTest: isTest);

      final loginService = services['loginService'] as LoginService;
      await BackgroundLogger.log("Got LoginService",
          tag: "STREAK_NOTIFICATION", isTest: isTest);

      final foodLogHistoryService =
          services['foodLogHistoryService'] as FoodLogHistoryService;
      await BackgroundLogger.log("Got FoodLogHistoryService",
          tag: "STREAK_NOTIFICATION", isTest: isTest);

      final notifications = services['flutterLocalNotificationsPlugin']
          as FlutterLocalNotificationsPlugin;
      await BackgroundLogger.log("Got FlutterLocalNotificationsPlugin",
          tag: "STREAK_NOTIFICATION", isTest: isTest);

      // Check if notifications are enabled
      final isEnabled =
          prefs.getBool(NotificationConstants.prefDailyStreakEnabled) ?? true;
      await BackgroundLogger.log("Notifications enabled: $isEnabled",
          tag: "STREAK_NOTIFICATION", isTest: isTest);
      if (!isEnabled) {
        await BackgroundLogger.log("Daily streak notifications are disabled",
            tag: "STREAK_NOTIFICATION", isTest: isTest);
        return false;
      }

      // Get current user
      await BackgroundLogger.log("Getting current user",
          tag: "STREAK_NOTIFICATION", isTest: isTest);
      final user = await loginService.getCurrentUser();
      final userId = user?.uid;
      await BackgroundLogger.log("Current user ID: $userId",
          tag: "STREAK_NOTIFICATION", isTest: isTest);
      if (userId == null) {
        await BackgroundLogger.log(
            "User not logged in, cannot show streak notification",
            tag: "STREAK_NOTIFICATION",
            isTest: isTest);
        return false;
      }

      // Calculate streak
      await BackgroundLogger.log("Calculating streak for user: $userId",
          tag: "STREAK_NOTIFICATION", isTest: isTest);
      final streakDays = await foodLogHistoryService.getFoodStreakDays(userId);
      await BackgroundLogger.log("User streak days: $streakDays",
          tag: "STREAK_NOTIFICATION", isTest: isTest);
      if (streakDays <= 0) {
        await BackgroundLogger.log("No active streak, skipping notification",
            tag: "STREAK_NOTIFICATION", isTest: isTest);
        return false;
      }

      // Create streak message
      final streakMessage = StreakMessageFactory.createMessage(streakDays);
      await BackgroundLogger.log(
          "Created streak message: ${streakMessage.title}",
          tag: "STREAK_NOTIFICATION",
          isTest: isTest);

      // Initialize local notifications if needed
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await notifications.initialize(initializationSettings);
      await BackgroundLogger.log("Initialized notifications",
          tag: "STREAK_NOTIFICATION", isTest: isTest);

      // Create streak notification channel if needed
      await notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(NotificationChannels.dailyStreak);
      await BackgroundLogger.log("Created notification channel",
          tag: "STREAK_NOTIFICATION", isTest: isTest);

      // Try to show a more styled notification with the panda image
      try {
        // Create style with large icon (panda_happy_notif.png)
        final bigPictureStyle = BigPictureStyleInformation(
          const DrawableResourceAndroidBitmap(
              'panda_happy_notif'), // Simple resource name for drawable
          largeIcon: const DrawableResourceAndroidBitmap('panda_happy_notif'),
          contentTitle: streakMessage.title,
          htmlFormatContentTitle: true,
          summaryText: streakMessage.body,
          htmlFormatSummaryText: true,
        );

        await notifications.show(
          'streak_celebration'.hashCode,
          streakMessage.title,
          streakMessage.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationChannels.dailyStreak.id,
              NotificationChannels.dailyStreak.name,
              channelDescription: NotificationChannels.dailyStreak.description,
              icon: '@mipmap/launcher_icon', // Using the app's launcher icon
              largeIcon:
                  const DrawableResourceAndroidBitmap('panda_happy_notif'),
              styleInformation: bigPictureStyle,
              playSound: true,
              priority: Priority.high,
              importance: Importance.high,
              color: const Color(0xFFFF6B6B), // Pockeat pink color
            ),
          ),
          payload: NotificationConstants.dailyStreakPayload,
        );
      } catch (e) {
        // If styled notification fails, fall back to simple version
        await BackgroundLogger.log(
            "Styled notification failed: $e, falling back to simple version",
            tag: "STREAK_NOTIFICATION",
            isTest: isTest);

        // Fallback simple notification
        await notifications.show(
          'streak_celebration'.hashCode,
          streakMessage.title,
          streakMessage.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationChannels.dailyStreak.id,
              NotificationChannels.dailyStreak.name,
              channelDescription: NotificationChannels.dailyStreak.description,
              icon: '@mipmap/launcher_icon',
              playSound: true,
              priority: Priority.high,
              importance: Importance.high,
            ),
          ),
          payload: NotificationConstants.dailyStreakPayload,
        );
      }

      await BackgroundLogger.log("Streak notification sent successfully",
          tag: "STREAK_NOTIFICATION", isTest: isTest);
      return true;
    } catch (e) {
      await BackgroundLogger.log("Error showing streak notification: $e",
          tag: "STREAK_NOTIFICATION", isTest: isTest);
      return false;
    }
  }
}
