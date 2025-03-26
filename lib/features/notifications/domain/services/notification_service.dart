import 'package:pockeat/features/notifications/domain/model/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {

  // Inisialisasi service
  Future<void> initialize();

  // Menjadwalkan notifikasi lokal
  Future<void> scheduleLocalNotification(NotificationModel notification, AndroidNotificationChannel channel);

  // Menampilkan notifikasi dari Firebase
  Future<void> showNotificationFromFirebase(RemoteMessage message);

  // Membatalkan notifikasi spesifik
  Future<void> cancelNotification(String id);

  // Membatalkan semua notifikasi
  Future<void> cancelAllNotifications();

}

