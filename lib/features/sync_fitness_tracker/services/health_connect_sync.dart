import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'dart:async';

class FitnessTrackerSync {
  /// Health plugin instance
  final Health _health;

  /// Method channel for platform interactions
  final MethodChannel _methodChannel;

  // Constructor with dependency injection
  FitnessTrackerSync({
    Health? health,
    MethodChannel? methodChannel,
  })  : _health = health ?? Health(),
        _methodChannel =
            methodChannel ?? const MethodChannel('com.pockeat/health_connect');

  /// The required data types
  final List<HealthDataType> _requiredTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  /// Local permission state to handle Health Connect inconsistencies
  bool _localPermissionState = false;

  /// Reset the cached permission state to force a fresh check
  void resetPermissionState() {
    _localPermissionState = false;
  }

  /// Access to Health instance (protected for testing)
  @protected
  Health get health => _health;

  /// Access to MethodChannel (protected for testing)
  @protected
  MethodChannel get methodChannel => _methodChannel;

  /// Access to required types (protected for testing)
  @protected
  List<HealthDataType> get requiredTypes => _requiredTypes;

  /// Initialize and check permissions in one step
  Future<bool> initializeAndCheckPermissions() async {
    try {
      debugPrint('Initializing health services...');
      // Configure health plugin - make this overridable in test subclass
      await configureHealth();

      // Check if Health Connect is available (Android only)
      if (Platform.isAndroid) {
        final isAvailable = await _health.isHealthConnectAvailable();
        debugPrint('Health Connect available: $isAvailable');
        if (!isAvailable) {
          return false;
        }
      }

      // Always do a fresh permission check at initialization
      _localPermissionState = false;

      // Try a direct permission check
      final hasPermissions = await hasRequiredPermissions();
      debugPrint('Has permissions check result: $hasPermissions');

      if (hasPermissions == true) {
        _localPermissionState = true;
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error in initializeAndCheckPermissions: $e');
      return false;
    }
  }

  /// Configure the health plugin (can be overridden in tests)
  @protected
  Future<void> configureHealth() async {
    await _health.configure();
  }

  /// Check if we have required permissions by actually trying to read data
  Future<bool> hasRequiredPermissions() async {
    // If we already know we have permissions, return early
    if (_localPermissionState) {
      debugPrint('Using cached permission state: $_localPermissionState');
      return _localPermissionState;
    }

    try {
      debugPrint('Checking permissions by direct data access...');

      // First try the canReadHealthData method which attempts to read data
      if (await canReadHealthData()) {
        _localPermissionState = true;
        return true;
      }

      // If we get here without getting any data or clear permission denial
      // Fall back to the hasPermissions check
      final hasPermissions = await _health.hasPermissions(_requiredTypes);
      debugPrint('Falling back to hasPermissions check: $hasPermissions');
      _localPermissionState = hasPermissions == true;
      return hasPermissions == true;
    } catch (e) {
      debugPrint('Error in hasRequiredPermissions: $e');
      _localPermissionState = false;
      return false;
    }
  }

  /// Attempt to read some data to check if we actually have permissions
  @protected
  Future<bool> canReadHealthData() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Try to read steps first
      try {
        await _health.getTotalStepsInInterval(yesterday, now);
        return true;
      } catch (e) {
        if (e.toString().contains("SecurityException")) {
          debugPrint('Permission denied: $e');
          _localPermissionState = false;
          return false;
        }
        debugPrint('Error reading steps: $e');
      }

      // Try reading any available data
      try {
        final results = await _health.getHealthDataFromTypes(
          types: _requiredTypes,
          startTime: yesterday,
          endTime: now,
        );

        // If we get here without an exception, we have permission
        debugPrint('Successfully read ${results.length} health records');
        return true;
      } catch (e) {
        if (e.toString().contains("SecurityException")) {
          debugPrint('Permission denied: $e');
          _localPermissionState = false;
          return false;
        }
        debugPrint('Error reading health data: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error in canReadHealthData: $e');
      return false;
    }
  }

