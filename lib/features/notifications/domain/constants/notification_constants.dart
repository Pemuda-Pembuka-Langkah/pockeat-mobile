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
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  // Notification IDs
  static const String dailyStreakNotificationId = 'daily_streak';
  static const String mealReminderNotificationId = 'meal_reminder';
  static const String workoutReminderNotificationId = 'workout_reminder';

  // SharedPreferences Keys
  static const String prefNotificationStatusPrefix = 'notification_status_';
  
  // Meal reminder notification preference keys
  static const String prefMealReminderMasterEnabled = 
      '$prefNotificationStatusPrefix$mealReminderChannelId';
  static const String prefMealTypePrefix = 'meal_reminder_';
  
  // Helper method to get meal type enabled preference key
  static String getMealTypeEnabledKey(String mealType) =>
      '$prefNotificationStatusPrefix$prefMealTypePrefix${mealType}_enabled';
      
  // Individual meal reminder enabled keys
  static final String prefBreakfastEnabled = getMealTypeEnabledKey(breakfast);
  static final String prefLunchEnabled = getMealTypeEnabledKey(lunch);
  static final String prefDinnerEnabled = getMealTypeEnabledKey(dinner);
  
  // Helper method to get meal type preference key
  static String getMealTypeKey(String mealType) =>
      '$prefMealTypePrefix$mealType';

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
  
  // Default meal reminder times
  static const int defaultBreakfastHour = 7;
  static const int defaultBreakfastMinute = 0;
  
  static const int defaultLunchHour = 12;
  static const int defaultLunchMinute = 0;
  
  static const int defaultDinnerHour = 18;
  static const int defaultDinnerMinute = 0;
  
  // Background task identifiers for meal reminders
  static const String breakfastReminderTaskName = 'breakfast_reminder_task';
  static const String lunchReminderTaskName = 'lunch_reminder_task';
  static const String dinnerReminderTaskName = 'dinner_reminder_task';
}

// coverage:ignore-end
