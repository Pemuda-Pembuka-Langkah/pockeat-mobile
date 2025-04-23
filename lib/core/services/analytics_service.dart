// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for tracking app analytics
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  FirebaseAnalyticsObserver? _observer;

  /// Constructor that allows for dependency injection to make service testable
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Initialize analytics configurations
  Future<void> initialize() async {
    try {
      // Enable analytics collection
      await _analytics.setAnalyticsCollectionEnabled(true);

      // Set default parameters that will be sent with all events
      await _analytics.setDefaultEventParameters({
        'app_platform': kIsWeb ? 'web' : 'mobile',
      });

      debugPrint('Google Analytics initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Google Analytics: $e');
    }
  }

  /// Get analytics observer for navigating routes
  FirebaseAnalyticsObserver get observer {
    _observer ??= FirebaseAnalyticsObserver(analytics: _analytics);
    return _observer!;
  }

  /// Track when a user logs in
  Future<void> logLogin({String? method}) async {
    try {
      debugPrint(
          'Analytics: Logging login event with method: ${method ?? 'email'}');
      await _analytics.logLogin(loginMethod: method ?? 'email');
    } catch (e) {
      debugPrint('Error logging login event: $e');
    }
  }

  /// Track when a user signs up
  Future<void> logSignUp({String? method}) async {
    try {
      debugPrint(
          'Analytics: Logging sign up event with method: ${method ?? 'email'}');
      await _analytics.logSignUp(signUpMethod: method ?? 'email');
    } catch (e) {
      debugPrint('Error logging sign up event: $e');
    }
  }

  /// Track when a user adds food to their log
  Future<void> logFoodAdded(
      {required String foodName, double? calories}) async {
    try {
      debugPrint(
          'Analytics: Logging food added event: $foodName, calories: $calories');
      await _analytics.logEvent(
        name: 'food_logged',
        parameters: {
          'food_name': foodName,
          'calories': calories,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error logging food added event: $e');
    }
  }

  /// Track when a user logs an exercise
  Future<void> logExerciseAdded({
    required String exerciseType,
    String? exerciseName,
    int? duration,
  }) async {
    try {
      debugPrint(
          'Analytics: Logging exercise added event: type=$exerciseType, name=$exerciseName, duration=$duration');
      await _analytics.logEvent(
        name: 'exercise_logged',
        parameters: {
          'exercise_type': exerciseType,
          'exercise_name': exerciseName,
          'duration': duration,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error logging exercise added event: $e');
    }
  }

  /// Track when a user views their progress
  Future<void> logProgressViewed({String? category}) async {
    try {
      debugPrint(
          'Analytics: Logging progress viewed event for category: ${category ?? 'all'}');
      await _analytics.logEvent(
        name: 'progress_viewed',
        parameters: {
          'category': category ?? 'all',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error logging progress viewed event: $e');
    }
  }

  /// Track screen views
  Future<void> logScreenView(
      {required String screenName, String? screenClass}) async {
    try {
      debugPrint(
          'Analytics: Logging screen view for screen: $screenName, class: $screenClass');
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('Error logging screen view: $e');
    }
  }

  /// Track when a user updates their health metrics
  Future<void> logHealthMetricsUpdated() async {
    try {
      debugPrint('Analytics: Logging health metrics updated event');
      await _analytics.logEvent(
        name: 'health_metrics_updated',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error logging health metrics update: $e');
    }
  }

  /// Enable analytics collection (can be toggled by user)
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      debugPrint('Analytics: Setting analytics collection to: $enabled');
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('Error setting analytics collection: $e');
    }
  }

  /// Log a custom event to analytics
  Future<void> logEvent(
      {required String name, Map<String, dynamic>? parameters}) async {
    try {
      debugPrint(
          'Analytics: Logging custom event: $name, parameters: $parameters');
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Error logging custom event: $e');
    }
  }
}
