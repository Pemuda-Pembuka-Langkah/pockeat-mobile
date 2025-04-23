// ignore_for_file: constant_identifier_names

import 'dart:core';

/// Constants for widget background service operations
enum BackgroundServiceConfig {
  /// Minimum interval for periodic tasks (15 minutes - Android limitation)
  minimumFetchInterval(Duration(minutes: 15)),
  
  /// Default periodic update interval
  defaultUpdateInterval(Duration(minutes: 15)),
  
  /// Periodic update task identifier
  periodicUpdateTaskId('com.pockeat.widgets.periodicUpdate'),
  
  /// Midnight update task identifier
  midnightUpdateTaskId('com.pockeat.widgets.midnightUpdate'),
  
  /// Periodic update task name
  periodicUpdateTaskName('widget_periodic_update'),
  
  /// Midnight update task name
  midnightUpdateTaskName('widget_midnight_update');

  /// The value associated with this configuration
  final dynamic value;
  
  /// Constructor
  const BackgroundServiceConfig(this.value);
  
  /// Static constants for use in switch statements
  static const String PERIODIC_UPDATE_TASK_ID = 'com.pockeat.widgets.periodicUpdate';
  static const String MIDNIGHT_UPDATE_TASK_ID = 'com.pockeat.widgets.midnightUpdate';
}
