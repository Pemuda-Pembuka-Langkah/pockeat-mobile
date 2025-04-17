// ignore_for_file: avoid_returning_null_for_void

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/bug_report_service_impl.dart';
import 'package:pockeat/features/authentication/services/utils/instabug_client.dart';

// Import the generated mock file
import 'bug_report_service_impl_test.mocks.dart';

// Generate mocks for the InstabugClient
@GenerateMocks([
  InstabugClient
])

// Note: Run flutter pub run build_runner build --delete-conflicting-outputs
// to generate the mock classes

// Mock DotEnv removed since initialization is now handled directly in main.dart

// No need for a custom test class since we can now inject the mock

void main() {
  late BugReportServiceImpl bugReportService;
  late MockInstabugClient mockInstabugClient;
  
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Create the mock instabug client
    mockInstabugClient = MockInstabugClient();
    
    // Create the service under test with our mock client
    bugReportService = BugReportServiceImpl(instabugClient: mockInstabugClient);
    
    // Override debugPrint to suppress console output during tests
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      // Don't print anything in tests
    };
    
    // Add teardown to restore original debugPrint
    addTearDown(() {
      debugPrint = originalDebugPrint;
    });
  });
  
  // Note: initialize tests removed since initialization is now handled in main.dart
  
  group('setUserData', () {
    test('should set user data successfully', () async {
      // Arrange
      final user = UserModel(
        uid: 'test_user_123',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      
      when(mockInstabugClient.identifyUser(
        any,
        any,
        any,
      )).thenAnswer((_) async => null);
      
      // Act
      final result = await bugReportService.setUserData(user);
      
      // Assert
      expect(result, true);
      verify(mockInstabugClient.identifyUser(
        'test@example.com',
        'Test User',
        'test_user_123',
      )).called(1);
    });
    
    test('should use uid prefix when displayName is null', () async {
      // Arrange
      final user = UserModel(
        uid: 'test_user_123',
        email: 'test@example.com', 
        displayName: null,
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      
      when(mockInstabugClient.identifyUser(
        any,
        any,
        any,
      )).thenAnswer((_) async => null);
      
      // Act
      final result = await bugReportService.setUserData(user);
      
      // Assert
      expect(result, true);
      verify(mockInstabugClient.identifyUser(
        'test@example.com',
        'User-test_',
        'test_user_123',
      )).called(1);
    });
    
    test('should return false when identifyUser throws an exception', () async {
      // Arrange
      final user = UserModel(
        uid: 'test_user_123',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      
      when(mockInstabugClient.identifyUser(
        any,
        any,
        any,
      )).thenThrow(Exception('Identify user error'));
      
      // Act
      final result = await bugReportService.setUserData(user);
      
      // Assert
      expect(result, false);
    });
  });
  
  group('clearUserData', () {
    test('should clear user data successfully', () async {
      // Arrange
      when(mockInstabugClient.logOut())
          .thenAnswer((_) async => null);
      
      // Act
      final result = await bugReportService.clearUserData();
      
      // Assert
      expect(result, true);
      verify(mockInstabugClient.logOut()).called(1);
    });
    
    test('should return false when logOut throws an exception', () async {
      // Arrange
      when(mockInstabugClient.logOut())
          .thenThrow(Exception('Logout error'));
      
      // Act
      final result = await bugReportService.clearUserData();
      
      // Assert
      expect(result, false);
    });
  });
  
  group('show', () {
    test('should show bug reporting UI successfully', () async {
      // Arrange
      when(mockInstabugClient.showReportingUI())
          .thenAnswer((_) async => null);
      
      // Act
      final result = await bugReportService.show();
      
      // Assert
      expect(result, true);
      verify(mockInstabugClient.showReportingUI()).called(1);
    });
    
    test('should return false when showReportingUI throws an exception', () async {
      // Arrange
      when(mockInstabugClient.showReportingUI())
          .thenThrow(Exception('Show reporting UI error'));
      
      // Act
      final result = await bugReportService.show();
      
      // Assert
      expect(result, false);
    });
  });
}
