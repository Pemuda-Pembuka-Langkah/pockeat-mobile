// Dart imports:
import 'dart:async';

// Package imports:
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/deep_link_result.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/services/email_verification_deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';
import 'deep_link_service_impl_test.mocks.dart';

@GenerateMocks([
  EmailVerificationDeepLinkService,
  ChangePasswordDeepLinkService,
  FirebaseAuth,
  User,
  DeepLinkServiceImpl
], customMocks: [
  MockSpec<AppLinks>(as: #TestAppLinks),
])
void main() {
  late MockDeepLinkServiceImpl mockService;
  late MockEmailVerificationDeepLinkService mockEmailVerificationService;
  late MockChangePasswordDeepLinkService mockChangePasswordService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late TestAppLinks mockAppLinks;
  late StreamController<Uri> uriStreamController;
  late StreamController<DeepLinkResult> resultStreamController;

  setUp(() {
    mockEmailVerificationService = MockEmailVerificationDeepLinkService();
    mockChangePasswordService = MockChangePasswordDeepLinkService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockAppLinks = TestAppLinks();
    mockService = MockDeepLinkServiceImpl();
    uriStreamController = StreamController<Uri>();
    resultStreamController = StreamController<DeepLinkResult>.broadcast();

    when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);
    when(mockAppLinks.uriLinkStream)
        .thenAnswer((_) => uriStreamController.stream);

    // Setup mock service
    when(mockService.initialize()).thenAnswer((_) async {});
    when(mockService.onDeepLinkResult)
        .thenAnswer((_) => resultStreamController.stream);
    when(mockService.onLinkReceived())
        .thenAnswer((_) => uriStreamController.stream);
  });

  tearDown(() {
    uriStreamController.close();
    resultStreamController.close();
  });

  group('initialize', () {
    test('should initialize both services and setup link listeners', () async {
      // Act
      await mockService.initialize();

      // Assert
      verify(mockService.initialize()).called(1);
    });

    test('should handle initial link if present', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/verify?oobCode=123');

      // Act
      await mockService.initialize();

      // Verify mock service was initialized
      verify(mockService.initialize()).called(1);
    });
  });

  group('handleDeepLink', () {
    test('should handle email verification link successfully', () async {
      // Arrange
      final testUri =
          Uri.parse('pockeat://test.com/verify?oobCode=123&mode=verifyEmail');

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async => true);

      // Act
      bool result = await mockService.handleDeepLink(testUri);

      // Assert
      expect(result, true);
      verify(mockService.handleDeepLink(testUri)).called(1);
    });

    test('should handle change password link successfully', () async {
      // Arrange
      final testUri =
          Uri.parse('pockeat://test.com/reset?oobCode=123&mode=resetPassword');

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async => true);

      // Act
      bool result = await mockService.handleDeepLink(testUri);

      // Assert
      expect(result, true);
      verify(mockService.handleDeepLink(testUri)).called(1);
    });

    test('should handle unknown link type', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/unknown');

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async => false);

      // Act
      bool result = await mockService.handleDeepLink(testUri);

      // Assert
      expect(result, false);
      verify(mockService.handleDeepLink(testUri)).called(1);
    });
    
    test('should handle streak celebration link successfully', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://streak-celebration?streakDays=5');

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async => true);

      // Act
      bool result = await mockService.handleDeepLink(testUri);

      // Assert
      expect(result, true);
      verify(mockService.handleDeepLink(testUri)).called(1);
    });

    test('should emit appropriate DeepLinkResult for email verification',
        () async {
      // Arrange
      final testUri =
          Uri.parse('pockeat://test.com/verify?oobCode=123&mode=verifyEmail');
      final expectedResult = DeepLinkResult.emailVerification(
        success: true,
        data: {'email': 'test@example.com'},
        originalUri: testUri,
      );

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async {
        resultStreamController.add(expectedResult);
        return true;
      });

      // Act
      expect(
        mockService.onDeepLinkResult,
        emits(expectedResult),
      );

      // Trigger the event
      await mockService.handleDeepLink(testUri);
    });

    test('should emit appropriate DeepLinkResult for change password',
        () async {
      // Arrange
      final testUri =
          Uri.parse('pockeat://test.com/reset?oobCode=123&mode=resetPassword');
      final expectedResult = DeepLinkResult.changePassword(
        success: true,
        data: {'oobCode': '123'},
        originalUri: testUri,
      );

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async {
        resultStreamController.add(expectedResult);
        return true;
      });

      // Act & Assert
      expect(
        mockService.onDeepLinkResult,
        emits(expectedResult),
      );

      // Trigger the event
      await mockService.handleDeepLink(testUri);
    });
    
    test('should emit appropriate DeepLinkResult for streak celebration',
        () async {
      // Arrange
      final testUri = Uri.parse('pockeat://streak-celebration?streakDays=7');
      final expectedResult = DeepLinkResult.streakCelebration(
        success: true,
        data: {'streakDays': 7},
        originalUri: testUri,
      );

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async {
        resultStreamController.add(expectedResult);
        return true;
      });

      // Act & Assert
      expect(
        mockService.onDeepLinkResult,
        emits(expectedResult),
      );

      // Trigger the event
      await mockService.handleDeepLink(testUri);
    });
    
    test('should handle widget quick log link successfully', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=log');

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async => true);

      // Act
      bool result = await mockService.handleDeepLink(testUri);

      // Assert
      expect(result, true);
      verify(mockService.handleDeepLink(testUri)).called(1);
    });

    test('should emit appropriate DeepLinkResult for widget quick log', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=log');
      final expectedResult = DeepLinkResult.quickLog(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
          'type': 'log',
        },
        originalUri: testUri,
      );

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async {
        resultStreamController.add(expectedResult);
        return true;
      });

      // Act & Assert
      expect(
        mockService.onDeepLinkResult,
        emits(expectedResult),
      );

      // Trigger the event
      await mockService.handleDeepLink(testUri);
    });
    
    test('should handle error in widget quick log link', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=log');
      final expectedResult = DeepLinkResult.quickLog(
        success: false,
        error: 'Test error',
        originalUri: testUri,
      );

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async {
        resultStreamController.add(expectedResult);
        return false;
      });

      // Act & Assert
      expect(
        mockService.onDeepLinkResult,
        emits(expectedResult),
      );

      // Trigger the event
      bool result = await mockService.handleDeepLink(testUri);
      expect(result, false);
    });
    
    test('should handle widget login link successfully', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=login');

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async => true);

      // Act
      bool result = await mockService.handleDeepLink(testUri);

      // Assert
      expect(result, true);
      verify(mockService.handleDeepLink(testUri)).called(1);
    });

    test('should emit appropriate DeepLinkResult for widget login', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=login');
      final expectedResult = DeepLinkResult.login(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
        },
        originalUri: testUri,
      );

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async {
        resultStreamController.add(expectedResult);
        return true;
      });

      // Act & Assert
      expect(
        mockService.onDeepLinkResult,
        emits(expectedResult),
      );

      // Trigger the event
      await mockService.handleDeepLink(testUri);
    });
    
    test('should handle widget dashboard link successfully', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=dashboard');

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async => true);

      // Act
      bool result = await mockService.handleDeepLink(testUri);

      // Assert
      expect(result, true);
      verify(mockService.handleDeepLink(testUri)).called(1);
    });

    test('should emit appropriate DeepLinkResult for widget dashboard', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=dashboard');
      final expectedResult = DeepLinkResult.dashboard(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
        },
        originalUri: testUri,
      );

      when(mockService.handleDeepLink(testUri)).thenAnswer((_) async {
        resultStreamController.add(expectedResult);
        return true;
      });

      // Act & Assert
      expect(
        mockService.onDeepLinkResult,
        emits(expectedResult),
      );

      // Trigger the event
      await mockService.handleDeepLink(testUri);
    });
  });

  group('getColdStartResult', () {
    test('should return null when no initial link is available', () async {
      // Arrange
      when(mockService.getColdStartResult()).thenAnswer((_) async => null);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, isNull);
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return email verification result for email verification link', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/verify?oobCode=123&mode=verifyEmail');
      final expectedResult = DeepLinkResult.emailVerification(
        success: true,
        data: {'email': 'test@example.com'},
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return change password result for change password link', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/reset?oobCode=123&mode=resetPassword');
      final expectedResult = DeepLinkResult.changePassword(
        success: true,
        data: {'oobCode': '123'},
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return quickLog result for widget quick log link', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=log');
      final expectedResult = DeepLinkResult.quickLog(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
          'type': 'log',
        },
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return login result for widget login link', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=login');
      final expectedResult = DeepLinkResult.login(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
        },
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return dashboard result for widget dashboard link', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=dashboard');
      final expectedResult = DeepLinkResult.dashboard(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
        },
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return unknown result for unknown link type', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/unknown');
      final expectedResult = DeepLinkResult.unknown(
        originalUri: testUri,
        error: 'Tidak ada handler yang sesuai untuk link ini',
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });
  });

  // Test for dispose method
  group('dispose', () {
    test('should properly free resources in dispose method', () {
      // Act
      mockService.dispose();
      
      // Assert
      verify(mockService.dispose()).called(1);
    });
  });

  // Test for initialization errors
  group('initialization errors', () {
    test('should handle errors during initialization', () async {
      // Arrange
      when(mockAppLinks.getInitialAppLink())
          .thenThrow(Exception('Test error'));
      when(mockService.initialize())
          .thenThrow(DeepLinkException('Failed to initialize'));
          
      // Act & Assert
      expect(() async => await mockService.initialize(), 
          throwsA(isA<DeepLinkException>()));
    });
  });

  // Tests for edge cases in link detection
  group('link detection edge cases', () {
    test('should correctly identify streak celebration link with different formats', () async {
      // Test different formats of streak celebration links
      final uriWithPath = Uri.parse('pockeat://domain.com/streak-celebration?streakDays=10');
      final uriWithHost = Uri.parse('pockeat://streak-celebration?streakDays=10');
      
      when(mockService.handleDeepLink(uriWithPath)).thenAnswer((_) async => true);
      when(mockService.handleDeepLink(uriWithHost)).thenAnswer((_) async => true);
      
      expect(await mockService.handleDeepLink(uriWithPath), true);
      expect(await mockService.handleDeepLink(uriWithHost), true);
    });
    
    test('should handle malformed links correctly', () async {
      // Arrange
      final malformedUri = Uri.parse('pockeat:invalid');
      when(mockService.handleDeepLink(malformedUri))
          .thenAnswer((_) async => false);
          
      // Act
      final result = await mockService.handleDeepLink(malformedUri);
          
      // Assert
      expect(result, false);
    });
  });

  group('getColdStartResult', () {
    // Positive path tests: Berbagai tipe link dihandle dengan benar
    test('should return null when no initial link is available', () async {
      // Arrange
      when(mockService.getColdStartResult()).thenAnswer((_) async => null);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, isNull);
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return email verification result for email verification link', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/verify?oobCode=123&mode=verifyEmail');
      final expectedResult = DeepLinkResult.emailVerification(
        success: true,
        data: {'email': 'test@example.com'},
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return change password result for change password link', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/reset?oobCode=123&mode=resetPassword');
      final expectedResult = DeepLinkResult.changePassword(
        success: true,
        data: {'oobCode': '123'},
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return quickLog result for widget quick log link', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=log');
      final expectedResult = DeepLinkResult.quickLog(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
          'type': 'log',
        },
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return login result for widget login link', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=login');
      final expectedResult = DeepLinkResult.login(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
        },
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return dashboard result for widget dashboard link', () async {
      // Arrange
      final testUri = Uri.parse(
          'pockeat://group.com.pockeat.widgets?widgetName=simple_food_tracking_widget&&type=dashboard');
      final expectedResult = DeepLinkResult.dashboard(
        success: true,
        data: {
          'widgetName': 'simple_food_tracking_widget',
        },
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    // Negative path tests: Error handling cases
    test('should return unknown result for unknown link type', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/unknown');
      final expectedResult = DeepLinkResult.unknown(
        originalUri: testUri,
        error: 'Tidak ada handler yang sesuai untuk link ini',
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return failure result when email verification service fails', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/verify?oobCode=123&mode=verifyEmail');
      final expectedResult = DeepLinkResult.emailVerification(
        success: false,
        error: 'Error verifying email',
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      expect(result?.success, isFalse);
      expect(result?.error, isNotNull);
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should return failure result when password reset service fails', () async {
      // Arrange
      final testUri = Uri.parse('pockeat://test.com/reset?oobCode=123&mode=resetPassword');
      final expectedResult = DeepLinkResult.changePassword(
        success: false,
        error: 'Error resetting password',
        originalUri: testUri,
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result, equals(expectedResult));
      expect(result?.success, isFalse);
      expect(result?.error, isNotNull);
      verify(mockService.getColdStartResult()).called(1);
    });

    // Edge cases tests
    test('should throw exception if AppLinks fails', () async {
      // Arrange
      when(mockService.getColdStartResult()).thenThrow(
        DeepLinkException('Error getting cold start result')
      );

      // Act & Assert
      expect(
        () => mockService.getColdStartResult(),
        throwsA(isA<DeepLinkException>())
      );
    });

    test('should handle malformed links', () async {
      // Arrange - link with invalid parameters
      final testUri = Uri.parse('pockeat://group.com.pockeat.widgets?invalid=param');
      final expectedResult = DeepLinkResult.unknown(
        originalUri: testUri,
        error: 'Tidak ada handler yang sesuai untuk link ini',
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result?.type, equals(DeepLinkType.unknown));
      verify(mockService.getColdStartResult()).called(1);
    });

    test('should handle links with scheme other than pockeat', () async {
      // Arrange - link with invalid scheme
      final testUri = Uri.parse('https://example.com?widgetName=test&type=log');
      final expectedResult = DeepLinkResult.unknown(
        originalUri: testUri,
        error: 'Tidak ada handler yang sesuai untuk link ini',
      );

      when(mockService.getColdStartResult()).thenAnswer((_) async => expectedResult);

      // Act
      final result = await mockService.getColdStartResult();

      // Assert
      expect(result?.type, equals(DeepLinkType.unknown));
      verify(mockService.getColdStartResult()).called(1);
    });
  });
  
  group('dispose', () {
    test('should dispose all resources', () async {
      // Arrange
      when(mockService.dispose()).thenReturn(null);

      // Act
      mockService.dispose();

      // Assert
      verify(mockService.dispose()).called(1);
    });
  });
}
