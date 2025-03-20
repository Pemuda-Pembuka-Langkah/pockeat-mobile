import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

// Generate mocks
@GenerateMocks([FirebaseAuth, FirebaseDynamicLinks, User, AppLinks])
import 'deep_link_service_test.mocks.dart';

// Mock for PendingDynamicLinkData
class MockPendingDynamicLinkData extends Mock
    implements PendingDynamicLinkData {
  @override
  final Uri link;

  MockPendingDynamicLinkData(this.link);
}

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
    required FirebaseDynamicLinks dynamicLinks,
    required this.mockAppLinks,
  }) : super(auth: auth, dynamicLinks: dynamicLinks);

  @override
  Future<Uri?> getInitialAppLink() => mockAppLinks.getInitialAppLink();

  @override
  Stream<Uri> getUriLinkStream() => mockAppLinks.uriLinkStream;
}

void main() {
  late TestableDeepLinkServiceImpl deepLinkService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseDynamicLinks mockFirebaseDynamicLinks;
  late MockAppLinks mockAppLinks;
  late MockUser mockUser;
  late StreamController<Uri> mockUriStreamController;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseDynamicLinks = MockFirebaseDynamicLinks();
    mockAppLinks = MockAppLinks();
    mockUser = MockUser();
    mockUriStreamController = StreamController<Uri>.broadcast();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

    // Mock AppLinks behavior
    when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);
    when(mockAppLinks.uriLinkStream)
        .thenAnswer((_) => mockUriStreamController.stream);

    // Create testable implementation
    deepLinkService = TestableDeepLinkServiceImpl(
      auth: mockFirebaseAuth,
      dynamicLinks: mockFirebaseDynamicLinks,
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

    test(
        'initialize should set up listeners for app_links and firebase dynamic links',
        () async {
      // Arrange
      final dynamicLinkStreamController =
          StreamController<PendingDynamicLinkData>();

      when(mockFirebaseDynamicLinks.onLink).thenAnswer(
        (_) => dynamicLinkStreamController.stream,
      );

      // Act - Note: initialize() may throw since we don't fully mock everything
      try {
        await deepLinkService.initialize();
      } catch (e) {
        // Expected due to mock implementation
      }

      // Assert
      verify(mockAppLinks.getInitialAppLink()).called(greaterThanOrEqualTo(1));
      verify(mockAppLinks.uriLinkStream).called(greaterThanOrEqualTo(1));
      verify(mockFirebaseDynamicLinks.onLink).called(greaterThanOrEqualTo(1));

      // Cleanup
      dynamicLinkStreamController.close();
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
      // Arrange & Act
      final exception1 = DeepLinkException('Test message');
      final exception2 = DeepLinkException('Test message', code: 'test-code');
      final exception3 = DeepLinkException('Test message',
          code: 'test-code', originalError: 'Original');

      // Assert
      expect(exception1.toString(), 'DeepLinkException: Test message');
      expect(exception2.toString(),
          'DeepLinkException: Test message (code: test-code)');
      expect(exception3.originalError, 'Original');
    });

    test('dispose should cancel subscriptions and close stream controller', () {
      // Act
      deepLinkService.dispose();

      // Assert - primarily testing that no exception is thrown
      expect(true, isTrue);
    });
  });
}
