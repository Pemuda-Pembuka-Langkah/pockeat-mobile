// lib/features/home_screen_widget/controllers/widget_installation_controller.dart

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';

/// Controller interface for widget installation management
///
/// Responsible for managing widget installation state and operations
abstract class WidgetInstallationController {
  /// Gets the current widget installation status
  ///
  /// Returns [WidgetInstallationStatus] containing information about installed widgets
  Future<WidgetInstallationStatus> getWidgetStatus();

  /// Initiates installation of specified widget type
  ///
  /// Takes [widgetType] to determine which widget to install
  /// Returns [bool] indicating if request was successfully initiated
  Future<bool> installWidget(WidgetType widgetType);

  /// Stream of widget installation status updates
  ///
  /// Can be used to reactively update UI based on widget installation changes
  Stream<WidgetInstallationStatus> get widgetStatusStream;

  /// Refreshes the widget status
  ///
  /// Forces a check of the current widget installation status and
  /// updates the stream if needed
  Future<void> refreshWidgetStatus();
}
