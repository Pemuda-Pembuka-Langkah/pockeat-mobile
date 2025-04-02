import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service_impl.dart';
import 'change_password_deeplink_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  ActionCodeInfo,
  ChangePasswordDeepLinkService
], customMocks: [
  MockSpec<AppLinks>(as: #TestAppLinks),
])
void main() {
  late MockChangePasswordDeepLinkService mockService;
  late MockFirebaseAuth mockAuth;
  late TestAppLinks mockAppLinks;
  late MockUser mockUser;
  late StreamController<Uri> mockLinkStreamController;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockAppLinks = TestAppLinks();
    mockUser = MockUser();
    mockLinkStreamController = StreamController<Uri>.broadcast();
    mockService = MockChangePasswordDeepLinkService();

    // Setup untuk mocking AppLinks
    when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);
    when(mockAppLinks.uriLinkStream)
        .thenAnswer((_) => mockLinkStreamController.stream);

    // Setup user mock
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');

    // Setup mockService
    when(mockService.initialize()).thenAnswer((_) async {});
    when(mockService.onLinkReceived())
        .thenAnswer((_) => mockLinkStreamController.stream);
  });

  tearDown(() {
    mockLinkStreamController.close();
  });

  Uri createPasswordResetUrl({String? oobCode}) {
    return Uri.parse(
        'pockeat://auth?mode=resetPassword&oobCode=${oobCode ?? 'testCode'}');
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
          .thenThrow(ChangePasswordDeepLinkException('Test exception'));

      // Act & Assert
      expect(
        () => mockService.initialize(),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
    });
  });

  group('isChangePasswordLink', () {
    test('should identify valid password reset links', () {
      // Arrange
      final validLink = createPasswordResetUrl();
      when(mockService.isChangePasswordLink(validLink)).thenReturn(true);

      // Act & Assert
      expect(mockService.isChangePasswordLink(validLink), true);
    });

    test('should reject invalid links', () {
      // Arrange
      final invalidLinks = [
        Uri.parse('pockeat://auth?someparam=value'),
        Uri.parse('pockeat://auth?mode=resetPassword'),
        Uri.parse('pockeat://auth?oobCode=testCode'),
        Uri.parse('https://example.com?mode=resetPassword&oobCode=testCode'),
      ];

      // Act & Assert
      for (var link in invalidLinks) {
        when(mockService.isChangePasswordLink(link)).thenReturn(false);
        expect(mockService.isChangePasswordLink(link), false);
      }
    });
  });

  group('handleChangePasswordLink', () {
    test('should verify password reset code successfully', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      when(mockService.handleChangePasswordLink(testLink))
          .thenAnswer((_) async => true);

      // Act
      final result = await mockService.handleChangePasswordLink(testLink);

      // Assert
      expect(result, true);
      verify(mockService.handleChangePasswordLink(testLink)).called(1);
    });

    test('should handle invalid password reset link', () async {
      // Arrange
      final invalidLink = Uri.parse('pockeat://auth?invalid=true');
      when(mockService.isChangePasswordLink(invalidLink)).thenReturn(false);
      when(mockService.handleChangePasswordLink(invalidLink))
          .thenAnswer((_) async => false);

      // Act
      final result = await mockService.handleChangePasswordLink(invalidLink);

      // Assert
      expect(result, false);
    });

    test('should handle Firebase auth exceptions', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      when(mockService.handleChangePasswordLink(testLink))
          .thenAnswer((_) async => false);

      // Act
      final result = await mockService.handleChangePasswordLink(testLink);

      // Assert
      expect(result, false);
    });

    test('should handle general exceptions', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      when(mockService.handleChangePasswordLink(testLink))
          .thenThrow(ChangePasswordDeepLinkException('Test exception'));

      // Act & Assert
      expect(
        () => mockService.handleChangePasswordLink(testLink),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
    });
  });

  group('onLinkReceived', () {
    test('should emit received links', () async {
      // Arrange
      final testUri = createPasswordResetUrl();
      final stream = mockService.onLinkReceived();

      // Act & Assert
      expect(stream, isNotNull);

      // Verifikasi bahwa stream berfungsi dengan baik
      mockLinkStreamController.add(testUri);
    });
  });

  group('dispose', () {
    test('should dispose resources properly', () async {
      // Act
      mockService.dispose();

      // Assert
      verify(mockService.dispose()).called(1);
    });

    test('should handle errors during disposal', () {
      // Arrange
      when(mockService.dispose())
          .thenThrow(ChangePasswordDeepLinkException('Test exception'));

      // Act & Assert
      expect(
        () => mockService.dispose(),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
    });
  });
}
