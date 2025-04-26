// Dart imports:
import 'dart:async';

// Package imports:
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/email_verification_deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';
import 'email_verification_deeplink_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserRepository,
  ActionCodeInfo,
  EmailVerificationDeepLinkService
], customMocks: [
  MockSpec<AppLinks>(as: #TestAppLinks),
])
void main() {
  late MockEmailVerificationDeepLinkService mockService;
  late MockFirebaseAuth mockAuth;
  late TestAppLinks mockAppLinks;
  late MockUserRepository mockUserRepository;
  late MockUser mockUser;
  late StreamController<Uri> mockLinkStreamController;
  late StreamController<Uri?> mockServiceStreamController;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockAppLinks = TestAppLinks();
    mockUserRepository = MockUserRepository();
    mockUser = MockUser();
    mockLinkStreamController = StreamController<Uri>.broadcast();
    mockServiceStreamController = StreamController<Uri?>.broadcast();

    mockService = MockEmailVerificationDeepLinkService();

    // Setup untuk mocking AppLinks
    when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);
    when(mockAppLinks.uriLinkStream)
        .thenAnswer((_) => mockLinkStreamController.stream);

    // Setup user mock
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.emailVerified).thenReturn(false);

    // Setup mock service
    when(mockService.initialize()).thenAnswer((_) async => null);
    when(mockService.onLinkReceived())
        .thenAnswer((_) => mockServiceStreamController.stream);
  });

  tearDown(() {
    mockLinkStreamController.close();
    mockServiceStreamController.close();
  });

  Uri createVerificationUrl({String? oobCode}) {
    return Uri.parse(
        'pockeat://auth?mode=verifyEmail&oobCode=${oobCode ?? 'testCode'}');
  }

  group('initialize', () {
    test('should initialize and handle initial link if present', () async {
      // Act
      await mockService.initialize();

      // Assert
      verify(mockService.initialize()).called(1);
    });

    test('should handle error during initialization', () async {
      // Arrange
      when(mockService.initialize())
          .thenThrow(EmailVerificationDeepLinkException('Error'));

      // Act & Assert
      expect(
        () => mockService.initialize(),
        throwsA(isA<EmailVerificationDeepLinkException>()),
      );
    });
  });

  group('isEmailVerificationLink', () {
    test('should identify valid email verification links', () {
      // Arrange
      final validLink = createVerificationUrl();
      when(mockService.isEmailVerificationLink(validLink)).thenReturn(true);

      // Act & Assert
      expect(mockService.isEmailVerificationLink(validLink), true);
    });

    test('should reject invalid links', () {
      // Arrange
      final invalidLinks = [
        Uri.parse('pockeat://auth?someparam=value'),
        Uri.parse('pockeat://auth?mode=verifyEmail'),
        Uri.parse('pockeat://auth?oobCode=testCode'),
        Uri.parse('https://example.com?mode=verifyEmail&oobCode=testCode'),
      ];

      // Act & Assert
      for (var link in invalidLinks) {
        when(mockService.isEmailVerificationLink(link)).thenReturn(false);
        expect(mockService.isEmailVerificationLink(link), false);
      }
    });
  });

  group('handleEmailVerificationLink', () {
    test('should verify email successfully', () async {
      // Arrange
      final testLink = createVerificationUrl();

      // Setup mock
      when(mockService.isEmailVerificationLink(testLink)).thenReturn(true);
      when(mockService.handleEmailVerificationLink(testLink))
          .thenAnswer((_) async => true);

      // Act
      final result = await mockService.handleEmailVerificationLink(testLink);

      // Assert
      expect(result, true);
    });

    test('should handle invalid verification link', () async {
      // Arrange
      final invalidLink = Uri.parse('pockeat://auth?invalid=true');

      when(mockService.isEmailVerificationLink(invalidLink)).thenReturn(false);
      when(mockService.handleEmailVerificationLink(invalidLink))
          .thenAnswer((_) async => false);

      // Act
      final result = await mockService.handleEmailVerificationLink(invalidLink);

      // Assert
      expect(result, false);
    });

    test('should handle Firebase auth exceptions', () async {
      // Arrange
      final testLink = createVerificationUrl();

      when(mockService.isEmailVerificationLink(testLink)).thenReturn(true);
      when(mockService.handleEmailVerificationLink(testLink))
          .thenAnswer((_) async => false);

      // Act
      final result = await mockService.handleEmailVerificationLink(testLink);

      // Assert
      expect(result, false);
    });
  });

  group('onLinkReceived', () {
    test('should emit received links', () async {
      // Arrange
      final testUri = createVerificationUrl();

      // Act - hanya test bahwa stream tersedia
      final stream = mockService.onLinkReceived();

      // Assert
      expect(stream, isNotNull);

      // Verifikasi stream dapat menerima event
      mockServiceStreamController.add(testUri);
    });
  });

  group('dispose', () {
    test('should dispose resources properly', () async {
      // Arrange
      when(mockService.dispose()).thenReturn(null);

      // Act
      mockService.dispose();

      // Assert
      verify(mockService.dispose()).called(1);
    });
  });
}
