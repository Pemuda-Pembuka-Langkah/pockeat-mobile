// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/repositories/progress_tabs_repository.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/progress_tabs_service.dart';
import 'progress_tabs_service_test.mocks.dart';

// Generate mock for ProgressTabsRepository
@GenerateMocks([ProgressTabsRepository])

void main() {
  late ProgressTabsService service;
  late MockProgressTabsRepository mockRepository;

  setUp(() {
    mockRepository = MockProgressTabsRepository();
    service = ProgressTabsService(mockRepository);
  });

  group('ProgressTabsService', () {
    test('should be instantiated with a repository', () {
      // Assert
      expect(service, isA<ProgressTabsService>());
    });

    group('getAppColors', () {
      test('should call repository.getAppColors and return its result', () async {
        // Arrange
        final mockColors = AppColors(
          primaryYellow: const Color(0xFFFFE893),
          primaryPink: const Color(0xFFFF6B6B),
          primaryGreen: const Color(0xFF4ECDC4),
        );
        when(mockRepository.getAppColors()).thenAnswer((_) async => mockColors);

        // Act
        final result = await service.getAppColors();

        // Assert
        verify(mockRepository.getAppColors()).called(1);
        expect(result, equals(mockColors));
        expect(result.primaryYellow, equals(mockColors.primaryYellow));
        expect(result.primaryPink, equals(mockColors.primaryPink));
        expect(result.primaryGreen, equals(mockColors.primaryGreen));
      });

      test('should propagate exceptions from repository', () async {
        // Arrange
        final exception = Exception('Repository error');
        when(mockRepository.getAppColors()).thenThrow(exception);

        // Act & Assert
        expect(() => service.getAppColors(), throwsA(same(exception)));
        verify(mockRepository.getAppColors()).called(1);
      });
    });

    group('getTabConfiguration', () {
      test('should call repository.getTabConfiguration and return its result', () async {
        // Arrange
        final mockConfig = TabConfiguration(
          mainTabCount: 2,
          progressTabCount: 3,
          progressTabLabels: ['Weight', 'Nutrition', 'Exercise'],
          logHistoryTabCount: 2,                       // Add this line
          logHistoryTabLabels: ['Food', 'Exercise'],   // Add this line
        );
        when(mockRepository.getTabConfiguration()).thenAnswer((_) async => mockConfig);

        // Act
        final result = await service.getTabConfiguration();

        // Assert
        verify(mockRepository.getTabConfiguration()).called(1);
        expect(result, equals(mockConfig));
        expect(result.mainTabCount, equals(mockConfig.mainTabCount));
        expect(result.progressTabCount, equals(mockConfig.progressTabCount));
        expect(result.progressTabLabels, equals(mockConfig.progressTabLabels));
      });

      test('should propagate exceptions from repository', () async {
        // Arrange
        final exception = Exception('Repository error');
        when(mockRepository.getTabConfiguration()).thenThrow(exception);

        // Act & Assert
        expect(() => service.getTabConfiguration(), throwsA(same(exception)));
        verify(mockRepository.getTabConfiguration()).called(1);
      });
    });
  });
}
