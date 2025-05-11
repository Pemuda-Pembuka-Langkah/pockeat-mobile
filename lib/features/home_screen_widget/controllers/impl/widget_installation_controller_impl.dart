// lib/features/home_screen_widget/controllers/impl/widget_installation_controller_impl.dart

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/controllers/widget_installation_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_installation_constants.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_installation_service.dart';

/// Implementation of [WidgetInstallationController]
class WidgetInstallationControllerImpl implements WidgetInstallationController {
  /// Service for widget installation operations
  final WidgetInstallationService _widgetInstallationService;

  /// Stream controller for widget status updates
  final StreamController<WidgetInstallationStatus> _widgetStatusController =
      StreamController<WidgetInstallationStatus>.broadcast();

  /// Cached widget status
  WidgetInstallationStatus? _cachedWidgetStatus;

  /// Timer for periodic status check
  Timer? _statusCheckTimer;

  /// Creates a new [WidgetInstallationControllerImpl] instance
  WidgetInstallationControllerImpl({
    required WidgetInstallationService widgetInstallationService,
  }) : _widgetInstallationService = widgetInstallationService {
    // Initialize status and setup periodic check
    _initializeStatus();
    _setupPeriodicStatusCheck();
  }

  /// Initialize widget status
  Future<void> _initializeStatus() async {
    try {
      final status =
          await _widgetInstallationService.checkWidgetInstallationStatus();
      _updateStatus(status);
    } catch (e) {
      debugPrint('Error initializing widget status: $e');
    }
  }

  /// Setup periodic check for widget status changes
  void _setupPeriodicStatusCheck() {
    // Check every 30 seconds if widgets were added/removed
    startPeriodicTimer();
  }

  /// Start a periodic timer for checking widget status
  @visibleForTesting
  void startPeriodicTimer() {
    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 300),

      (_) => refreshWidgetStatus(),
    );
  }

  /// Updates the current widget status and notifies listeners
  void _updateStatus(WidgetInstallationStatus status) {
    // Only update if status changed
    if (_cachedWidgetStatus != status) {
      _cachedWidgetStatus = status;
      _widgetStatusController.add(status);
    }
  }

  @override
  Future<WidgetInstallationStatus> getWidgetStatus() async {
    if (_cachedWidgetStatus != null) {
      return _cachedWidgetStatus!;
    }

    final status =
        await _widgetInstallationService.checkWidgetInstallationStatus();
    _updateStatus(status);
    return status;
  }

  @override
  Future<bool> installWidget(WidgetType widgetType) async {
    try {
      final result =
          await _widgetInstallationService.addWidgetToHomescreen(widgetType);

      // Save the user's widget type preference
      if (result) {
        _saveWidgetTypePreference(widgetType);
      }

      // Refresh status after attempting to add widget
      await refreshWidgetStatus();

      return result;
    } catch (e) {
      debugPrint('Error installing widget: $e');
      return false;
    }
  }

  /// Saves the user's widget type preference
  Future<void> _saveWidgetTypePreference(WidgetType widgetType) async {
    try {
      await savePreferenceInternal(widgetType);
    } catch (e) {
      handlePreferenceError(e);
    }
  }

  /// Internal method to save preference - extracted for testability
  @visibleForTesting
  Future<void> savePreferenceInternal(WidgetType widgetType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      WidgetInstallationConstants.widgetTypePreferenceKey.value,
      widgetType.name,
    );
  }

  /// Handle preference error - extracted for testability
  @visibleForTesting
  void handlePreferenceError(dynamic error) {
    debugPrint('Error saving widget type preference: $error');
  }

  @override
  Stream<WidgetInstallationStatus> get widgetStatusStream =>
      _widgetStatusController.stream;

  @override
  Future<void> refreshWidgetStatus() async {
    try {
      final status =
          await _widgetInstallationService.checkWidgetInstallationStatus();
      _updateStatus(status);
    } catch (e) {
      debugPrint('Error refreshing widget status: $e');
    }
  }

  /// Checks if the timer is active
  bool get hasActiveTimer =>
      _statusCheckTimer != null && _statusCheckTimer!.isActive;

  /// Disposes resources
  void dispose() {
    _statusCheckTimer?.cancel();
    _widgetStatusController.close();
  }
}
