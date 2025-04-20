import 'package:pockeat/features/home_screen_widget/services/widget_background_service.dart';

// coverage:ignore-file
/// Interface untuk WidgetBackgroundService yang memudahkan mocking di unit tests
abstract class WidgetBackgroundServiceHelperInterface {
  /// Initialize workmanager untuk background task
  Future<void> initialize();
  
  /// Register periodic task untuk update widget
  Future<void> registerPeriodicTask();
  
  /// Register midnight task untuk update di jam 00:00
  Future<void> registerMidnightTask();
  
  /// Cancel semua background task
  Future<void> cancelAllTasks();
}

/// Default implementation of WidgetBackgroundServiceHelperInterface using WidgetBackgroundService
class WidgetBackgroundServiceHelper implements WidgetBackgroundServiceHelperInterface {
  @override
  Future<void> initialize() async {
    await WidgetBackgroundService.initialize();
  }
  
  @override
  Future<void> registerPeriodicTask() async {
    await WidgetBackgroundService.registerPeriodicTask();
  }
  
  @override
  Future<void> registerMidnightTask() async {
    await WidgetBackgroundService.registerMidnightTask();
  }
  
  @override
  Future<void> cancelAllTasks() async {
    await WidgetBackgroundService.cancelAllTasks();
  }
}
