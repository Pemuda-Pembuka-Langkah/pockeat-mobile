// lib/features/home_screen_widget/domain/constants/widget_installation_constants.dart

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_config.dart';

/// Constants for widget installation features
///
/// Contains all string constants related to widget installation features.
/// Follows enum pattern consistent with HomeWidgetConfig.
enum WidgetInstallationConstants {
  /// Method names for platform channel - check widget status
  checkWidgetInstalledMethod('checkWidgetInstalled'),

  /// Method names for platform channel - add widget
  addWidgetToHomeScreenMethod('addWidgetToHomeScreen'),

  /// Preference key to store user selection of last added widget type
  widgetTypePreferenceKey('last_added_widget_type');

  /// The string value
  final String value;

  /// Constructor
  const WidgetInstallationConstants(this.value);
  
  /// Method channel name for widget installation
  /// Uses the existing channel name from HomeWidgetConfig
  static String get channelName => "com.pockeat/widget_installation";

  /// Widget identifiers from HomeWidgetConfig
  static String get simpleWidgetIdentifier => HomeWidgetConfig.simpleWidgetName.value;
  static String get detailedWidgetIdentifier => HomeWidgetConfig.detailedWidgetName.value;
}
