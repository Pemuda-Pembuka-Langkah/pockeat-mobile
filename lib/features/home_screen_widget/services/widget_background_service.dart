// lib/features/home_screen_widget/services/widget_background_service.dart

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/background_service_config.dart';

// coverage:ignore-start
class WidgetBackgroundService {
  /// Now we only register the tasks, initialization happens in BackgroundServiceManager
  static Future<void> registerTasks() async {
    // Just register our tasks
    await registerPeriodicTask();
    await registerMidnightTask();
  }

  /// Register periodic task untuk update widget
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      BackgroundServiceConfig.periodicUpdateTaskId.value,
      BackgroundServiceConfig.periodicUpdateTaskName.value,
      // Set task untuk berjalan setiap 5 menit
      frequency: const Duration(minutes: 5),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      // Ini untuk delay retry jika task gagal, bukan frekuensi task
      backoffPolicyDelay: const Duration(minutes: 1),
    );
  }

  /// Register one-time task untuk midnight update (00:00)
  static Future<void> registerMidnightTask() async {
    // Hitung waktu untuk besok 00:00
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0);
    final initialDelay = midnight.difference(now);

    await Workmanager().registerOneOffTask(
      BackgroundServiceConfig.midnightUpdateTaskId.value,
      BackgroundServiceConfig.midnightUpdateTaskName.value,
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false, // Tidak perlu sedang mengisi daya
      ),
    );
  }

  /// Batalkan semua task yang terdaftar
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
}

// NOTE: This function is no longer used. We now use the centralized dispatcher in BackgroundServiceManager.
/*
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final services = await WidgetServiceLocator.setupBackgroundServices();

      switch (task) {
        case BackgroundServiceConfig.PERIODIC_UPDATE_TASK_ID:
          await _updateWidgets(services);

          // Setup lagi midnight task jika periodic task berjalan
          await WidgetBackgroundService.registerMidnightTask();
          break;

        case BackgroundServiceConfig.MIDNIGHT_UPDATE_TASK_ID:
          await _updateWidgets(services);

          // Re-schedule task untuk midnight besok
          await WidgetBackgroundService.registerMidnightTask();
          break;

        default:
          break;
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}
*/

// coverage:ignore-end
