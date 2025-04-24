// Package imports:
import 'package:workmanager/workmanager.dart';

/// Wrapper for WorkManager that allows mocking in tests
class WorkManagerClient {
  /// Initialize the WorkManager with a callback dispatcher
  // coverage:ignore-start
  Future<void> initialize(
    Function callbackDispatcher, {
    bool isInDebugMode = false,
  }) async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: isInDebugMode,
    );
  }
  // coverage:ignore-end

  /// Register a periodic task with WorkManager
  // coverage:ignore-start
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration frequency = const Duration(days: 1),
    Duration? initialDelay,
    Constraints? constraints,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    Map<String, dynamic>? inputData,
    ExistingWorkPolicy? existingWorkPolicy,
    OutOfQuotaPolicy? outOfQuotaPolicy,
  }) async {
    // Create a map of parameters that filters out null values
    final Map<String, dynamic> params = {};

    // Required parameters
    params['frequency'] = frequency;

    // Optional parameters - only add if not null
    if (initialDelay != null) params['initialDelay'] = initialDelay;
    if (constraints != null) params['constraints'] = constraints;
    if (backoffPolicy != null) params['backoffPolicy'] = backoffPolicy;
    if (backoffPolicyDelay != null) {
      params['backoffPolicyDelay'] = backoffPolicyDelay;
    }
    if (inputData != null) params['inputData'] = inputData;
    params['existingWorkPolicy'] =
        existingWorkPolicy ?? ExistingWorkPolicy.keep;
    if (outOfQuotaPolicy != null) params['outOfQuotaPolicy'] = outOfQuotaPolicy;

    // Use spread operator to pass only non-null parameters
    await Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: params['frequency'],
      initialDelay: params['initialDelay'],
      constraints: params['constraints'],
      backoffPolicy: params['backoffPolicy'],
      backoffPolicyDelay: params['backoffPolicyDelay'],
      inputData: params['inputData'],
      existingWorkPolicy: params['existingWorkPolicy'],
      outOfQuotaPolicy: params['outOfQuotaPolicy'],
    );
  }
  // coverage:ignore-end

  /// Cancel a task by unique name
  // coverage:ignore-start
  Future<void> cancelByUniqueName(String uniqueName) async {
    await Workmanager().cancelByUniqueName(uniqueName);
  }
  // coverage:ignore-end

  /// Cancel all tasks
  // coverage:ignore-start
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
  // coverage:ignore-end
}
