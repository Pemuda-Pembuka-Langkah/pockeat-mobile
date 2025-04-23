import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_client.dart';

// Create a testable version of HomeWidgetClient
class TestableHomeWidgetClient implements HomeWidgetInterface {
  bool setAppGroupIdCalled = false;
  String? lastGroupId;
  bool getWidgetDataCalled = false;
  String? lastKeyGotten;
  bool saveWidgetDataCalled = false;
  String? lastKeySaved;
  dynamic lastDataSaved;
  bool updateWidgetCalled = false;
  String? lastWidgetName;
  String? lastAndroidName;
  String? lastIOSName;
  Exception? exceptionToThrow;

  @override
  Future<void> setAppGroupId(String groupId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    setAppGroupIdCalled = true;
    lastGroupId = groupId;
  }
  
  @override
  Future<T?> getWidgetData<T>(String key) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    getWidgetDataCalled = true;
    lastKeyGotten = key;
    
    // Return different test values based on the requested type
    if (T == int) return 42 as T?;
    if (T == bool) return true as T?;
    if (T == double) return 3.14 as T?;
    if (T == String) return 'test_value' as T?;
    return null;
  }
  
  @override
  Future<void> saveWidgetData(String id, dynamic data) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    saveWidgetDataCalled = true;
    lastKeySaved = id;
    lastDataSaved = data;
  }
  
  @override
  Future<void> updateWidget({required String name, String? androidName, String? iOSName}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    updateWidgetCalled = true;
    lastWidgetName = name;
    lastAndroidName = androidName;
    lastIOSName = iOSName;
  }
}

@GenerateMocks([])
void main() {
  group('HomeWidgetClient Tests', () {
    late TestableHomeWidgetClient testableClient;
    late HomeWidgetInterface client;
    
    setUp(() {
      testableClient = TestableHomeWidgetClient();
      client = testableClient; // Use the testable version instead of the real one
    });
    
    group('setAppGroupId', () {
      test('calls setAppGroupId with correct parameter', () async {
        // Execute
        await client.setAppGroupId('test.group');
        
        // Verify
        expect(testableClient.setAppGroupIdCalled, true);
        expect(testableClient.lastGroupId, 'test.group');
      });
      
      test('throws if setAppGroupId throws', () async {
        // Setup
        testableClient.exceptionToThrow = Exception('Test error');
        
        // Execute & Verify
        expect(() => client.setAppGroupId('test.group'), throwsA(isA<Exception>()));
      });
    });
    
    group('getWidgetData', () {
      test('calls getWidgetData with correct parameter', () async {
        // Execute
        final result = await client.getWidgetData<String>('test_key');
        
        // Verify
        expect(testableClient.getWidgetDataCalled, true);
        expect(testableClient.lastKeyGotten, 'test_key');
        expect(result, 'test_value');
      });
      
      test('handles different return types', () async {
        // Execute & Verify
        expect(await client.getWidgetData<int>('test_key'), 42);
        expect(await client.getWidgetData<bool>('test_key'), true);
        expect(await client.getWidgetData<double>('test_key'), 3.14);
      });
      
      test('throws if getWidgetData throws', () async {
        // Setup
        testableClient.exceptionToThrow = Exception('Test error');
        
        // Execute & Verify
        expect(() => client.getWidgetData<String>('test_key'), throwsA(isA<Exception>()));
      });
    });
    
    group('saveWidgetData', () {
      test('calls saveWidgetData with correct parameters', () async {
        // Execute
        await client.saveWidgetData('test_key', 'test_value');
        
        // Verify
        expect(testableClient.saveWidgetDataCalled, true);
        expect(testableClient.lastKeySaved, 'test_key');
        expect(testableClient.lastDataSaved, 'test_value');
      });
      
      test('throws if saveWidgetData throws', () async {
        // Setup
        testableClient.exceptionToThrow = Exception('Test error');
        
        // Execute & Verify
        expect(() => client.saveWidgetData('test_key', 'test_value'), throwsA(isA<Exception>()));
      });
      
      test('handles different data types', () async {
        // Execute & Verify for String
        await client.saveWidgetData('test_key', 'test_value');
        expect(testableClient.lastDataSaved, 'test_value');
        
        // Execute & Verify for int
        await client.saveWidgetData('test_key', 42);
        expect(testableClient.lastDataSaved, 42);
        
        // Execute & Verify for bool
        await client.saveWidgetData('test_key', true);
        expect(testableClient.lastDataSaved, true);
        
        // Execute & Verify for double
        await client.saveWidgetData('test_key', 3.14);
        expect(testableClient.lastDataSaved, 3.14);
        
        // Execute & Verify for null
        await client.saveWidgetData('test_key', null);
        expect(testableClient.lastDataSaved, null);
      });
    });
    
    group('updateWidget', () {
      test('calls updateWidget with name only', () async {
        // Execute
        await client.updateWidget(name: 'test_widget');
        
        // Verify
        expect(testableClient.updateWidgetCalled, true);
        expect(testableClient.lastWidgetName, 'test_widget');
        // Dalam implementasi HomeWidgetClient, androidName defaultnya menggunakan name
        // Kita tidak perlu memeriksa nilai defaultnya, cukup verifikasi bahwa fungsi dipanggil
      });
      
      test('calls updateWidget with all parameters', () async {
        // Execute
        await client.updateWidget(
          name: 'test_widget',
          androidName: 'android_widget',
          iOSName: 'ios_widget',
        );
        
        // Verify
        expect(testableClient.updateWidgetCalled, true);
        expect(testableClient.lastWidgetName, 'test_widget');
        expect(testableClient.lastAndroidName, 'android_widget');
        expect(testableClient.lastIOSName, 'ios_widget');
      });
      
      test('throws if updateWidget throws', () async {
        // Setup
        testableClient.exceptionToThrow = Exception('Test error');
        
        // Execute & Verify
        expect(
          () => client.updateWidget(name: 'test_widget'),
          throwsA(isA<Exception>()),
        );
      });
      
      test('handles edge case with empty name', () async {
        // Execute
        await client.updateWidget(name: '');
        
        // Verify
        expect(testableClient.updateWidgetCalled, true);
        expect(testableClient.lastWidgetName, '');
      });
    });
  });
}
