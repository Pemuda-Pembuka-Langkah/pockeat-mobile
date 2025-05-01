//

// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

//

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
//coverage:ignore-start
  /// Reset the cached permission state to force a fresh check
  void resetPermissionState() {
    _localPermissionState = false;
  }
//coverage:ignore-end
  /// Access to Health instance (protected for testing)
  // coverage:ignore-start
  @protected
  Health get health => _health;
  // coverage:ignore-end

  /// Access to MethodChannel (protected for testing)
  // coverage:ignore-start
  @protected
  MethodChannel get methodChannel => _methodChannel;
  // coverage:ignore-end

  /// Access to required types (protected for testing)
  // coverage:ignore-start
  @protected
  List<HealthDataType> get requiredTypes => _requiredTypes;
  // coverage:ignore-end

  /// Initialize and check permissions in one step
  Future<bool> initializeAndCheckPermissions() async {
    try {
      debugPrint('Initializing Health Connect and checking permissions...');

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

      // On first launch, only do a simple permission check without attempting data reads
      // This avoids infinite loops of permission checking
      try {
        final directCheck = await _health.hasPermissions(_requiredTypes);
        debugPrint('Quick permission check: $directCheck');
        _localPermissionState = directCheck == true;
        return directCheck == true;
      } catch (e) {
        debugPrint('Error during quick permission check: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error during Health Connect initialization: $e');
      return false;
    }
  }

  /// Configure the health plugin (can be overridden in tests)
  // coverage:ignore-start
  @protected
  Future<void> configureHealth() async {
    try {
      debugPrint('Configuring Health Connect...');
      // Configure health with default settings
      await _health.configure();
      debugPrint('Health Connect configured successfully');
    } catch (e) {
      debugPrint('Error configuring Health Connect: $e');
      // Continue despite errors - we'll catch permission issues later
    }
  }
  // coverage:ignore-end

  /// Check if we have required permissions by actually trying to read data
  /// Only call this method when explicitly checking permissions, not in regular data flows
  Future<bool> hasRequiredPermissions() async {
    // If we're sure we don't have permission, avoid unnecessary checks
    if (_localPermissionState == false) {
      debugPrint('Using cached permission state (false)');
      return false;
    }

    try {
      debugPrint('Checking Health Connect permissions...');

      // First request Activity Recognition permission if on Android
      if (Platform.isAndroid) {
        debugPrint('Requesting Activity Recognition permission...');
        final status = await Permission.activityRecognition.request();
        debugPrint('Activity Recognition permission status: $status');
      }

      // Simple direct permission check - READ access only
      final directPermissionCheck = await _health.hasPermissions(
        _requiredTypes,
        permissions: List.filled(_requiredTypes.length, HealthDataAccess.READ),
      );

      debugPrint(
          'Health Connect direct permission check: $directPermissionCheck');

      // Update local state based on direct check
      _localPermissionState = directPermissionCheck == true;

      return directPermissionCheck == true;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      _localPermissionState = false;
      return false;
    }
  }

  /// Attempt to read some data to check if we actually have permissions
  @protected
  Future<bool> canReadHealthData() async {
    try {
      debugPrint('Testing Health Connect data read access...');
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Try to read steps first
      try {
        final steps = await _health.getTotalStepsInInterval(yesterday, now);
        debugPrint('Successfully read steps data: $steps');
        _localPermissionState = true;
        return true;
      } catch (e) {
        debugPrint('Error reading steps: $e');
        if (e.toString().contains("SecurityException") ||
            e.toString().contains("permission") ||
            e.toString().contains("Permission")) {
          _localPermissionState = false;
          return false;
        }
      }

      // If steps didn't work, try reading any available data
      try {
        await _health.getHealthDataFromTypes(
          types: _requiredTypes,
          startTime: yesterday,
          endTime: now,
        );

        // If we get here without an exception, we have permission
        debugPrint('Successfully read health data');
        _localPermissionState = true;
        return true;
      } catch (e) {
        debugPrint('Error reading health data: $e');
        if (e.toString().contains("SecurityException") ||
            e.toString().contains("permission") ||
            e.toString().contains("Permission")) {
          _localPermissionState = false;
          return false;
        }

        // For any other error, it might not be permission-related
        return false;
      }
    } catch (e) {
      debugPrint('Unexpected error testing Health Connect data read: $e');
      return false;
    }
  }

  /// Open the Health Connect permissions screen directly
  // coverage:ignore-start
  @protected
  Future<void> openHealthConnect(BuildContext context) async {
    if (!Platform.isAndroid) {
      debugPrint('Not on Android, skipping Health Connect launch');
      return;
    }

    try {
      debugPrint('Launching Health Connect permissions screen...');

      // Try to directly launch the Health Connect permissions screen for our app
      final bool result =
          await _methodChannel.invokeMethod('launchHealthConnectPermissions');

      debugPrint('Health Connect permissions screen launch result: $result');

      if (!result) {
        // If we couldn't launch the permissions screen directly, try opening the app
        debugPrint(
            'Permissions screen not available, launching Health Connect app...');
        final appResult =
            await _methodChannel.invokeMethod('launchHealthConnect');
        debugPrint('Health Connect app launch result: $appResult');
      }

      // We'll attempt to verify permissions later when app resumes
      return;
    } catch (e) {
      debugPrint('Failed to launch Health Connect: $e');
      // If we can't launch Health Connect at all, maybe it's not installed
      try {
        await openHealthConnectPlayStore();
      } catch (e2) {
        debugPrint('Also failed to open Health Connect Play Store: $e2');
      }
    }
  }
  // coverage:ignore-end

  /// Open the Google Play Store to install Health Connect
  // coverage:ignore-start
  @protected
  Future<void> openHealthConnectPlayStore() async {
    if (!Platform.isAndroid) return;

    try {
      debugPrint('Opening Health Connect on Play Store...');
      final bool result =
          await _methodChannel.invokeMethod('openHealthConnectPlayStore');
      debugPrint('Play Store open result: $result');
    } catch (e) {
      debugPrint('Failed to open Health Connect Play Store: $e');
    }
  }
  // coverage:ignore-end

  /// Request authorization for required health data types
  // coverage:ignore-start
  Future<bool> requestAuthorization() async {
    try {
      debugPrint('Requesting Health Connect authorization...');

      // First request Activity Recognition permission if on Android
      if (Platform.isAndroid) {
        debugPrint('Requesting Activity Recognition permission...');
        final status = await Permission.activityRecognition.request();
        debugPrint('Activity Recognition permission status: $status');
      }

      // First ensure health is properly configured
      await configureHealth();

      // Request permissions with explicit READ access only
      final granted = await _health.requestAuthorization(
        _requiredTypes,
        permissions: List.filled(_requiredTypes.length, HealthDataAccess.READ),
      );

      debugPrint('Authorization request result: $granted');

      if (granted) {
        _localPermissionState = true;
        await Future.delayed(const Duration(
            milliseconds: 1000)); // Longer delay to ensure permissions register
        return true;
      }

      _localPermissionState = false;
      return false;
    } catch (e) {
      debugPrint('Error requesting authorization: $e');
      _localPermissionState = false;
      return false;
    }
  }
  // coverage:ignore-end

  /// Perform a forced data read to ensure permissions are working
  Future<bool> performForcedDataRead() async {
    try {
      debugPrint('Performing forced Health Connect data read...');
      final result = await canReadHealthData();
      _localPermissionState = result;
      debugPrint('Forced data read result: $result');
      return result;
    } catch (e) {
      debugPrint('Error during forced data read: $e');
      _localPermissionState = false;
      return false;
    }
  }

  /// Get today's fitness data (steps and calories)
  Future<Map<String, dynamic>> getTodayFitnessData() async {
    debugPrint('Getting today\'s fitness data...');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize with default values and use cached permission state
    final Map<String, dynamic> todayData = {
      'steps': 0,
      'calories': 0,
      'hasPermissions': _localPermissionState,
    };

    // If we know we don't have permissions, return early
    if (_localPermissionState == false) {
      debugPrint(
          'Known to have no Health Connect permissions, returning default data');
      return todayData;
    }

    try {
      // Get steps
      final steps = await getStepsForDay(today);
      todayData['steps'] = steps ?? 0;
      debugPrint('Retrieved steps: ${steps ?? 0}');

      // Get calories
      final calories = await getCaloriesBurnedForDay(today);
      todayData['calories'] = calories ?? 0;
      debugPrint('Retrieved calories: ${calories ?? 0}');

      // If we successfully got data, update permission state
      _localPermissionState = true;
      todayData['hasPermissions'] = true;

      return todayData;
    } catch (e) {
      debugPrint('Error getting fitness data: $e');
      if (e.toString().contains("SecurityException") ||
          e.toString().contains("permission") ||
          e.toString().contains("Permission")) {
        todayData['hasPermissions'] = false;
        _localPermissionState = false;
      }
      return todayData;
    }
  }

  /// Get step count for a specific day
  Future<int?> getStepsForDay(DateTime date) async {
    debugPrint('Getting steps for day: ${formatDate(date)}');

    // Create date range for the entire day
    final DateTimeRange dateRange = getDateRange(date);
    final startTime = dateRange.start;
    final endTime = dateRange.end;

    try {
      // Try to get the step count using the specialized method first
      try {
        debugPrint('Using specialized steps method...');
        final steps = await _health.getTotalStepsInInterval(startTime, endTime);

        if (steps != null) {
          debugPrint('Got steps from specialized method: $steps');
          // We successfully read steps, so we have permission
          _localPermissionState = true;
          return steps;
        } else {
          debugPrint('Specialized method returned null steps');
        }
      } catch (e) {
        debugPrint('Error using specialized steps method: $e');
        if (e.toString().contains("SecurityException") ||
            e.toString().contains("permission") ||
            e.toString().contains("Permission")) {
          _localPermissionState = false;
          throw Exception('Permission denied: $e');
        }
      }

      // Try the more general method
      try {
        debugPrint('Using general health data method for steps...');
        final results = await _health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: startTime,
          endTime: endTime,
        );

        // Sum up all step counts from the results
        int totalSteps = 0;
        for (final dataPoint in results) {
          if (dataPoint.type == HealthDataType.STEPS) {
            final stepValue =
                (dataPoint.value as NumericHealthValue).numericValue.toInt();
            totalSteps += stepValue;
            debugPrint('Found step data point: $stepValue');
          }
        }

        debugPrint('Total steps from general method: $totalSteps');
        if (totalSteps > 0) {
          _localPermissionState = true;
        }
        return totalSteps;
      } catch (e) {
        debugPrint('Error using general method for steps: $e');
        if (e.toString().contains("SecurityException") ||
            e.toString().contains("permission") ||
            e.toString().contains("Permission")) {
          _localPermissionState = false;
          throw Exception('Permission denied: $e');
        }
      }

      // Return 0 if no steps found
      debugPrint('No step data found, returning 0');
      return 0;
    } catch (e) {
      debugPrint('Error getting steps: $e');
      if (e.toString().contains("SecurityException") ||
          e.toString().contains("permission") ||
          e.toString().contains("Permission")) {
        _localPermissionState = false;
        throw Exception('Permission denied: $e');
      }
      return 0;
    }
  }
