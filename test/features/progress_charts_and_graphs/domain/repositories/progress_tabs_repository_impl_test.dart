import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/repositories/progress_tabs_repository.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/repositories/progress_tabs_repository_impl.dart';

void main() {
  late ProgressTabsRepository repository;

  setUp(() {
    repository = ProgressTabsRepositoryImpl();
  });

  group('ProgressTabsRepositoryImpl', () {
    test('should be instantiated', () {
      // Assert
      expect(repository, isA<ProgressTabsRepositoryImpl>());
      expect(repository, isA<ProgressTabsRepository>());
    });

    group('getAppColors', () {
      test('should return AppColors.defaultColors', () async {
        // Act
        final result = await repository.getAppColors();
        final defaultColors = AppColors.defaultColors();

        // Assert
        expect(result, isA<AppColors>());
        expect(result.primaryYellow.value, equals(defaultColors.primaryYellow.value));
        expect(result.primaryPink.value, equals(defaultColors.primaryPink.value));
        expect(result.primaryGreen.value, equals(defaultColors.primaryGreen.value));
      });

      test('should return the correct color values', () async {
        // Act
        final result = await repository.getAppColors();

        // Assert
        expect(result.primaryYellow.value, equals(0xFFFFE893));
        expect(result.primaryPink.value, equals(0xFFFF6B6B));
        expect(result.primaryGreen.value, equals(0xFF4ECDC4));
      });
    });

    group('getTabConfiguration', () {
      test('should return correct TabConfiguration', () async {
        // Act
        final result = await repository.getTabConfiguration();

        // Assert
        expect(result, isA<TabConfiguration>());
        expect(result.mainTabCount, equals(2));
        expect(result.logHistoryTabCount, equals(2));
        expect(result.logHistoryTabLabels, equals(['Food', 'Exercise']));
      });

      test('should return TabConfiguration with exact values specified in implementation', () async {
        // Act
        final result = await repository.getTabConfiguration();

        // Assert
        expect(result.mainTabCount, equals(2));
        expect(result.logHistoryTabCount, equals(2));
        expect(result.logHistoryTabLabels.length, equals(2));
        expect(result.logHistoryTabLabels[0], equals('Food'));
        expect(result.logHistoryTabLabels[1], equals('Exercise'));
      });
    });
  });
}