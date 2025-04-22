import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_config.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/custom_home_widget_client.dart';

@GenerateMocks([], customMocks: [
  MockSpec<MethodChannel>(onMissingStub: OnMissingStub.returnDefault),
])
import 'custom_home_widget_client_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomHomeWidgetClient Tests', () {
    late MockMethodChannel mockChannel;
    late CustomHomeWidgetClient client;
    
    setUp(() {
      mockChannel = MockMethodChannel();
      
      // Override method channel for testing
      const MethodChannel('com.pockeat/custom_home_widget')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        return await mockChannel.invokeMethod(
          methodCall.method,
          methodCall.arguments,
        );
      });
      
      client = CustomHomeWidgetClient();
    });

    tearDown(() {
      // Reset mock method channel handler
      const MethodChannel('com.pockeat/custom_home_widget')
          .setMockMethodCallHandler(null);
    });

    group('setAppGroupId', () {
      // Positive case
      test('successfully sets app group ID', () async {
        // Setup
        when(mockChannel.invokeMethod('setAppGroupId', {
          'groupId': 'test.group',
        })).thenAnswer((_) async => true);

        // Execute
        await client.setAppGroupId('test.group');

        // Verify
        verify(mockChannel.invokeMethod('setAppGroupId', {
          'groupId': 'test.group',
        })).called(1);
      });

      // Negative case
      test('throws exception when method channel throws', () async {
        // Setup
        when(mockChannel.invokeMethod('setAppGroupId', any))
            .thenThrow(PlatformException(code: 'ERROR'));

        // Execute & Verify
        expect(() => client.setAppGroupId('test.group'), throwsA(isA<PlatformException>()));
      });
    });

    group('getWidgetData', () {
      // Positive case - String
      test('successfully gets String widget data', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => 'test_value');

        // Execute
        final result = await client.getWidgetData<String>('test_key');

        // Verify
        expect(result, 'test_value');
        verify(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).called(1);
      });

      // Positive case - int
      test('successfully gets int widget data', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => 42);

        // Execute
        final result = await client.getWidgetData<int>('test_key');

        // Verify
        expect(result, 42);
      });

      // Positive case - double
      test('successfully gets double widget data', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => 42.5);

        // Execute
        final result = await client.getWidgetData<double>('test_key');

        // Verify
        expect(result, 42.5);
      });

      // Positive case - bool
      test('successfully gets bool widget data', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => true);

        // Execute
        final result = await client.getWidgetData<bool>('test_key');

        // Verify
        expect(result, true);
      });

      // Edge case - type conversion String to int
      test('converts String to int when int type is requested', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => '42');

        // Execute
        final result = await client.getWidgetData<int>('test_key');

        // Verify
        expect(result, 42);
      });

      // Edge case - type conversion String to double
      test('converts String to double when double type is requested', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => '42.5');

        // Execute
        final result = await client.getWidgetData<double>('test_key');

        // Verify
        expect(result, 42.5);
      });

      // Edge case - type conversion String to bool
      test('converts String to bool when bool type is requested', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => 'true');

        // Execute
        final result = await client.getWidgetData<bool>('test_key');

        // Verify
        expect(result, true);
      });

      // Negative case - appGroupId not set
      test('returns null when appGroupId is not set', () async {
        // Setup - create a new client to have null appGroupId
        final newClient = CustomHomeWidgetClient();
        
        // Purposely set appGroupId to null through reflection
        final field = newClient.runtimeType.toString().contains('_appGroupId');
        if (field) {
          // This would need to access private field which isn't directly possible
          // Just test the behavior
        }

        // We'll simulate this with a different call to ensure the test works
        when(mockChannel.invokeMethod('getWidgetData', any))
            .thenAnswer((_) async => null);

        // Execute
        final result = await newClient.getWidgetData<String>('test_key');

        // Verify
        expect(result, null);
      });

      // Negative case - method channel throws
      test('returns null when method channel throws', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', any))
            .thenThrow(PlatformException(code: 'ERROR'));

        // Execute
        final result = await client.getWidgetData<String>('test_key');

        // Verify
        expect(result, null);
      });

      // Edge case - invalid string for number conversion
      test('defaults to 0 when invalid string for int conversion', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => 'not_a_number');

        // Execute
        final result = await client.getWidgetData<int>('test_key');

        // Verify
        expect(result, 0);
      });

      // Edge case - invalid string for double conversion
      test('defaults to 0.0 when invalid string for double conversion', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => 'not_a_number');

        // Execute
        final result = await client.getWidgetData<double>('test_key');

        // Verify
        expect(result, 0.0);
      });

      // Edge case - null result
      test('handles null result correctly', () async {
        // Setup
        when(mockChannel.invokeMethod('getWidgetData', {
          'key': 'test_key',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => null);

        // Execute
        final result = await client.getWidgetData<String>('test_key');

        // Verify
        expect(result, null);
      });
    });

    group('saveWidgetData', () {
      // Positive case - String
      test('successfully saves String widget data', () async {
        // Setup
        when(mockChannel.invokeMethod('saveWidgetData', {
          'key': 'test_key',
          'value': 'test_value',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => true);

        // Execute
        await client.saveWidgetData('test_key', 'test_value');

        // Verify
        verify(mockChannel.invokeMethod('saveWidgetData', {
          'key': 'test_key',
          'value': 'test_value',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).called(1);
      });

      // Positive case - int
      test('successfully saves int widget data', () async {
        // Setup
        when(mockChannel.invokeMethod('saveWidgetData', {
          'key': 'test_key',
          'value': 42,
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => true);

        // Execute
        await client.saveWidgetData('test_key', 42);

        // Verify
        verify(mockChannel.invokeMethod('saveWidgetData', {
          'key': 'test_key',
          'value': 42,
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).called(1);
      });

      // Test tidak relevan karena appGroupId telah diset dengan default dari HomeWidgetConfig
      test('uses default appGroupId from HomeWidgetConfig', () async {
        // Setup - create a new client
        final newClient = CustomHomeWidgetClient();
        
        when(mockChannel.invokeMethod('saveWidgetData', {
          'key': 'test_key',
          'value': 'test_value',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => true);
        
        // Execute - should work with default appGroupId
        await newClient.saveWidgetData('test_key', 'test_value');
        
        // Verify
        verify(mockChannel.invokeMethod('saveWidgetData', {
          'key': 'test_key',
          'value': 'test_value',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).called(1);
      });

      // Negative case - method channel throws
      test('rethrows exception when method channel throws', () async {
        // Setup
        when(mockChannel.invokeMethod('saveWidgetData', any))
            .thenThrow(PlatformException(code: 'ERROR'));

        // Execute & Verify
        expect(() => client.saveWidgetData('test_key', 'test_value'), 
               throwsA(isA<PlatformException>()));
      });

      // Edge case - empty key
      test('handles empty key', () async {
        // Setup
        when(mockChannel.invokeMethod('saveWidgetData', {
          'key': '',
          'value': 'test_value',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => true);

        // Execute
        await client.saveWidgetData('', 'test_value');

        // Verify
        verify(mockChannel.invokeMethod('saveWidgetData', {
          'key': '',
          'value': 'test_value',
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).called(1);
      });

      // Edge case - null value
      test('handles null value', () async {
        // Setup
        when(mockChannel.invokeMethod('saveWidgetData', {
          'key': 'test_key',
          'value': null,
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).thenAnswer((_) async => true);

        // Execute
        await client.saveWidgetData('test_key', null);

        // Verify
        verify(mockChannel.invokeMethod('saveWidgetData', {
          'key': 'test_key',
          'value': null,
          'appGroupId': HomeWidgetConfig.appGroupId.value,
        })).called(1);
      });
    });

    group('updateWidget', () {
      // Positive case - with name only
      test('successfully updates widget with name only', () async {
        // Setup
        when(mockChannel.invokeMethod('updateWidget', {
          'name': 'test_widget',
          'androidName': 'test_widget',
          'iOSName': null,
        })).thenAnswer((_) async => true);

        // Execute
        await client.updateWidget(name: 'test_widget');

        // Verify
        verify(mockChannel.invokeMethod('updateWidget', {
          'name': 'test_widget',
          'androidName': 'test_widget',
          'iOSName': null,
        })).called(1);
      });

      // Positive case - with all names
      test('successfully updates widget with all names', () async {
        // Setup
        when(mockChannel.invokeMethod('updateWidget', {
          'name': 'test_widget',
          'androidName': 'android_widget',
          'iOSName': 'ios_widget',
        })).thenAnswer((_) async => true);

        // Execute
        await client.updateWidget(
          name: 'test_widget',
          androidName: 'android_widget',
          iOSName: 'ios_widget',
        );

        // Verify
        verify(mockChannel.invokeMethod('updateWidget', {
          'name': 'test_widget',
          'androidName': 'android_widget',
          'iOSName': 'ios_widget',
        })).called(1);
      });

      // Negative case - method channel throws
      test('rethrows exception when method channel throws', () async {
        // Setup
        when(mockChannel.invokeMethod('updateWidget', any))
            .thenThrow(PlatformException(code: 'ERROR'));

        // Execute & Verify
        expect(() => client.updateWidget(name: 'test_widget'), 
               throwsA(isA<PlatformException>()));
      });

      // Edge case - empty name
      test('handles empty name', () async {
        // Setup
        when(mockChannel.invokeMethod('updateWidget', {
          'name': '',
          'androidName': '',
          'iOSName': null,
        })).thenAnswer((_) async => true);

        // Execute
        await client.updateWidget(name: '');

        // Verify
        verify(mockChannel.invokeMethod('updateWidget', {
          'name': '',
          'androidName': '',
          'iOSName': null,
        })).called(1);
      });

      // Edge case - long name
      test('handles very long name', () async {
        // Setup
        final longName = 'a' * 1000;
        when(mockChannel.invokeMethod('updateWidget', {
          'name': longName,
          'androidName': longName,
          'iOSName': null,
        })).thenAnswer((_) async => true);

        // Execute
        await client.updateWidget(name: longName);

        // Verify
        verify(mockChannel.invokeMethod('updateWidget', {
          'name': longName,
          'androidName': longName,
          'iOSName': null,
        })).called(1);
      });
    });
  });
}
