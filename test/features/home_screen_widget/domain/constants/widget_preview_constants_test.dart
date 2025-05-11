// test/features/home_screen_widget/domain/constants/widget_preview_constants_test.dart

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_preview_constants.dart';

void main() {
  group('WidgetPreviewConstants', () {
    test('should have correct simple widget preview path', () {
      expect(
        WidgetPreviewConstants.simpleWidgetPreviewPath,
        equals('assets/images/simple_widget_preview.png'),
      );
    });

    test('should have correct detailed widget preview path', () {
      expect(
        WidgetPreviewConstants.detailedWidgetPreviewPath,
        equals('assets/images/detailed_widget_preview.png'),
      );
    });

    test('should have correct simple widget title', () {
      expect(
        WidgetPreviewConstants.simpleWidgetTitle,
        equals('Simple Food Tracking'),
      );
    });

    test('should have correct detailed widget title', () {
      expect(
        WidgetPreviewConstants.detailedWidgetTitle,
        equals('Detailed Nutrition Tracking'),
      );
    });

    test('all constants should be non-empty strings', () {
      // Verify all constants are non-empty strings
      expect(WidgetPreviewConstants.simpleWidgetPreviewPath.isNotEmpty, isTrue);
      expect(WidgetPreviewConstants.detailedWidgetPreviewPath.isNotEmpty, isTrue);
      expect(WidgetPreviewConstants.simpleWidgetTitle.isNotEmpty, isTrue);
      expect(WidgetPreviewConstants.detailedWidgetTitle.isNotEmpty, isTrue);
    });

    test('image paths should have correct extensions', () {
      // Verify image paths have correct extensions
      expect(
        WidgetPreviewConstants.simpleWidgetPreviewPath.endsWith('.png'),
        isTrue,
      );
      expect(
        WidgetPreviewConstants.detailedWidgetPreviewPath.endsWith('.png'),
        isTrue,
      );
    });

    test('image paths should start with assets directory', () {
      // Verify image paths are in assets directory
      expect(
        WidgetPreviewConstants.simpleWidgetPreviewPath.startsWith('assets/'),
        isTrue,
      );
      expect(
        WidgetPreviewConstants.detailedWidgetPreviewPath.startsWith('assets/'),
        isTrue,
      );
    });
  });
}
