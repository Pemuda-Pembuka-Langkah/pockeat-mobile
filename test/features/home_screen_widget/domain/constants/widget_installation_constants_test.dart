// test/features/home_screen_widget/domain/constants/widget_installation_constants_test.dart

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_config.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_installation_constants.dart';

void main() {
  group('WidgetInstallationConstants', () {
    test('should have correct enum values', () {
      // Test enum values
      expect(WidgetInstallationConstants.checkWidgetInstalledMethod.value, 
          equals('checkWidgetInstalled'));
      expect(WidgetInstallationConstants.addWidgetToHomeScreenMethod.value, 
          equals('addWidgetToHomeScreen'));
      expect(WidgetInstallationConstants.widgetTypePreferenceKey.value, 
          equals('last_added_widget_type'));
    });

    test('should have correct static getters', () {
      // Test static getters match HomeWidgetConfig values
      expect(WidgetInstallationConstants.channelName, 
          equals(HomeWidgetConfig.customChannelName.value));
      expect(WidgetInstallationConstants.simpleWidgetIdentifier, 
          equals(HomeWidgetConfig.simpleWidgetName.value));
      expect(WidgetInstallationConstants.detailedWidgetIdentifier, 
          equals(HomeWidgetConfig.detailedWidgetName.value));
    });

    test('should match expected values from existing HomeWidgetConfig', () {
      // Check the actual values to ensure they match expectations
      expect(WidgetInstallationConstants.channelName, equals('com.pockeat/custom_home_widget'));
      expect(WidgetInstallationConstants.simpleWidgetIdentifier, equals('simple_food_tracking_widget'));
      expect(WidgetInstallationConstants.detailedWidgetIdentifier, equals('detailed_food_tracking_widget'));
    });

    test('should have values consistent with usage requirements', () {
      // Verify format and pattern appropriateness
      expect(WidgetInstallationConstants.checkWidgetInstalledMethod.value, 
          matches(RegExp(r'^[a-zA-Z]+[a-zA-Z0-9]*$'))); // camelCase format
      expect(WidgetInstallationConstants.addWidgetToHomeScreenMethod.value, 
          matches(RegExp(r'^[a-zA-Z]+[a-zA-Z0-9]*$'))); // camelCase format
      expect(WidgetInstallationConstants.widgetTypePreferenceKey.value, 
          matches(RegExp(r'^[a-z_]+[a-z0-9_]*$'))); // snake_case format for preferences
    });
  });
}
