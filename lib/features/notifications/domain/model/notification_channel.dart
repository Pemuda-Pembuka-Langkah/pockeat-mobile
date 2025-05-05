// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';

/// Notification channels for the app
///
/// Each channel has a specific purpose and importance level
class NotificationChannels {
  /// Meal reminder notifications (breakfast, lunch, dinner)
  static const AndroidNotificationChannel mealReminder =
      AndroidNotificationChannel(
    NotificationConstants.mealReminderChannelId,
    'Pengingat Waktu Makan',
    description:
        'Channel untuk mengirim pengingat tentang waktu makan (sarapan, makan siang, makan malam)',
    importance: Importance.high,
  );

  /// Workout reminders
  static const AndroidNotificationChannel workoutReminder =
      AndroidNotificationChannel(
    NotificationConstants.workoutReminderChannelId,
    'Pengingat Workout',
    description: 'Channel untuk mengirim pengingat tentang workout',
    importance: Importance.high,
  );

  /// Subscription notifications
  static const AndroidNotificationChannel subscription =
      AndroidNotificationChannel(
    NotificationConstants.subscriptionChannelId,
    'Informasi Langganan',
    description: 'Channel untuk informasi terkait langganan',
    importance: Importance.high,
  );

  /// Server notifications (from Firebase)
  static const AndroidNotificationChannel server = AndroidNotificationChannel(
    NotificationConstants.serverChannelId,
    'Notifikasi Server',
    description: 'Channel untuk notifikasi dari server',
    importance: Importance.high,
  );

  /// Daily streak notifications
  static const AndroidNotificationChannel dailyStreak =
      AndroidNotificationChannel(
    NotificationConstants.dailyStreakChannelId,
    'Streak Harian',
    description: 'Channel untuk mengirim notifikasi tentang streak pola makan',
    importance: Importance.high,
  );

  /// Pet sadness notifications when user is inactive
  static const AndroidNotificationChannel petSadness =
      AndroidNotificationChannel(
    NotificationConstants.petSadnessChannelId,
    'Pet Sadness Alerts',
    description:
        'Notifikasi saat pet kamu sedih karena tidak melihatmu dalam waktu lama',
    importance: Importance.high,
  );

  /// Pet status notifications
  static const AndroidNotificationChannel petStatus =
      AndroidNotificationChannel(
    NotificationConstants.petStatusChannelId,
    'Pet Status Updates',
    description:
        'Channel for sending notifications about your pet\'s status and mood',
    importance: Importance.high,
  );

  /// Legacy name for backward compatibility with tests
  /// Do not use in new code
  static AndroidNotificationChannel get caloriesReminder => mealReminder;
}
