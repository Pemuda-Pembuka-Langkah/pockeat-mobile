import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, FirebaseDynamicLinks, User])
import 'deep_link_service_test.mocks.dart';

void main() {
  late DeepLinkServiceImpl deepLinkService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseDynamicLinks mockFirebaseDynamicLinks;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseDynamicLinks = MockFirebaseDynamicLinks();
    mockUser = MockUser();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

    deepLinkService = DeepLinkServiceImpl(
      auth: mockFirebaseAuth,
      dynamicLinks: mockFirebaseDynamicLinks,
    );
  });

  group('DeepLinkService', () {
    test(
        'isEmailVerificationLink should return true for valid Firebase email verification URLs',
        () {
      // Arrange
      final Uri validLink = Uri.parse(
          'https://example.firebaseapp.com/__/auth/action?mode=verifyEmail&oobCode=abc123');

      // Act
      final result = deepLinkService.isEmailVerificationLink(validLink);

      // Assert
      expect(result, isTrue);
    });

    test('isEmailVerificationLink should return false for invalid URLs', () {
      // Arrange
      final Uri invalidLink1 = Uri.parse('https://example.com/verify?code=123');
      final Uri invalidLink2 = Uri.parse(
          'https://example.firebaseapp.com/__/auth/action?mode=resetPassword&oobCode=abc123');
      final Uri invalidLink3 = Uri.parse(
          'https://example.firebaseapp.com/__/auth/action?mode=verifyEmail');

      // Act & Assert
      expect(deepLinkService.isEmailVerificationLink(invalidLink1), isFalse);
      expect(deepLinkService.isEmailVerificationLink(invalidLink2), isFalse);
      expect(deepLinkService.isEmailVerificationLink(invalidLink3), isFalse);
    });

    test(
        'handleEmailVerificationLink should return true when verification succeeds',
        () async {
      // Arrange
      final Uri validLink = Uri.parse(
          'https://example.firebaseapp.com/__/auth/action?mode=verifyEmail&oobCode=abc123');

      when(mockFirebaseAuth.checkActionCode('abc123'))
          .thenAnswer((_) async => MockActionCodeInfo());
      when(mockFirebaseAuth.applyActionCode('abc123'))
          .thenAnswer((_) async => null);
      when(mockUser.reload()).thenAnswer((_) async => null);
      when(mockUser.emailVerified).thenReturn(true);

      // Act
      final result =
          await deepLinkService.handleEmailVerificationLink(validLink);

      // Assert
      expect(result, isTrue);
      verify(mockFirebaseAuth.checkActionCode('abc123')).called(1);
      verify(mockFirebaseAuth.applyActionCode('abc123')).called(1);
      verify(mockUser.reload()).called(1);
    });

    test('handleEmailVerificationLink should return false when link is invalid',
        () async {
      // Arrange
      final Uri invalidLink = Uri.parse('https://example.com/verify');

      // Act
      final result =
          await deepLinkService.handleEmailVerificationLink(invalidLink);

      // Assert
      expect(result, isFalse);
      verifyNever(mockFirebaseAuth.checkActionCode(any));
      verifyNever(mockFirebaseAuth.applyActionCode(any));
    });

    test(
        'handleEmailVerificationLink should return false when oobCode is missing',
        () async {
      // Arrange
      final Uri invalidLink = Uri.parse(
          'https://example.firebaseapp.com/__/auth/action?mode=verifyEmail');

      // Act
      final result =
          await deepLinkService.handleEmailVerificationLink(invalidLink);

      // Assert
      expect(result, isFalse);
      verifyNever(mockFirebaseAuth.checkActionCode(any));
      verifyNever(mockFirebaseAuth.applyActionCode(any));
    });

    test(
        'handleEmailVerificationLink should return false when Firebase throws an exception',
        () async {
      // Arrange
      final Uri validLink = Uri.parse(
          'https://example.firebaseapp.com/__/auth/action?mode=verifyEmail&oobCode=invalid');

      when(mockFirebaseAuth.checkActionCode('invalid'))
          .thenThrow(FirebaseAuthException(code: 'invalid-action-code'));

      // Act
      final result =
          await deepLinkService.handleEmailVerificationLink(validLink);

      // Assert
      expect(result, isFalse);
      verify(mockFirebaseAuth.checkActionCode('invalid')).called(1);
      verifyNever(mockFirebaseAuth.applyActionCode(any));
    });

    test('handleEmailVerificationLink should return false when user is null',
        () async {
      // Arrange
      final Uri validLink = Uri.parse(
          'https://example.firebaseapp.com/__/auth/action?mode=verifyEmail&oobCode=abc123');

      when(mockFirebaseAuth.currentUser).thenReturn(null);
      when(mockFirebaseAuth.checkActionCode('abc123'))
          .thenAnswer((_) async => MockActionCodeInfo());
      when(mockFirebaseAuth.applyActionCode('abc123'))
          .thenAnswer((_) async => null);

      // Act
      final result =
          await deepLinkService.handleEmailVerificationLink(validLink);

      // Assert
      expect(result, isFalse);
      verify(mockFirebaseAuth.checkActionCode('abc123')).called(1);
      verify(mockFirebaseAuth.applyActionCode('abc123')).called(1);
    });
  });
}

// Helper class for tests
class MockActionCodeInfo implements ActionCodeInfo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
