// Dart imports:
import 'dart:async';

/// Abstract interface for updating widgets in background tasks
abstract class WidgetUpdaterService {
  /// Updates widgets with current user data
  ///
  /// Takes a map of services already initialized for background tasks.
  /// Returns void, but should handle any errors internally.
  Future<void> updateWidgets(Map<String, dynamic> services);

  /// Calculates the consumed calories for today
  ///
  /// Takes a map of services and the userId to calculate for.
  /// Returns the calculated calories consumed today.
  Future<int> calculateConsumedCalories(
      Map<String, dynamic> services, String userId);

  /// Calculates the target calories based on user health metrics
  ///
  /// Takes a map of services and the userId to calculate for.
  /// Returns the calculated target calories.
  Future<int> calculateTargetCalories(
      Map<String, dynamic> services, String userId);
}
