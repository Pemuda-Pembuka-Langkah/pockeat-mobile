// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:pockeat/core/service/background_dependency_service.dart';
import 'package:pockeat/core/utils/background_logger.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/background_service_config.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/widget_updater_service_impl.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_background_service.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_updater_service.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/services/impl/notification_background_displayer_service_impl.dart';
import 'package:pockeat/features/notifications/domain/services/notification_background_displayer_service.dart';

// Flutter imports:

const String _tag = "BACKGROUND_MANAGER";

// coverage:ignore-start
/// Main callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await BackgroundLogger.log("Task received: $taskName", tag: _tag);

      // Setup all dependencies needed for background tasks
      final services = await BackgroundServiceManager.setupDependencies();
      await BackgroundLogger.log(
          "Dependencies set up with ${services.length} services",
          tag: _tag);

      // Handle tasks using a switch statement
      switch (taskName) {
        case NotificationConstants.streakCalculationTaskName:
          await BackgroundLogger.log("Handling streak notification task",
              tag: _tag);
          final NotificationBackgroundDisplayerService notificationDisplayer =
              NotificationBackgroundDisplayerServiceImpl();
          final result =
              await notificationDisplayer.showStreakNotification(services);
          await BackgroundLogger.log("Streak notification result: $result",
              tag: _tag);
          break;

        case BackgroundServiceConfig.PERIODIC_UPDATE_TASK_ID:
          await BackgroundLogger.log(
              "Forwarding to widget background service handler",
              tag: _tag);
          // Delegate to the widget service's callback handler
          await BackgroundServiceManager._updateWidgets(services);
          await BackgroundLogger.log("Widget task delegation complete",
              tag: _tag);
          break;

        case BackgroundServiceConfig.MIDNIGHT_UPDATE_TASK_ID:
          await BackgroundLogger.log(
              "Forwarding to widget background service handler",
              tag: _tag);
          // Delegate to the widget service's callback handler
          await BackgroundServiceManager._updateWidgets(services);
          await WidgetBackgroundService.registerMidnightTask();

          await BackgroundLogger.log("Widget task delegation complete",
              tag: _tag);
          break;

        default:
          await BackgroundLogger.log("No specific handler for task: $taskName",
              tag: _tag);
          break;
      }

      await BackgroundLogger.log("Task completed: $taskName", tag: _tag);
      return true;
    } catch (e) {
      await BackgroundLogger.log("Error in callback dispatcher: $e", tag: _tag);
      return false;
    }
  });
}

/// A centralized manager for background services
class BackgroundServiceManager {
  /// Initialize WorkManager with a single callback dispatcher
  static Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('Background services only supported on Android');
      return;
    }

    try {
      // Initialize WorkManager with the centralized callback dispatcher
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      await BackgroundLogger.log("Background Service Manager initialized",
          tag: _tag);
    } catch (e) {
      debugPrint('Failed to initialize background service manager: $e');
      await BackgroundLogger.log("Failed to initialize: $e", tag: _tag);
    }
  }

  /// Helper method to update widgets using the dedicated WidgetUpdaterService
  static Future<void> _updateWidgets(Map<String, dynamic> services) async {
    try {
      await BackgroundLogger.log("Updating widgets via WidgetUpdaterService",
          tag: _tag);

      // Create and use the widget updater service
      final WidgetUpdaterService widgetUpdater = WidgetUpdaterServiceImpl();
      await widgetUpdater.updateWidgets(services);

      await BackgroundLogger.log("Widget update completed", tag: _tag);
    } catch (e) {
      await BackgroundLogger.log("Error updating widgets: $e", tag: _tag);
    }
  }

  /// Setup dependencies for background services
  static Future<Map<String, dynamic>> setupDependencies() async {
    await BackgroundLogger.log(
        "Setting up dependencies via BackgroundDependencyService",
        tag: _tag);
    return await BackgroundDependencyService.setupDependencies();
  }
}
// coverage:ignore-end
