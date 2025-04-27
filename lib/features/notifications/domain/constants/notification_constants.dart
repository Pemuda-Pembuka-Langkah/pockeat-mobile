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
  static const String petSadnessChannelId = 'pet_sadness_channel';
  static const String petStatusChannelId = 'pet_status_channel';
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  // Notification IDs
  static const String dailyStreakNotificationId = 'daily_streak';
  static const String mealReminderNotificationId = 'meal_reminder';
  static const String workoutReminderNotificationId = 'workout_reminder';
  static const String petSadnessNotificationId = 'pet_sadness';
  static const String petStatusNotificationId = 'pet_status';

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

  // Pet Sadness Notification Preference Keys
  static const String prefPetSadnessEnabled =
      '$prefNotificationStatusPrefix$petSadnessChannelId';
      
  // Pet Status Notification Preference Keys
  static const String prefPetStatusEnabled =
      '$prefNotificationStatusPrefix$petStatusChannelId';
  static const String prefDailyStreakHour = 'daily_streak_notification_hour';
  static const String prefDailyStreakMinute =
      'daily_streak_notification_minute';

  // Notification Payloads
  static const String dailyStreakPayload = 'daily_streak';
  static const String mealReminderPayload = 'meal_reminder';
  static const String workoutReminderPayload = 'workout_reminder';
  static const String petSadnessPayload = 'pet_sadness';
  static const String petStatusPayload = 'pet_status';

  // Background task identifiers
  static const String streakCalculationTaskName =
      'notification_streak_calculation_task';
  static const String petSadnessCheckTaskName = 'pet_sadness_check_task';
  static const String petStatusUpdateTaskName = 'pet_status_update_task';

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
  static const String mealReminderTaskName =
      'meal_reminder_task'; // Generic task name
  static const String breakfastReminderTaskName = 'breakfast_reminder_task';
  static const String lunchReminderTaskName = 'lunch_reminder_task';
  static const String dinnerReminderTaskName = 'dinner_reminder_task';

  // Intent storing keys for notification navigation
  static const String storedIntentTypeKey = 'stored_notification_intent_type';
  static const String storedIntentDataKey = 'stored_notification_intent_data';

  // Intent types
  static const String intentTypeStreakCelebration = 'streak_celebration';
  static const String intentTypeMealReminder = 'meal_reminder';
  static const String intentTypePetSadness = 'pet_sadness';
  static const String intentTypePetStatus = 'pet_status';

  // User activity tracking
  static const String lastAppOpenTimeKey = 'last_app_open_time';
  static const Duration inactivityThreshold = Duration(hours: 24);

  // Pet sadness levels based on inactivity duration
  static const Duration slightlySadThreshold = Duration(hours: 24);
  static const Duration verySadThreshold = Duration(hours: 48);
  static const Duration extremelySadThreshold = Duration(hours: 72);
}

// coverage:ignore-end
