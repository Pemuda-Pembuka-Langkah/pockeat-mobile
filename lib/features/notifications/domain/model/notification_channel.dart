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
    'Pengingat Streak Harian',
    description: 'Channel untuk pengingat streak harian',
    importance: Importance.high,
  );

  /// Pet status notifications
  static const AndroidNotificationChannel petStatus =
      AndroidNotificationChannel(
    'pet_status_channel',
    'Status Hewan Peliharaan',
    description:
        'Channel untuk mengirim notifikasi tentang status hewan peliharaan',
    importance: Importance.high,
  );

  /// Legacy name for backward compatibility with tests
  /// Do not use in new code
  static AndroidNotificationChannel get caloriesReminder => mealReminder;
}
