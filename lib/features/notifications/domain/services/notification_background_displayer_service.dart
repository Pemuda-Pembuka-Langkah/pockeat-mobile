// Dart imports:
import 'dart:async';

/// Abstract interface for displaying notifications in background tasks
abstract class NotificationBackgroundDisplayerService {
  /// Shows a streak notification in the background
  /// Returns true if notification was shown, false otherwise
  Future<bool> showStreakNotification(Map<String, dynamic> services);
}
