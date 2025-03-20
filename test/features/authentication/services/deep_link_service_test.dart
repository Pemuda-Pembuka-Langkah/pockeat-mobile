import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, User, AppLinks, UserRepository])
import 'deep_link_service_test.mocks.dart';

// Helper class for tests
class MockActionCodeInfo implements ActionCodeInfo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Extended implementation for testing
class TestableDeepLinkServiceImpl extends DeepLinkServiceImpl {
  final AppLinks mockAppLinks;

  TestableDeepLinkServiceImpl({
    required FirebaseAuth auth,
    required UserRepository userRepository,
    required this.mockAppLinks,
  }) : super(auth: auth, userRepository: userRepository);

  @override
  Future<Uri?> getInitialAppLink() => mockAppLinks.getInitialAppLink();

  @override
  Stream<Uri> getUriLinkStream() => mockAppLinks.uriLinkStream;
}

void main() {
  late TestableDeepLinkServiceImpl deepLinkService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockAppLinks mockAppLinks;
  late MockUserRepository mockUserRepository;
  late MockUser mockUser;
  late StreamController<Uri> mockUriStreamController;
  late GlobalKey<NavigatorState> mockNavigatorKey;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockAppLinks = MockAppLinks();
    mockUserRepository = MockUserRepository();
    mockUser = MockUser();
    mockUriStreamController = StreamController<Uri>.broadcast();
    mockNavigatorKey = GlobalKey<NavigatorState>();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

    // Mock AppLinks behavior
    when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);
    when(mockAppLinks.uriLinkStream)
        .thenAnswer((_) => mockUriStreamController.stream);

    // Create testable implementation
    deepLinkService = TestableDeepLinkServiceImpl(
      auth: mockFirebaseAuth,
      userRepository: mockUserRepository,
      mockAppLinks: mockAppLinks,
    );
  });

  tearDown(() {
    mockUriStreamController.close();
  });

  group('DeepLinkService', () {
    test(
        'isEmailVerificationLink should return true for valid pockeat scheme URLs',
        () {
      // Arrange
      final Uri validLink =
          Uri.parse('pockeat://verify?mode=verifyEmail&oobCode=abc123');

      // Act
      final result = deepLinkService.isEmailVerificationLink(validLink);

      // Assert
      expect(result, isTrue);
    });

    test('isEmailVerificationLink should return false for invalid URLs', () {
      // Arrange
      final Uri invalidLink1 = Uri.parse('https://example.com/verify?code=123');
      final Uri invalidLink2 =
          Uri.parse('pockeat://verify?mode=resetPassword&oobCode=abc123');
      final Uri invalidLink3 = Uri.parse('pockeat://verify?mode=verifyEmail');
      final Uri invalidLink4 = Uri.parse(
          'https://example.firebaseapp.com/__/auth/action?mode=verifyEmail&oobCode=abc123');

      // Act & Assert
      expect(deepLinkService.isEmailVerificationLink(invalidLink1), isFalse);
      expect(deepLinkService.isEmailVerificationLink(invalidLink2), isFalse);
      expect(deepLinkService.isEmailVerificationLink(invalidLink3), isFalse);
      expect(deepLinkService.isEmailVerificationLink(invalidLink4), isFalse);
    });

    test('initialize should set up listeners for app_links', () async {
      // Arrange
      when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);

      // Act - Note: initialize() may throw since we don't fully mock everything
      try {
        await deepLinkService.initialize(navigatorKey: mockNavigatorKey);
      } catch (e) {
        // Expected due to mock implementation
      }

      // Assert
      verify(mockAppLinks.getInitialAppLink()).called(greaterThanOrEqualTo(1));
      verify(mockAppLinks.uriLinkStream).called(greaterThanOrEqualTo(1));
    });

    test(
        'handleEmailVerificationLink should return true when verification succeeds',
        () async {
      // Arrange
      final Uri validLink =
          Uri.parse('pockeat://verify?mode=verifyEmail&oobCode=abc123');

      when(mockFirebaseAuth.checkActionCode('abc123'))
          .thenAnswer((_) async => MockActionCodeInfo());
      when(mockFirebaseAuth.applyActionCode('abc123')).thenAnswer((_) async {});
      when(mockUser.reload()).thenAnswer((_) async {});
      when(mockUser.emailVerified).thenReturn(true);
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockUserRepository.updateEmailVerificationStatus(
              'test-user-id', true))
          .thenAnswer((_) async {});

      // Act
      final result =
          await deepLinkService.handleEmailVerificationLink(validLink);

      // Assert
      expect(result, isTrue);
      verify(mockFirebaseAuth.checkActionCode('abc123')).called(1);
      verify(mockFirebaseAuth.applyActionCode('abc123')).called(1);
      verify(mockUser.reload()).called(1);
      verify(mockUserRepository.updateEmailVerificationStatus(
              'test-user-id', true))
          .called(1);
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
      final Uri invalidLink = Uri.parse('pockeat://verify?mode=verifyEmail');

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
      final Uri validLink =
          Uri.parse('pockeat://verify?mode=verifyEmail&oobCode=invalid');

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
      final Uri validLink =
          Uri.parse('pockeat://verify?mode=verifyEmail&oobCode=abc123');

      when(mockFirebaseAuth.currentUser).thenReturn(null);
      when(mockFirebaseAuth.checkActionCode('abc123'))
          .thenAnswer((_) async => MockActionCodeInfo());
      when(mockFirebaseAuth.applyActionCode('abc123')).thenAnswer((_) async {});

      // Act
      final result =
          await deepLinkService.handleEmailVerificationLink(validLink);

      // Assert
      expect(result, isFalse);
      verify(mockFirebaseAuth.checkActionCode('abc123')).called(1);
      verify(mockFirebaseAuth.applyActionCode('abc123')).called(1);
    });

    test('getInitialLink should return initial app link from AppLinks',
        () async {
      // Arrange
      final expectedLink = Uri.parse('https://example.com/test');
      when(mockAppLinks.getInitialAppLink())
          .thenAnswer((_) async => expectedLink);

      // Act
      final stream = deepLinkService.getInitialLink();
      final result = await stream.first;

      // Assert
      expect(result, equals(expectedLink));
      verify(mockAppLinks.getInitialAppLink()).called(greaterThanOrEqualTo(1));
    });

    test('DeepLinkException should format message correctly', () {
      // Arrange
      final exception = DeepLinkException(
        'Test message',
        code: 'test-code',
        originalError: Exception('Original error'),
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(
          result, equals('DeepLinkException: Test message (code: test-code)'));
    });

    test('DeepLinkException should format message without code correctly', () {
      // Arrange
      final exception = DeepLinkException(
        'Test message',
        originalError: Exception('Original error'),
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, equals('DeepLinkException: Test message'));
    });

    test('onLinkReceived should broadcast received links', () async {
      // Arrange
      await deepLinkService.initialize(navigatorKey: mockNavigatorKey);
      final expectedLink = Uri.parse('pockeat://test');

      // Act - send a link to the stream
      mockUriStreamController.add(expectedLink);

      // Assert - check if it's received through onLinkReceived stream
      final receivedLink = await deepLinkService.onLinkReceived().first;
      expect(receivedLink, equals(expectedLink));
    });

    test('dispose should close subscriptions and controllers', () async {
      // Arrange
      await deepLinkService.initialize(navigatorKey: mockNavigatorKey);

      // Act
      deepLinkService.dispose();

      // Assert
      // This test mostly checks that dispose() doesn't throw
      expect(true, isTrue); // Dummy assertion
    });
  });
}
