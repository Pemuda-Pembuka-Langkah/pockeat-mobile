// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';

void main() {
  group('TabConfiguration', () {
    test('should correctly assign values when created', () {
      // Arrange
      const mainTabCount = 2;
      const logHistoryTabCount = 2;
      final logHistoryTabLabels = ['Food', 'Exercise'];

      // Act
      final tabConfiguration = TabConfiguration(
        mainTabCount: mainTabCount,
        logHistoryTabCount: logHistoryTabCount,
        logHistoryTabLabels: logHistoryTabLabels,
      );

      // Assert
      expect(tabConfiguration.mainTabCount, equals(mainTabCount));
      expect(tabConfiguration.logHistoryTabCount, equals(logHistoryTabCount));
      expect(tabConfiguration.logHistoryTabLabels, equals(logHistoryTabLabels));
    });

    test('should correctly assign different values when created', () {
      // Arrange
      const mainTabCount = 4;
      const logHistoryTabCount = 3;
      final logHistoryTabLabels = ['Log1', 'Log2', 'Log3'];

      // Act
      final tabConfiguration = TabConfiguration(
        mainTabCount: mainTabCount,
        logHistoryTabCount: logHistoryTabCount,
        logHistoryTabLabels: logHistoryTabLabels,
      );

      // Assert
      expect(tabConfiguration.mainTabCount, equals(mainTabCount));
      expect(tabConfiguration.logHistoryTabCount, equals(logHistoryTabCount));
      expect(tabConfiguration.logHistoryTabLabels, equals(logHistoryTabLabels));
    });

    test('should correctly handle empty labels list', () {
      // Arrange
      const mainTabCount = 0;
      const logHistoryTabCount = 0;
      final logHistoryTabLabels = <String>[];

      // Act
      final tabConfiguration = TabConfiguration(
        mainTabCount: mainTabCount,
        logHistoryTabCount: logHistoryTabCount,
        logHistoryTabLabels: logHistoryTabLabels,
      );

      // Assert
      expect(tabConfiguration.mainTabCount, equals(mainTabCount));
      expect(tabConfiguration.logHistoryTabCount, equals(logHistoryTabCount));
      expect(tabConfiguration.logHistoryTabLabels, isEmpty);
    });

    test('should correctly handle single label', () {
      // Arrange
      const mainTabCount = 1;
      const logHistoryTabCount = 1;
      final logHistoryTabLabels = ['SingleTab'];

      // Act
      final tabConfiguration = TabConfiguration(
        mainTabCount: mainTabCount,
        logHistoryTabCount: logHistoryTabCount,
        logHistoryTabLabels: logHistoryTabLabels,
      );

      // Assert
      expect(tabConfiguration.mainTabCount, equals(mainTabCount));
      expect(tabConfiguration.logHistoryTabCount, equals(logHistoryTabCount));
      expect(tabConfiguration.logHistoryTabLabels, equals(logHistoryTabLabels));
      expect(tabConfiguration.logHistoryTabLabels.length, equals(1));
    });
  });
}
