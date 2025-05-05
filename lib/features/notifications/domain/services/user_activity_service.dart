// Project imports:

/// Service to track user's app activity like last app open time
abstract class UserActivityService {
  /// Track when user opens the app
  Future<void> trackAppOpen();

  /// Get the duration since the user last opened the app
  Future<Duration> getInactiveDuration();

  /// Check if user has been inactive for specified duration
  Future<bool> isInactiveFor(Duration duration);

  /// Get the last time user opened the app
  Future<DateTime?> getLastOpenTime();
}
