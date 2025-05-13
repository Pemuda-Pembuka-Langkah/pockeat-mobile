// lib/features/home_screen_widget/services/widget_installation_service.dart

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';

/// Service interface for widget installation operations
///
/// Defines operations for checking widget installation status
/// and adding widgets to the homescreen
abstract class WidgetInstallationService {
  /// Checks if any of the app widgets are installed on homescreen
  ///
  /// Returns [WidgetInstallationStatus] containing detailed information
  /// about which widgets are currently installed
  Future<WidgetInstallationStatus> checkWidgetInstallationStatus();

  /// Attempts to add a specific widget type to homescreen
  ///
  /// Takes [widgetType] to determine which widget to add
  /// Returns a [bool] indicating whether the process was initiated successfully
  /// Note: This does not guarantee the widget was added, only that the request was made
  Future<bool> addWidgetToHomescreen(WidgetType widgetType);
}
