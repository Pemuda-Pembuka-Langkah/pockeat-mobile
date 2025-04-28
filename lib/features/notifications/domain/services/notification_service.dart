// Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationService {
  // Inisialisasi service
  Future<void> initialize();

  // Menampilkan notifikasi dari Firebase
  Future<void> showNotificationFromFirebase(RemoteMessage message);

  // Membatalkan notifikasi spesifik
  Future<void> cancelNotification(String id);

  // Membatalkan semua notifikasi
  Future<void> cancelAllNotifications();

  // Mengaktifkan atau menonaktifkan channel notifikasi
  Future<void> toggleNotification(String channelId, bool enabled);

  // Memeriksa apakah notifikasi aktif
  Future<bool> isNotificationEnabled(String channelId);
}
