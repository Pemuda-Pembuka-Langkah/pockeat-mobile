// lib/features/home_screen_widget/services/impl/widget_installation_service_impl.dart

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_installation_constants.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_installation_service.dart';

/// Implementation of [WidgetInstallationService] that communicates with native platform
class WidgetInstallationServiceImpl implements WidgetInstallationService {
  /// Method channel for communication with native platform
  final MethodChannel _channel;
  
  /// Creates a new instance of [WidgetInstallationServiceImpl] with default channel
  WidgetInstallationServiceImpl()
      : _channel = MethodChannel(WidgetInstallationConstants.channelName);
      
  /// Creates a new instance with custom method channel (for testing)
  @visibleForTesting
  WidgetInstallationServiceImpl.withChannel(this._channel);

  @override
  Future<WidgetInstallationStatus> checkWidgetInstallationStatus() async {
    try {
      // Call platform-specific method to check widget installation status
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod(
        WidgetInstallationConstants.checkWidgetInstalledMethod.value,
      );
      
      if (result == null) {
        return const WidgetInstallationStatus();
      }
      
      // Parse result into model
      return WidgetInstallationStatus(
        isSimpleWidgetInstalled: result['isSimpleWidgetInstalled'] ?? false,
        isDetailedWidgetInstalled: result['isDetailedWidgetInstalled'] ?? false,
      );
    } on PlatformException catch (e) {
      debugPrint('Error checking widget installation status: ${e.message}');
      // Return default (not installed) on error
      return const WidgetInstallationStatus();
    }
  }

  @override
  Future<bool> addWidgetToHomescreen(WidgetType widgetType) async {
    try {
      // Call platform-specific method to add widget to homescreen
      final bool result = await _channel.invokeMethod(
        WidgetInstallationConstants.addWidgetToHomeScreenMethod.value,
        {'widgetType': widgetType.name},
      );
      
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error adding widget to homescreen: ${e.message}');
      return false;
    }
  }
}
