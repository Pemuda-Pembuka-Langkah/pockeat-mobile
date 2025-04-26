// Dart imports:
import 'dart:async';

/// Abstract interface for displaying notifications in background tasks
abstract class NotificationBackgroundDisplayerService {
  /// Shows a streak notification in the background
  /// Returns true if notification was shown, false otherwise
  Future<bool> showStreakNotification(Map<String, dynamic> services);
  
  /// Shows a meal reminder notification in the background
  /// [services] - Required services for background tasks (shared prefs, notifications, etc.)
  /// [mealType] - Type of meal (breakfast, lunch, dinner)
  /// Returns true if notification was shown, false otherwise
  Future<bool> showMealReminderNotification(Map<String, dynamic> services, String mealType);
}
