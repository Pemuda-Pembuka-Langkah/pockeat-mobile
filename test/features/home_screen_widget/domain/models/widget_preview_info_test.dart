// test/features/home_screen_widget/domain/models/widget_preview_info_test.dart

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_preview_info.dart';

void main() {
  group('WidgetPreviewInfo', () {
    // Test constants
    const WidgetType simpleWidgetType = WidgetType.simple;
    const WidgetType detailedWidgetType = WidgetType.detailed;
    const String simpleImagePath = 'assets/images/simple_widget.png';
    const String detailedImagePath = 'assets/images/detailed_widget.png';
    const String simpleTitle = 'Simple Widget';
    const String detailedTitle = 'Detailed Widget';
    const bool isInstalled = true;
    const bool isNotInstalled = false;

    // Initialization test
    test('should initialize with correct values', () {
      // Setup
      const widgetPreviewInfo = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isInstalled,
      );

      // Verify
      expect(widgetPreviewInfo.widgetType, equals(simpleWidgetType));
      expect(widgetPreviewInfo.imagePath, equals(simpleImagePath));
      expect(widgetPreviewInfo.title, equals(simpleTitle));
      expect(widgetPreviewInfo.isInstalled, equals(isInstalled));
    });

    // Equality test
    test('should be equal when all properties match', () {
      // Setup
      const widgetPreviewInfo1 = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isInstalled,
      );

      const widgetPreviewInfo2 = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isInstalled,
      );

      // Verify
      expect(widgetPreviewInfo1, equals(widgetPreviewInfo2));
      expect(widgetPreviewInfo1.hashCode, equals(widgetPreviewInfo2.hashCode));
    });

    // Inequality test
    test('should not be equal when any property does not match', () {
      // Setup - Base object
      const baseInfo = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isInstalled,
      );

      // Different widget type
      const differentTypeInfo = WidgetPreviewInfo(
        widgetType: detailedWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isInstalled,
      );

      // Different image path
      const differentImageInfo = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: detailedImagePath,
        title: simpleTitle,
        isInstalled: isInstalled,
      );

      // Different title
      const differentTitleInfo = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: detailedTitle,
        isInstalled: isInstalled,
      );

      // Different installation status
      const differentInstalledInfo = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isNotInstalled,
      );

      // Verify
      expect(baseInfo, isNot(equals(differentTypeInfo)));
      expect(baseInfo.hashCode, isNot(equals(differentTypeInfo.hashCode)));

      expect(baseInfo, isNot(equals(differentImageInfo)));
      expect(baseInfo.hashCode, isNot(equals(differentImageInfo.hashCode)));

      expect(baseInfo, isNot(equals(differentTitleInfo)));
      expect(baseInfo.hashCode, isNot(equals(differentTitleInfo.hashCode)));

      expect(baseInfo, isNot(equals(differentInstalledInfo)));
      expect(baseInfo.hashCode, isNot(equals(differentInstalledInfo.hashCode)));
    });



    // Test different combinations
    test('should handle different combinations correctly', () {
      // Simple widget installed
      const simpleInstalled = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isInstalled,
      );
      expect(simpleInstalled.widgetType, equals(simpleWidgetType));
      expect(simpleInstalled.isInstalled, isTrue);

      // Simple widget not installed
      const simpleNotInstalled = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isNotInstalled,
      );
      expect(simpleNotInstalled.widgetType, equals(simpleWidgetType));
      expect(simpleNotInstalled.isInstalled, isFalse);

      // Detailed widget installed
      const detailedInstalled = WidgetPreviewInfo(
        widgetType: detailedWidgetType,
        imagePath: detailedImagePath,
        title: detailedTitle,
        isInstalled: isInstalled,
      );
      expect(detailedInstalled.widgetType, equals(detailedWidgetType));
      expect(detailedInstalled.isInstalled, isTrue);

      // Detailed widget not installed
      const detailedNotInstalled = WidgetPreviewInfo(
        widgetType: detailedWidgetType,
        imagePath: detailedImagePath,
        title: detailedTitle,
        isInstalled: isNotInstalled,
      );
      expect(detailedNotInstalled.widgetType, equals(detailedWidgetType));
      expect(detailedNotInstalled.isInstalled, isFalse);
    });

    // Test against non-WidgetPreviewInfo
    test('should not be equal to non-WidgetPreviewInfo objects', () {
      // Setup
      const widgetPreviewInfo = WidgetPreviewInfo(
        widgetType: simpleWidgetType,
        imagePath: simpleImagePath,
        title: simpleTitle,
        isInstalled: isInstalled,
      );

      // Verify
      expect(widgetPreviewInfo, isNot(equals(null)));
      expect(widgetPreviewInfo, isNot(equals(Object())));
      expect(widgetPreviewInfo, isNot(equals(42)));
      expect(widgetPreviewInfo, isNot(equals('widgetPreviewInfo')));
    });
  });
}
