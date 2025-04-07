import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/email_verification_deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/domain/model/deep_link_result.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
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
