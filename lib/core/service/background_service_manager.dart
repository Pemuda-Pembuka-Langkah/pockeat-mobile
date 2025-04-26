// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_background_service.dart';

// Package imports:
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:pockeat/core/service/background_dependency_service.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/background_service_config.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/widget_updater_service_impl.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_updater_service.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/services/impl/notification_background_displayer_service_impl.dart';
import 'package:pockeat/features/notifications/domain/services/notification_background_displayer_service.dart';

// coverage:ignore-start
/// Main callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // Setup all dependencies needed for background tasks
      final services = await BackgroundServiceManager.setupDependencies();

      // Handle tasks using a switch statement
      switch (taskName) {
        case NotificationConstants.streakCalculationTaskName:
          final NotificationBackgroundDisplayerService notificationDisplayer =
              NotificationBackgroundDisplayerServiceImpl();
          await notificationDisplayer.showStreakNotification(services);
          break;
          
        // Add handlers for meal reminder tasks
        case NotificationConstants.mealReminderTaskName: // Use constant instead of hardcoded string
          final NotificationBackgroundDisplayerService notificationDisplayer =
              NotificationBackgroundDisplayerServiceImpl();
          // Get the meal type from inputData
          final mealType = inputData?['meal_type'] as String?;
          if (mealType != null) {
            await notificationDisplayer.showMealReminderNotification(services, mealType);
          }
          break;

        case BackgroundServiceConfig.PERIODIC_UPDATE_TASK_ID:
          // Delegate to the widget service's callback handler
          await BackgroundServiceManager._updateWidgets(services);
          break;

        case BackgroundServiceConfig.MIDNIGHT_UPDATE_TASK_ID:
          // Delegate to the widget service's callback handler
          await BackgroundServiceManager._updateWidgets(services);
          await WidgetBackgroundService.registerMidnightTask();
          break;

        default:
          break;
      }

      return true;
    } catch (e) {
      debugPrint('Error in callback dispatcher: $e');
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
    } catch (e) {
      debugPrint('Failed to initialize background service manager: $e');
    }
  }

  /// Helper method to update widgets using the dedicated WidgetUpdaterService
  static Future<void> _updateWidgets(Map<String, dynamic> services) async {
    try {
      // Create and use the widget updater service
      final WidgetUpdaterService widgetUpdater = WidgetUpdaterServiceImpl();
      await widgetUpdater.updateWidgets(services);
    } catch (e) {
      debugPrint('Error updating widgets: $e');
    }
  }

  /// Setup dependencies for background services
  static Future<Map<String, dynamic>> setupDependencies() async {
    return await BackgroundDependencyService.setupDependencies();
  }
}
// coverage:ignore-end