  Future<void> openHealthConnect(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      // Launch Health Connect using the injected channel
      await _methodChannel.invokeMethod('launchHealthConnect');

      // We'll attempt to verify permissions later when app resumes
      return;
    } catch (e) {
      debugPrint('Error launching Health Connect: $e');
    }
  }

  /// Request authorization for required health data types
  Future<bool> requestAuthorization() async {
    try {
      debugPrint('Requesting authorization for health data types...');

      // Request permissions
      final granted = await _health.requestAuthorization(_requiredTypes);
      debugPrint('Authorization request result: $granted');

      if (granted) {
        _localPermissionState = true;
      } else {
        _localPermissionState = false;
      }

      return granted;
    } catch (e) {
      debugPrint('Error in requestAuthorization: $e');
      _localPermissionState = false;
      return false;
    }
  }

  /// Perform a forced data read to ensure permissions are working
  Future<bool> performForcedDataRead() async {
    debugPrint('Performing forced data read...');
    try {
      final result = await canReadHealthData();
      if (result) {
        _localPermissionState = true;
      } else {
        _localPermissionState = false;
      }
      return result;
    } catch (e) {
      debugPrint('Error in forced data read: $e');
      _localPermissionState = false;
      return false;
    }
  }

  /// Get today's fitness data (steps and calories)
  Future<Map<String, dynamic>> getTodayFitnessData() async {
    debugPrint('Getting today\'s fitness data...');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize with default values
    final Map<String, dynamic> todayData = {
      'steps': 0,
      'calories': 0,
      'hasPermissions': true,
    };

    try {
      // Get steps
      final steps = await getStepsForDay(today);
      todayData['steps'] = steps ?? 0;

      // Get calories
      final calories = await getCaloriesBurnedForDay(today);
      todayData['calories'] = calories ?? 0;

      debugPrint(
          'Today\'s data: Steps=${todayData['steps']}, Calories=${todayData['calories']}');

      // If we got zero data, check if we still have permissions
      if (todayData['steps'] == 0 && todayData['calories'] == 0) {
        // Verify permissions
        final directPermissionCheck = await hasRequiredPermissions();
        if (!directPermissionCheck) {
          todayData['hasPermissions'] = false;
          _localPermissionState = false;
        }
      }
    } catch (e) {
      debugPrint('Error getting fitness data: $e');
      if (e.toString().contains("SecurityException")) {
        todayData['hasPermissions'] = false;
        _localPermissionState = false;
      }
    }

    return todayData;
  }

  /// Get step count for a specific day
  Future<int?> getStepsForDay(DateTime date) async {
    debugPrint('Getting steps for ${formatDate(date)}...');

    // Create date range for the entire day
    final DateTimeRange dateRange = getDateRange(date);
    final startTime = dateRange.start;
    final endTime = dateRange.end;

    try {
      // Try to get the step count using the specialized method first
      try {
        final steps = await _health.getTotalStepsInInterval(startTime, endTime);
        debugPrint('Steps from getTotalStepsInInterval: $steps');

        if (steps != null && steps > 0) {
          // We successfully read steps, so we have permission
          _localPermissionState = true;
          return steps;
        }
      } catch (e) {
        debugPrint('Error with getTotalStepsInInterval: $e');
        if (e.toString().contains("SecurityException")) {
          _localPermissionState = false;
          throw e; // Rethrow to handle at higher level
        }
      }

      // Try the more general method
      try {
        final results = await _health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: startTime,
          endTime: endTime,
        );

        // Sum up all step counts from the results
        int totalSteps = 0;
        for (final dataPoint in results) {
          if (dataPoint.type == HealthDataType.STEPS) {
            totalSteps +=
                (dataPoint.value as NumericHealthValue).numericValue.toInt();
          }
        }

        debugPrint(
            'Steps from getHealthDataFromTypes: $totalSteps (${results.length} records)');
        if (totalSteps > 0) {
          _localPermissionState = true;
          return totalSteps;
        }
      } catch (e) {
        if (e.toString().contains("SecurityException")) {
          debugPrint('Permission denied for steps data: $e');
          _localPermissionState = false;
          throw e; // Rethrow to handle at higher level
        }
        debugPrint('Error with getHealthDataFromTypes: $e');
      }

      // Return 0 if no steps found
      return 0;
    } catch (e) {
      debugPrint('Error getting steps: $e');
      if (e.toString().contains("SecurityException")) {
        _localPermissionState = false;
        throw e; // Rethrow to handle at higher level
      }
      return 0;
    }
  }

  /// Get calories burned for a specific day
  Future<double?> getCaloriesBurnedForDay(DateTime date) async {
    debugPrint('Getting calories for ${formatDate(date)}...');

    // Create date range for the entire day
    final DateTimeRange dateRange = getDateRange(date);
    final startTime = dateRange.start;
    final endTime = dateRange.end;

    try {
      // Request calories data from both active energy and total calories
      try {
        final results = await _health.getHealthDataFromTypes(
          types: [
            HealthDataType.ACTIVE_ENERGY_BURNED,
            HealthDataType.TOTAL_CALORIES_BURNED,
          ],
          startTime: startTime,
          endTime: endTime,
        );

        debugPrint('Calories data records: ${results.length}');

        // Try to get Total Calories Burned first, as it's more comprehensive
        double totalCalories = 0;
        bool hasTotalCalories = false;

        for (final dataPoint in results) {
          if (dataPoint.type == HealthDataType.TOTAL_CALORIES_BURNED) {
            totalCalories +=
                (dataPoint.value as NumericHealthValue).numericValue.toDouble();
            hasTotalCalories = true;
          }
        }

        // If no total calories found, use active energy burned
        if (!hasTotalCalories) {
          for (final dataPoint in results) {
            if (dataPoint.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              totalCalories += (dataPoint.value as NumericHealthValue)
                  .numericValue
                  .toDouble();
            }
          }
        }

        debugPrint(
            'Total calories: $totalCalories, from total calories: $hasTotalCalories');
        if (totalCalories > 0) {
          _localPermissionState = true;
          return totalCalories;
        }
      } catch (e) {
        if (e.toString().contains("SecurityException")) {
          debugPrint('Permission denied for calories: $e');
          _localPermissionState = false;
          throw e; // Rethrow to handle at higher level
        }
        debugPrint('Error getting calories data: $e');
      }

      // Return 0 if no calories found
      return 0;
    } catch (e) {
      debugPrint('Error getting calories burned: $e');
      if (e.toString().contains("SecurityException")) {
        _localPermissionState = false;
        throw e; // Rethrow to handle at higher level
      }
      return 0;
    }
  }

  /// Helper method to get date range for a day (testable)
  @protected
  DateTimeRange getDateRange(DateTime date) {
    final startTime = DateTime(date.year, date.month, date.day);
    final endTime = startTime
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    return DateTimeRange(start: startTime, end: endTime);
  }

  /// Check if Health Connect is available
  Future<bool> isHealthConnectAvailable() async {
    try {
      if (Platform.isAndroid) {
        if (await _health.isHealthConnectAvailable()) {
          return true;
        }
        return false;
      }
      // iOS uses HealthKit which is different
      return true;
    } catch (e) {
      debugPrint('Error checking Health Connect availability: $e');
      return false; // Better to return false on error
    }
  }

  /// Open the Google Play Store to install Health Connect
  Future<void> openHealthConnectPlayStore() async {
    if (Platform.isAndroid) {
      try {
        await _methodChannel.invokeMethod('openHealthConnectPlayStore');
      } catch (e) {
        debugPrint('Error opening Play Store: $e');
      }
    }
  }

  /// Manually set the permission state (for fixing permission detection issues)
  @protected
  void setPermissionGranted() {
    _localPermissionState = true;
  }

  /// Format readable date
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
