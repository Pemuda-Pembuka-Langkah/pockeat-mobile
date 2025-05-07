// lib/features/home_screen_widget/domain/models/widget_installation_status.dart

/// Enum representing the types of widgets available
enum WidgetType {
  /// Simple calories widget showing basic information
  simple,

  /// Detailed calories widget showing more comprehensive information
  detailed
}

/// Model representing the installation status of app widgets
///
/// Keeps track of which widgets are currently installed on the user's home screen
class WidgetInstallationStatus {
  /// Whether the simple widget is installed
  final bool isSimpleWidgetInstalled;

  /// Whether the detailed widget is installed
  final bool isDetailedWidgetInstalled;

  /// Constructs widget installation status
  const WidgetInstallationStatus({
    this.isSimpleWidgetInstalled = false,
    this.isDetailedWidgetInstalled = false,
  });

  /// Checks if any widget type is installed
  bool get isAnyWidgetInstalled =>
      isSimpleWidgetInstalled || isDetailedWidgetInstalled;

  /// Creates a copy of this object with given fields replaced with new values
  WidgetInstallationStatus copyWith({
    bool? isSimpleWidgetInstalled,
    bool? isDetailedWidgetInstalled,
  }) {
    return WidgetInstallationStatus(
      isSimpleWidgetInstalled:
          isSimpleWidgetInstalled ?? this.isSimpleWidgetInstalled,
      isDetailedWidgetInstalled:
          isDetailedWidgetInstalled ?? this.isDetailedWidgetInstalled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WidgetInstallationStatus &&
        other.isSimpleWidgetInstalled == isSimpleWidgetInstalled &&
        other.isDetailedWidgetInstalled == isDetailedWidgetInstalled;
  }

  @override
  int get hashCode =>
      isSimpleWidgetInstalled.hashCode ^ isDetailedWidgetInstalled.hashCode;

  @override
  String toString() => 'WidgetInstallationStatus('
      'isSimpleWidgetInstalled: $isSimpleWidgetInstalled, '
      'isDetailedWidgetInstalled: $isDetailedWidgetInstalled)';
}
