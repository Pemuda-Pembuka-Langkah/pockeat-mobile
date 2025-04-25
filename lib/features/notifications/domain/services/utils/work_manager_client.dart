// Package imports:
import 'package:workmanager/workmanager.dart';

// coverage-ignore:start

/// Wrapper for WorkManager that allows mocking in tests
class WorkManagerClient {
  // Initialization method has been removed and is now centralized in BackgroundServiceManager

  /// Register a periodic task with WorkManager
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration frequency = const Duration(days: 1),
    Duration? initialDelay,
    Constraints? constraints,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    Map<String, dynamic>? inputData,
    ExistingWorkPolicy? existingWorkPolicy = ExistingWorkPolicy.keep,
    OutOfQuotaPolicy? outOfQuotaPolicy,
  }) async {
    // Instead of using a params map with possible null values,
    // call the method conditionally with only non-null parameters
    if (initialDelay != null &&
        constraints != null &&
        backoffPolicy != null &&
        backoffPolicyDelay != null &&
        inputData != null &&
        outOfQuotaPolicy != null) {
      // All parameters are present
      await Workmanager().registerPeriodicTask(
        uniqueName,
        taskName,
        frequency: frequency,
        initialDelay: initialDelay,
        constraints: constraints,
        backoffPolicy: backoffPolicy,
        backoffPolicyDelay: backoffPolicyDelay,
        inputData: inputData,
        existingWorkPolicy: existingWorkPolicy,
        outOfQuotaPolicy: outOfQuotaPolicy,
      );
    } else if (initialDelay != null) {
      // Only initialDelay is present (common case)
      await Workmanager().registerPeriodicTask(
        uniqueName,
        taskName,
        frequency: frequency,
        initialDelay: initialDelay,
        existingWorkPolicy: existingWorkPolicy,
      );
    } else {
      // Basic case - only required parameters
      await Workmanager().registerPeriodicTask(
        uniqueName,
        taskName,
        frequency: frequency,
        existingWorkPolicy: existingWorkPolicy,
      );
    }
  }

  /// Cancel a task by unique name
  Future<void> cancelByUniqueName(String uniqueName) async {
    await Workmanager().cancelByUniqueName(uniqueName);
  }

  /// Cancel all tasks
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}

// coverage-ignore:end
