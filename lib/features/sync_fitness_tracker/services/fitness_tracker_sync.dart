import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'dart:async';

class FitnessTrackerSync {
  /// Health plugin instance
  final Health _health = Health();

  /// Health Connect package name
  static const String healthConnectPackage = 'com.google.android.apps.healthdata';

  /// The required data types
  final List<HealthDataType> _requiredTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  /// Local permission state to handle Health Connect inconsistencies
  bool _localPermissionState = false;

  /// Initialize and check permissions in one step
  Future<bool> initializeAndCheckPermissions() async {
    try {
      debugPrint('Initializing health services...');
      // Configure health plugin
      await _health.configure();

      // Check if Health Connect is available (Android only)
      if (Platform.isAndroid) {
        final isAvailable = await _health.isHealthConnectAvailable();
        debugPrint('Health Connect available: $isAvailable');
        if (!isAvailable) {
          return false;
        }
      }

      // Check if we have local permission state first
      if (_localPermissionState) {
        debugPrint('Using cached permission state: $_localPermissionState');
        return true;
      }

      // Try a simple permission check
      try {
        final hasPermissions = await _health.hasPermissions(_requiredTypes);
        debugPrint('Has permissions check result: $hasPermissions');
        
        // Also try a data read to double-check permissions
        final canReadData = await _canReadHealthData();
        debugPrint('Can read health data: $canReadData');
        
        if (canReadData) {
          _localPermissionState = true;
          return true;
        }
        
        return hasPermissions == true;
      } catch (e) {
        debugPrint('Error checking permissions: $e');
        
        // Try a data read anyway to check permissions
        final canReadData = await _canReadHealthData();
        if (canReadData) {
          _localPermissionState = true;
          return true;
        }
        
        return false;
      }
    } catch (e) {
      debugPrint('Error in initializeAndCheckPermissions: $e');
      return false;
    }
  }

  /// Attempt to read some data to check if we actually have permissions
  Future<bool> _canReadHealthData() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Try to read steps first
      try {
        await _health.getTotalStepsInInterval(yesterday, now);
        return true;
      } catch (e) {
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
        debugPrint('Error reading health data: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error in _canReadHealthData: $e');
      return false;
    }
  }

  Future<void> openHealthConnect(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      // Launch Health Connect
      const MethodChannel('com.pockeat/health_connect')
          .invokeMethod('launchHealthConnect');

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
      }
      
      return granted;
    } catch (e) {
      debugPrint('Error in requestAuthorization: $e');
      return false;
    }
  }

  /// Check if we have required permissions
  Future<bool> hasRequiredPermissions() async {
    try {
      debugPrint('Checking if we have required permissions...');

      // Check local state first
      if (_localPermissionState) {
        debugPrint('Using cached permission state: true');
        return true;
      }

      // First try actual data read
      final canReadData = await _canReadHealthData();
      if (canReadData) {
        _localPermissionState = true;
        return true;
      }
      
      // If data read fails, check permissions formally
      final hasPermissions = await _health.hasPermissions(_requiredTypes);
      debugPrint('Has permissions check result: $hasPermissions');
      
      if (hasPermissions == true) {
        _localPermissionState = true;
      }
      
      return hasPermissions == true;
    } catch (e) {
      debugPrint('Error in hasRequiredPermissions: $e');
      
      // Try data read as a fallback
      return _canReadHealthData();
    }
  }

  /// Perform a forced data read to ensure permissions are working
  Future<bool> performForcedDataRead() async {
    debugPrint('Performing forced data read...');
    try {
      final result = await _canReadHealthData();
      if (result) {
        _localPermissionState = true;
      }
      return result;
    } catch (e) {
      debugPrint('Error in forced data read: $e');
      return false;
    }
  }

  /// Get today's fitness data (steps and calories)
  Future<Map<String, dynamic>> getTodayFitnessData() async {
    debugPrint('Getting today\'s fitness data...');
    
    // Set local permission state to true if we can fetch data
    _localPermissionState = true;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Initialize with default values
    final Map<String, dynamic> todayData = {
      'steps': 0,
      'calories': 0,
    };
    
    // Get steps
    final steps = await getStepsForDay(today);
    todayData['steps'] = steps ?? 0;
    
    // Get calories
    final calories = await getCaloriesBurnedForDay(today);
    todayData['calories'] = calories ?? 0;
    
    debugPrint('Today\'s data: Steps=${todayData['steps']}, Calories=${todayData['calories']}');
    
    return todayData;
  }

  /// Get step count for a specific day
  Future<int?> getStepsForDay(DateTime date) async {
    debugPrint('Getting steps for ${DateFormat('yyyy-MM-dd').format(date)}...');

    // Create date range for the entire day
    final startTime = DateTime(date.year, date.month, date.day);
    final endTime = startTime
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

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
      }

      // Try the more general method
      try {
        final results = await _health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: startTime,
          endTime: endTime,
        );

        // We successfully read data, so we have permission
        _localPermissionState = true;

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
          return totalSteps;
        }
      } catch (e) {
        debugPrint('Error with getHealthDataFromTypes: $e');
      }

      // Return 0 if no steps found
      return 0;
    } catch (e) {
      debugPrint('Error getting steps: $e');
      return 0;
    }
  }

  /// Get calories burned for a specific day
  Future<double?> getCaloriesBurnedForDay(DateTime date) async {
    debugPrint(
        'Getting calories for ${DateFormat('yyyy-MM-dd').format(date)}...');

    // Create date range for the entire day
    final startTime = DateTime(date.year, date.month, date.day);
    final endTime = startTime
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

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

        // Successfully read data, so we have permission
        _localPermissionState = true;
        
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
          return totalCalories;
        }
      } catch (e) {
        debugPrint('Error getting calories data: $e');
      }

      // Return 0 if no calories found
      return 0;
    } catch (e) {
      debugPrint('Error getting calories burned: $e');
      return 0;
    }
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
        const MethodChannel('com.pockeat/health_connect')
            .invokeMethod('openHealthConnectPlayStore');
      } catch (e) {
        debugPrint('Error opening Play Store: $e');
      }
    }
  }

  /// Manually set the permission state (for fixing permission detection issues)
  void setPermissionGranted() {
    _localPermissionState = true;
  }

  /// Format readable date
  String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}