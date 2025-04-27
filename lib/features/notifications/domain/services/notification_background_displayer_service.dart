// Dart imports:
import 'dart:async';

// Project imports:
import 'package:pockeat/features/notifications/domain/services/user_activity_service.dart';

/// Abstract interface for displaying notifications in background tasks
abstract class NotificationBackgroundDisplayerService {
  /// Shows a streak notification in the background
  /// Returns true if notification was shown, false otherwise
  Future<bool> showStreakNotification(Map<String, dynamic> services);

  /// Shows a meal reminder notification in the background
  /// [services] - Required services for background tasks (shared prefs, notifications, etc.)
  /// [mealType] - Type of meal (breakfast, lunch, dinner)
  /// Returns true if notification was shown, false otherwise
  Future<bool> showMealReminderNotification(
      Map<String, dynamic> services, String mealType);

  /// Menampilkan notifikasi pet sadness saat user tidak aktif
  /// Melakukan pengecekan durasi inaktivitas pengguna
  /// [services] - Required services for background tasks (shared prefs, notifications, etc.)
  /// [userActivityService] - Optional UserActivityService for testability
  Future<bool> showPetSadnessNotification(
      Map<String, dynamic> services, {UserActivityService? userActivityService});
      
  /// Shows a pet status notification displaying the current mood and health of the pet
  /// [services] - Required services for background tasks (shared prefs, notifications, etc.)
  /// Returns true if notification was shown, false otherwise
  Future<bool> showPetStatusNotification(Map<String, dynamic> services);
}
