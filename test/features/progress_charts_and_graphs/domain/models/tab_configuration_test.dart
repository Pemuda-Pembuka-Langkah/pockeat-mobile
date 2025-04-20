import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';

void main() {
  group('TabConfiguration', () {
    test('should correctly assign values when created', () {
      // Arrange
      const mainTabCount = 2;
      const progressTabCount = 3;
      final progressTabLabels = ['Weight', 'Nutrition', 'Exercise'];
      const logHistoryTabCount = 2;
      final logHistoryTabLabels = ['Food', 'Exercise'];

      // Act
      final tabConfiguration = TabConfiguration(
        mainTabCount: mainTabCount,
        progressTabCount: progressTabCount,
        progressTabLabels: progressTabLabels,
        logHistoryTabCount: logHistoryTabCount,
        logHistoryTabLabels: logHistoryTabLabels,
      );

      // Assert
      expect(tabConfiguration.mainTabCount, equals(mainTabCount));
      expect(tabConfiguration.progressTabCount, equals(progressTabCount));
      expect(tabConfiguration.progressTabLabels, equals(progressTabLabels));
      expect(tabConfiguration.logHistoryTabCount, equals(logHistoryTabCount));
      expect(tabConfiguration.logHistoryTabLabels, equals(logHistoryTabLabels));
    });

    test('should correctly assign different values when created', () {
      // Arrange
      const mainTabCount = 4;
      const progressTabCount = 5;
      final progressTabLabels = ['Tab1', 'Tab2', 'Tab3', 'Tab4', 'Tab5'];
      const logHistoryTabCount = 2;
      final logHistoryTabLabels = ['Food', 'Exercise'];

      // Act
      final tabConfiguration = TabConfiguration(
        mainTabCount: mainTabCount,
        progressTabCount: progressTabCount,
        progressTabLabels: progressTabLabels,
        logHistoryTabCount: logHistoryTabCount,
        logHistoryTabLabels: logHistoryTabLabels,
      );

      // Assert
      expect(tabConfiguration.mainTabCount, equals(mainTabCount));
      expect(tabConfiguration.progressTabCount, equals(progressTabCount));
      expect(tabConfiguration.progressTabLabels, equals(progressTabLabels));
      expect(tabConfiguration.logHistoryTabCount, equals(logHistoryTabCount));
      expect(tabConfiguration.logHistoryTabLabels, equals(logHistoryTabLabels));
    });

    test('should correctly handle empty labels list', () {
      // Arrange
      const mainTabCount = 0;
      const progressTabCount = 0;
      final progressTabLabels = <String>[];
      const logHistoryTabCount = 0;
      final logHistoryTabLabels = <String>[];

      // Act
      final tabConfiguration = TabConfiguration(
        mainTabCount: mainTabCount,
        progressTabCount: progressTabCount,
        progressTabLabels: progressTabLabels,
        logHistoryTabCount: logHistoryTabCount,
        logHistoryTabLabels: logHistoryTabLabels,
      );

      // Assert
      expect(tabConfiguration.mainTabCount, equals(mainTabCount));
      expect(tabConfiguration.progressTabCount, equals(progressTabCount));
      expect(tabConfiguration.progressTabLabels, isEmpty);
    });
  });
}