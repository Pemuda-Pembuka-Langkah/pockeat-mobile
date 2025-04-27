// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:pockeat/core/service/background_dependency_service.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/background_service_config.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/widget_updater_service_impl.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_background_service.dart';
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
        case NotificationConstants.petStatusUpdateTaskName:
          final NotificationBackgroundDisplayerService notificationDisplayer =
              NotificationBackgroundDisplayerServiceImpl();
          await notificationDisplayer.showPetStatusNotification(services);

          break;
            
        case NotificationConstants.streakCalculationTaskName:
          final NotificationBackgroundDisplayerService notificationDisplayer =
              NotificationBackgroundDisplayerServiceImpl();
          await notificationDisplayer.showStreakNotification(services);

          break;

        // Handler for pet sadness notification task
        case NotificationConstants.petSadnessCheckTaskName:
          final NotificationBackgroundDisplayerService notificationDisplayer =
              NotificationBackgroundDisplayerServiceImpl();
          await notificationDisplayer.showPetSadnessNotification(services);
          break;

        // Add handlers for meal reminder tasks
        case NotificationConstants
              .mealReminderTaskName: // Generic meal reminder task
        case NotificationConstants
              .breakfastReminderTaskName: // Breakfast specific
        case NotificationConstants.lunchReminderTaskName: // Lunch specific
        case NotificationConstants.dinnerReminderTaskName: // Dinner specific
          // Determine meal type directly from the task name
          String? mealType;

          if (taskName == NotificationConstants.breakfastReminderTaskName) {
            mealType = NotificationConstants.breakfast;
          } else if (taskName == NotificationConstants.lunchReminderTaskName) {
            mealType = NotificationConstants.lunch;
          } else if (taskName == NotificationConstants.dinnerReminderTaskName) {
            mealType = NotificationConstants.dinner;
          }

          final NotificationBackgroundDisplayerService notificationDisplayer =
              NotificationBackgroundDisplayerServiceImpl();

          if (mealType != null) {
            await notificationDisplayer.showMealReminderNotification(
                services, mealType);
          } else {}
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
    } catch (e, stackTrace) {
      debugPrint('Error in callback dispatcher: $e\nStack trace: $stackTrace');
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
