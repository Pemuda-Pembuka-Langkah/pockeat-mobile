// coverage:ignore-start

/// Constants for notification management across the app
///
/// This file centralizes all notification identifiers, channel IDs, and preference keys
/// to ensure consistency between UI and services
class NotificationConstants {
  // Notification Channel IDs
  static const String mealReminderChannelId = 'meal_reminder_channel';
  static const String workoutReminderChannelId = 'workout_reminder_channel';
  static const String subscriptionChannelId = 'subscription_channel';
  static const String serverChannelId = 'server_channel';
  static const String dailyStreakChannelId = 'daily_streak_channel';

  // Notification IDs
  static const String dailyStreakNotificationId = 'daily_streak';
  static const String mealReminderNotificationId = 'meal_reminder';
  static const String workoutReminderNotificationId = 'workout_reminder';

  // SharedPreferences Keys
  static const String prefNotificationStatusPrefix = 'notification_status_';

  // Helper method to get notification status preference key for a channel
  static String getNotificationStatusKey(String channelId) =>
      '$prefNotificationStatusPrefix$channelId';

  // Daily Streak Notification Preference Keys
  static const String prefDailyStreakEnabled =
      '$prefNotificationStatusPrefix$dailyStreakChannelId';
  static const String prefDailyStreakHour = 'daily_streak_notification_hour';
  static const String prefDailyStreakMinute =
      'daily_streak_notification_minute';

  // Notification Payloads
  static const String dailyStreakPayload = 'daily_streak';
  static const String mealReminderPayload = 'meal_reminder';
  static const String workoutReminderPayload = 'workout_reminder';

  // Background task identifiers
  static const String streakCalculationTaskName =
      'notification_streak_calculation_task';

  // Default notification times
  static const int defaultStreakNotificationHour = 10;
  static const int defaultStreakNotificationMinute = 0;
}

// coverage:ignore-end
