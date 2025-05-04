// Package imports:
import 'package:permission_handler/permission_handler.dart';

//
/// Interface for handling permissions that makes it easier to mock in unit tests
abstract class PermissionHelperInterface {
  /// Request notification permission
  Future<PermissionStatus> requestNotificationPermission();

  /// Request battery optimization exemption
  Future<PermissionStatus> requestBatteryOptimizationExemption();

  /// Check if battery optimization exemption is granted
  Future<bool> isBatteryOptimizationExemptionGranted();
}

/// Default implementation of PermissionHelperInterface using permission_handler package
class PermissionHelper implements PermissionHelperInterface {
  @override
  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  @override
  Future<PermissionStatus> requestBatteryOptimizationExemption() async {
    return await Permission.ignoreBatteryOptimizations.request();
  }

  @override
  Future<bool> isBatteryOptimizationExemptionGranted() async {
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }
}
