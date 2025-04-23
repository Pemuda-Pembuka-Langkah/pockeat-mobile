// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannels {
  static const AndroidNotificationChannel caloriesReminder =
      AndroidNotificationChannel(
    'calories_reminder_channel',
    'Pengingat Kalori Harian',
    description:
        'Channel untuk mengirim pengingat tentang pelacakan kalori harian',
    importance: Importance.high,
  );

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
}
