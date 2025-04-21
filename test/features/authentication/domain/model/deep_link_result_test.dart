import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/authentication/domain/model/deep_link_result.dart';

void main() {
  group('DeepLinkResult', () {
    test('should create instance with direct constructor', () {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com');
      
      // Act
      final result = DeepLinkResult(
        type: DeepLinkType.unknown,
        success: true,
        data: {'test': 'data'},
        error: 'test error',
        originalUri: testUri,
      );
      
      // Assert
      expect(result.type, DeepLinkType.unknown);
      expect(result.success, true);
      expect(result.data, {'test': 'data'});
      expect(result.error, 'test error');
      expect(result.originalUri, testUri);
    });
    
    test('should create email verification result with factory constructor', () {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/verify');
      
      // Act
      final result = DeepLinkResult.emailVerification(
        success: true,
        data: {'email': 'test@example.com'},
        error: null,
        originalUri: testUri,
      );
      
      // Assert
      expect(result.type, DeepLinkType.emailVerification);
      expect(result.success, true);
      expect(result.data, {'email': 'test@example.com'});
      expect(result.error, null);
      expect(result.originalUri, testUri);
    });
    
    test('should create change password result with factory constructor', () {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/reset');
      
      // Act
      final result = DeepLinkResult.changePassword(
        success: true,
        data: {'oobCode': '123abc'},
        error: null,
        originalUri: testUri,
      );
      
      // Assert
      expect(result.type, DeepLinkType.changePassword);
      expect(result.success, true);
      expect(result.data, {'oobCode': '123abc'});
      expect(result.error, null);
      expect(result.originalUri, testUri);
    });
    
    test('should create quick log result with factory constructor', () {
      // Arrange
      final testUri = Uri.parse('pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=log');
      
      // Act
      final result = DeepLinkResult.quickLog(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
          'type': 'log',
        },
        error: null,
        originalUri: testUri,
      );
      
      // Assert
      expect(result.type, DeepLinkType.quickLog);
      expect(result.success, true);
      expect(result.data, {
        'widgetName': 'simple_food_tracking_widget',
        'type': 'log',
      });
      expect(result.error, null);
      expect(result.originalUri, testUri);
    });
    
    test('should create login result with factory constructor', () {
      // Arrange
      final testUri = Uri.parse('pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=login');
      
      // Act
      final result = DeepLinkResult.login(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
        },
        error: null,
        originalUri: testUri,
      );
      
      // Assert
      expect(result.type, DeepLinkType.login);
      expect(result.success, true);
      expect(result.data, {
        'widgetName': 'simple_food_tracking_widget',
      });
      expect(result.error, null);
      expect(result.originalUri, testUri);
    });
    
    test('should create dashboard result with factory constructor', () {
      // Arrange
      final testUri = Uri.parse('pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=dashboard');
      
      // Act
      final result = DeepLinkResult.dashboard(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
        },
        error: null,
        originalUri: testUri,
      );
      
      // Assert
      expect(result.type, DeepLinkType.dashboard);
      expect(result.success, true);
      expect(result.data, {
        'widgetName': 'simple_food_tracking_widget',
      });
      expect(result.error, null);
      expect(result.originalUri, testUri);
    });
    
    test('should create unknown result with factory constructor', () {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/unknown');
      final errorMessage = 'Unknown deep link type';
      
      // Act
      final result = DeepLinkResult.unknown(
        originalUri: testUri,
        error: errorMessage,
      );
      
      // Assert
      expect(result.type, DeepLinkType.unknown);
      expect(result.success, false);
      expect(result.data, null);
      expect(result.error, errorMessage);
      expect(result.originalUri, testUri);
    });
    
    test('unknown constructor should use default error message if none provided', () {
      // Act
      final result = DeepLinkResult.unknown(
        originalUri: Uri.parse('pockeat://test.com/unknown'),
      );
      
      // Assert
      expect(result.error, 'Unknown deep link type');
    });
  });
}
