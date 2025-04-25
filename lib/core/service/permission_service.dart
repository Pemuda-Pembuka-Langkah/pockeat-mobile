// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle all permission-related tasks centrally
/// Permissions should be requested BEFORE any service that needs them is initialized

// coverage:ignore-start
class PermissionService {
  final FirebaseMessaging _firebaseMessaging;

  PermissionService({
    FirebaseMessaging? firebaseMessaging,
  }) : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  /// Request all needed permissions for the app
  Future<void> requestAllPermissions() async {
    debugPrint('Requesting all permissions...');
    
    // Request notification permissions (via FCM dan permission_handler)
    await requestNotificationPermissions();
    
    // Request battery optimization exemption
    await requestBatteryOptimizationExemption();
    
    // Add other permission requests here as needed
    // e.g., storage, location, etc.
  }

  /// Request notification permissions specifically using FCM and permission_handler
  Future<void> requestNotificationPermissions() async {
    debugPrint('Requesting notification permissions...');
    
    if (Platform.isAndroid) {
      try {
        // Request via FirebaseMessaging
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        
        debugPrint('User FCM notification permission status: ${settings.authorizationStatus}');
        
        // Also request via permission_handler for Android
        final status = await Permission.notification.request();
        debugPrint('User permission_handler notification status: $status');
      } catch (e) {
        debugPrint('Failed to request notification permissions: $e');
      }
    }
  }
  
  /// Request battery optimization exemption for background services
  Future<void> requestBatteryOptimizationExemption() async {
    debugPrint('Requesting battery optimization exemption...');
    
    if (Platform.isAndroid) {
      try {
        // Check current status
        if (await isBatteryOptimizationExemptionGranted() == false) {
          // Request exemption
          final status = await Permission.ignoreBatteryOptimizations.request();
          debugPrint('Battery optimization exemption request result: $status');
        } else {
          debugPrint('Battery optimization exemption already granted');
        }
      } catch (e) {
        debugPrint('Failed to request battery optimization exemption: $e');
      }
    }
  }
  
  /// Check if battery optimization exemption is granted
  Future<bool> isBatteryOptimizationExemptionGranted() async {
    if (Platform.isAndroid) {
      return await Permission.ignoreBatteryOptimizations.isGranted;
    }
    return true; // Non-Android platforms don't need this permission
  }
}
// coverage:ignore-end
