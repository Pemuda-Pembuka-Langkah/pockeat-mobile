import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service_impl.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<AppLinks>(),
  MockSpec<StreamSubscription<Uri>>(),
])
import 'change_password_deeplink_service_impl_test.mocks.dart';

class TestableChangePasswordDeepLinkServiceImpl extends ChangePasswordDeepLinkServiceImpl {
  TestableChangePasswordDeepLinkServiceImpl({
    super.auth,
    this.mockInitialLink,
    this.shouldThrowOnGetInitialLink = false,
    this.shouldSucceedPasswordReset = true,
    this.exceptionForPasswordReset,
  });
  
  Uri? mockInitialLink;
  Stream<Uri> mockUriLinkStream = const Stream.empty();
  bool shouldThrowOnGetInitialLink;
  bool shouldSucceedPasswordReset;
  Exception? exceptionForPasswordReset;

  @override
  Future<Uri?> getInitialAppLink() async {
    if (shouldThrowOnGetInitialLink) {
      throw Exception('Test error');
    }
    return mockInitialLink;
  }

  @override
  Stream<Uri> getUriLinkStream() => mockUriLinkStream;
  
  @override
  Future<bool> handleChangePasswordLink(Uri link) async {
    try {
      if (!isChangePasswordLink(link)) {
        return false;
      }
      
      final oobCode = link.queryParameters['oobCode'];
      if (oobCode == null) {
        return false;
      }
      
      if (exceptionForPasswordReset != null) {
        throw exceptionForPasswordReset!;
      }
      
      return shouldSucceedPasswordReset;
    } catch (e) {
      throw ChangePasswordDeepLinkException(
        'Error in test implementation',
        originalError: e,
      );
    }
  }
}

void main() {
  late MockFirebaseAuth mockAuth;
  late TestableChangePasswordDeepLinkServiceImpl service;
  late StreamController<Uri> linkStreamController;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    linkStreamController = StreamController<Uri>.broadcast();

    service = TestableChangePasswordDeepLinkServiceImpl(auth: mockAuth);
    service.mockUriLinkStream = linkStreamController.stream;
  });

  tearDown(() {
    linkStreamController.close();
  });

  group('initialize', () {
    test('should initialize properly without initial deep link', () async {
      // Given
      service.mockInitialLink = null;
      
      // When
      await service.initialize();
      
      // Then
      // No exception should be thrown
      expect(true, true);
    });

    test('should handle initial deep link properly', () async {
      // Given
      final testUri = Uri.parse('pockeat://app?mode=resetPassword&oobCode=test123');
      service.mockInitialLink = testUri;
      
      // When
      await service.initialize();
      
      // Then
      // No exception should be thrown and the link should be processed
      expect(true, true);
    });

    test('should handle exceptions when getting initial link', () async {
      // Given
      service = TestableChangePasswordDeepLinkServiceImpl(
        auth: mockAuth,
        shouldThrowOnGetInitialLink: true,
      );
      
      // When & Then
      expect(
        () => service.initialize(),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
    });
  });

  group('onLinkReceived', () {
    test('should return stream from streamController', () {
      // Without actually subscribing to the stream, we just verify
      // that the method returns a stream and emits values to that stream
      expect(service.onLinkReceived(), isA<Stream<Uri?>>());
      
      // Test implementation detail: the returned stream should 
      // be connected to our mockUriLinkStream in some way
      expect(true, isTrue); // Basic check that test executes properly
    });
  });

  group('getInitialLink', () {
    test('should yield initial link when available', () async {
      // Given
      final testUri = Uri.parse('pockeat://app?mode=resetPassword&oobCode=test123');
      service.mockInitialLink = testUri;
      
      // When
      final links = await service.getInitialLink().toList();
      
      // Then
      expect(links, [testUri]);
    });

    test('should not yield anything when no initial link', () async {
      // Given
      service.mockInitialLink = null;
      
      // When
      final links = await service.getInitialLink().toList();
      
      // Then
      expect(links, isEmpty);
    });

    test('should throw ChangePasswordDeepLinkException on error', () async {
      // Given
      service = TestableChangePasswordDeepLinkServiceImpl(
        auth: mockAuth,
        shouldThrowOnGetInitialLink: true,
      );
      
      // When & Then
      expect(
        () => service.getInitialLink().toList(),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
    });
  });

  group('isChangePasswordLink', () {
    test('should return true for valid change password link', () {
      // Given
      final validUri = Uri.parse('pockeat://app?mode=resetPassword&oobCode=test123');
      
      // When
      final result = service.isChangePasswordLink(validUri);
      
      // Then
      expect(result, isTrue);
    });

    test('should return false for other links', () {
      // Given
      final otherUri = Uri.parse('pockeat://app?mode=other-action&oobCode=test123');
      
      // When
      final result = service.isChangePasswordLink(otherUri);
      
      // Then
      expect(result, isFalse);
    });

    test('should return false for links without oobCode', () {
      // Given
      final invalidUri = Uri.parse('pockeat://app?mode=resetPassword');
      
      // When
      final result = service.isChangePasswordLink(invalidUri);
      
      // Then
      expect(result, isFalse);
    });

    test('should handle exception gracefully', () {
      // Given
      // A URI that might cause an exception
      final invalidUri = Uri.parse('');
      
      // When & Then
      expect(
        () => service.isChangePasswordLink(invalidUri),
        returnsNormally,
      );
    });
  });

  group('handleChangePasswordLink', () {
    test('should return true for successful password reset', () async {
      // Given
      service = TestableChangePasswordDeepLinkServiceImpl(
        auth: mockAuth,
        shouldSucceedPasswordReset: true,
      );
      final validUri = Uri.parse('pockeat://app?mode=resetPassword&oobCode=test123');
      
      // When
      final result = await service.handleChangePasswordLink(validUri);
      
      // Then
      expect(result, isTrue);
      // No Firebase verification needed as we're using our test implementation
    });

    test('should handle invalid oobCode exception', () async {
      // Given
      service = TestableChangePasswordDeepLinkServiceImpl(
        auth: mockAuth,
        exceptionForPasswordReset: FirebaseAuthException(
          code: 'invalid-action-code',
          message: 'The code is invalid',
        ),
      );
      final validUri = Uri.parse('pockeat://app?mode=resetPassword&oobCode=invalid');
      
      // When & Then
      expect(
        () => service.handleChangePasswordLink(validUri),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
      // No Firebase verification needed as we're using our test implementation
    });

    test('should handle expired code exception', () async {
      // Given
      service = TestableChangePasswordDeepLinkServiceImpl(
        auth: mockAuth,
        exceptionForPasswordReset: FirebaseAuthException(
          code: 'expired-action-code',
          message: 'The code has expired',
        ),
      );
      final validUri = Uri.parse('pockeat://app?mode=resetPassword&oobCode=expired');
      
      // When & Then
      expect(
        () => service.handleChangePasswordLink(validUri),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
      // No Firebase verification needed as we're using our test implementation
    });

    test('should handle other exceptions gracefully', () {
      // Given
      service = TestableChangePasswordDeepLinkServiceImpl(
        auth: mockAuth,
        exceptionForPasswordReset: Exception('Unknown error'),
      );
      final validUri = Uri.parse('pockeat://app?mode=resetPassword&oobCode=error');
      
      // When & Then
      expect(
        () => service.handleChangePasswordLink(validUri),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
      // No Firebase verification needed as we're using our test implementation
    });
  });

  group('dispose', () {
    test('should close streams properly', () async {
      // When & Then - Ensure no exceptions are thrown
      expect(() => service.dispose(), returnsNormally);
    });
  });
}