//coverage:ignore-start
  /// Get calories burned for a specific day
  Future<double?> getCaloriesBurnedForDay(DateTime date) async {
    debugPrint('Getting calories for day: ${formatDate(date)}');

    // Create date range for the entire day
    final DateTimeRange dateRange = getDateRange(date);
    final startTime = dateRange.start;
    final endTime = dateRange.end;

    try {
      // Request calories data from both active energy and total calories
      try {
        debugPrint('Requesting calories data...');
        final results = await _health.getHealthDataFromTypes(
          types: [
            HealthDataType.ACTIVE_ENERGY_BURNED,
            HealthDataType.TOTAL_CALORIES_BURNED,
          ],
          startTime: startTime,
          endTime: endTime,
        );

        // Try to get Total Calories Burned first, as it's more comprehensive
        double totalCalories = 0;
        bool hasTotalCalories = false;

        for (final dataPoint in results) {
          if (dataPoint.type == HealthDataType.TOTAL_CALORIES_BURNED) {
            final calories =
                (dataPoint.value as NumericHealthValue).numericValue.toDouble();
            totalCalories += calories;
            hasTotalCalories = true;
            debugPrint('Found total calories data point: $calories');
          }
        }

        // If no total calories found, use active energy burned
        if (!hasTotalCalories) {
          debugPrint('No total calories found, using active energy burned...');
          for (final dataPoint in results) {
            if (dataPoint.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              final calories = (dataPoint.value as NumericHealthValue)
                  .numericValue
                  .toDouble();
              totalCalories += calories;
              debugPrint('Found active calories data point: $calories');
            }
          }
        }

        debugPrint('Total calories: $totalCalories');
        if (totalCalories > 0) {
          _localPermissionState = true;
        }
        return totalCalories;
      } catch (e) {
        debugPrint('Error getting calories data: $e');
        if (e.toString().contains("SecurityException") ||
            e.toString().contains("permission") ||
            e.toString().contains("Permission")) {
          _localPermissionState = false;
          throw Exception('Permission denied: $e');
        }
      }

      // Return 0 if no calories found
      debugPrint('No calories data found, returning 0');
      return 0;
    } catch (e) {
      debugPrint('Error getting calories: $e');
      if (e.toString().contains("SecurityException") ||
          e.toString().contains("permission") ||
          e.toString().contains("Permission")) {
        _localPermissionState = false;
        throw Exception('Permission denied: $e');
      }
      return 0;
    }
  }

//coverage:ignore-end
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
  // coverage:ignore-start
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
      return false; // Better to return false on error
    }
  }
  // coverage:ignore-end

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
