// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/model/meal_reminder_message.dart';
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';
import 'package:pockeat/features/notifications/domain/model/pet_sadness_message.dart';
import 'package:pockeat/features/notifications/domain/model/pet_status_message.dart';
import 'package:pockeat/features/notifications/domain/model/streak_message.dart';
import 'package:pockeat/features/notifications/domain/services/impl/user_activity_service_impl.dart';
import 'package:pockeat/features/notifications/domain/services/notification_background_displayer_service.dart';
import 'package:pockeat/features/notifications/domain/services/user_activity_service.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';

/// Implementation of NotificationBackgroundDisplayerService
class NotificationBackgroundDisplayerServiceImpl
    implements NotificationBackgroundDisplayerService {
  // Parameter untuk testing
  final bool isTest;

  /// Constructor
  /// [isTest] - Set true untuk testing mode di mana platform dependencies akan di-bypass
  NotificationBackgroundDisplayerServiceImpl({this.isTest = false});

  @override
  Future<bool> showPetSadnessNotification(Map<String, dynamic> services,
      {UserActivityService? userActivityService}) async {
    try {
      // Use provided userActivityService or create a new one
      // coverage:ignore-start
      final activityService = userActivityService ??
          UserActivityServiceImpl(
            prefs: services['sharedPreferences'] as SharedPreferences,
          );
      // coverage:ignore-end
      final inactivityDuration = await activityService.getInactiveDuration();

      debugPrint(
          'Checking pet sadness: User inactive for ${inactivityDuration.inHours} hours');

      // Only show notification if user has been inactive for longer than threshold
      if (inactivityDuration <= NotificationConstants.inactivityThreshold) {
        debugPrint(
            'User not inactive long enough for pet sadness notification');
        return false;
      }

      final prefs = services['sharedPreferences'] as SharedPreferences;
      final notifications = services['flutterLocalNotificationsPlugin']
          as FlutterLocalNotificationsPlugin;

      // Check if pet sadness notifications are enabled
      final isEnabled =
          prefs.getBool(NotificationConstants.prefPetSadnessEnabled) ?? true;
      if (!isEnabled) {
        debugPrint('Pet sadness notifications are disabled');
        return false;
      }

      // Create appropriate sadness message based on inactivity duration
      final sadnessMessage =
          PetSadnessMessageFactory.createMessage(inactivityDuration);

      debugPrint(
          'Creating pet sadness notification after ${inactivityDuration.inHours} hours of inactivity');

      // Initialize local notifications if needed
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await notifications.initialize(initializationSettings);

      // Create pet sadness notification channel if needed
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        NotificationConstants.petSadnessChannelId,
        'Pet Sadness Alerts',
        description:
            'Notifikasi saat pet kamu sedih karena tidak melihatmu dalam waktu lama',
        importance: Importance.high,
        playSound: true,
      );

      await notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Try to show a more styled notification with the panda image
      try {
        // Check if we have a custom asset for this sadness level
        final String imageAsset =
            sadnessMessage.imageAsset ?? 'panda_sad_notif'; // Fallback image

        final bigPictureStyle = BigPictureStyleInformation(
          DrawableResourceAndroidBitmap(imageAsset),
          largeIcon: DrawableResourceAndroidBitmap(imageAsset),
          contentTitle: sadnessMessage.title,
          htmlFormatContentTitle: true,
          summaryText: sadnessMessage.body,
          htmlFormatSummaryText: true,
        );

        await notifications.show(
          NotificationConstants.petSadnessNotificationId.hashCode,
          sadnessMessage.title,
          sadnessMessage.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/launcher_icon',
              largeIcon: DrawableResourceAndroidBitmap(imageAsset),
              styleInformation: bigPictureStyle,
              playSound: true,
              priority: Priority.high,
              importance: Importance.high,
              color: const Color(0xFFFF6B6B), // Pockeat pink color
            ),
          ),
          payload: NotificationConstants.petSadnessPayload,
        );
      } catch (e) {
        debugPrint('Error showing styled notification: $e');
        // Fallback simple notification
        await notifications.show(
          NotificationConstants.petSadnessNotificationId.hashCode,
          sadnessMessage.title,
          sadnessMessage.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/launcher_icon',
              priority: Priority.high,
              importance: Importance.high,
            ),
          ),
          payload: NotificationConstants.petSadnessPayload,
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error showing pet sadness notification: $e');
      return false;
    }
  }

  @override
  Future<bool> showMealReminderNotification(
      Map<String, dynamic> services, String mealType) async {
    try {
      final prefs = services['sharedPreferences'] as SharedPreferences;
      final notifications = services['flutterLocalNotificationsPlugin']
          as FlutterLocalNotificationsPlugin;

      // Check if notifications are enabled (both master toggle and individual toggle)
      final isMasterEnabled =
          prefs.getBool(NotificationConstants.prefMealReminderMasterEnabled) ??
              true;

      if (!isMasterEnabled) {
        return false;
      }

      // Check if the specific meal type is enabled
      final prefKey = NotificationConstants.getMealTypeEnabledKey(mealType);
      final isMealTypeEnabled = prefs.getBool(prefKey) ?? true;

      if (!isMealTypeEnabled) {
        return false;
      }

      // Create appropriate meal reminder message
      final reminderMessage =
          MealReminderMessageFactory.createMessage(mealType);

      // Initialize local notifications if needed
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await notifications.initialize(initializationSettings);

      // Create meal reminder notification channel if needed
      await notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(NotificationChannels.mealReminder);

      // Show the notification
      await notifications.show(
        NotificationConstants.mealReminderNotificationId.hashCode,
        reminderMessage.title,
        reminderMessage.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationChannels.mealReminder.id,
            NotificationChannels.mealReminder.name,
            channelDescription: NotificationChannels.mealReminder.description,
            icon: '@mipmap/launcher_icon',
            priority: Priority.high,
            importance: Importance.high,
            color: const Color(0xFF00AA5B), // Pockeat green color
          ),
        ),
        payload: NotificationConstants.mealReminderPayload,
      );

      return true;
    } catch (e) {
      debugPrint('Error showing meal reminder notification: $e');
      return false;
    }
  }

  @override
  Future<bool> showPetStatusNotification(Map<String, dynamic> services) async {
    try {
      final prefs = services['sharedPreferences'] as SharedPreferences;
      final notifications = services['flutterLocalNotificationsPlugin']
          as FlutterLocalNotificationsPlugin;
      final loginService = services['loginService'] as LoginService;

      // Check if pet status notifications are enabled
      final isEnabled =
          prefs.getBool(NotificationConstants.prefPetStatusEnabled) ?? true;
      if (!isEnabled) {
        debugPrint('Pet status notifications are disabled');
        return false;
      }

      // Get current user ID
      final userId = (await loginService.getCurrentUser())?.uid;
      if (userId == null) {
        debugPrint('No user logged in, skipping pet status notification');
        return false;
      }

      // Get pet service from services
      final PetService petService = services['petService'] as PetService;

      // Get current pet mood and heart level
      final String mood = await petService.getPetMood(userId);
      final int heartLevel = await petService.getPetHeart(userId);

      // Calculate consumed calories using proper strategy
      int currentCalories = 0;
      int targetCalories = 0;
      try {
        // Calculate consumed calories
        final calorieStrategy = services['calorieCalculationStrategy']
            as CalorieCalculationStrategy;
        final foodLogService =
            services['foodLogHistoryService'] as FoodLogHistoryService;

        // Use strategy to calculate total calories
        currentCalories = await calorieStrategy.calculateTodayTotalCalories(
            foodLogService, userId);

        // Calculate target calories
        final healthMetricsRepository =
            services['healthMetricsRepository'] as HealthMetricsRepository;
        final caloricRequirementService =
            services['caloricRequirementService'] as CaloricRequirementService;

        // Use strategy to calculate target calories
        targetCalories = await calorieStrategy.calculateTargetCalories(
            healthMetricsRepository, caloricRequirementService, userId);
      } catch (e) {
        debugPrint('Error calculating calories: $e');
        // Fallback to use heart level to estimate calories as before
        targetCalories = 2000; // Default target calories
        currentCalories = (heartLevel / 4 * targetCalories).round();
      }

      // Create status message
      final statusMessage = PetStatusMessageFactory.createMessage(
        mood: mood,
        heartLevel: heartLevel,
        currentCalories: currentCalories,
        requiredCalories: targetCalories,
      );

      debugPrint('Creating pet status notification: ${statusMessage.title}');

      // Initialize local notifications if needed
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await notifications.initialize(initializationSettings);

      // Create pet status notification channel if needed
      await notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(NotificationChannels.petStatus);

      // Show a styled notification with pet image
      try {
        final bigPictureStyle = BigPictureStyleInformation(
          DrawableResourceAndroidBitmap(statusMessage.imageAsset),
          largeIcon: DrawableResourceAndroidBitmap(statusMessage.imageAsset),
          contentTitle: statusMessage.title,
          htmlFormatContentTitle: true,
          summaryText: statusMessage.body,
          htmlFormatSummaryText: true,
        );

        await notifications.show(
          NotificationConstants.petStatusNotificationId.hashCode,
          statusMessage.title,
          statusMessage.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationChannels.petStatus.id,
              NotificationChannels.petStatus.name,
              channelDescription: NotificationChannels.petStatus.description,
              icon: '@mipmap/launcher_icon',
              largeIcon:
                  DrawableResourceAndroidBitmap(statusMessage.imageAsset),
              styleInformation: bigPictureStyle,
              playSound: true,
              priority: Priority.high,
              importance: Importance.high,
              color: const Color(0xFFFF6B6B), // Pockeat pink color
            ),
          ),
          payload: NotificationConstants.petStatusPayload,
        );
      } catch (e) {
        debugPrint('Error showing styled notification: $e');
        // Fallback to simple notification
        await notifications.show(
          NotificationConstants.petStatusNotificationId.hashCode,
          statusMessage.title,
          statusMessage.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationChannels.petStatus.id,
              NotificationChannels.petStatus.name,
              channelDescription: NotificationChannels.petStatus.description,
              icon: '@mipmap/launcher_icon',
              priority: Priority.high,
              importance: Importance.high,
            ),
          ),
          payload: NotificationConstants.petStatusPayload,
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error showing pet status notification: $e');
      return false;
    }
  }

  @override
  Future<bool> showStreakNotification(Map<String, dynamic> services) async {
    try {
      final prefs = services['sharedPreferences'] as SharedPreferences;

      final loginService = services['loginService'] as LoginService;

      final foodLogHistoryService =
          services['foodLogHistoryService'] as FoodLogHistoryService;

      final notifications = services['flutterLocalNotificationsPlugin']
          as FlutterLocalNotificationsPlugin;

      // Check if notifications are enabled
      final isEnabled =
          prefs.getBool(NotificationConstants.prefDailyStreakEnabled) ?? true;
      if (!isEnabled) {
        return false;
      }

      // Get current user
      final user = await loginService.getCurrentUser();
      final userId = user?.uid;
      if (userId == null) {
        return false;
      }

      // Calculate streak
      final streakDays = await foodLogHistoryService.getFoodStreakDays(userId);
      if (streakDays < 0) {
        return false;
      }

      // Create streak message
      final streakMessage = StreakMessageFactory.createMessage(streakDays);

      // Initialize local notifications if needed
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await notifications.initialize(initializationSettings);

      // Create streak notification channel if needed
      await notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(NotificationChannels.dailyStreak);

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

      return true;
    } catch (e) {
      return false;
    }
  }
}
