/// Constants for home screen widget configuration
enum HomeWidgetConfig {
  /// Simple food tracking widget name
  simpleWidgetName('simple_food_tracking_widget'),
  
  /// Detailed food tracking widget name
  detailedWidgetName('detailed_food_tracking_widget'),
  
  /// App group ID for communication with widgets
  appGroupId('group.com.pockeat.widgets');

  /// The string value
  final String value;
  
  /// Constructor
  const HomeWidgetConfig(this.value);
}
