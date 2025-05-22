// Project imports:
import 'package:pockeat/features/home_screen_widget/services/widget_background_service.dart';

// coverage:ignore-start

/// Interface untuk WidgetBackgroundService yang memudahkan mocking di unit tests
abstract class WidgetBackgroundServiceHelperInterface {
  /// Initialize workmanager untuk background task
  Future<void> registerTasks();

  /// Cancel semua background task
  Future<void> cancelAllTasks();
}

/// Default implementation of WidgetBackgroundServiceHelperInterface using WidgetBackgroundService
class WidgetBackgroundServiceHelper
    implements WidgetBackgroundServiceHelperInterface {
  @override
  Future<void> registerTasks() async {
    await WidgetBackgroundService.registerTasks();
  }

  @override
  Future<void> cancelAllTasks() async {
    await WidgetBackgroundService.cancelAllTasks();
  }
}
// coverage:ignore-end
