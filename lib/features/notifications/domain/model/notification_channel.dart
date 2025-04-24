// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannels {
  static const AndroidNotificationChannel mealReminder =
      AndroidNotificationChannel(
    'meal_reminder_channel',
    'Pengingat Waktu Makan',
    description:
        'Channel untuk mengirim pengingat tentang waktu makan (sarapan, makan siang, makan malam)',
    importance: Importance.high,
  );

  // Legacy name for backward compatibility
  @Deprecated('Use mealReminder instead')
  static const AndroidNotificationChannel caloriesReminder = mealReminder;

  static const AndroidNotificationChannel workoutReminder =
      AndroidNotificationChannel(
    'workout_reminder_channel',
    'Pengingat Workout',
    description: 'Channel untuk mengirim pengingat tentang workout',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel subscription =
      AndroidNotificationChannel(
    'subscription_channel',
    'Subscription Channel',
    description: 'Channel untuk mengirim notifikasi tentang subscription',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel server = AndroidNotificationChannel(
    'server_channel',
    'Server Channel',
    description: 'Channel untuk mengirim notifikasi dari server',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel petStatus =
      AndroidNotificationChannel(
    'pet_status_channel',
    'Status Hewan Peliharaan',
    description:
        'Channel untuk mengirim notifikasi tentang status hewan peliharaan',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel dailyStreak =
      AndroidNotificationChannel(
    'daily_streak_channel',
    'Pencapaian Streak Harian',
    description:
        'Channel untuk mengirim notifikasi tentang pencapaian streak dan milestone',
    importance: Importance.high,
  );
}
