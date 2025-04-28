// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/services/user_activity_service.dart';

/// Implementation of UserActivityService that tracks user app activity
class UserActivityServiceImpl implements UserActivityService {
  final SharedPreferences _prefs;

  // Using constant from NotificationConstants

  /// Constructor
  UserActivityServiceImpl({
    SharedPreferences? prefs,
  }) : _prefs = prefs ?? getIt<SharedPreferences>();

  @override
  Future<void> trackAppOpen() async {
    // Store current time as millisecondsSinceEpoch for easier comparison later
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs.setInt(NotificationConstants.lastAppOpenTimeKey, now);
    debugPrint('Tracked app open at: ${DateTime.now()}');
  }

  @override
  Future<Duration> getInactiveDuration() async {
    final lastOpenTime = await getLastOpenTime();

    if (lastOpenTime == null) {
      // If no last open time recorded, return zero duration
      return Duration.zero;
    }

    final now = DateTime.now();
    return now.difference(lastOpenTime);
  }

  @override
  Future<bool> isInactiveFor(Duration duration) async {
    final inactiveDuration = await getInactiveDuration();
    return inactiveDuration >= duration;
  }

  @override
  Future<DateTime?> getLastOpenTime() async {
    final lastOpenMillis =
        _prefs.getInt(NotificationConstants.lastAppOpenTimeKey);

    if (lastOpenMillis == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(lastOpenMillis);
  }
}
