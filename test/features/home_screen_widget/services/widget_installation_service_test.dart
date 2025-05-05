// test/features/home_screen_widget/services/widget_installation_service_test.dart

// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_installation_constants.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/widget_installation_service_impl.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_installation_service.dart';

// Generate mocks untuk MethodChannel
@GenerateMocks([MethodChannel])
import 'widget_installation_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMethodChannel mockChannel;
  late WidgetInstallationService service;

  setUp(() {
    // Setup mock method channel
    mockChannel = MockMethodChannel();
    
    // Create service with mock channel
    service = WidgetInstallationServiceImpl.withChannel(mockChannel);
  });

  group('WidgetInstallationService', () {
    test('should be created properly using withChannel constructor', () {
      expect(service, isA<WidgetInstallationService>());
      expect(service, isA<WidgetInstallationServiceImpl>());
    });
    
    test('should be created properly using default constructor', () {
      // Act - Create instance with default constructor
      final defaultService = WidgetInstallationServiceImpl();
      
      // Assert - Service type
      expect(defaultService, isA<WidgetInstallationService>());
      expect(defaultService, isA<WidgetInstallationServiceImpl>());
    });

    group('checkWidgetInstallationStatus', () {
      test('should return default status when result is null', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).thenAnswer((_) async => null);
        
        // Act
        final result = await service.checkWidgetInstallationStatus();
        
        // Assert
        expect(result, isA<WidgetInstallationStatus>());
        expect(result.isSimpleWidgetInstalled, isFalse);
        expect(result.isDetailedWidgetInstalled, isFalse);
        expect(result.isAnyWidgetInstalled, isFalse);
        
        // Verify
        verify(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).called(1);
      });
      
      test('should return status with simple widget installed', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).thenAnswer((_) async => {
          'isSimpleWidgetInstalled': true,
          'isDetailedWidgetInstalled': false,
        });
        
        // Act
        final result = await service.checkWidgetInstallationStatus();
        
        // Assert
        expect(result.isSimpleWidgetInstalled, isTrue);
        expect(result.isDetailedWidgetInstalled, isFalse);
        expect(result.isAnyWidgetInstalled, isTrue);
      });
      
      test('should return status with detailed widget installed', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).thenAnswer((_) async => {
          'isSimpleWidgetInstalled': false,
          'isDetailedWidgetInstalled': true,
        });
        
        // Act
        final result = await service.checkWidgetInstallationStatus();
        
        // Assert
        expect(result.isSimpleWidgetInstalled, isFalse);
        expect(result.isDetailedWidgetInstalled, isTrue);
        expect(result.isAnyWidgetInstalled, isTrue);
      });
      
      test('should return status with both widgets installed', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).thenAnswer((_) async => {
          'isSimpleWidgetInstalled': true,
          'isDetailedWidgetInstalled': true,
        });
        
        // Act
        final result = await service.checkWidgetInstallationStatus();
        
        // Assert
        expect(result.isSimpleWidgetInstalled, isTrue);
        expect(result.isDetailedWidgetInstalled, isTrue);
        expect(result.isAnyWidgetInstalled, isTrue);
      });
      
      test('should handle missing fields in result map', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).thenAnswer((_) async => {
          // Empty map or missing expected fields
        });
        
        // Act
        final result = await service.checkWidgetInstallationStatus();
        
        // Assert
        expect(result.isSimpleWidgetInstalled, isFalse);
        expect(result.isDetailedWidgetInstalled, isFalse);
      });
      
      test('should return default status when PlatformException is thrown', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).thenThrow(PlatformException(code: 'ERROR'));
        
        // Act
        final result = await service.checkWidgetInstallationStatus();
        
        // Assert
        expect(result, isA<WidgetInstallationStatus>());
        expect(result.isSimpleWidgetInstalled, isFalse);
        expect(result.isDetailedWidgetInstalled, isFalse);
      });
    });

    group('addWidgetToHomescreen', () {
      test('should return true when method channel returns true', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.addWidgetToHomeScreenMethod.value, 
          {'widgetType': WidgetType.simple.name},
        )).thenAnswer((_) async => true);
        
        // Act
        final result = await service.addWidgetToHomescreen(WidgetType.simple);
        
        // Assert
        expect(result, isTrue);
        
        // Verify
        verify(mockChannel.invokeMethod(
          WidgetInstallationConstants.addWidgetToHomeScreenMethod.value,
          {'widgetType': WidgetType.simple.name},
        )).called(1);
      });
      
      test('should return false when method channel returns false', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.addWidgetToHomeScreenMethod.value,
          {'widgetType': WidgetType.detailed.name},
        )).thenAnswer((_) async => false);
        
        // Act
        final result = await service.addWidgetToHomescreen(WidgetType.detailed);
        
        // Assert
        expect(result, isFalse);
      });
      
      test('should return false when PlatformException is thrown', () async {
        // Arrange
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.addWidgetToHomeScreenMethod.value,
          {'widgetType': WidgetType.simple.name},
        )).thenThrow(PlatformException(code: 'ERROR'));
        
        // Act
        final result = await service.addWidgetToHomescreen(WidgetType.simple);
        
        // Assert
        expect(result, isFalse);
      });

      test('should invoke method with different widget types', () async {
        // Test for both widget types
        for (final widgetType in WidgetType.values) {
          // Reset mock between iterations
          reset(mockChannel);
          
          // Setup
          when(mockChannel.invokeMethod(
            WidgetInstallationConstants.addWidgetToHomeScreenMethod.value,
            {'widgetType': widgetType.name},
          )).thenAnswer((_) async => true);
          
          // Act
          await service.addWidgetToHomescreen(widgetType);
          
          // Verify
          verify(mockChannel.invokeMethod(
            WidgetInstallationConstants.addWidgetToHomeScreenMethod.value,
            {'widgetType': widgetType.name},
          )).called(1);
        }
      });
    });

    group('error handling', () {
      test('should handle various PlatformException scenarios', () async {
        // Test different error codes
        final errorCodes = ['NOT_IMPLEMENTED', 'PERMISSION_DENIED', 'UNAVAILABLE', 'UNKNOWN'];
        
        for (final errorCode in errorCodes) {
          // Reset mock
          reset(mockChannel);
          
          // Setup for this iteration
          when(mockChannel.invokeMethod(
            WidgetInstallationConstants.checkWidgetInstalledMethod.value,
          )).thenThrow(PlatformException(code: errorCode));
          
          // Act & Assert - should not throw
          expect(
            () => service.checkWidgetInstallationStatus(),
            returnsNormally,
            reason: 'Should handle $errorCode error gracefully'
          );
        }
      });
    });

    group('integration tests', () {
      test('should handle realistic platform interaction scenarios', () async {
        // Scenario: Check status first, then add widget, then check status again
        
        // Arrange - initial status (no widgets)
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).thenAnswer((_) async => {
          'isSimpleWidgetInstalled': false,
          'isDetailedWidgetInstalled': false,
        });
        
        // Act - check initial status
        final initialStatus = await service.checkWidgetInstallationStatus();
        
        // Assert - no widgets installed
        expect(initialStatus.isAnyWidgetInstalled, isFalse);
        
        // Arrange - success adding widget
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.addWidgetToHomeScreenMethod.value,
          {'widgetType': WidgetType.simple.name},
        )).thenAnswer((_) async => true);
        
        // Act - add widget
        final addResult = await service.addWidgetToHomescreen(WidgetType.simple);
        
        // Assert - add was successful
        expect(addResult, isTrue);
        
        // Arrange - updated status after widget installation
        when(mockChannel.invokeMethod(
          WidgetInstallationConstants.checkWidgetInstalledMethod.value,
        )).thenAnswer((_) async => {
          'isSimpleWidgetInstalled': true,
          'isDetailedWidgetInstalled': false,
        });
        
        // Act - check updated status
        final updatedStatus = await service.checkWidgetInstallationStatus();
        
        // Assert - simple widget now installed
        expect(updatedStatus.isSimpleWidgetInstalled, isTrue);
        expect(updatedStatus.isDetailedWidgetInstalled, isFalse);
        expect(updatedStatus.isAnyWidgetInstalled, isTrue);
      });
    });
  });
}
